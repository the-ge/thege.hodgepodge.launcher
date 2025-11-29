/*
    SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.kirigami.platform as Platform

Item {
    property string label
    property bool hasLine: true
    anchors.left: parent.left
    anchors.leftMargin: Platform.Units.gridUnit * 1
    anchors.right: parent.right
    anchors.rightMargin: Platform.Units.gridUnit * 1
    implicitHeight: Platform.Units.gridUnit * (hasLine ? 4 : 2)

    Kirigami.Heading {
        text: parent.label
        level: 2
        type: Kirigami.Heading.Type.Primary
        anchors.top: parent.top
        anchors.topMargin: (parent.hasLine ? Platform.Units.gridUnit : 0)
        anchors.left: parent.left
    }

    Rectangle {
        color: Platform.ColorUtils.linearInterpolation(
            Platform.Theme.backgroundColor,
            Platform.Theme.textColor,
            Platform.Theme.lightFrameContrast
        )
        visible: parent.hasLine
        height: 1
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: (parent.hasLine ? Platform.Units.gridUnit * 1.5 : 0)
    }
}
