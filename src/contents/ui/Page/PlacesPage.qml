/*
 * SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T

import org.kde.plasma.extras as PExtras
import org.kde.plasma.plasmoid

import "../Helper"
import "../View"

BasePage {
    id: root

    sidebarComponent: KickoffListView {
        id: sidebar
        isSidebar: true
        focus: true // needed for Loaders
        model: placesCategoryModel
        delegate: KickoffListDelegate {
            url: ""
            description: ""
            width: view.availableWidth
            isCategoryListItem: true
            isMultilineText: false
            background: PExtras.Highlight {
                // I have to do this for it to actually fill the item for some reason
                anchors.fill: parent
                active: false
                hovered: parent.mouseArea.containsMouse
                visible: !Plasmoid.configuration.isUpdateOnHover
                    && !parent.isSeparator && !parent.ListView.isCurrentItem
                    && hovered
            }
        }
    }

    contentAreaComponent: KickoffListView {
        id: contentArea
        mainContentView: true
        focus: true
        objectName: "frequentlyUsedView"
        model: switch (root.sidebarItem.currentIndex) {
            case 0: return kickoff.computerModel
            case 1: return kickoff.recentUsageModel
            case 2: return kickoff.frequentUsageModel
        }
        onActiveFocusChanged: if (activeFocus && count < 1) {
            root.sidebarItem.forceActiveFocus()
        }
    }

    // we make our model ourselves
    ListModel {
        id: placesCategoryModel
        ListElement { display: "Computer"; decoration: "computer" }
        ListElement { display: "History"; decoration: "view-history" }
        ListElement { display: "Frequently Used"; decoration: "clock" }
        Component.onCompleted: {
            // Can't use a function in a QML ListElement declaration
            placesCategoryModel.setProperty(0, "display", i18nc("category in Places sidebar", "Computer"))
            placesCategoryModel.setProperty(1, "display", i18nc("category in Places sidebar", "History"))
            placesCategoryModel.setProperty(2, "display", i18nc("category in Places sidebar", "Frequently Used"))
            if (Global.powerManagement.data["PowerDevil"]
                && Global.powerManagement.data["PowerDevil"]["Is Lid Present"]) {
                placesCategoryModel.setProperty(0, "decoration", "computer-laptop")
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
        value: root.contentAreaItem // NOT root.contentAreaItem.currentItem
        when: root.T.StackView.status === T.StackView.Active && root.visible
        restoreMode: Binding.RestoreBinding
    }
}
