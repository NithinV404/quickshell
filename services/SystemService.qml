pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // --- WiFi Properties ---
    property bool wifiEnabled: false
    property bool wifiConnected: false
    property string wifiSsid: ""
    property int wifiStrength: 0
    property var wifiNetworks: []

    // --- Ethernet Properties ---
    property bool wiredConnected: false
    property string wiredDevice: ""

    // --- Bluetooth Properties ---
    property bool btPowered: false
    property bool btScanning: false
    property var btDevices: []

    // --- WiFi Functions ---
    function toggleWifi() {
        _wifiToggleProc.command = ["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"];
        _wifiToggleProc.running = true;
    }

    function connectWifi(ssid, password) {
        if (password) {
            _wifiConnectProc.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password];
        } else {
            _wifiConnectProc.command = ["nmcli", "dev", "wifi", "connect", ssid];
        }
        _wifiConnectProc.running = true;
    }

    function disconnectWifi() {
        _wifiDisconnectProc.running = true;
    }

    function scanWifi() {
        _wifiScanProc.running = true;
    }

    // --- Bluetooth Functions ---
    function toggleBluetooth() {
        _btToggleProc.command = ["bluetoothctl", "power", btPowered ? "off" : "on"];
        _btToggleProc.running = true;
    }

    function scanBluetooth() {
        _btScanProc.running = true;
    }

    function connectBluetooth(mac) {
        _btConnectProc.command = ["bluetoothctl", "connect", mac];
        _btConnectProc.running = true;
    }

    function disconnectBluetooth(mac) {
        _btDisconnectProc.command = ["bluetoothctl", "disconnect", mac];
        _btDisconnectProc.running = true;
    }

    // --- Daemon Process ---
    property Process _daemon: Process {
        command: ["/home/nithin/.config/quickshell/core/target/release/core"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    var s = JSON.parse(data);
                    root.wifiEnabled = s.wifi_enabled;
                    root.wifiConnected = s.wifi_connected;
                    root.wifiSsid = s.wifi_ssid;
                    root.wifiStrength = s.wifi_strength;
                    root.wifiNetworks = s.wifi_networks;
                    root.wiredConnected = s.wired_connected;
                    root.wiredDevice = s.wired_device;
                    root.btPowered = s.bt_powered;
                    root.btScanning = s.bt_scanning;
                    root.btDevices = s.bt_devices;
                } catch (e) {
                    console.error("[SystemService] Parse error:", e);
                }
            }
        }

        onExited: (exitCode, exitStatus) => {
            console.error("[SystemService] Daemon exited with code:", exitCode);
            // Restart daemon after 2 seconds
            restartTimer.start();
        }
    }

    property Timer restartTimer: Timer {
        interval: 2000
        onTriggered: {
            console.log("[SystemService] Restarting daemon...");
            _daemon.running = true;
        }
    }

    // --- Helper Processes ---
    property Process _wifiToggleProc: Process {}
    property Process _wifiConnectProc: Process {}
    property Process _wifiDisconnectProc: Process {
        command: ["nmcli", "dev", "disconnect", "wlan0"]
    }
    property Process _wifiScanProc: Process {
        command: ["nmcli", "dev", "wifi", "rescan"]
    }
    property Process _btToggleProc: Process {}
    property Process _btScanProc: Process {
        command: ["bluetoothctl", "scan", "on"]
    }
    property Process _btConnectProc: Process {}
    property Process _btDisconnectProc: Process {}
}
