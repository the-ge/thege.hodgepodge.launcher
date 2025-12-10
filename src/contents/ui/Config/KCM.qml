/*
 * SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kcmutils as KCMU
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

KCMU.SimpleKCM {
    id: root

    property bool         cfg_isAlphaSortedDefault: Plasmoid.configuration.isAlphaSorted
    property bool         cfg_isNewHighlightedDefault: Plasmoid.configuration.isNewHighlighted
    property bool         cfg_isUpdateOnHoverDefault: Plasmoid.configuration.isUpdateOnHover
    property int          cfg_appNameFormatDefault: Plasmoid.configuration.appNameFormat
    property int          cfg_startWithDefault: Plasmoid.configuration.startWith
    property list<string> cfg_powerActionsDefault: Plasmoid.configuration.powerActions
    property list<string> cfg_sessionActionsDefault: Plasmoid.configuration.sessionActions
    property bool         cfg_isPowerVisibleDefault: Plasmoid.configuration.isPowerVisible
    property bool         cfg_isSessionVisibleDefault: Plasmoid.configuration.isSessionVisible
    property bool         cfg_hasToolbarCaptionsDefault: Plasmoid.configuration.hasToolbarCaptions

    property bool         cfg_isPaneOrderReversedDefault: Plasmoid.configuration.isPaneOrderReversed
    property bool         cfg_isListCompactDefault: Plasmoid.configuration.isListCompact
    property string       cfg_launcherIconDefault: Plasmoid.configuration.launcherIcon
    property string       cfg_launcherIconTextDefault: Plasmoid.configuration.launcherIconText
    property int          cfg_userIconSizeDefault: Plasmoid.configuration.userIconSize
    property int          cfg_gridIconSizeDefault: Plasmoid.configuration.gridIconSize
    property int          cfg_listIconSizeDefault: Plasmoid.configuration.listIconSize
    property int          cfg_favoritesLayoutDefault: Plasmoid.configuration.favoritesLayout
    property int          cfg_appsLayoutDefault: Plasmoid.configuration.appsLayout
    property int          cfg_separatorLineWidthDefault: Plasmoid.configuration.separatorLineWidth
    property string       cfg_separatorLineColorDefault: Plasmoid.configuration.separatorLineColor

    property bool         cfg_isAppletPinnedDefault: Plasmoid.configuration.isAppletPinned
    property bool         cfg_favoritesPortedToKAstatsDefault: Plasmoid.configuration.favoritesPortedToKAstats
    property string       cfg_systemApplicationsDefault: String(Plasmoid.configuration.systemApplications)
    property string       cfg_sidebarActionsDefault: String(Plasmoid.configuration.sidebarActions)

    property bool         cfg_isAlphaSorted: cfg_isAlphaSortedDefault
    property bool         cfg_isNewHighlighted: cfg_isNewHighlightedDefault
    property bool         cfg_isUpdateOnHover: cfg_isUpdateOnHoverDefault
    property int          cfg_appNameFormat: cfg_appNameFormatDefault
    property int          cfg_startWith: cfg_startWithDefault
    property list<string> cfg_powerActions: cfg_powerActionsDefault
    property list<string> cfg_sessionActions: cfg_sessionActionsDefault
    property bool         cfg_isPowerVisible: cfg_isPowerVisibleDefault
    property bool         cfg_isSessionVisible: cfg_isSessionVisibleDefault
    property bool         cfg_hasToolbarCaptions: cfg_hasToolbarCaptionsDefault

    property bool         cfg_isPaneOrderReversed: cfg_isPaneOrderReversedDefault
    property bool         cfg_isListCompact: cfg_isListCompactDefault
    property string       cfg_launcherIcon: cfg_launcherIconDefault
    property string       cfg_launcherIconText: cfg_launcherIconTextDefault
    property int          cfg_userIconSize: cfg_userIconSizeDefault
    property int          cfg_gridIconSize: cfg_gridIconSizeDefault
    property int          cfg_listIconSize: cfg_listIconSizeDefault
    property int          cfg_favoritesLayout: cfg_favoritesLayoutDefault
    property int          cfg_appsLayout: cfg_appsLayoutDefault
    property int          cfg_separatorLineWidth: cfg_separatorLineWidthDefault
    property string       cfg_separatorLineColor: cfg_separatorLineColorDefault

    property bool         cfg_isAppletPinned: cfg_isAppletPinnedDefault
    property bool         cfg_favoritesPortedToKAstats: cfg_favoritesPortedToKAstatsDefault
    property string       cfg_systemApplications: cfg_systemApplicationsDefault
    property string       cfg_sidebarActions: cfg_sidebarActionsDefault

    function restoreDefaults() {
        // TODO get default values from main.xml
        cfg_launcherIcon = 'start-here-kde-symbolic'
        cfg_isAlphaSorted = false
        cfg_isNewHighlighted = true
        cfg_isUpdateOnHover = false
        cfg_appNameFormat = 2
        cfg_startWith = 0
        cfg_favoritesLayout = 0
        cfg_appsLayout = 1
        cfg_powerActions = 'suspend,hibernate,reboot,shutdown'
        cfg_sessionActions = 'lock-screen,logout,save-session,switch-user'
        cfg_isPowerVisible = true
        cfg_isSessionVisible = false
        cfg_hasToolbarCaptions = true

        cfg_isPaneOrderReversed = false
        cfg_isListCompact = false
        cfg_launcherIcon = 'start-here-kde-symbolic'
        cfg_launcherIconText = ''
        cfg_userIconSize = '3'
        cfg_gridIconSize = '3'
        cfg_listIconSize = '2'
        cfg_favoritesLayout = 0
        cfg_appsLayout = 1
        cfg_favoritesLayout = 0
        cfg_appsLayout = 1
        cfg_separatorLineWidth = '1'
        cfg_separatorLineColor = '#15ffffff'

        cfg_isAppletPinned = false
        cfg_favoritesPortedToKAstats = false
        cfg_systemApplications = 'systemsettings.desktop,org.kde.kinfocenter.desktop,org.kde.discover.desktop'
        cfg_sidebarActions = 'preferred://browser,org.kde.kontact.desktop,systemsettings.desktop,org.kde.dolphin.desktop,org.kde.discover.desktop'
    }

    Kirigami.FormLayout {
        id: form
    }
}
