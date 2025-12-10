/*
 * SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
 * SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
 * SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PComponents
import org.kde.plasma.extras as PExtras
import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as KirigamiPComponents
import org.kde.coreaddons as KPCoreAddons
import org.kde.kcmutils as KCMU
import org.kde.config as KConfig
import org.kde.plasma.plasmoid

PExtras.PlasmoidHeading {
    id: root

    property alias searchText: searchField.text
    property Item configureButton: configureButton
    property Item pinButton: pinButton
    property Item avatar: avatar
    property real preferredNameAndIconWidth: 0

    contentHeight: layoutContainer.height
        + kickoff.backgroundMetrics.topPadding
        + kickoff.backgroundMetrics.bottomPadding
    enabledBorders: Qt.TopEdge | Qt.LeftEdge | Qt.RightEdge // disable bottom border

    KPCoreAddons.KUser {
        id: kuser
    }

    spacing: kickoff.backgroundMetrics.spacing

    function tabSetFocus(event, invertedTarget, normalTarget) {
        // Set input focus depending on whether layout order matches focus chain order
        // normalTarget is optional
        const reason = event.key == Qt.Key_Tab ? Qt.TabFocusReason : Qt.BacktabFocusReason
        if (kickoff.isPaneOrderReversed) {
            invertedTarget.forceActiveFocus(reason)
        } else if (normalTarget !== undefined) {
            normalTarget.forceActiveFocus(reason)
        } else {
            event.accepted = false
        }
    }

    contentItem: Item {
        Item {
            id: layoutContainer

            height: Math.max(avatar.height, searchField.implicitHeight, configureButton.implicitHeight)
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: kickoff.backgroundMetrics.leftPadding
                right: parent.right
                rightMargin: kickoff.backgroundMetrics.rightPadding
            }

            RowLayout {
                id: nameAndIcon
                spacing: root.spacing
                anchors.left: parent.left
                height: parent.height
                width: root.preferredNameAndIconWidth - layoutContainer.anchors.leftMargin
                LayoutMirroring.enabled: kickoff.sidebarOnRight

                KirigamiPComponents.AvatarButton {
                    id: avatar
                    visible: KConfig.KAuthorized.authorizeControlModule("kcm_users")

                    Layout.preferredHeight: kickoff.userIconSize
                    Layout.minimumWidth: height
                    Layout.maximumWidth: height

                    text: i18n("Open user settings")
                    name: kuser.fullName

                    // The icon property emits two signals in a row during which it
                    // changes to an empty URL and probably back to the same
                    // static file path, so we need QtQuick.Image not to cache it.
                    cache: false
                    source: kuser.faceIconUrl

                    Keys.onTabPressed: event => {
                        root.tabSetFocus(event, kickoff.firstCentralPane);
                    }
                    Keys.onBacktabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain());
                    }
                    Keys.onLeftPressed: event => {
                        if (kickoff.sidebarOnRight) {
                            searchField.forceActiveFocus(Application.layoutDirection == Qt.RightToLeft ? Qt.TabFocusReason : Qt.BacktabFocusReason)
                        }
                    }
                    Keys.onRightPressed: event => {
                        if (!kickoff.sidebarOnRight) {
                            searchField.forceActiveFocus(Application.layoutDirection == Qt.RightToLeft ? Qt.BacktabFocusReason : Qt.TabFocusReason)
                        }
                    }
                    Keys.onDownPressed: event => {
                        if (kickoff.sidebar) {
                            kickoff.sidebar.forceActiveFocus(Qt.TabFocusReason)
                        } else {
                            kickoff.contentArea.forceActiveFocus(Qt.TabFocusReason)
                        }
                    }

                    onClicked: KCMU.KCMLauncher.openSystemSettings("kcm_users")
                }

                MouseArea {
                    id: nameAndInfoMouseArea
                    hoverEnabled: true

                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    Kirigami.Heading {
                        id: nameLabel
                        anchors.fill: parent
                        opacity: parent.containsMouse ? 0 : 1
                        color: Kirigami.Theme.textColor
                        level: 4
                        text: kuser.fullName
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        horizontalAlignment: kickoff.isPaneOrderReversed ? Text.AlignRight : Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    Kirigami.Heading {
                        id: infoLabel
                        anchors.fill: parent
                        level: 5
                        opacity: parent.containsMouse ? 1 : 0
                        color: Kirigami.Theme.textColor
                        text: `${kuser.loginName}@${kuser.host}` + (kuser.os ? ` (${kuser.os})` : '')
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        horizontalAlignment: kickoff.isPaneOrderReversed ? Text.AlignRight : Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    PComponents.ToolTip.text: infoLabel.text
                    PComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PComponents.ToolTip.visible: infoLabel.truncated && containsMouse
                }
            }
            RowLayout {
                id: rowLayout
                spacing: root.spacing
                height: parent.height
                anchors {
                    left: nameAndIcon.right
                    right: parent.right
                }
                LayoutMirroring.enabled: kickoff.sidebarOnRight
                Keys.onDownPressed: event => {
                    kickoff.contentArea.forceActiveFocus(Qt.TabFocusReason);
                }

                PExtras.SearchField {
                    id: searchField
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                    Layout.fillWidth: true
                    Layout.leftMargin: kickoff.backgroundMetrics.leftPadding
                    focus: true
                    // larger padding and height for the search field
                    leftPadding: Math.round(Kirigami.Units.iconSizes.sizeForLabels * 2)
                    rightPadding: leftPadding
                    background: Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        color: Kirigami.Theme.backgroundColor
                        height: searchField.leftPadding * 1.25
                        radius: height
                    }

                    Binding {
                        target: kickoff
                        property: "searchField"
                        value: searchField
                        // there's only one header ever, so don't waste resources
                        restoreMode: Binding.RestoreNone
                    }
                    Connections {
                        target: kickoff
                        function onExpandedChanged() {
                            if (kickoff.expanded) {
                                searchField.clear()
                            }
                        }
                    }
                    onTextEdited: {
                        searchField.forceActiveFocus(Qt.ShortcutFocusReason)
                    }
                    Keys.priority: Keys.AfterItem
                    Keys.forwardTo: kickoff.contentArea !== null ? kickoff.contentArea.view : []
                    Keys.onTabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain(false));
                    }
                    Keys.onBacktabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain());
                    }
                    Keys.onLeftPressed: event => {
                        if (activeFocus) {
                            nextItemInFocusChain(kickoff.sidebarOnRight).forceActiveFocus(
                                Application.layoutDirection === Qt.RightToLeft ? Qt.TabFocusReason : Qt.BacktabFocusReason)
                        }
                    }
                    Keys.onRightPressed: event => {
                        if (activeFocus) {
                            nextItemInFocusChain(!kickoff.sidebarOnRight).forceActiveFocus(
                                Application.layoutDirection === Qt.RightToLeft ? Qt.BacktabFocusReason : Qt.TabFocusReason)
                        }
                    }
                }

                PComponents.ToolButton {
                    id: configureButton
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    visible: Plasmoid.internalAction("configure").enabled
                    icon.name: "configure"
                    text: Plasmoid.internalAction("configure").text
                    display: PComponents.ToolButton.IconOnly

                    PComponents.ToolTip.text: text
                    PComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PComponents.ToolTip.visible: hovered
                    Keys.onTabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain(false));
                    }
                    Keys.onBacktabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain());
                    }
                    Keys.onLeftPressed: event => {
                        nextItemInFocusChain(kickoff.sidebarOnRight).forceActiveFocus(
                            Application.layoutDirection == Qt.RightToLeft ? Qt.TabFocusReason : Qt.BacktabFocusReason)
                    }
                    Keys.onRightPressed: event => {
                        nextItemInFocusChain(!kickoff.sidebarOnRight).forceActiveFocus(
                            Application.layoutDirection == Qt.RightToLeft ? Qt.BacktabFocusReason : Qt.TabFocusReason)
                    }
                    onClicked: plasmoid.internalAction("configure").trigger()
                }
                PComponents.ToolButton {
                    id: pinButton
                    checkable: true
                    checked: Plasmoid.configuration.isAppletPinned
                    icon.name: "window-pin"
                    text: i18n("Keep Open")
                    display: PComponents.ToolButton.IconOnly
                    PComponents.ToolTip.text: text
                    PComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                    PComponents.ToolTip.visible: hovered
                    Binding {
                        target: kickoff
                        property: "hideOnWindowDeactivate"
                        value: !Plasmoid.configuration.isAppletPinned
                        // there should be no other bindings, so don't waste resources
                        restoreMode: Binding.RestoreNone
                    }
                    Keys.onTabPressed: event => {
                        root.tabSetFocus(event, nextItemInFocusChain(false), kickoff.firstCentralPane || nextItemInFocusChain());
                    }
                    Keys.onBacktabPressed: event => {
                        root.tabSetFocus(event, nameAndIcon.nextItemInFocusChain(false), nextItemInFocusChain(false));
                    }
                    Keys.onLeftPressed: event => {
                        if (!kickoff.sidebarOnRight) {
                            nextItemInFocusChain(false).forceActiveFocus(Application.layoutDirection == Qt.RightToLeft ? Qt.TabFocusReason : Qt.BacktabFocusReason)
                        }
                    }
                    Keys.onRightPressed: event => {
                        if (kickoff.sidebarOnRight) {
                            nextItemInFocusChain(false).forceActiveFocus(Application.layoutDirection == Qt.RightToLeft ? Qt.BacktabFocusReason : Qt.TabFocusReason)
                        }
                    }
                    onToggled: Plasmoid.configuration.isAppletPinned = checked
                }
            }
        }
    }
}
