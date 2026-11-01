pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    readonly property bool active: pam.active
    property string error: ""
    readonly property string message: pam.message
    readonly property bool messageIsError: pam.messageIsError
    readonly property bool responseRequired: pam.responseRequired
    readonly property bool responseVisible: pam.responseVisible

    signal clearInput
    signal unlocked

    function respond(response: string): void {
        if (!pam.responseRequired)
            return;
        error = "";
        clearInput();
        pam.respond(response);
    }

    function start(): void {
        if (pam.active)
            return;
        error = "";
        if (!pam.start())
            error = "Authentication unavailable. Try again.";
    }

    PamContext {
        id: pam

        config: "login"

        onCompleted: result => {
            root.clearInput();
            if (result === PamResult.Success) {
                root.unlocked();
            } else if (result === PamResult.Failed) {
                root.error = "Authentication failed. Try again.";
                Qt.callLater(pam.start);
            } else {
                root.error = "Authentication unavailable. Try again.";
            }
        }
    }
}
