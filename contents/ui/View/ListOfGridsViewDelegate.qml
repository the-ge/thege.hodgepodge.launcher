/*
 * SPDX-FileCopyrightText: 2023 Tanbir Jishan <tantalising007@gmail.com>
 * SPDX-FileCopyrightText: Gabriel Tenita <g1704578400@tenita.eu@tenita.eu>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Templates as T

import org.kde.plasma.extras as PExtras

import "../Helper"

KickoffGridView {
    id: root

    property int gridIndex: -1 // to know the index of the grid when used inside a listivew
    property bool isCurrentSectionGrid: false
    property bool isSearchFieldActive: false // needed since check doesn't work here when gridview used in all apps
    property ListView parentView // neeeded when used inside a listview e.g. all apps view

    signal showSectionView(string sectionName)

    // When nested inside a listview, other items will still treat it as a delegate,
    // - because this was the truth always till now - so just call the appropriate function
    readonly property QtObject action: QtObject {
        function triggered(): void {
            root.view.currentItem.action.triggered();
            root.view.currentItem.forceActiveFocus();
        }
    }

    view.height: view.cellHeight * Math.ceil(count / view.columns)
    view.cellHeight: view.iconSize + Global.gridCellSpacing
    view.cellWidth: view.iconSize + Global.gridCellSpacing
    view.implicitHeight: view.contentHeight
    blockTargetWheel: false
    view.highlight: PExtras.Highlight {
        visible: root.isCurrentSectionGrid
        pressed: (root.view.currentItem as T.AbstractButton)?.down ?? false

        // The default Z value for delegates is 1. The default Z value for the section delegate is 2.
        // The highlight gets a value of 3 while the drag is active and then goes back to the default value of 0.
        z: (root.currentItem?.Drag.active ?? false) ? 3 : 0

        //width: root.view.cellWidth
        //height: root.view.cellHeight
        active: root.view.activeFocus
            || (kickoff.contentArea === root
                && kickoff.searchField.activeFocus)
    }

    delegate: KickoffGridDelegate {
        id: itemDelegate
        width: root.view.cellWidth
        icon.width: root.view.iconSize
        icon.height: root.view.iconSize
        Accessible.role: Accessible.Cell

        Connections {
            target: itemDelegate.mouseArea
            function onPositionChanged(mouse) {
                if (!root.parentView.movedWithKeyboard) {
                    root.parentView.currentIndex = root.gridIndex
                    root.parentView.currentItem.forceActiveFocus()
                }
            }
        }
    }
}
