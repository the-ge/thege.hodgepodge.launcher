/*
    SPDX-FileCopyrightText: 2011 Martin *Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015-2018 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid // qmllint disable import

import "../Helper"

AbstractKickoffItemDelegate {
    id: root

    leftPadding: Global.listItemMetrics.margins.left
    rightPadding: Global.listItemMetrics.margins.right
    topPadding: Kirigami.Units.smallSpacing * 2
    bottomPadding: Kirigami.Units.smallSpacing * 2

    labelTruncated: label.truncated
    descriptionVisible: false

    dragIconItem: iconItem

    contentItem: ColumnLayout {
        spacing: root.spacing

        Kirigami.Icon {
            id: iconItem
            implicitWidth: root.icon.width
            implicitHeight: root.icon.height
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom

            animated: false
            selected: root.iconAndLabelsShouldlookSelected
            source: root.decoration || root.icon.name || root.icon.source
        }

        PComponents.Label {
            id: label
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight * (lineCount === 1 ? 2 : 1)

            text: root.text
            textFormat: Text.PlainText
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            maximumLineCount: 2
            wrapMode: Text.Wrap
            color: root.iconAndLabelsShouldlookSelected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
        }
    }
}
