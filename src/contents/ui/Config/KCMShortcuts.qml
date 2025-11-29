/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2025 Gabriel Tenita <g1704578400@tenita.eu>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC
import QtQuick.Layouts
import org.kde.kquickcontrols as KQC
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid // qmllint disable import

KCM {
    id: root

    title: i18nContext.i18n("Shortcuts")

    //signal configurationChanged
    //function saveConfig() {
    //    Plasmoid.globalShortcut = root.form.button.keySequence
    //}

    Kirigami.FormLayout {
        id: form

        QQC.Label {
            Layout.fillWidth: true
            text: i18nd("plasma_shell_org.kde.plasma.desktop", "This shortcut will activate the applet as though it had been clicked.")
            textFormat: Text.PlainText
            wrapMode: Text.WordWrap
        }

        KQC.KeySequenceItem {
            id: button
            keySequence: Plasmoid.globalShortcut
            onKeySequenceModified: {
                if (Plasmoid.globalShortcut !== keySequence) {
                    //root.configurationChanged();
                    Plasmoid.globalShortcut = keySequence;
                }
            }
        }
    }
}
