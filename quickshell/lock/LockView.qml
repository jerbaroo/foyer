pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import FoyerConfig 1.0

Rectangle {
    id: root

    required property Authentication authentication

    color: Config.background
    focus: true

    Keys.onEnterPressed: authentication.start()
    Keys.onReturnPressed: authentication.start()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Connections {
        target: root.authentication

        function onActiveChanged(): void {
            if (!root.authentication.active)
                root.forceActiveFocus();
        }

        function onClearInput(): void {
            response.clear();
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: Config.spacing.medium
        width: Math.min(360, Math.max(0, root.width - 2 * Config.spacing.large))

        Text {
            color: Config.text
            font.family: Config.font.family
            font.pixelSize: Config.shellFontSize * 3
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            width: parent.width
        }

        Text {
            color: Config.textMuted
            font.family: Config.font.family
            font.pixelSize: Config.font.pixelSize.small
            horizontalAlignment: Text.AlignHCenter
            text: Quickshell.env("USER")
            width: parent.width
        }

        TextField {
            id: response

            background: Rectangle {
                border.color: response.activeFocus ? Config.accent : Config.controlBorder
                border.width: 1
                color: Config.fieldBackground
                radius: Config.rounding
            }
            color: Config.text
            echoMode: root.authentication.responseVisible ? TextInput.Normal : TextInput.Password
            enabled: root.authentication.responseRequired
            focus: true
            font.family: Config.font.family
            font.pixelSize: Config.font.pixelSize.small
            inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
            padding: Config.spacing.medium
            placeholderText: "Password"
            placeholderTextColor: Config.textMuted
            selectByMouse: false
            width: parent.width

            onAccepted: root.authentication.respond(text)
            onEnabledChanged: {
                if (enabled)
                    forceActiveFocus();
            }
            Keys.onEscapePressed: clear()
        }

    }
}
