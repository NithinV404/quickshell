pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // =========================================================================
    //  STATE PROPERTIES (Read from Rust Daemon)
    // =========================================================================

    // --- WiFi ---
    property bool wifiEnabled: false
    property bool wifiConnected: false
    property string wifiSsid: ""
    property int wifiStrength: 0
    property var wifiNetworks: [] // Array of {ssid, signal, security, active}

    // --- Ethernet ---
    property bool wiredConnected: false
    property string wiredDevice: ""

    // --- Bluetooth ---
    property bool btPowered: false
    property bool btScanning: false // State reported by hardware
    property var btDevices: []      // Array of {name, mac, connected, paired, rssi}

    // =========================================================================
    //  FUNCTIONS (Actions)
    // =========================================================================

    // --- WiFi Actions ---

    function toggleWifi() {
        // Toggles the radio state
        _procWifiToggle.command = ["nmcli", "radio", "wifi", wifiEnabled ? "off" : "on"];
        _procWifiToggle.running = true;
    }

    function connectWifi(ssid, password) {
        console.log("[System] Connecting to:", ssid);
        if (password && password !== "") {
            _procWifiConnect.command = ["nmcli", "dev", "wifi", "connect", ssid, "password", password];
        } else {
            _procWifiConnect.command = ["nmcli", "dev", "wifi", "connect", ssid];
        }
        _procWifiConnect.running = true;
    }

    function disconnectWifi() {
        // Best practice: disconnect the specific connection ID if known,
        // otherwise disconnect the interface.
        if (wifiSsid !== "") {
            _procWifiDisconnect.command = ["nmcli", "con", "down", "id", wifiSsid];
            _procWifiDisconnect.running = true;
        }
    }

    function scanWifi() {
        // Rust daemon does passive scanning, but this forces a refresh
        _procWifiScan.running = true;
    }

    // --- Bluetooth Actions ---

    function toggleBluetooth() {
        _procBtToggle.command = ["bluetoothctl", "power", btPowered ? "off" : "on"];
        _procBtToggle.running = true;
    }

    function toggleBluetoothScan() {
        // "bluetoothctl scan on" is a blocking command.
        // If it is running, we stop it. If not, we start it.
        if (_procBtScan.running) {
            console.log("[System] Stopping BT Scan...");
            _procBtScan.running = false;
        } else {
            console.log("[System] Starting BT Scan...");
            _procBtScan.running = true;
        }
    }

    function connectBluetooth(mac) {
        console.log("[System] Connecting BT Device:", mac);
        _procBtConnect.command = ["bluetoothctl", "connect", mac];
        _procBtConnect.running = true;
    }

    function disconnectBluetooth(mac) {
        console.log("[System] Disconnecting BT Device:", mac);
        _procBtDisconnect.command = ["bluetoothctl", "disconnect", mac];
        _procBtDisconnect.running = true;
    }

    function pairBluetooth(mac) {
        console.log("[System] Pairing BT Device:", mac);
        _procBtPair.command = ["bluetoothctl", "pair", mac];
        _procBtPair.running = true;
    }

    // =========================================================================
    //  BACKGROUND PROCESSES
    // =========================================================================

    // 1. The Rust Daemon (Reads State)
    property Process _daemon: Process {
        // CHANGE THIS PATH to where your compiled rust binary is located
        command: ["/home/nithin/.config/quickshell/core/target/release/core"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    const s = JSON.parse(data);

                    // Update WiFi
                    root.wifiEnabled = s.wifi_enabled;
                    root.wifiConnected = s.wifi_connected;
                    root.wifiSsid = s.wifi_ssid;
                    root.wifiStrength = s.wifi_strength;
                    root.wifiNetworks = s.wifi_networks;

                    // Update Wired
                    root.wiredConnected = s.wired_connected;
                    root.wiredDevice = s.wired_device;

                    // Update Bluetooth
                    root.btPowered = s.bt_powered;
                    // Note: s.bt_scanning comes from the Rust daemon checking the adapter.
                    // It confirms if the hardware is actually scanning.
                    root.btScanning = s.bt_scanning;
                    root.btDevices = s.bt_devices;
                } catch (e) {
                    console.error("[System] JSON Parse Error:", e);
                }
            }
        }

        onExited: (code, status) => {
            console.warn(`[System] Daemon exited (${code}). Restarting in 2s...`);
            _timerRestartDaemon.start();
        }
    }

    property Timer _timerRestartDaemon: Timer {
        interval: 2000
        repeat: false
        onTriggered: _daemon.running = true
    }

    // 2. Action Processes (Fire and Forget)

    // WiFi
    property Process _procWifiToggle: Process {}
    property Process _procWifiScan: Process {
        command: ["nmcli", "dev", "wifi", "rescan"]
    }
    property Process _procWifiDisconnect: Process {}
    property Process _procWifiConnect: Process {
        // Capture output to debug connection failures
        stdout: SplitParser {
            onRead: data => console.log("[Wifi Connect]", data)
        }
        stderr: SplitParser {
            onRead: data => console.error("[Wifi Connect Error]", data)
        }
    }

    // Bluetooth
    property Process _procBtToggle: Process {}
    property Process _procBtConnect: Process {}
    property Process _procBtDisconnect: Process {}
    property Process _procBtPair: Process {}

    // 3. Bluetooth Scan Process (Long Running)
    // This needs to stay running for scanning to continue.
    // Toggling root.toggleBluetoothScan() starts/stops this.
    property Process _procBtScan: Process {
        command: ["bluetoothctl", "scan", "on"]

        // We don't really need the output, but reading it prevents buffer filling
        stdout: SplitParser {
            onRead: data => { /* optionally log scan results here */ }
        }

        onExited: (code, status) => {
            console.log("[System] Bluetooth scan stopped.");
        }
    }
}
