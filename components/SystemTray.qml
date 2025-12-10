import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import QtQuick.Effects
import "../services"

Row {
    id: root
    spacing: 8
    Layout.alignment: Qt.AlignVCenter

    required property var colorScheme
    signal openControlCenter

    Rectangle {
        color: root.colorScheme.getColor("primary_container")
        radius: 4
        implicitWidth: contentRow.implicitWidth + 8
        implicitHeight: 26

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 0

            // WiFi indicator
            Item {
                width: 24
                height: 24
                visible: SystemService.wifiEnabled

                Image {
                    anchors.fill: parent
                    source: {
                        if (!SystemService.wifiConnected)
                            return "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-disconnected.svg";
                        if (SystemService.wifiStrength > 75)
                            return "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-100.svg";
                        if (SystemService.wifiStrength > 50)
                            return "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-60.svg";
                        if (SystemService.wifiStrength > 25)
                            return "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-20.svg";
                        return "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-0.svg";
                    }
                    sourceSize: Qt.size(20, 20)
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: root.colorScheme.getColor("on_tertiary_container")
                        brightness: 1.0
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.openControlCenter()
                    onEntered: TooltipService.show(SystemService.wifiConnected ? `${SystemService.wifiSsid} (${SystemService.wifiStrength}%)` : "No WiFi", parent.mapToItem(null, parent.width / 2, 0).x)
                    onExited: TooltipService.hide()
                }
            }
            // Bluetooth indicator
            Item {
                width: 24
                height: 24
                visible: SystemService.btPowered

                Image {
                    anchors.fill: parent
                    source: {
                        var hasConnected = SystemService.btDevices.some(d => d.connected);
                        if (hasConnected)
                            return "file:///usr/share/icons/Papirus/24x24/panel/bluetooth-paired.svg";
                        return "file:///usr/share/icons/Papirus/24x24/panel/bluetooth-active.svg";
                    }
                    sourceSize: Qt.size(24, 24)
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: root.colorScheme.getColor("on_tertiary_container")
                        brightness: 0.1
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.openControlCenter()
                    onEntered: {
                        var connected = SystemService.btDevices.filter(d => d.connected);
                        var text = connected.length > 0 ? connected[0].name : "Bluetooth On";
                        TooltipService.show(text, parent.mapToItem(null, parent.width / 2, 0).x);
                    }
                    onExited: TooltipService.hide()
                }
            }

            // Ethernet indicator
            Item {
                width: 24
                height: 24

                Image {
                    anchors.fill: parent
                    source: SystemService.wiredConnected ? "file:///usr/share/icons/Papirus/24x24/panel/network-wired-activated.svg" : "file:///usr/share/icons/Papirus/24x24/panel/network-wired-disconnected.svg"
                    sourceSize: Qt.size(24, 24)
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: root.colorScheme.getColor("on_tertiary_container")
                        brightness: 0.1
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.openControlCenter()
                    onEntered: TooltipService.show(SystemService.wiredConnected ? `Ethernet (${SystemService.wiredDevice})` : "Ethernet Disconnected", parent.mapToItem(null, parent.width / 2, 0).x)
                    onExited: TooltipService.hide()
                }
            }

            // Battery
            Item {
                width: 24
                height: 24
                visible: UPower.onBattery

                property int level: Math.round(UPower.displayDevice.percentage * 100)

                Image {
                    anchors.fill: parent
                    source: {
                        const base = "file:///usr/share/icons/Papirus/24x24/panel/";
                        if (parent.level > 90)
                            return base + "battery-full.svg";
                        if (parent.level > 60)
                            return base + "battery-good.svg";
                        if (parent.level > 30)
                            return base + "battery-low.svg";
                        if (parent.level > 10)
                            return base + "battery-caution.svg";
                        return base + "battery-empty.svg";
                    }
                    sourceSize: Qt.size(24, 24)
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1.0
                        colorizationColor: root.colorScheme.getColor("on_tertiary_container")
                        brightness: 1.0
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.openControlCenter()
                    onEntered: TooltipService.show(`Battery: ${parent.level}%`, parent.mapToItem(null, parent.width / 2, 0).x)
                    onExited: TooltipService.hide()
                }
            }
        }
    }
}
