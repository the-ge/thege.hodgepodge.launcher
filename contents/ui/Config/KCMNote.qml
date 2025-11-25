/*
    SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC

import org.kde.kirigami as Kirigami

QQC.Label {
    visible: true
    font.family: Kirigami.Theme.smallFont.family
    font.bold: Kirigami.Theme.smallFont.bold
    font.italic: true
    font.pointSize: Kirigami.Theme.smallFont.pointSize
    wrapMode: Text.Wrap
    Layout.fillWidth: true
    Layout.maximumWidth: Kirigami.Units.gridUnit * 21
}
