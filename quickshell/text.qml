//@ pragma Env QT_QUICK_BACKEND=software

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

import FoyerConfig 1.0
import qs.common

Scope {
    id: root

    property string content: ""
    property bool shown: false

    FileView {
        id: source
    }

    IpcHandler {
        target: "text"

        function setShown(path: string): void {
            source.path = path;
            source.waitForJob();
            if (source.loaded) {
                root.content = source.text();
                root.shown = true;
            }
            source.path = "";
        }

        function setHidden(): void {
            root.shown = false;
        }
    }

    OverlayWindow {
        id: window

        layerNamespace: Config.layers.text
        visible: root.shown

        Shortcut {
            onActivated: root.shown = false
            sequence: "Escape"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.shown = false
        }

        PanelSurface {
            anchors.centerIn: parent
            height: Math.min(960, window.height * 0.8)
            width: Math.min(1200, window.width * 0.8)

            MouseArea {
                anchors.fill: parent
            }

            ScrollView {
                anchors.fill: parent
                anchors.margins: Config.spacing.medium
                clip: true

                TextArea {
                    background: null
                    color: Config.text
                    focus: true
                    font.family: Config.font.family
                    font.pixelSize: Config.font.pixelSize.small
                    readOnly: true
                    selectByMouse: true
                    text: root.content
                    textFormat: TextEdit.PlainText
                    wrapMode: TextEdit.NoWrap
                }
            }
        }
    }
}
