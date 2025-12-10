import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import "../services"

Row {
    id: root
    spacing: 8
    Layout.alignment: Qt.AlignVCenter

    required property var colorScheme

    Rectangle {
        color: root.colorScheme.getColor("primary_container")
        radius: 4
        implicitWidth: contentRow.implicitWidth + 12
        implicitHeight: 26

        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 8

            // WiFi indicator
            Item {
                width: NetworkService.wifiEnabled ? 24 : 0
                height: 24
                visible: NetworkService.wifiEnabled

                Image {
                    anchors.fill: parent
                    source: {
                        if (!NetworkService.connected)
                            return "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-disconnected.svg";
                        if (NetworkService.strength > 75)
                            return "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-100.svg";
                        if (NetworkService.strength > 50)
                            return "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-60.svg";
                        if (NetworkService.strength > 25)
                            return "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-20.svg";
                        return "file:///usr/share/icons/Papirus/24x24/panel/network-wireless-0.svg";
                    }
                    sourceSize: Qt.size(24, 24)
                }

                TooltipArea {
                    tooltipText: NetworkService.connected ? `${NetworkService.ssid} (${NetworkService.strength}%)` : "No WiFi"
                }
            }

            // Ethernet indicator
            Item {
                width: 20
                height: 20

                Image {
                    anchors.fill: parent
                    source: NetworkService.wiredConnected ? "file:///usr/share/icons/Papirus/24x24/panel/network-wired-activated.svg" : "file:///usr/share/icons/Papirus/24x24/panel/network-wired-disconnected.svg"
                    sourceSize: Qt.size(20, 20)
                }

                TooltipArea {
                    tooltipText: NetworkService.wiredConnected ? `Ethernet Connected (${NetworkService.wiredDevice})` : "Ethernet Disconnected"
                }
            }

            // Battery
            Item {
                width: UPower.onBattery ? 20 : 0
                height: 20
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
                    sourceSize: Qt.size(20, 20)
                }

                TooltipArea {
                    tooltipText: `Battery: ${parent.level}%`
                }
            }
        }
    }
}
