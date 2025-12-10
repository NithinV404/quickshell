import QtQuick
import QtQuick.Layouts
import Quickshell
import "../services"

PopupWindow {
    id: root

    required property var parentWindow
    required property var colorScheme

    property bool isOpen: false

    // Opacity for fade animation
    property real popupOpacity: isOpen ? 1.0 : 0.0

    height: 520

    // Slide animation from right edge
    property real targetX: isOpen ? parentWindow.width : parentWindow.width
    anchor.window: parentWindow
    anchor.rect.x: targetX
    // Anchor to bottom with margin, adjusting for fixed height
    anchor.rect.y: parentWindow.height + 8

    visible: popupOpacity > 0  // Hide only after fade-out completes

    implicitWidth: 320

    color: "transparent"

    // Animate slide and fade
    Behavior on targetX {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    Behavior on popupOpacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }

    function toggle() {
        isOpen = !isOpen;
    }

    function close() {
        isOpen = false;
    }

    Rectangle {
        anchors.fill: parent
        color: root.colorScheme.getColor("surface_container")
        radius: 16
        border.color: root.colorScheme.getColor("outline_variant")
        border.width: 1

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Control Center"
                    color: root.colorScheme.getColor("on_surface")
                    font {
                        pixelSize: 16
                        weight: Font.DemiBold
                        family: "Adwaita Sans"
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Close button
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    color: closeMouseArea.containsMouse ? root.colorScheme.getColor("surface_container_high") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: root.colorScheme.getColor("on_surface_variant")
                        font.pixelSize: 12
                    }

                    MouseArea {
                        id: closeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.close()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.colorScheme.getColor("outline_variant")
            }

            // WiFi Panel
            WifiPanel {
                Layout.fillWidth: true
                colorScheme: root.colorScheme
            }

            // Bluetooth Panel
            BluetoothPanel {
                Layout.fillWidth: true
                colorScheme: root.colorScheme
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }
}
