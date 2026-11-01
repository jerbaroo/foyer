pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool capsLock: false

    Timer {
        interval: 250
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: poll.running = true
    }

    Process {
        id: poll

        command: ["hyprctl", "-j", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim())
                    return;
                const keyboards = JSON.parse(text).keyboards;
                root.capsLock = keyboards.find(keyboard => keyboard.main)?.capsLock ?? false;
            }
        }
    }
}
