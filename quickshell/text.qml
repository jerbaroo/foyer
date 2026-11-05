//@ pragma Env QT_QUICK_BACKEND=software

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io

import FoyerConfig 1.0
import qs.common

Scope {
    FileView {
        id: source

        path: Quickshell.env("FOYER_TEXT_FILE")
        onLoadFailed: Qt.exit(1)
    }

    OverlayWindow {
        id: window

        layerNamespace: Config.layers.text

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
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
                    text: source.text()
                    textFormat: TextEdit.PlainText
                    wrapMode: TextEdit.NoWrap

                    Keys.onEscapePressed: Qt.quit()
                }
            }
        }
    }
}
