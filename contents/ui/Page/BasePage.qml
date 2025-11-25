/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2015-2018 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.plasmoid // qmllint disable import
import org.kde.plasma.workspace.trianglemousefilter

FocusScope {
    id: root

    property real preferredSidebarWidth: implicitSidebarWidth
    property real preferredSidebarHeight: implicitSidebarHeight

    property alias sidebarComponent: sidebarLoader.sourceComponent
    property alias sidebarItem: sidebarLoader.item
    property alias contentAreaComponent: contentAreaLoader.sourceComponent
    property alias contentAreaItem: contentAreaLoader.item

    property alias implicitSidebarWidth: sidebarLoader.implicitWidth
    property alias implicitSidebarHeight: sidebarLoader.implicitHeight

    implicitWidth: preferredSidebarWidth + separator.implicitWidth + contentAreaLoader.implicitWidth
    implicitHeight: Math.max(preferredSidebarHeight, contentAreaLoader.implicitHeight)

    TriangleMouseFilter {
        id: sidebarFilter
        active: Plasmoid.configuration.isUpdateOnHover // qmllint disable unqualified
        anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
        }
        LayoutMirroring.enabled: kickoff.sidebarOnRight
        implicitWidth: root.preferredSidebarWidth
        implicitHeight: root.preferredSidebarHeight
        edge: kickoff.sidebarOnRight ? Qt.LeftEdge : Qt.RightEdge
        blockFirstEnter: true
        Loader {
            id: sidebarLoader
            anchors.fill: parent
            // When positioned after the content area, Tab should go to the start of the footer focus chain
            Keys.onTabPressed: event => {
                (kickoff.isPaneOrderReversed ? kickoff.footer.nextItemInFocusChain() : contentAreaLoader)
                    .forceActiveFocus(Qt.TabFocusReason);
            }
            Keys.onBacktabPressed: event => {
                (kickoff.isPaneOrderReversed ? contentAreaLoader : kickoff.header.pinButton)
                    .forceActiveFocus(Qt.BacktabFocusReason);
            }
            Keys.onLeftPressed: event => {
                if (kickoff.sidebarOnRight) {
                    contentAreaLoader.forceActiveFocus();
                }
            }
            Keys.onRightPressed: event => {
                if (!kickoff.sidebarOnRight) {
                    contentAreaLoader.forceActiveFocus();
                }
            }
            Keys.onUpPressed: event => {
                kickoff.header.nextItemInFocusChain()
                    .forceActiveFocus(Qt.BacktabFocusReason);
            }
            Keys.onDownPressed: event => {
                (kickoff.isPaneOrderReversed ? kickoff.footer.leaveButtons.nextItemInFocusChain() : kickoff.footer.tabBar)
                    .forceActiveFocus(Qt.TabFocusReason);
            }
        }
    }

    Rectangle {
        id: separator
        anchors.top: parent.top
        anchors.left: sidebarFilter.right
        anchors.bottom: parent.bottom
        LayoutMirroring.enabled: kickoff.sidebarOnRight
        implicitWidth: Plasmoid.configuration.separatorLineWidth // qmllint disable unqualified
        color: Plasmoid.configuration.separatorLineColor // qmllint disable unqualified
    }

    Loader {
        id: contentAreaLoader
        focus: true
        anchors {
            top: parent.top
            left: separator.right
            right: parent.right
            bottom: parent.bottom
        }
        LayoutMirroring.enabled: kickoff.sidebarOnRight
        // When positioned after the sidebar, Tab should go to the start of the footer focus chain
        Keys.onTabPressed: event => {
            (kickoff.isPaneOrderReversed ? sidebarLoader : kickoff.footer.nextItemInFocusChain())
                .forceActiveFocus(Qt.TabFocusReason)
        }
        Keys.onBacktabPressed: event => {
            (kickoff.isPaneOrderReversed ? kickoff.header.avatar : sidebarLoader)
                .forceActiveFocus(Qt.BacktabFocusReason)
        }
        Keys.onLeftPressed: event => {
            if (!kickoff.sidebarOnRight) {
                sidebarLoader.forceActiveFocus();
            }
        }
        Keys.onRightPressed: event => {
            if (kickoff.sidebarOnRight) {
                sidebarLoader.forceActiveFocus();
            }
        }
        Keys.onUpPressed: event => {
            kickoff.searchField.forceActiveFocus(Qt.BacktabFocusReason);
        }
        Keys.onDownPressed: event => {
            (kickoff.isPaneOrderReversed ? kickoff.footer.tabBar : kickoff.footer.leaveButtons.nextItemInFocusChain())
                .forceActiveFocus(Qt.TabFocusReason)
        }
    }
}
