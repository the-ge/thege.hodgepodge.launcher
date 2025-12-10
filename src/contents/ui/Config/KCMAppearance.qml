/*
 * SPDX-FileCopyrightText: 2013 David Edmundson <davidedmundson@kde.org>
 * SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
 * SPDX-FileCopyrightText: 2022 Nate Graham <nate@kde.org>
 * SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 * SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * HACK: disabled useless warnings from qmllint for stuff related to:
 *     - i18n*()
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC

import org.kde.iconthemes as KIconThemes
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQC
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PCore
import org.kde.plasma.plasmoid

import "../Helper"
import "../Helper/Tools.js" as Tools

KCM {
    id: root

    property alias  cfg_isPaneOrderReversed: isPaneOrderReversedOn.checked
    property alias  cfg_isListCompact: isListCompact.checked
    property string cfg_launcherIcon: cfg_launcherIconDefault
    property alias  cfg_launcherIconText: launcherIconText.text
    property alias  cfg_userIconSize: userIconSize.currentIndex
    property alias  cfg_gridIconSize: gridIconSize.currentIndex
    property alias  cfg_listIconSize: listIconSize.currentIndex
    property alias  cfg_separatorLineWidth: separatorLineWidth.value
    property alias  cfg_separatorLineColor: separatorLineColor.color

    Kirigami.FormLayout {

        RowLayout { // isPaneOrderReversed
            Kirigami.FormData.label: i18n("Sidebar position:") // qmllint disable unqualified
            QQC.RadioButton {
                id: isPaneOrderReversedOff
                text: i18n("Left") // qmllint disable unqualified
                checked: root.cfg_isPaneOrderReversed === false
            }
            QQC.RadioButton {
                id: isPaneOrderReversedOn
                text: i18n("Right") // qmllint disable unqualified
                checked: root.cfg_isPaneOrderReversed === true
            }
        }

        RowLayout { // isListCompact
            //Layout.columnSpan: 2
            Kirigami.FormData.label: i18n("List style:") // qmllint disable unqualified
            QQC.RadioButton {
                id: isListNormal
                text: i18n("Normal") // qmllint disable unqualified
                checked: !root.cfg_isListCompact
                enabled: !Kirigami.Settings.tabletMode
                onToggled: root.cfg_isListCompact = false
            }
            QQC.RadioButton {
                id: isListCompact
                text: i18n("Compact") // qmllint disable unqualified
                checked: root.cfg_isListCompact
                enabled: !Kirigami.Settings.tabletMode
                onToggled: root.cfg_isListCompact = true
            }
            KCMNote {
                text: i18nc("@info:usagetip under a checkbox when Touch Mode is on", "Disabled in Touch Mode") // qmllint disable unqualified
                visible: Kirigami.Settings.tabletMode
            }
        }

        KCMNote {
            text: i18nc("@info:isListCompact", "Normal: two rows, compact: one row.") // qmllint disable unqualified
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC.Button { // launcherIcon
            Kirigami.FormData.label: i18n("Launcher icon:") // qmllint disable unqualified
            id: launcherIcon
            implicitWidth: previewFrame.width
            implicitHeight: previewFrame.height
            hoverEnabled: true
            Accessible.name: i18nc("@action:button", "Change Application Launcher's icon") // qmllint disable unqualified
            Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", root.cfg_launcherIcon) // qmllint disable unqualified
            Accessible.role: Accessible.ButtonMenu
            QQC.ToolTip.delay: Kirigami.Units.toolTipDelay
            QQC.ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", root.cfg_launcherIcon) // qmllint disable unqualified
            QQC.ToolTip.visible: launcherIcon.hovered && root.cfg_launcherIcon.length > 0

            KIconThemes.IconDialog {
                id: iconDialog
                onIconNameChanged: {
                    root.cfg_launcherIcon = iconName || Tools.defaultIconName;
                }
            }

            KSvg.FrameSvgItem {
                id: previewFrame
                anchors.centerIn: parent
                imagePath: Plasmoid.formFactor === PCore.Types.Vertical || Plasmoid.formFactor === PCore.Types.Horizontal
                    ? "widgets/panel-background"
                    : "widgets/background"
                width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: Tools.iconOrDefault(Plasmoid.formFactor, root.cfg_launcherIcon)
                }
            }

            QQC.Menu {
                id: iconMenu

                // Appear below the button
                y: parent.height

                QQC.MenuItem {
                    text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…") // qmllint disable unqualified
                    icon.name: "document-open-folder"
                    Accessible.description: i18nc("@info:whatsthis", "Choose an icon for Application Launcher") // qmllint disable unqualified
                    onClicked: iconDialog.open()
                }
                QQC.MenuItem {
                    text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon") // qmllint disable unqualified
                    icon.name: "edit-clear"
                    enabled: root.cfg_launcherIcon !== Tools.defaultIconName
                    onClicked: root.cfg_launcherIcon = Tools.defaultIconName
                }
                QQC.MenuItem {
                    text: i18nc("@action:inmenu", "Remove icon") // qmllint disable unqualified
                    icon.name: "delete"
                    enabled: root.cfg_launcherIcon !== "" && launcherIconText.text && Plasmoid.formFactor !== PCore.Types.Vertical
                    onClicked: root.cfg_launcherIcon = ""
                }
            }

            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()
        }

        Kirigami.ActionTextField { // launcherIconText
            id: launcherIconText
            enabled: Plasmoid.formFactor !== PCore.Types.Vertical
            Kirigami.FormData.label: i18nc("@label:textbox", "Launcher icon text:") // qmllint disable unqualified
            text: root.cfg_launcherIconTextDefault
            placeholderText: i18nc("@info:placeholder", "Type here to add a text label next to the launcher icon…") // qmllint disable unqualified
            onTextEdited: {
                root.cfg_launcherIconText = launcherIconText.text
                // This is to make sure that we always have a icon if there is no text.
                // If the user remove the icon and remove the text, without this, we'll have no icon and no text.
                // This is to force the icon to be there.
                if (!launcherIconText.text) {
                    root.cfg_launcherIcon = root.cfg_launcherIcon || Tools.defaultIconName
                }
            }
            rightActions: QQC.Action {
                icon.name: "edit-clear"
                enabled: launcherIconText.text !== ""
                text: i18nc("@action:button", "Remove launcher icon text") // qmllint disable unqualified
                onTriggered: {
                    launcherIconText.clear()
                    root.cfg_launcherIconText = ""
                    root.cfg_launcherIcon = root.cfg_launcherIcon || Tools.defaultIconName
                }
            }
        }

        QQC.Label {
            Layout.fillWidth: true
            Layout.maximumWidth: Kirigami.Units.gridUnit * 25
            visible: Plasmoid.formFactor === PCore.Types.Vertical
            text: i18nc("@info", "An icon text cannot be set when the launcher's container is vertical.") // qmllint disable unqualified
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout { // userIconSize
            Kirigami.FormData.label: i18n("User avatar size:") // qmllint disable unqualified
            QQC.ComboBox {
                id: userIconSize
                model: Global.iconSizes
            }
            QQC.Label {
                text: i18n("px") // qmllint disable unqualified
            }
        }

        RowLayout { // gridIconSize
            Kirigami.FormData.label: i18n("Grid icons size:") // qmllint disable unqualified
            QQC.ComboBox {
                id: gridIconSize
                model: Global.iconSizes
            }
            QQC.Label {
                text: i18n("px") // qmllint disable unqualified
            }
        }

        RowLayout { // listIconSize
            Kirigami.FormData.label: i18n("List icons size:") // qmllint disable unqualified
            QQC.ComboBox {
                id: listIconSize
                model: Global.iconSizes
            }
            QQC.Label {
                text: i18n("px") // qmllint disable unqualified
            }
        }

        KCMNote {
            text: i18nc("@info:userIconSize", "The size of the user avatar located in the launcher header.") // qmllint disable unqualified
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Favorites layout:") // qmllint disable unqualified
            QQC.RadioButton {
                id: favoritesLayoutGrid
                text: i18n("Grid") // qmllint disable unqualified
                checked: root.cfg_favoritesLayout === 0
                onToggled: root.cfg_favoritesLayout = 0
            }
            QQC.RadioButton {
                id: favoritesLayoutList
                text: i18n("List") // qmllint disable unqualified
                checked: root.cfg_favoritesLayout === 1
                onToggled: root.cfg_favoritesLayout = 1
            }
        }

        RowLayout { // appsLayout
            Kirigami.FormData.label: i18n("Applications layout:") // qmllint disable unqualified
            QQC.RadioButton {
                id: appsLayoutGrid
                text: i18n("Grid") // qmllint disable unqualified
                checked: root.cfg_appsLayout === 0
                onToggled: root.cfg_appsLayout = 0
            }
            QQC.RadioButton {
                id: appsLayoutList
                text: i18n("List") // qmllint disable unqualified
                checked: root.cfg_appsLayout === 1
                onToggled: root.cfg_appsLayout = 1
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Separator lines:") // qmllint disable unqualified
            ColumnLayout {
                RowLayout { // separatorLineWidth
                    QQC.Label {
                        text: i18n("Width:") // qmllint disable unqualified
                    }
                    QQC.SpinBox {
                        id: separatorLineWidth
                        from: 0
                        to: 10
                        editable: false
                        // TODO get min and max from main.xml
                    }
                    QQC.Label {
                        text: i18n("px") // qmllint disable unqualified
                    }
                }
                RowLayout { // separatorLineColor
                    QQC.Label {
                        text: i18n("Color:") // qmllint disable unqualified
                    }
                    KQC.ColorButton {
                        id: separatorLineColor
                        dialogTitle: i18n("Separator lines color") // qmllint disable unqualified
                        color: root.cfg_separatorLineColorDefault
                        showAlphaChannel: true
                        onAccepted: root.separatorLineColor = color
                    }
                }
            }
            KSvg.FrameSvgItem {
                imagePath: "widgets/background"
                readonly property int blurWidth: 7
                implicitHeight: Kirigami.Units.gridUnit * 4
                implicitWidth: Kirigami.Units.gridUnit * 4
                //Layout.fillHeight: true
                //Layout.minimumWidth: parent.height * 2 + blurWidth * 3
                //Layout.topMargin: blurWidth * -1
                //Layout.bottomMargin: - parent.height * 1 - blurWidth * 2
                Rectangle {
                    color: root.cfg_separatorLineColor
                    implicitWidth: root.cfg_separatorLineWidth
                    implicitHeight: parent.height - 20
                    anchors.centerIn: parent
                }
            }
        }
    }
}
