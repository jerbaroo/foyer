import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property string layerNamespace

    WlrLayershell.namespace: root.layerNamespace
    anchors {
        bottom: true
        left: true
        right: true
        top: true
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: true
}
