/*
    SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu@tenita.eu>

    SPDX-License-Identifier: GPL-2.0-or-later

    TODO: remove implicit categories (shortcuts and about) or - at least - change their icons (needs C++ plugin)
*/

import QtQuick
import org.kde.plasma.configuration // qmllint disable import

// qmllint disable missing-property import unqualified
ConfigModel {
    id: kcmRoot
    ConfigCategory {
        id: kcmBehavior
        name: i18n("Behavior")
        icon: "preferences-desktop" // plasma preferences-advanced preferences-desktop preferences-desktop-plasma preferences-desktop-symbolic
        source: "Config/KCMBehavior.qml"
    }
    ConfigCategory {
        id: kcmAppearance
        name: i18n("Appearance")
        icon: "preferences-desktop-color" // preferences-desktop-color preferences-desktop-display-color preferences-desktop-appearance-symbolic preferences-theme
        source: "Config/KCMAppearance.qml"
    }
    //ConfigCategory {
    //    id: kcmShortcuts
    //    name: i18n("Keyboard Shortcuts")
    //    icon: "preferences-desktop-keyboard-symbolic" // preferences-desktop-keyboard-rtl cs-keyboard
    //    source: "Config/KCMShortcuts.qml"
    //}
    //ConfigCategory {
    //    id: kcmAbout
    //    name: i18n("About")
    //    icon: "info-symbolic"
    //    source: "Config/KCMAbout.qml"
    //}
// qmllint enable
}
