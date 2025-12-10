/*
 *    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
 *    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 *
 *    SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PComponents
import org.kde.plasma.extras as PExtras
import org.kde.kirigami as Kirigami

import "../Helper"

PExtras.PlasmoidHeading {
    id: root

    required property bool isAtPlaces
 
    property int iconSize: Kirigami.Units.iconSizes.smallMedium
    property real preferredTabBarWidth: 0

    readonly property alias tabBar: tabBar
    readonly property alias leaveButtons: leaveButtons

    spacing: kickoff.backgroundMetrics.spacing
    contentWidth: tabBar.implicitWidth + spacing
    contentHeight: leaveButtons.implicitHeight

    // We use an increased vertical padding to improve touch usability
    leftPadding: kickoff.backgroundMetrics.leftPadding
    rightPadding: kickoff.backgroundMetrics.rightPadding
    topPadding: spacing * 2
    bottomPadding: spacing * 2

    topInset: 0
    leftInset: 0
    rightInset: 0
    bottomInset: 0

    position: PComponents.ToolBar.Footer
    enabledBorders: Qt.BottomEdge | Qt.LeftEdge | Qt.RightEdge // disable top border

    FontMetrics {
        id: fontMetrics
        font.family: Kirigami.Theme.defaultFont.family
    }

    PComponents.TabBar {
        id: tabBar
        focus: true

        property real tabWidth: Math.max(firstTab.implicitWidth, nextTab.implicitWidth)

        width: root.preferredTabBarWidth > 0 ? root.preferredTabBarWidth : undefined
        implicitWidth: contentWidth + leftPadding + rightPadding
        implicitHeight: contentHeight + topPadding + bottomPadding
        // This is needed to keep the sparators horizontally aligned
        leftPadding: mirrored ? root.spacing : 0
        rightPadding: !mirrored ? root.spacing : 0
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }

        position: PComponents.TabBar.Footer

        contentItem: ListView {
            id: tabBarListView
            focus: true
            model: tabBar.contentModel
            currentIndex: tabBar.currentIndex
            spacing: root.spacing
            orientation: ListView.Horizontal
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.AutoFlickIfNeeded
            snapMode: ListView.SnapToItem

            highlight: KSvg.FrameSvgItem {
                anchors {
                    top: tabBarListView.contentItem.top
                    bottom: tabBarListView.contentItem.bottom
                    topMargin: -root.topPadding
                    bottomMargin: -root.bottomPadding
                }
                imagePath: "widgets/tabbar"
                prefix: tabBar.position === PComponents.TabBar.Header ? "north-active-tab" : "south-active-tab"
            }
            highlightMoveDuration: Kirigami.Units.longDuration
            highlightRangeMode: ListView.ApplyRange
            preferredHighlightBegin: tabBar.tabWidth
            preferredHighlightEnd: width - tabBar.tabWidth
            keyNavigationEnabled: false
        }

        component BaseButton: PComponents.TabButton {
            opacity: focus || area.hovered ? 1 : 0.5
            width: fontMetrics.averageCharacterWidth * text.length + root.iconSize + leftPadding + rightPadding
            anchors {
                top: tabBarListView.contentItem.top
                topMargin: -root.topPadding
                bottom: tabBarListView.contentItem.bottom
                bottomMargin: -root.bottomPadding
            }
            rightPadding: root.spacing * 2
            icon.width: root.iconSize
            icon.height: root.iconSize
            HoverHandler { id: area }
        }
        BaseButton {
            id: firstTab
            focus: !root.isAtPlaces
            icon.name: "applications-all-symbolic"
            text: i18n("Favorites")
            Keys.onBacktabPressed: event => (kickoff.lastCentralPane || nextItemInFocusChain(false)).forceActiveFocus(Qt.BacktabFocusReason)
        }
        BaseButton {
            id: nextTab
            focus: root.isAtPlaces
            icon.name: "compass"
            text: i18n("Places")
        }

        Connections {
            target: kickoff
            function onExpandedChanged() {
                if (kickoff.expanded) {
                    tabBar.currentIndex = root.isAtPlaces ? 1 : 0
                }
            }
        }

        Keys.onPressed: event => {
            const Key_Next = Qt.application.layoutDirection === Qt.RightToLeft ? Qt.Key_Left : Qt.Key_Right
            const Key_Prev = Qt.application.layoutDirection === Qt.RightToLeft ? Qt.Key_Right : Qt.Key_Left
            if (event.key === Key_Next) {
                if (currentIndex === count - 1) {
                    leaveButtons.nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
                } else {
                    incrementCurrentIndex()
                    currentItem.forceActiveFocus(Qt.TabFocusReason)
                }
                event.accepted = true
            } else if (event.key === Key_Prev && currentIndex > 0) {
                decrementCurrentIndex()
                currentItem.forceActiveFocus(Qt.BacktabFocusReason)
                event.accepted = true
            }
        }
        Keys.onUpPressed: event => {
            kickoff.firstCentralPane.forceActiveFocus(Qt.BacktabFocusReason);
        }
    }

    PageFooterLeaveButtons {
        id: leaveButtons

        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }

        // available width for leaveButtons
        maximumWidth: root.availableWidth - tabBar.width

        Keys.onUpPressed: event => {
            kickoff.lastCentralPane.forceActiveFocus(Qt.BacktabFocusReason);
        }
    }

    Behavior on height {
        enabled: kickoff.expanded
        NumberAnimation {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InQuad
        }
    }

    // Using item containing WheelHandler instead of MouseArea because
    // MouseArea doesn't keep track to the total amount of rotation.
    // Keeping track of the total amount of rotation makes it work
    // better for touch pads.
    Item {
        id: mouseItem
        parent: root
        anchors.left: parent.left
        height: root.height
        width: tabBar.width
        z: 1 // Has to be above contentItem to receive mouse wheel events
        WheelHandler {
            id: tabScrollHandler
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: {
                const shouldDec = rotation >= 15
                const shouldInc = rotation <= -15
                const shouldReset = (rotation > 0 && tabBar.currentIndex === 0) || (rotation < 0 && tabBar.currentIndex === tabBar.count - 1)
                if (shouldDec) {
                    tabBar.decrementCurrentIndex();
                    rotation = 0
                } else if (shouldInc) {
                    tabBar.incrementCurrentIndex();
                    rotation = 0
                } else if (shouldReset) {
                    rotation = 0
                }
            }
        }
    }

    Shortcut {
        sequences: ["Ctrl+Tab", "Ctrl+Shift+Tab", StandardKey.NextChild, StandardKey.PreviousChild]
        onActivated: {
            tabBar.currentIndex = (tabBar.currentIndex === 0) ? 1 : 0;
        }
    }
}
