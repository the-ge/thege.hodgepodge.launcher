/*
 * SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
 * SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
 * SPDX-FileCopyrightText: 2015 Eike Hein <hein@kde.org>
 * SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * HACK: disabled useless warnings from qmllint for stuff related to:
 *     - org.kde.plasma.plasmoid
 *     - org.kde.plasma.private.kicker
 *     - JavaScript Math
 *     - i18n*()
*/

pragma ComponentBehavior: Bound

import QtQuick as QQ
import QtQuick.Layouts as QQL

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PComponents
import org.kde.plasma.core as PCore
import org.kde.plasma.plasmoid // qmllint disable import
import org.kde.plasma.private.kicker as Kicker // qmllint disable unused-imports

import "Helper"
import "Helper/Tools.js" as Tools
import "View"

PlasmoidItem { // qmllint disable import
    id: kickoff

    width: Kirigami.Units.iconSizes.large // qmllint disable missing-property
    height: Kirigami.Units.iconSizes.large // qmllint disable missing-property

    // The properties are defined here instead of the singleton because each
    // instance of Kickoff requires different instances of these properties
    readonly property bool inPanel: [
        PCore.Types.TopEdge,
        PCore.Types.RightEdge,
        PCore.Types.BottomEdge,
        PCore.Types.LeftEdge,
    ].includes(Plasmoid.location) // qmllint disable unqualified
    readonly property bool isVertical: Plasmoid.formFactor === PCore.Types.Vertical // qmllint disable unqualified

    // Used to prevent the width from changing frequently when the scrollbar appears or disappears in the grid favorites layout
    readonly property bool mayHaveGridWithScrollBar: Plasmoid.configuration.appsLayout === 0 || ( // qmllint disable unqualified
        Plasmoid.configuration.favoritesLayout === 0 // qmllint disable unqualified
        && kickoff.rootModel.favoritesModel.count > minGridRowCount * minGridRowCount // qmllint disable unresolved-type
    )

    //BEGIN Models
    // qmllint disable import missing-property unqualified
    readonly property Kicker.RootModel rootModel: Kicker.RootModel {
        autoPopulate: false

        // TODO: appletInterface property now can be ported to "applet" and have the real Applet* assigned directly
        appletInterface: kickoff

        appNameFormat: Plasmoid.configuration.appNameFormat
        flat: true // have categories, but no subcategories
        sorted: Plasmoid.configuration.isAlphaSorted
        showSeparators: true
        showTopLevelItems: true

        showAllApps: true
        showAllAppsCategorized: false
        showRecentApps: false
        showRecentDocs: false
        showPowerSession: false
        showFavoritesPlaceholder: true

        QQ.Component.onCompleted: {
            favoritesModel.initForClient("org.kde.plasma.kickoff.favorites.instance-" + Plasmoid.id)
            if (!Plasmoid.configuration.favoritesPortedToKAstats) {
                if (favoritesModel.count < 1) {
                    favoritesModel.portOldFavorites(Plasmoid.configuration.favorites);
                }
                Plasmoid.configuration.favoritesPortedToKAstats = true;
            }
        }
    }

    readonly property Kicker.RunnerModel runnerModel: Kicker.RunnerModel {
        query: kickoff.searchField ? kickoff.searchField.text : ""
        onRequestUpdateQuery: query => {
            if (kickoff.searchField) {
                kickoff.searchField.text = query;
            }
        }
        appletInterface: kickoff
        mergeResults: true
        favoritesModel: rootModel.favoritesModel
    }

    readonly property Kicker.ComputerModel computerModel: Kicker.ComputerModel {
        appletInterface: kickoff
        favoritesModel: rootModel.favoritesModel
        systemApplications: Plasmoid.configuration.systemApplications
        QQ.Component.onCompleted: {
            //systemApplications = Plasmoid.configuration.systemApplications;
        }
    }

    readonly property alias recentUsageModel: recentUsageModel
    Kicker.RecentUsageModel {
        id: recentUsageModel
        favoritesModel: rootModel.favoritesModel
    }

    readonly property alias frequentUsageModel: frequentUsageModel
    Kicker.RecentUsageModel {
        id: frequentUsageModel
        favoritesModel: rootModel.favoritesModel
        ordering: 1 // Popular / Frequently Used
    }
    // qmllint enable
    //END

    //BEGIN UI elements
    // Set in FullRepresentation.qml
    property FullRepresentationHeader header: null

    // Set in Header.qml
    // QTBUG Using PComponents.TextField as type makes assignment fail
    // "Cannot assign QObject* to TextField_QMLTYPE_8*"
    property QQ.Item searchField: null

    // Set in FullRepresentation.qml, Page/ApplicationPage.qml, Page/PlacesPage.qml
    property QQ.Item sidebar: null // is null when searching
    property QQ.Item contentArea: null // is searchView when searching

    // Set in Page/NormalPage.qml
    property QQ.Item footer: null

    readonly property int startWith: Plasmoid.configuration.startWith // qmllint disable unqualified

    // True when the header and the content pane LayoutMirroring diverges from global LayoutMirroring,
    // in order to achieve the desired sidebar position
    readonly property bool isPaneOrderReversed: Plasmoid.configuration.isPaneOrderReversed // qmllint disable unqualified
    readonly property bool sidebarOnRight: (QQ.Application.layoutDirection == Qt.RightToLeft) != isPaneOrderReversed
    // References to items according to their focus chain order
    readonly property QQ.Item firstHeaderItem: header ? (isPaneOrderReversed ? header.pinButton : header.avatar) : null
    readonly property QQ.Item lastHeaderItem: header ? (isPaneOrderReversed ? header.avatar : header.pinButton) : null
    readonly property QQ.Item firstCentralPane: isPaneOrderReversed ? contentArea : sidebar
    readonly property QQ.Item lastCentralPane: isPaneOrderReversed ? sidebar : contentArea

    readonly property QQ.Item dragSource: QQ.Item {
        id: dragSource // BUG 449426
        property QQ.Item sourceItem
        QQ.Drag.dragType: QQ.Drag.Automatic
    }
    //END

    //BEGIN Metrics
    readonly property KSvg.FrameSvgItem backgroundMetrics: KSvg.FrameSvgItem {
        visible: false
        // Inset defaults to a negative value when not set by margin hints
        // qmllint disable unqualified
        readonly property real leftPadding: Math.round(margins.left - Math.max(inset.left, 0))
        readonly property real rightPadding: Math.round(margins.right - Math.max(inset.right, 0))
        readonly property real topPadding: Math.round(margins.top - Math.max(inset.top, 0))
        readonly property real bottomPadding: Math.round(margins.bottom - Math.max(inset.bottom, 0))
        readonly property real spacing: Math.round(leftPadding)
        imagePath: Plasmoid.formFactor === PCore.Types.Planar ? "widgets/background" : "dialogs/background"
        // qmllint enable
    }

    // Used to show smaller Kickoff on small screens
    readonly property real minScreenDimension: Math.min(QQ.Screen.desktopAvailableWidth, QQ.Screen.desktopAvailableHeight) * QQ.Screen.devicePixelRatio // size of the smallest side of the screen, in pixels
    readonly property real minSidebarWidth: Plasmoid.fullRepresentationItem ? Plasmoid.fullRepresentationItem?.normalPage?.preferredSidebarWidth : (gridIconSize + Global.gridCellSpacing) * 2 // qmllint disable unqualified
    // (4 grid rows if 4 grid cells fit on screen in any direction, else 2 grid rows)
    readonly property int minGridRowCount: minScreenDimension > (kickoff.gridIconSize + Global.gridCellSpacing) * 4 + minSidebarWidth ? 4 : 2

    property int gridIconSize: Global.iconSizes[Plasmoid.configuration.gridIconSize] // qmllint disable unqualified
    property int listIconSize: Global.iconSizes[Plasmoid.configuration.listIconSize] // qmllint disable unqualified
    property int userIconSize: Global.iconSizes[Plasmoid.configuration.userIconSize] // qmllint disable unqualified

    // This is here, not in the singleton with the other metrics items,
    // because the list delegates' height depends on a configuration setting
    // and the singleton can't access configuration
    readonly property real listDelegateHeight: listDelegate.height
    KickoffListDelegate {
        id: listDelegate
        visible: false
        enabled: false
        compact: false
        model: null
        index: -1
        text: "asdf"
        description: "asdf"
        url: ""
        decoration: "applications-featured"
        action: null
        indicator: null
        isMultilineText: false
    }
    //END

    Plasmoid.icon: Plasmoid.configuration.launcherIcon // qmllint disable unresolved-type missing-property unqualified

    switchWidth: fullRepresentationItem ? QQL.Layout.minimumWidth : -1
    switchHeight: fullRepresentationItem ? QQL.Layout.minimumHeight : -1

    preferredRepresentation: compactRepresentation

    fullRepresentation: FullRepresentation {
        focus: true
    }

    // Only exists because the default CompactRepresentation doesn't:
    // - open on drag
    // - allow defining a custom drop handler
    // - expose the ability to show text below or beside the icon
    // TODO remove once it gains those features
    compactRepresentation: QQ.MouseArea {
        id: compactRoot

        // Taken from DigitalClock to ensure uniform sizing when next to each other
        readonly property bool isTooSmall: Plasmoid.formFactor === PCore.Types.Horizontal && Math.round(2 * (compactRoot.height / 5)) <= Kirigami.Theme.smallFont.pixelSize // qmllint disable unqualified
        readonly property bool hasIcon: kickoff.isVertical || Plasmoid.icon !== ""
        readonly property bool hasLabel: !kickoff.isVertical && Plasmoid.configuration.launcherIconText !== ""
        readonly property int iconSize: Kirigami.Units.iconSizes.large
        readonly property var sizing: {
            const displayedIcon = imageFallback.visible ? imageFallback : (buttonIcon.valid ? buttonIcon : buttonIconFallback);
            const impWidth = 0
                + (hasIcon  ? displayedIcon.width                                                                 : 0)
                + (hasLabel ? iconLabel.contentWidth + iconLabel.Layout.leftMargin + iconLabel.Layout.rightMargin : 0)
            const impHeight = displayedIcon.height > 0 ? displayedIcon.height : iconSize
            // at least square, but can be wider/taller
            const preferredWidth = kickoff.inPanel && kickoff.isVertical ? iconSize : impWidth;
            const preferredHeight = kickoff.inPanel && !kickoff.isVertical ? iconSize : impHeight;

            return { preferredWidth: preferredWidth, preferredHeight: preferredHeight }
        }

        implicitWidth: iconSize
        implicitHeight: iconSize
        hoverEnabled: true

        property bool wasExpanded

        QQL.Layout.preferredWidth: sizing.preferredWidth
        QQL.Layout.preferredHeight: sizing.preferredHeight
        QQL.Layout.minimumWidth: QQL.Layout.preferredWidth
        QQL.Layout.minimumHeight: QQL.Layout.preferredHeight

        QQ.Accessible.name: parent.Plasmoid.title
        QQ.Accessible.role: QQ.Accessible.Button

        onPressed: wasExpanded = kickoff.expanded
        onClicked: kickoff.expanded = !wasExpanded

        QQ.DropArea {
            id: compactDragArea
            anchors.fill: parent
            onEntered: drag => {
                if (drag.hasUrls) {
                    parent.expandOnDragTimer.start()
                }
            }
            onExited: parent.expandOnDragTimer.stop()
        }

        QQ.Timer {
            id: expandOnDragTimer
            // this is an interaction and not an animation, so we want it as a constant
            interval: 250
            onTriggered: kickoff.expanded = true
        }

        QQL.RowLayout {
            id: iconLabelRow
            anchors.fill: parent
            spacing: 0

            Kirigami.Icon {
                id: buttonIcon

                QQL.Layout.fillWidth: kickoff.isVertical
                QQL.Layout.fillHeight: !kickoff.isVertical
                QQL.Layout.preferredWidth: kickoff.isVertical ? -1 : height / (implicitHeight / implicitWidth)
                QQL.Layout.preferredHeight: !kickoff.isVertical ? -1 : width * (implicitHeight / implicitWidth)
                QQL.Layout.maximumHeight: Kirigami.Units.iconSizes.huge
                QQL.Layout.maximumWidth: Kirigami.Units.iconSizes.huge
                QQL.Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                source: Tools.iconOrDefault(Plasmoid.formFactor, Plasmoid.icon)
                active: compactRoot.containsMouse || compactDragArea.containsDrag
                roundToIconSize: implicitHeight === implicitWidth
                visible: valid && !imageFallback.visible
            }

            Kirigami.Icon {
                id: buttonIconFallback
                // fallback is assumed to be square
                QQL.Layout.fillWidth: kickoff.isVertical
                QQL.Layout.fillHeight: !kickoff.isVertical
                QQL.Layout.preferredWidth: kickoff.isVertical ? -1 : height
                QQL.Layout.preferredHeight: !kickoff.isVertical ? -1 : width
                QQL.Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

                source: buttonIcon.valid ? null : Tools.defaultIconName
                active: compactRoot.containsMouse || compactDragArea.containsDrag
                visible: !buttonIcon.valid && Plasmoid.icon !== "" && !imageFallback.visible
            }

            QQ.Image {
                id: imageFallback

                readonly property bool nonSquareImage: sourceSize.width != sourceSize.height

                visible: nonSquareImage && status == Image.Ready
                source: Plasmoid.icon

                QQL.Layout.fillWidth: kickoff.isVertical
                QQL.Layout.fillHeight: !kickoff.isVertical
                QQL.Layout.preferredWidth: kickoff.isVertical ? -1 : height / (implicitHeight / implicitWidth)
                QQL.Layout.preferredHeight: !kickoff.isVertical ? -1 : width * (implicitHeight / implicitWidth)
                QQL.Layout.maximumHeight: kickoff.isVertical ? -1 : Kirigami.Units.iconSizes.huge
                QQL.Layout.maximumWidth: kickoff.isVertical ? Kirigami.Units.iconSizes.huge : -1
                QQL.Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
                fillMode: QQ.Image.PreserveAspectFit
            }

            PComponents.Label {
                id: iconLabel

                QQL.Layout.fillHeight: true
                QQL.Layout.leftMargin: Kirigami.Units.smallSpacing
                QQL.Layout.rightMargin: Kirigami.Units.smallSpacing

                text: Plasmoid.configuration.launcherIconText // qmllint disable unqualified
                textFormat: QQ.Text.StyledText
                horizontalAlignment: QQ.Text.AlignLeft
                verticalAlignment: QQ.Text.AlignVCenter
                wrapMode: QQ.Text.NoWrap
                fontSizeMode: QQ.Text.VerticalFit
                font.pixelSize: compactRoot.isTooSmall ? Kirigami.Theme.defaultFont.pixelSize : Kirigami.Units.iconSizes.roundedIconSize(Kirigami.Units.gridUnit * 2)
                minimumPointSize: Kirigami.Theme.smallFont.pointSize
                visible: compactRoot.hasLabel
            }
        }
    }

    Kicker.ProcessRunner { // qmllint disable import
        id: processRunner
    }

    Plasmoid.contextualActions: [
        PCore.Action {
            text: i18n("Edit Applications…") // qmllint disable unqualified
            icon.name: "kmenuedit"
            visible: Plasmoid.immutability !== PCore.Types.SystemImmutable
            onTriggered: processRunner.runMenuEditor()
        }
    ]

    QQ.Component.onCompleted: {
        if (kickoff.hasOwnProperty("activationTogglesExpanded")) { //qmllint disable missing-property
            kickoff.activationTogglesExpanded = true
        }
    }
} // root
