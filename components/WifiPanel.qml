import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../services"

Item {
    id: root

    required property var colorScheme
    property var fontFamily: "Adwaita Sans"
    implicitHeight: wifiColumn.implicitHeight

    property bool expanded: false
    property string connectingSsid: ""
    property bool showPasswordDialog: false
    property string passwordSsid: ""

    ColumnLayout {
        id: wifiColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 8

        // WiFi header with toggle
        RowLayout {
            Layout.fillWidth: true

            Image {
                source: "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-100.svg"
                sourceSize: Qt.size(20, 20)
            }

            Text {
                text: "WiFi"
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
                color: SystemService.wifiEnabled ? root.colorScheme.getColor("primary") : root.colorScheme.getColor("surface_container_high")

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    anchors.verticalCenter: parent.verticalCenter
                    x: SystemService.wifiEnabled ? parent.width - width - 2 : 2
                    color: root.colorScheme.getColor("on_primary")

                    Behavior on x {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: SystemService.toggleWifi()
                }
            }
        }

        // Current connection
        Rectangle {
            Layout.fillWidth: true
            height: 40
            radius: 8
            color: root.colorScheme.getColor("surface_container_high")
            visible: SystemService.wifiEnabled

            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 8
                spacing: 8

                Column {
                    Text {
                        text: SystemService.wifiConnected ? SystemService.wifiSsid : "Not connected"
                        color: root.colorScheme.getColor("on_surface")
                        font {
                            pixelSize: 12
                            weight: Font.Medium
                            family: "Adwaita Sans"
                        }
                    }
                    Text {
                        text: SystemService.wifiConnected ? `Signal: ${SystemService.wifiStrength}%` : "Select device to connect"
                        color: root.colorScheme.getColor("on_surface_variant")
                        font.pixelSize: 10
                        font.family: root.fontFamily
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Item {
                    implicitWidth: 16
                    implicitHeight: 16
                    Layout.alignment: Qt.AlignVCenter

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
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    expanded = !expanded;
                    if (expanded)
                        SystemService.scanWifi();
                }
            }
        }

        // Available networks list
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: networkList.implicitHeight + 16
            radius: 8
            color: root.colorScheme.getColor("surface_container_low")
            visible: expanded && SystemService.wifiEnabled
            clip: true

            ColumnLayout {
                id: networkList
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 8
                spacing: 4

                Repeater {
                    model: SystemService.wifiNetworks

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 6
                        color: networkMouse.containsMouse ? root.colorScheme.getColor("surface_container") : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8

                            // Signal icon
                            Item {
                                implicitHeight: 20
                                implicitWidth: 20
                                // Lock icon for secured networks
                                Image {
                                    source: {
                                        var base = "file:///usr/share/icons/Papirus/24x24/panel/";
                                        if (modelData.signal > 75)
                                            return base + "network-wireless-100.svg";
                                        if (modelData.signal > 50)
                                            return base + "network-wireless-60.svg";
                                        if (modelData.signal > 25)
                                            return base + "network-wireless-20.svg";
                                        return base + "network-wireless-0.svg";
                                    }
                                    sourceSize: Qt.size(20, 20)
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        colorization: 1.0
                                        colorizationColor: root.colorScheme.getColor("primary")
                                        brightness: 1.0
                                    }
                                }
                            }

                            Text {
                                text: modelData.ssid
                                color: root.colorScheme.getColor("on_surface")
                                font.pixelSize: 12
                                font.family: root.fontFamily
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Item {
                                implicitHeight: 12
                                implicitWidth: 12
                                // Lock icon for secured networks
                                Image {
                                    source: modelData.security !== "" && modelData.security !== "Open" ? "file:///usr/share/icons/Papirus/16x16/actions/lock.svg" : ""
                                    sourceSize: Qt.size(12, 12)
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        colorization: 1.0
                                        colorizationColor: root.colorScheme.getColor("primary")
                                        brightness: 1.0
                                    }
                                }
                            }

                            // Connected indicator
                            Text {
                                text: modelData.active ? "✓" : ""
                                color: root.colorScheme.getColor("primary")
                                font {
                                    pixelSize: 12
                                    weight: Font.Bold
                                }
                            }
                        }

                        MouseArea {
                            id: networkMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (!modelData.active) {
                                    // For simplicity, try connecting without password first
                                    // A proper implementation would check if password is needed
                                    SystemService.connectWifi(modelData.ssid, "");
                                }
                            }
                        }
                    }
                }

                // Refresh button
                Rectangle {
                    Layout.fillWidth: true
                    height: 32
                    radius: 6
                    color: refreshMouse.containsMouse ? root.colorScheme.getColor("surface_container") : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "↻ Refresh"
                        color: root.colorScheme.getColor("primary")
                        font {
                            pixelSize: 12
                            weight: Font.Medium
                        }
                    }

                    MouseArea {
                        id: refreshMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: SystemService.scanWifi()
                    }
                }
            }
        }
    }
}
