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

import org.kde.config as KConfig
import org.kde.kcmutils as KCMU
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid // qmllint disable import

import "../Helper"

KCM {
    id: root

    property alias        cfg_isAlphaSorted: isAlphaSorted.checked
    property alias        cfg_isUpdateOnHover: isUpdateOnHover.checked
    property alias        cfg_appNameFormat: appNameFormat.currentIndex
    property alias        cfg_startWith: startWith.currentIndex
    property alias        cfg_isPowerVisible: isPowerVisible.checked
    property alias        cfg_isSessionVisible: isSessionVisible.checked
    property alias        cfg_hasToolbarCaptions: hasToolbarCaptions.checked

    function visibleActions() {
        return (root.cfg_isPowerVisible ? root.cfg_powerActionsDefault : [])
            .concat(root.cfg_isSessionVisible ? root.cfg_sessionActionsDefault : [])
    }

    Kirigami.FormLayout {
        QQC.CheckBox { // isAlphaSorted
            id: isAlphaSorted
            text: Global.i18nContext.i18n("Always sort applications alphabetically")
        }

        QQC.CheckBox { // isNewHighlighted
            id: isNewHighlighted
            enabled: false
            text: Global.i18nContext.i18n("Highlight new apps")
        }

        RowLayout {
            QQC.CheckBox { // isUpdateOnHover
                id: isUpdateOnHover
                text: Global.i18nContext.i18n("Update main panel when hovering over sidebar categories")
            }
        }

        KCMNote {
            text: Global.i18nContext.i18nc("@info:isUpdateOnHover", "If unchecked, the apps in the main panel will be updated when clicking (instead of hovering) on a sidebar category.")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC.Button { // Configure Search Plugins
            enabled: KConfig.KAuthorized.authorizeControlModule("kcm_plasmasearch")
            icon.name: "settings-configure"
            text: Global.i18nContext.i18nc("@action:button opens plasmasearch kcm", "Configure Search Plugins…")
            onClicked: KCMU.KCMLauncher.openSystemSettings("kcm_plasmasearch")
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC.ComboBox { // startWith
            Kirigami.FormData.label: Global.i18nContext.i18n("Open launcher in:")
            id: startWith
            model: Global.categories
        }

        KCMNote {
            text: Global.i18nContext.i18nc("@info:startWith", "Select what is visible when opened.")
        }

        QQC.ComboBox { // appNameFormat
            Kirigami.FormData.label: Global.i18nContext.i18n("Show applications as:")
            id: appNameFormat
            model: [
                Global.i18nContext.i18n("Name only"),
                Global.i18nContext.i18n("Description only"),
                Global.i18nContext.i18n("Name (Description)"),
                Global.i18nContext.i18n("Description (Name)")
            ]
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout { // Show buttons for Power/Session
            Kirigami.FormData.label: Global.i18nContext.i18n("Show buttons for:")
            QQC.CheckBox {
                id: isPowerVisible
                text: Global.i18nContext.i18n("Power actions")
                onToggled: root.visibleActions()
            }
            QQC.CheckBox {
                id: isSessionVisible
                text: Global.i18nContext.i18n("Session actions")
                onToggled: root.visibleActions()
            }
        }

        KCMNote {
            text: Global.i18nContext.i18nc("@info:isPowerVisible,isSessionVisible", "If unchecked or not enough space, buttons will move to the 'Power/Session' menu.")
        }

        QQC.CheckBox { // hasToolbarCaptions
            id: hasToolbarCaptions
            text: Global.i18nContext.i18n("Show button captions in the Power/Session toolbar")
        }

        KCMSeparator {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            QQC.Button { // Reset configuration
                id: configReset
                text: Global.i18nContext.i18n("Reset configuration")
                onClicked: {
                    root.restoreDefaults()
                    configResetWarning.visible = true
                }
            }

            RowLayout {
                id: configResetWarning
                visible: false
                Kirigami.Icon {
                    source: 'dialog-warning'
                }
                QQC.Label {
                    text: Global.i18nContext.i18n("Clicking 'OK' will reset the settings.")
                    font.bold: true
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
