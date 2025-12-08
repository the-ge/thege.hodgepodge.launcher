/*
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T
//import org.kde.kirigami as Kirigami

import "../Helper"
import "../View"

EmptyPage {
    id: root

    readonly property int defaultIndex: kickoff.startWith
    property real preferredSidebarWidth: Math.max(footer.tabBar.implicitWidth, applicationsPage.implicitSidebarWidth) + kickoff.backgroundMetrics.spacing * 2

    contentItem: HorizontalStackView {
        id: stackView
        focus: true
        reverseTransitions: footer.tabBar.currentIndex === 1
        initialItem: applicationsPage

        ApplicationsPage {
            id: applicationsPage
            defaultIndex: root.defaultIndex
            preferredSidebarWidth: root.preferredSidebarWidth + kickoff.backgroundMetrics.leftPadding
        }
        Component {
            id: placesPage
            PlacesPage {
                preferredSidebarWidth: root.preferredSidebarWidth + kickoff.backgroundMetrics.leftPadding
                preferredSidebarHeight: applicationsPage.implicitSidebarHeight
            }
        }

        Connections {
            target: footer.tabBar
            function onCurrentIndexChanged() {
                stackView.replace(footer.tabBar.currentIndex === 1 ? placesPage : applicationsPage)
            }
        }
    }

    footer: PageFooter {
        id: footer
        isAtPlaces: root.defaultIndex === Global.placesIndex
        preferredTabBarWidth: root.preferredSidebarWidth

        Binding {
            target: kickoff
            property: "footer"
            value: footer
            restoreMode: Binding.RestoreBinding
        }

        // Eat down events to prevent them from reaching the contentArea or searchField
        Keys.onDownPressed: event => {}
    }
}
