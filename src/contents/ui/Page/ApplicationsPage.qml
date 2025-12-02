/*
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-FileCopyrightText: Gabriel Tenita <g1704578400@tenita.eu@tenita.eu>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 *
 * HACK: disabled useless warnings from qmllint for stuff related to:
 *     - org.kde.plasma.plasmoid
 *     - org.kde.plasma.private.kicker
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T

import org.kde.kirigami as Kirigami
import org.kde.plasma.extras as PExtras
import org.kde.plasma.plasmoid // qmllint disable import
import org.kde.plasma.private.kicker as Kicker // qmllint disable unused-imports

import "../Helper"
import "../View"

BasePage {
    id: root

    required property int defaultIndex // Favorites, Places, All Applications, then app categories start at 3
    property bool hasFavsGrid: Plasmoid.configuration.favoritesLayout === 0 // qmllint disable unqualified
    property bool hasAppsGrid: Plasmoid.configuration.appsLayout === 0 // qmllint disable unqualified

    sidebarComponent: KickoffListView {
        id: sidebar
        focus: true // needed for Loaders
        model: kickoff.rootModel
        defaultIndex: root.defaultIndex
        // needed otherwise app displayed at top-level will show a first character as group.
        section.property: ""
        delegate: KickoffListDelegate {
            id: listDelegate
            width: sidebar.view.availableWidth
            isCategoryListItem: true
            background: PExtras.Highlight {
                // I have to do this for it to actually fill the item for some reason
                anchors.fill: parent
                active: false
                hovered: listDelegate.mouseArea.containsMouse
                visible: !Plasmoid.configuration.isUpdateOnHover // qmllint disable unqualified
                    && !listDelegate.isSeparator && !parent.ListView.isCurrentItem
                    && hovered
            }
        }
    }

    contentAreaComponent: VerticalStackView {
        id: stackView

        popEnter: Transition {
            NumberAnimation {
                property: "x"
                from: 0.5 * root.width
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        pushEnter: Transition {
            NumberAnimation {
                property: "x"
                from: 0.5 * -root.width
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        readonly property string favoritesViewObjectName: root.hasFavsGrid ? "favoritesGridView" : "favoritesListView"
        readonly property Component favoritesViewComponent: root.hasFavsGrid ? favoritesGridViewComponent : favoritesListViewComponent
        readonly property string appsAllViewObjectName: root.hasAppsGrid ? "listOfGridsView" : "applicationsListView"
        readonly property Component appsAllViewComponent: root.hasAppsGrid ? listOfGridsViewComponent : applicationsListViewComponent
        readonly property string appsCategoryViewObjectName: root.hasAppsGrid ? "applicationsGridView" : "applicationsListView"
        readonly property Component appsCategoryViewComponent: root.hasAppsGrid ? applicationsGridViewComponent : applicationsListViewComponent
        // NOTE: The 0 index modelForRow isn't supposed to be used. That's just how it works.
        // But to trigger model data update, set initial value to 0
        property int appsModelRow: 0
        readonly property Kicker.AppsModel appsModel: kickoff.rootModel.modelForRow(appsModelRow)
        focus: true
        initialItem: favoritesViewComponent

        function showSectionView(sectionName: string, parentView: KickoffListView): void {
            stackView.push(applicationsSectionViewComponent, {
                currentSection: sectionName,
                parentView,
            });
        }

        function updateOnSidebarIndex(index: int) {
            // Only update row index if the condition is met.
            // The 0 index modelForRow isn't supposed to be used. That's just how it works.
            if (index > 0) {
                stackView.appsModelRow = index
            }

            if (index === Global.favoritesIndex && stackView.currentItem.objectName !== stackView.favoritesViewObjectName) {
                stackView.replace(stackView.favoritesViewComponent)
            } else if (index === Global.allAppsIndex && stackView.currentItem.objectName !== stackView.appsAllViewObjectName) {
                stackView.replace(stackView.appsAllViewComponent)
            } else if (index > Global.placesIndex && stackView.currentItem.objectName !== stackView.appsCategoryViewObjectName) {
                stackView.replace(stackView.appsCategoryViewComponent)
            }
        }

        Component {
            id: favoritesListViewComponent
            DropAreaListView {
                id: favoritesListView
                objectName: "favoritesListView"
                mainContentView: true
                focus: true
                model: kickoff.rootModel.favoritesModel
            }
        }

        Component {
            id: favoritesGridViewComponent
            DropAreaGridView {
                id: favoritesGridView
                objectName: "favoritesGridView"
                focus: true
                model: kickoff.rootModel.favoritesModel
            }
        }

        Component {
            id: applicationsListViewComponent

            KickoffListView {
                id: applicationsListView
                objectName: "applicationsListView"
                mainContentView: true
                model: stackView.appsModel
                // we want to semantically switch between group and "", disabling grouping, workaround for QTBUG-121797
                section.property: model && model.description === "KICKER_ALL_MODEL" ? "group" : "_unset"
                section.criteria: ViewSection.FirstCharacter
                hasSectionView: stackView.appsModelRow === 1

                onShowSectionViewRequested: sectionName => stackView.showSectionView(sectionName, this);
            }
        }

        Component {
            id: applicationsSectionViewComponent

            SectionView {
                id: sectionView
                model: stackView.appsModel.sections

                onHideSectionViewRequested: index => {
                    stackView.pop();
                    stackView.currentItem.view.positionViewAtIndex(index, ListView.Beginning);
                    stackView.currentItem.currentIndex = index;
                }
            }
        }

        Component {
            id: applicationsGridViewComponent
            KickoffGridView {
                id: applicationsGridView
                objectName: "applicationsGridView"
                model: stackView.appsModel
            }
        }

        Component {
            id: listOfGridsViewComponent

            ListOfGridsView {
                id: listOfGridsView
                objectName: "listOfGridsView"
                mainContentView: true
                gridModel: stackView.appsModel

                onShowSectionViewRequested: sectionName => {
                    stackView.showSectionView(sectionName, this);
                }
            }
        }

        onFavoritesViewComponentChanged: {
            if (sidebar?.currentIndex === Global.favoritesIndex) {
                stackView.replace(stackView.favoritesViewComponent)
            }
        }
        onAppsAllViewComponentChanged: {
            if (sidebar?.currentIndex === Global.allAppsIndex) {
                stackView.replace(stackView.appsAllViewComponent)
            }
        }
        onAppsCategoryViewComponentChanged: {
            if (sidebar?.currentIndex > Global.placesIndex) {
                stackView.replace(stackView.appsCategoryViewComponent)
            }
        }

        Connections {
            target: root.sidebarItem
            function onCurrentIndexChanged() {
                stackView.updateOnSidebarIndex(sidebar.currentIndex)
            }
        }
        Connections {
            target: kickoff
            function onExpandedChanged() {
                if (kickoff.expanded && kickoff.contentArea.currentItem) {
                    kickoff.contentArea.currentItem.forceActiveFocus()
                }
            }
        }
    }

    // NormalPage doesn't get destroyed when deactivated, so the binding uses
    // StackView.status and visible. This way the bindings are reset when
    // NormalPage is Activated again.
    Binding {
        target: kickoff
        property: "sidebar"
        value: root.sidebarItem
        when: root.T.StackView.status === T.StackView.Active && root.visible
        restoreMode: Binding.RestoreBinding
    }
    Binding {
        target: kickoff
        property: "contentArea"
        value: root.contentAreaItem.currentItem // NOT just root.contentAreaItem
        when: root.T.StackView.status === T.StackView.Active && root.visible
        restoreMode: Binding.RestoreBinding
    }
}
