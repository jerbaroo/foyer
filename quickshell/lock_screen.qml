pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pam
import Quickshell.Wayland

Scope {
    PamContext {
        id: pam
        active: true

        onCompleted: result => {
            if (result === PamResult.Success) {
                lock.locked = false;
                Qt.quit();
            } else if (result !== PamResult.Error) {
                Qt.callLater(pam.start);
            }
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            color: "black"

            TextField {
                anchors.centerIn: parent
                echoMode: TextInput.Password
                enabled: pam.responseRequired
                focus: true
                placeholderText: "Password"
                width: 300

                onAccepted: {
                    pam.respond(text);
                    clear();
                }
            }
        }
    }
}
