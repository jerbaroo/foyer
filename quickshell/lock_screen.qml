//@ pragma Env QT_QUICK_BACKEND=software

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import FoyerConfig 1.0
import qs.lock

Scope {
    Authentication {
        id: auth

        onUnlocked: {
            lock.locked = false;
            Qt.quit();
        }
    }

    KeyboardState {
        id: keyboard
    }

    WlSessionLock {
        id: lock
        locked: true

        onSecureChanged: {
            if (secure)
                auth.start();
        }

        WlSessionLockSurface {
            color: Config.background

            LockView {
                anchors.fill: parent
                authentication: auth
                capsLock: keyboard.capsLock
            }
        }
    }
}
