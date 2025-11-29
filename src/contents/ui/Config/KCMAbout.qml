/*
    SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
    SPDX-FileCopyrightText: 2020 David Redondo <kde@david-redondo.de>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC

import org.kde.kcmutils as KCMU
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid // qmllint disable import

KCM {
    id: root

    Kirigami.FormLayout {
        KCMU.AboutPlugin {
            id: aboutPlugin
            metaData: Plasmoid.metaData // qmllint disable unqualified
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC.Button {
            icon.name: "tools-report-bug"
            text: i18nd("plasma_shell_org.kde.plasma.desktop", "Report a Bug…")
            visible: aboutPlugin.metaData.bugReportUrl.length > 0
            onClicked: Qt.openUrlExternally(aboutPlugin.metaData.bugReportUrl)
        }
    }
}
