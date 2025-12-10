/*
 * SPDX-FileCopyrightText: 2020 Mikel Johnson <mikel5764@gmail.com>
 * SPDX-FileCopyrightText: 2021 Kai Uwe Broulik <kde@broulik.de>
 * SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * HACK: disabled useless warnings from qmllint for stuff related to:
 *     - org.kde.plasma.plasmoid
 *     - org.kde.plasma.private.kicker
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.private.kicker as Kicker // qmllint disable unused-imports
import org.kde.plasma.extras as PExtras
import org.kde.plasma.components as PComponents
import org.kde.plasma.core as PCore
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as KItemModels
import org.kde.plasma.plasmoid // qmllint disable import

RowLayout {
    id: root

    spacing: kickoff.backgroundMetrics.spacing
    required property real maximumWidth

    // When all actions are configured as primary, none of them should be
    // hidden into the overflow menu as long as the available space allows
    // it.
    readonly property var view: {
        const isPowerVisible = Plasmoid.configuration.isPowerVisible // qmllint disable unqualified
        const isSessionVisible = Plasmoid.configuration.isSessionVisible; // qmllint disable unqualified
        const hasToolbarCaptions = Plasmoid.configuration.hasToolbarCaptions // qmllint disable unqualified

        const rowImplicitWidth = buttonsRepeaterRow.implicitWidth;
        let rowImplicitWidthAsIcons = rowImplicitWidth;
        let rowImplicitWidthWithText = rowImplicitWidth;

        if (!isPowerVisible || !isSessionVisible) {
            rowImplicitWidthAsIcons += overflowButtonAsIcon.implicitWidth + spacing;
            rowImplicitWidthWithText += overflowButtonWithText.implicitWidth + spacing;
        }

        const isRowFitAsIcons = rowImplicitWidthAsIcons < maximumWidth;
        const isRowFitFull = isRowFitAsIcons && rowImplicitWidthWithText < maximumWidth;

        // Can't rely on the transient Item::visible property
        const isOverflowActive = !isPowerVisible || !isSessionVisible // configured to overflow
            || (!hasToolbarCaptions && !isRowFitAsIcons)  // overflows without captions
            || (hasToolbarCaptions && !isRowFitFull); // overflows with captions

        return {
            isPowerVisible,
            isSessionVisible,
            hasToolbarCaptions,
            isRowFitAsIcons,
            isRowFitFull,
            isOverflowActive,
        };
    }

    component FilteredModel : KItemModels.KSortFilterProxyModel {
        property var visibleActions: getVisibleActions()

        sourceModel: Kicker.SystemModel { // qmllint disable import
            id: systemModel
            favoritesModel: kickoff.rootModel.systemFavoritesModel
        }

        function getVisibleActions() {
            return (Plasmoid.configuration.isPowerVisible ? Plasmoid.configuration.powerActionsDefault : []) // qmllint disable unqualified
                .concat(Plasmoid.configuration.isSessionVisible ? Plasmoid.configuration.sessionActionsDefault : []); // qmllint disable unqualified
        }

        function isValidVisibleAction(sourceRow, sourceParent) {
            const role = sourceModel.KItemModels.KRoleNames.role("favoriteId");
            const id = sourceModel.data(sourceModel.index(sourceRow, 0, sourceParent), role);
            return getVisibleActions().includes(id);
        }

        function trigger(index) {
            const sourceIndex = mapToSource(this.index(index, 0));
            systemModel.trigger(sourceIndex.row, "", null);
        }

        Component.onCompleted: {
            Plasmoid.configuration.valueChanged.connect((key, value) => { // qmllint disable unqualified
                if (key === "isPowerVisible" || key === "isSessionVisible") {
                    invalidateFilter();
                }
            });
        }
    }

    FilteredModel {
        id: filteredButtonsModel
        filterRowCallback: (sourceRow, sourceParent) => isValidVisibleAction(sourceRow, sourceParent)
    }

    FilteredModel {
        id: filteredMenuItemsModel
        filterRowCallback: root.view.isRowFitAsIcons
            ? (sourceRow, sourceParent) => !isValidVisibleAction(sourceRow, sourceParent)
            : null // keep all rows
    }

    RowLayout {
        id: buttonsRepeaterRow
        // HACK Can't use `visible` property, as the layout needs to be
        // visible to be able to update its implicit size,
        // which in turn is be used to set isRowFitAsIcons.
        enabled: root.view.isRowFitAsIcons
        opacity: root.view.isRowFitAsIcons ? 1 : 0
        spacing: parent.spacing

        Repeater {
            id: buttonRepeater

            model: filteredButtonsModel
            delegate: PComponents.ToolButton {
                required property int index
                required property var model

                text: model.display
                icon.name: model.decoration
                onClicked: {
                    filteredButtonsModel.trigger(index);
                    if (kickoff.hideOnWindowDeactivate) {
                        kickoff.expanded = false;
                    }
                }
                display: Plasmoid.configuration.hasToolbarCaptions ? PComponents.AbstractButton.TextBesideIcon : PComponents.AbstractButton.IconOnly;
                Layout.rightMargin: model.favoriteId === "switch-user" && root.view.isPowerVisible && root.view.isSessionVisible
                    ? Kirigami.Units.gridUnit
                    : undefined

                PComponents.ToolTip.text: text
                PComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                PComponents.ToolTip.visible: display === PComponents.AbstractButton.IconOnly && hovered

                Keys.onTabPressed: event => {
                    if (index === buttonRepeater.count - 1 && !root.view.isOverflowActive) {
                        kickoff.firstHeaderItem.forceActiveFocus(Qt.TabFocusReason)
                    } else {
                        event.accepted = false
                    }
                }
                Keys.onLeftPressed: event => {
                    if (Qt.application.layoutDirection === Qt.LeftToRight) {
                        nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
                    } else if (index < buttonRepeater.count - 1 || root.view.isOverflowActive) {
                        nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
                    }
                }
                Keys.onRightPressed: event => {
                    if (Qt.application.layoutDirection === Qt.RightToLeft) {
                        nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
                    } else if (index < buttonRepeater.count - 1 || root.view.isOverflowActive) {
                        nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
                    }
                }
                Keys.onEnterPressed: clicked()
                Keys.onReturnPressed: clicked()
            }
        }
    }

    Item {
        Layout.minimumWidth: root.view.isPowerVisible && root.view.isSessionVisible ? 0 : Kirigami.Units.largeSpacing
    }

    // Just like Kirigami.ActionToolBar, it takes two actual instances of a
    // button with different display modes to calculate the layout properly
    // without binding loops.
    component OverflowMenuButton : PComponents.ToolButton {
        Accessible.role: Accessible.ButtonMenu
        icon.width: Kirigami.Units.iconSizes.smallMedium
        icon.height: Kirigami.Units.iconSizes.smallMedium
        property var overflowButtonData: [
            {text: i18n("Power/Session") , icon: "view-more-symbolic"},
            {text: i18n("Session"), icon: "system-log-out"},
            {text: i18n("Power"), icon: "system-shutdown"},
            {text: i18n("More") , icon: "view-more-symbolic"},
        ][Plasmoid.configuration.isPowerVisible * 1 + Plasmoid.configuration.isSessionVisible * 2] // qmllint disable unqualified
        icon.name: overflowButtonData.icon
        text: root.view.hasToolbarCaptions ? overflowButtonData.text : ''
        // Make it look pressed while the menu is open
        down: contextMenu.status === PExtras.Menu.Open || pressed
        PComponents.ToolTip.text: overflowButtonData.text
        PComponents.ToolTip.visible: hovered
        PComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
        Keys.onTabPressed: event => {
            kickoff.firstHeaderItem.forceActiveFocus(Qt.TabFocusReason);
        }
        Keys.onLeftPressed: event => {
            if (!mirrored) {
                nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
            }
        }
        Keys.onRightPressed: event => {
            if (mirrored) {
                nextItemInFocusChain(false).forceActiveFocus(Qt.BacktabFocusReason)
            }
        }
        onPressed: {
            contextMenu.visualParent = this;
            contextMenu.openRelative();
        }
    }

    OverflowMenuButton {
        id: overflowButtonAsIcon
        display: PComponents.AbstractButton.IconOnly
        visible: !root.view.hasToolbarCaptions && root.view.isOverflowActive
    }

    OverflowMenuButton {
        id: overflowButtonWithText
        display: PComponents.AbstractButton.TextBesideIcon
        visible: root.view.hasToolbarCaptions && root.view.isOverflowActive
    }

    Instantiator {
        model: filteredMenuItemsModel
        delegate: PExtras.MenuItem {
            required property int index
            required property var model

            text: model.display
            icon: model.decoration
            onClicked: filteredMenuItemsModel.trigger(index)
        }
        onObjectAdded: (index, object) => contextMenu.addMenuItem(object)
        onObjectRemoved: (index, object) => contextMenu.removeMenuItem(object)
    }

    PExtras.Menu {
        id: contextMenu
        placement: {
            switch (Plasmoid.location) { // qmllint disable unqualified
                case PCore.Types.LeftEdge:
                case PCore.Types.RightEdge:
                case PCore.Types.TopEdge:
                    return PExtras.Menu.BottomPosedRightAlignedPopup;
                case PCore.Types.BottomEdge:
                default:
                    return PExtras.Menu.TopPosedRightAlignedPopup;
            }
        }
    }
}
