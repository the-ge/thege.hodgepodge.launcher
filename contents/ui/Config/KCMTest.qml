/*
    SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC
import org.kde.kirigami as Kirigami

KCM {
    id: root

    Kirigami.FormLayout {

        QQC.Label {
            text: root.objectName + ': ' + root.icon
        }

    }
}
