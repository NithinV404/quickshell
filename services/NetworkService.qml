pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // --- Public Properties ---
    property string ssid: "Disconnected"
    property int strength: 0
    property bool connected: ssid !== "Disconnected"
    property bool wifiEnabled: true

    property bool wiredConnected: false
    property string wiredDevice: ""
    property bool _wiredFound: false

    // --- Internals ---

    // 1. Get WiFi Info (SSID + Signal)
    property Process _wifiProc: Process {
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SIGNAL", "dev", "wifi"]

        stdout: SplitParser {
            onRead: data => {
                const lines = data.split("\n");
                let found = false;

                for (let i = 0; i < lines.length; i++) {
                    const parts = lines[i].split(":");
                    if (parts.length >= 3 && parts[0] === "yes") {
                        root.ssid = parts[1];
                        root.strength = parseInt(parts[2]) || 0;
                        found = true;
                        break;
                    }
                }

                if (!found && lines.length > 1) {
                    root.ssid = "Disconnected";
                    root.strength = 0;
                }
            }
        }
    }

    // 2. Check Wifi Radio Status (Enabled/Disabled)
    property Process _radioProc: Process {
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser {
            onRead: data => {
                root.wifiEnabled = (data.trim() === "enabled");
            }
        }
    }

    // 3. Process to check wired network status
    property Process _wiredStatusProc: Process {
        command: ["sh", "-c", "nmcli -t -f DEVICE,TYPE,STATE device | grep ethernet"]

        onStarted: {
            root._wiredFound = false;
        }

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(":");
                if (parts.length >= 3 && parts[2] === "connected") {
                    root.wiredDevice = parts[0];
                    root.wiredConnected = true;
                    root._wiredFound = true;
                }
            }
        }
    }

    // Master Timer
    property Timer _timer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!root._wifiProc.running)
                root._wifiProc.running = true;
            if (!root._radioProc.running)
                root._radioProc.running = true;
            if (!root._wiredStatusProc.running)
                root._wiredStatusProc.running = true;
        }
    }
}
