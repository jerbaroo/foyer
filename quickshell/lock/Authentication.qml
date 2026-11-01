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
    property bool responsePending: false
    readonly property bool responseRequired: pam.active && pam.responseRequired && !responsePending
    readonly property bool responseVisible: pam.responseVisible

    signal clearInput
    signal failed
    signal unlocked

    function fail(message: string): void {
        error = message;
        failed();
    }

    function respond(response: string): void {
        if (!responseRequired)
            return;
        responsePending = true;
        error = "";
        clearInput();
        pam.respond(response);
    }

    function start(): void {
        if (pam.active)
            return;
        error = "";
        if (!pam.start())
            fail("Authentication unavailable. Try again.");
    }

    PamContext {
        id: pam

        config: "login"

        onPamMessage: {
            if (pam.responseRequired)
                root.responsePending = false;
        }

        onCompleted: result => {
            root.clearInput();
            if (result === PamResult.Success) {
                root.unlocked();
            } else if (result === PamResult.Failed) {
                root.fail("Authentication failed. Try again.");
                Qt.callLater(pam.start);
            } else {
                root.fail("Authentication unavailable. Try again.");
            }
        }
    }
}
