/*
 * SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu@tenita.eu>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 *
 * HACK: disabled useless warnings from qmllint for stuff related to:
 *     - i18n*()
*/

import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    id: kcmRoot
    ConfigCategory {
        id: kcmBehavior
        name: i18n("Behavior") // qmllint disable unqualified
        icon: "preferences-desktop" // plasma preferences-advanced preferences-desktop preferences-desktop-plasma preferences-desktop-symbolic
        source: "Config/KCMBehavior.qml"
    }
    ConfigCategory {
        id: kcmAppearance
        name: i18n("Appearance") // qmllint disable unqualified
        icon: "preferences-desktop-color" // preferences-desktop-color preferences-desktop-display-color preferences-desktop-appearance-symbolic preferences-theme
        source: "Config/KCMAppearance.qml"
    }
    //ConfigCategory {
    //    id: kcmShortcuts
    //    name: i18n("Keyboard Shortcuts") // qmllint disable unqualified
    //    icon: "preferences-desktop-keyboard-symbolic" // preferences-desktop-keyboard-rtl cs-keyboard
    //    source: "Config/KCMShortcuts.qml"
    //}
    //ConfigCategory {
    //    id: kcmAbout
    //    name: i18n("About") // qmllint disable unqualified
    //    icon: "info-symbolic"
    //    source: "Config/KCMAbout.qml"
    //}
}
