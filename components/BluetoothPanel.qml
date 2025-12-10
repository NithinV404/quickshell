import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../services"

Item {
    id: root

    required property var colorScheme
    property var fontFamily: "Adwaita Sans"

    implicitHeight: btColumn.implicitHeight

    property bool expanded: false

    ColumnLayout {
        id: btColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        // Bluetooth header with toggle
        RowLayout {
            Layout.fillWidth: true

            Image {
                source: "file:///usr/share/icons/Papirus/24x24/panel/bluetooth-active.svg"
                sourceSize: Qt.size(20, 20)
            }

            Text {
                text: "Bluetooth"
                color: root.colorScheme.getColor("on_surface")
                font {
                    pixelSize: 14
                    weight: Font.Medium
                    family: root.fontFamily
                }
            }

            Item {
                Layout.fillWidth: true
            }

            // Toggle switch
            Rectangle {
                width: 44
                height: 24
                radius: 12
                color: SystemService.btPowered ? root.colorScheme.getColor("primary") : root.colorScheme.getColor("surface_container_high")

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    anchors.verticalCenter: parent.verticalCenter
                    x: SystemService.btPowered ? parent.width - width - 2 : 2
                    color: root.colorScheme.getColor("on_primary")

                    Behavior on x {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: SystemService.toggleBluetooth()
                }
            }
        }

        // Status / Expand button
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: root.colorScheme.getColor("surface_container_high")
            visible: SystemService.btPowered

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 8
                spacing: 8

                Column {
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: {
                            var connected = SystemService.btDevices.filter(d => d.connected);
                            if (connected.length > 0)
                                return connected[0].name;
                            return "No device connected";
                        }
                        color: root.colorScheme.getColor("on_surface")
                        font {
                            pixelSize: 12
                            weight: Font.Medium
                            family: root.fontFamily
                        }
                    }
                    Text {
                        text: SystemService.btDevices.length + " paired device(s)"
                        color: root.colorScheme.getColor("on_surface_variant")
                        font.pixelSize: 10
                        font.family: root.fontFamily
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Image {
                    source: expanded ? "file:///usr/share/icons/Papirus/16x16/actions/go-up.svg" : "file:///usr/share/icons/Papirus/16x16/actions/go-down.svg"
                    sourceSize: Qt.size(16, 16)
                    Layout.alignment: Qt.AlignVCenter
                    width: 16
                    height: 16

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: root.colorScheme.getColor("primary")
                        brightness: 0.5
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: expanded = !expanded
            }
        }

        // Paired devices list
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: deviceList.implicitHeight + 16
            radius: 8
            color: root.colorScheme.getColor("surface_container_low")
            visible: expanded && SystemService.btPowered
            clip: true

            ColumnLayout {
                id: deviceList
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 8
                spacing: 4

                Repeater {
                    model: SystemService.btDevices

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 6
                        color: deviceMouse.containsMouse ? root.colorScheme.getColor("surface_container") : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            Text {
                                text: modelData.name
                                color: root.colorScheme.getColor("on_surface")
                                font.pixelSize: 12
                                font.family: root.fontFamily
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            // Connected indicator
                            Text {
                                text: modelData.connected ? "Connected" : "Tap to connect"
                                color: modelData.connected ? root.colorScheme.getColor("primary") : root.colorScheme.getColor("on_surface_variant")
                                font.pixelSize: 10
                                font.family: root.fontFamily
                            }
                        }

                        MouseArea {
                            id: deviceMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (modelData.connected)
                                    SystemService.disconnectBluetooth(modelData.mac);
                                else
                                    SystemService.connectBluetooth(modelData.mac);
                            }
                        }
                    }
                }

                // Scan button
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 6
                    color: scanMouse.containsMouse ? root.colorScheme.getColor("surface_container") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: SystemService.btScanning ? "Scanning..." : "↻ Scan for devices"
                        color: root.colorScheme.getColor("primary")
                        font {
                            pixelSize: 12
                            weight: Font.Medium
                            family: root.fontFamily
                        }
                    }

                    MouseArea {
                        id: scanMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (!SystemService.btScanning)
                                SystemService.scanBluetooth();
                        }
                    }
                }
            }
        }
    }
}
