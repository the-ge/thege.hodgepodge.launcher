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
 *     - org.kde.plasma.plasmoid
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
import org.kde.plasma.plasmoid // qmllint disable import

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
            Kirigami.FormData.label: Global.i18nContext.i18n("Sidebar position:")
            QQC.RadioButton {
                id: isPaneOrderReversedOff
                text: Global.i18nContext.i18n("Left")
                checked: root.cfg_isPaneOrderReversed === false
            }
            QQC.RadioButton {
                id: isPaneOrderReversedOn
                text: Global.i18nContext.i18n("Right")
                checked: root.cfg_isPaneOrderReversed === true
            }
        }

        RowLayout { // isListCompact
            //Layout.columnSpan: 2
            Kirigami.FormData.label: Global.i18nContext.i18n("List style:")
            QQC.RadioButton {
                id: isListNormal
                text: Global.i18nContext.i18n("Normal")
                checked: !root.cfg_isListCompact
                enabled: !Kirigami.Settings.tabletMode
                onToggled: root.cfg_isListCompact = false
            }
            QQC.RadioButton {
                id: isListCompact
                text: Global.i18nContext.i18n("Compact")
                checked: root.cfg_isListCompact
                enabled: !Kirigami.Settings.tabletMode
                onToggled: root.cfg_isListCompact = true
            }
            KCMNote {
                text: Global.i18nContext.i18nc("@info:usagetip under a checkbox when Touch Mode is on", "Disabled in Touch Mode")
                visible: Kirigami.Settings.tabletMode
            }
        }

        KCMNote {
            text: Global.i18nContext.i18nc("@info:isListCompact", "Normal: two rows, compact: one row.")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC.Button { // launcherIcon
            Kirigami.FormData.label: Global.i18nContext.i18n("Launcher icon:")
            id: launcherIcon
            implicitWidth: previewFrame.width
            implicitHeight: previewFrame.height
            hoverEnabled: true
            Accessible.name: Global.i18nContext.i18nc("@action:button", "Change Application Launcher's icon")
            Accessible.description: Global.i18nContext.i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", root.cfg_launcherIcon)
            Accessible.role: Accessible.ButtonMenu
            QQC.ToolTip.delay: Kirigami.Units.toolTipDelay
            QQC.ToolTip.text: Global.i18nContext.i18nc("@info:tooltip", "Icon name is \"%1\"", root.cfg_launcherIcon)
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
                imagePath: Plasmoid.formFactor === PCore.Types.Vertical || Plasmoid.formFactor === PCore.Types.Horizontal // qmllint disable unqualified
                    ? "widgets/panel-background"
                    : "widgets/background"
                width: Kirigami.Units.iconSizes.large + fixedMargins.left + fixedMargins.right
                height: Kirigami.Units.iconSizes.large + fixedMargins.top + fixedMargins.bottom
                Kirigami.Icon {
                    anchors.centerIn: parent
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: Tools.iconOrDefault(Plasmoid.formFactor, root.cfg_launcherIcon) // qmllint disable unqualified
                }
            }

            QQC.Menu {
                id: iconMenu

                // Appear below the button
                y: parent.height

                QQC.MenuItem {
                    text: Global.i18nContext.i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
                    icon.name: "document-open-folder"
                    Accessible.description: Global.i18nContext.i18nc("@info:whatsthis", "Choose an icon for Application Launcher")
                    onClicked: iconDialog.open()
                }
                QQC.MenuItem {
                    text: Global.i18nContext.i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
                    icon.name: "edit-clear"
                    enabled: root.cfg_launcherIcon !== Tools.defaultIconName
                    onClicked: root.cfg_launcherIcon = Tools.defaultIconName
                }
                QQC.MenuItem {
                    text: Global.i18nContext.i18nc("@action:inmenu", "Remove icon")
                    icon.name: "delete"
                    enabled: root.cfg_launcherIcon !== "" && launcherIconText.text && Plasmoid.formFactor !== PCore.Types.Vertical // qmllint disable unqualified
                    onClicked: root.cfg_launcherIcon = ""
                }
            }

            onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()
        }

        Kirigami.ActionTextField { // launcherIconText
            id: launcherIconText
            enabled: Plasmoid.formFactor !== PCore.Types.Vertical // qmllint disable unqualified
            Kirigami.FormData.label: Global.i18nContext.i18nc("@label:textbox", "Launcher icon text:")
            text: root.cfg_launcherIconTextDefault
            placeholderText: Global.i18nContext.i18nc("@info:placeholder", "Type here to add a text label next to the launcher icon...")
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
                text: Global.i18nContext.i18nc("@action:button", "Reset menu label")
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
            visible: Plasmoid.formFactor === PCore.Types.Vertical // qmllint disable unqualified
            text: Global.i18nContext.i18nc("@info", "A text label cannot be set when the Panel is vertical.")
            wrapMode: Text.Wrap
            font: Kirigami.Theme.smallFont
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout { // userIconSize
            Kirigami.FormData.label: Global.i18nContext.i18n("User icon size:")
            QQC.ComboBox {
                id: userIconSize
                model: Global.iconSizes
            }
            QQC.Label {
                text: Global.i18nContext.i18n("px")
            }
        }

        RowLayout { // gridIconSize
            Kirigami.FormData.label: Global.i18nContext.i18n("Grid icons size:")
            QQC.ComboBox {
                id: gridIconSize
                model: Global.iconSizes
            }
            QQC.Label {
                text: Global.i18nContext.i18n("px")
            }
        }

        RowLayout { // listIconSize
            Kirigami.FormData.label: Global.i18nContext.i18n("List icons size:")
            QQC.ComboBox {
                id: listIconSize
                model: Global.iconSizes
            }
            QQC.Label {
                text: Global.i18nContext.i18n("px")
            }
        }

        KCMNote {
            text: Global.i18nContext.i18nc("@info:userIconSize", "The size of the header user icon.")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: Global.i18nContext.i18n("Favorites layout:")
            QQC.RadioButton {
                id: favoritesLayoutGrid
                text: Global.i18nContext.i18n("Grid")
                checked: root.cfg_favoritesLayout === 0
                onToggled: root.cfg_favoritesLayout = 0
            }
            QQC.RadioButton {
                id: favoritesLayoutList
                text: Global.i18nContext.i18n("List")
                checked: root.cfg_favoritesLayout === 1
                onToggled: root.cfg_favoritesLayout = 1
            }
        }

        RowLayout { // appsLayout
            Kirigami.FormData.label: Global.i18nContext.i18n("Applications layout:")
            QQC.RadioButton {
                id: appsLayoutGrid
                text: Global.i18nContext.i18n("Grid")
                checked: root.cfg_appsLayout === 0
                onToggled: root.cfg_appsLayout = 0
            }
            QQC.RadioButton {
                id: appsLayoutList
                text: Global.i18nContext.i18n("List")
                checked: root.cfg_appsLayout === 1
                onToggled: root.cfg_appsLayout = 1
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout { // separatorLineWidth
            Kirigami.FormData.label: Global.i18nContext.i18n("Separator lines width:")
            QQC.SpinBox {
                id: separatorLineWidth
                from: 0
                to: 10
                editable: false
                // TODO get min and max from main.xml
            }
            QQC.Label {
                text: Global.i18nContext.i18n("px")
            }
            KSvg.FrameSvgItem {
                imagePath: "widgets/background"
                readonly property int blurWidth: 7
                Layout.fillHeight: true
                Layout.minimumWidth: parent.height * 2 + blurWidth * 3
                Layout.topMargin: blurWidth * -1
                Layout.bottomMargin: - parent.height * 1 - blurWidth * 2
                Rectangle {
                    color: root.cfg_separatorLineColor
                    implicitWidth: root.cfg_separatorLineWidth
                    implicitHeight: parent.height - 20
                    anchors.centerIn: parent
                }
            }
        }

        RowLayout { // separatorLineColor
            Kirigami.FormData.label: Global.i18nContext.i18n("Separator lines color:")
            KQC.ColorButton {
                id: separatorLineColor
                dialogTitle: Global.i18nContext.i18n("Separator lines color")
                color: root.cfg_separatorLineColorDefault
                showAlphaChannel: true
                onAccepted: root.separatorLineColor = color
            }
        }

    }
}
