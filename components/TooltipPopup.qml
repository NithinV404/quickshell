import QtQuick
import Quickshell
import "../services"

// The actual tooltip popup - use this in your PanelWindow
PopupWindow {
    id: root

    required property var parentWindow
    required property var colorScheme

    anchor.window: parentWindow
    anchor.rect.x: TooltipService.anchorX - width / 2
    anchor.rect.y: parentWindow.height + 4

    visible: TooltipService.visible

    implicitWidth: tooltipText.implicitWidth + 16
    implicitHeight: tooltipText.implicitHeight + 12

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: root.colorScheme.getColor("surface_container")
        radius: 8
        border.color: root.colorScheme.getColor("outline_variant")
        border.width: 1

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: TooltipService.text
            color: root.colorScheme.getColor("on_surface")
            font {
                pixelSize: 12
                family: "Adwaita Sans"
                weight: Font.Medium
            }
        }
    }
}
