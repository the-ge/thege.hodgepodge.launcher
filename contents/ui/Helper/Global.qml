/* SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound
pragma Singleton // NOTE: Singletons are shared between all instances of a plasmoid

import QtQuick

import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.private.kicker as Kicker // qmllint disable unused-imports
import org.kde.private.kquickcontrols as PKQC

import "../View"

// Using Item because it has a default property.
// Trying to create a default property for a QtObject seems to cause segfaults.
Item {
    id: root
    visible: false


    //BEGIN Models and Data Sources
    readonly property P5Support.DataSource powerManagement: P5Support.DataSource {
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
        // For some reason, these signal handlers need to be here for `data` to actually contain data.
        onSourceAdded: source => {
            disconnectSource(source);
            connectSource(source);
        }
        onSourceRemoved: source => disconnectSource(source);
    }
    //END

    //BEGIN Reusable Objects
    readonly property PKQC.TranslationContext i18nContext: PKQC.TranslationContext{
        domain: "thege.hodpodge.launcher"
    }

    readonly property string favoritesLabel: i18nContext.i18n("Favorites")
    readonly property string appsLabel: i18nContext.i18n("Apps")
    readonly property string allAppsLabel: i18nContext.i18n("All Apps")
    readonly property string placesLabel: i18nContext.i18n("Places")
    property list<string> categories: [
        favoritesLabel, // index (cfg_startWith) 0
        allAppsLabel,   // index (cfg_startWith) 1
        placesLabel,    // index (cfg_startWith) 2
    ]
    readonly property int favoritesIndex: categories.indexOf(favoritesLabel)
    readonly property int allAppsIndex: categories.indexOf(allAppsLabel)
    readonly property int placesIndex: categories.indexOf(placesLabel)
    readonly property Kicker.RootModel slimModel: Kicker.RootModel {
        // qmllint disable missing-property
        autoPopulate: true
        sorted: false // leave 'Lost & Found' last
        flat: true // have categories, but no subcategories
        showSeparators: false
        showTopLevelItems: false
        showAllApps: false
        showAllAppsCategorized: false
        showRecentApps: false
        showRecentDocs: false
        showPowerSession: false
        showFavoritesPlaceholder: false
        // qmllint enable
        Component.onCompleted: {
            for (let i=0, max=rowCount(); i < max; i++) {
                categories.push(labelForRow(i)); // categories already contain 3 items
            }
        }
    }

    readonly property var iconSizes: [
        Kirigami.Units.iconSizes.small,
        Kirigami.Units.iconSizes.smallMedium,
        Kirigami.Units.iconSizes.medium,
        Kirigami.Units.iconSizes.large,
        Kirigami.Units.iconSizes.huge,
        Kirigami.Units.iconSizes.enormous
    ]

    readonly property KSvg.Svg lineSvg: KSvg.Svg {
        id: singletonLine
        imagePath: "widgets/line"
        property int heightIfHorizontal: singletonLine.elementSize("horizontal-line").height
        property int widthIfVertical: singletonLine.elementSize("vertical-line").width
    }
    //END

    //BEGIN Metrics
    readonly property KSvg.FrameSvgItem listItemMetrics: KSvg.FrameSvgItem {
        visible: false
        imagePath: "widgets/listitem"
        prefix: "normal"
    }

    readonly property FontMetrics fontMetrics: FontMetrics {
        id: fontMetrics
        font: Kirigami.Theme.defaultFont
    }

    readonly property real gridCellSpacing: gridDelegate.implicitHeight
    readonly property real compactListDelegateHeight: compactListDelegate.implicitHeight
    readonly property real compactListDelegateContentHeight: compactListDelegate.implicitContentHeight
    //END

    //BEGIN Private
    KickoffGridDelegate {
        id: gridDelegate
        visible: false
        enabled: false
        model: null
        index: -1
        text: "asdf"
        description: "asdf"
        url: ""
        decoration: "applications-featured"
        width: implicitHeight
        action: null
        indicator: null
        isMultilineText: false
    }
    KickoffListDelegate {
        id: compactListDelegate
        visible: false
        enabled: false
        compact: true
        model: null
        index: -1
        text: "asdf"
        description: "asdf"
        url: ""
        decoration: "applications-featured"
        action: null
        indicator: null
        isMultilineText: false
    }
    //END
}
