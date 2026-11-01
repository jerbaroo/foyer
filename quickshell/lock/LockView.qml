pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import FoyerConfig 1.0

Rectangle {
    id: root

    required property Authentication authentication
    property bool capsLock: false

    color: Config.background
    focus: true

    Keys.onEnterPressed: authentication.start()
    Keys.onReturnPressed: authentication.start()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Timer {
        id: errorFeedback

        interval: Config.lockScreen.errorDurationMs
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

        function onFailed(): void {
            if (errorFeedback.interval > 0)
                errorFeedback.restart();
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
                border.color: errorFeedback.running ? Config.lockScreen.errorColor : root.capsLock ? Config.lockScreen.capsLockColor : Config.accent
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
