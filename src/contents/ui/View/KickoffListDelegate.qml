/*
    SPDX-FileCopyrightText: 2011 Martin *Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Gregor Taetzner <gregor@freenet.de>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2015-2018 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
    SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu>

    SPDX-License-Identifier: GPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PComponents
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

import "../Helper"

AbstractKickoffItemDelegate {
    id: root

    property bool compact: Kirigami.Settings.tabletMode ? false : Plasmoid.configuration.isListCompact

    leftPadding: Global.listItemMetrics.margins.left + (mirrored ? Global.fontMetrics.descent : 0)
    rightPadding: Global.listItemMetrics.margins.right + (!mirrored ? Global.fontMetrics.descent : 0)
    // Otherwise it's *too* compact :)
    topPadding: compact ? Kirigami.Units.mediumSpacing : Kirigami.Units.smallSpacing
    bottomPadding: compact ? Kirigami.Units.mediumSpacing : Kirigami.Units.smallSpacing

    labelTruncated: label.truncated
    descriptionTruncated: descriptionLabel.truncated
    descriptionVisible: descriptionLabel.visible

    dragIconItem: icon

    contentItem: RowLayout {
        id: row
        spacing: Global.listItemMetrics.margins.left * 2

        Kirigami.Icon {
            id: icon
            implicitWidth: root.icon.width
            implicitHeight: root.icon.height
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            animated: false
            selected: root.iconAndLabelsShouldlookSelected
            source: root.decoration || root.icon.name || root.icon.source
        }

        GridLayout {
            id: gridLayout

            readonly property color textColor: root.iconAndLabelsShouldlookSelected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor

            Layout.fillWidth: true

            rows: root.compact ? 1 : 2
            columns: root.compact ? 2 : 1
            rowSpacing: 0
            columnSpacing: Kirigami.Units.largeSpacing

            PComponents.Label {
                id: label
                Layout.fillWidth: !descriptionLabel.visible
                Layout.maximumWidth: root.width - root.leftPadding - root.rightPadding - icon.width - row.spacing
                text: root.text
                textFormat: root.isMultilineText ? Text.StyledText : Text.PlainText
                elide: Text.ElideRight
                wrapMode: root.isMultilineText ? Text.WordWrap : Text.NoWrap
                verticalAlignment: Text.AlignVCenter
                maximumLineCount: root.isMultilineText ? Infinity : 1
                color: gridLayout.textColor
            }

            PComponents.Label {
                id: descriptionLabel
                Layout.fillWidth: true
                visible: {
                    let isApplicationSearchResult = root.model?.group === "Applications" || root.model?.group === "System Settings"
                    let isSearchResultWithDescription = root.isSearchResult && (Plasmoid.configuration?.appNameFormat > 1 || !isApplicationSearchResult)
                    return text.length > 0 && (isSearchResultWithDescription || (text !== label.text && !root.isCategoryListItem && Plasmoid.configuration?.appNameFormat > 1))
                }
                enabled: false
                text: root.description
                textFormat: Text.PlainText
                font: Kirigami.Theme.smallFont
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: root.compact ? Text.AlignRight : Text.AlignLeft
                maximumLineCount: 1
                color: gridLayout.textColor
            }
        }
    }

    Loader {
        id: separatorLoader

        anchors.left: root.left
        anchors.right: root.right
        anchors.verticalCenter: root.verticalCenter

        active: root.isSeparator
        asynchronous: false

        // replace separator line with a more subdued one
        sourceComponent: Rectangle {
            id: separator
            color: Plasmoid.configuration.separatorLineColor
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            implicitHeight: Plasmoid.configuration.separatorLineWidth
        }
    }
}
