pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // --- Public Properties ---
    property bool powered: false
    property bool scanning: false
    property var devices: []  // [{name, mac, connected, paired}]

    // --- Public Functions ---
    function togglePower() {
        _powerProc.command = ["bluetoothctl", "power", powered ? "off" : "on"];
        _powerProc.running = true;
    }

    function startScan() {
        _scanOnProc.running = true;
        root.scanning = true;
        // Stop scan after 10 seconds
        _scanTimer.restart();
    }

    function stopScan() {
        _scanOffProc.running = true;
        root.scanning = false;
    }

    function connect(mac) {
        _connectProc.command = ["bluetoothctl", "connect", mac];
        _connectProc.running = true;
    }

    function disconnect(mac) {
        _disconnectProc.command = ["bluetoothctl", "disconnect", mac];
        _disconnectProc.running = true;
    }

    // --- Internal ---
    property Process _powerProc: Process {
        onExited: {
            // Refresh status after toggling power
            _statusProc.running = true;
        }
    }

    property Process _scanOnProc: Process {
        command: ["bluetoothctl", "scan", "on"]
    }

    property Process _scanOffProc: Process {
        command: ["bluetoothctl", "scan", "off"]
    }

    property Process _connectProc: Process {
        onExited: _refreshProc.running = true
    }

    property Process _disconnectProc: Process {
        onExited: _refreshProc.running = true
    }

    property Timer _scanTimer: Timer {
        interval: 10000
        onTriggered: root.stopScan()
    }

    // Check power status - buffer output and check in onExited
    property Process _statusProc: Process {
        command: ["bluetoothctl", "show"]
        property string buffer: ""
        onStarted: buffer = ""
        stdout: SplitParser {
            onRead: data => _statusProc.buffer += data + "\n"
        }
        onExited: {
            root.powered = _statusProc.buffer.includes("Powered: yes");
        }
    }

    // Get paired/connected devices
    property Process _refreshProc: Process {
        command: ["sh", "-c", "bluetoothctl devices Paired && bluetoothctl devices Connected"]

        property string buffer: ""

        onStarted: buffer = ""

        stdout: SplitParser {
            onRead: data => {
                _refreshProc.buffer += data + "\n";
            }
        }

        onExited: {
            var lines = _refreshProc.buffer.trim().split("\n");
            var deviceMap = {};

            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim();
                // Format: "Device XX:XX:XX:XX:XX:XX Name"
                var match = line.match(/Device\s+([0-9A-Fa-f:]+)\s+(.+)/);
                if (match) {
                    var mac = match[1];
                    var name = match[2];
                    if (!deviceMap[mac]) {
                        deviceMap[mac] = {
                            mac: mac,
                            name: name,
                            connected: false,
                            paired: true
                        };
                    }
                }
            }

            var devList = Object.values(deviceMap);
            root.devices = devList;
            _checkConnected();
        }
    }

    function _checkConnected() {
        _connectedProc.running = true;
    }

    property Process _connectedProc: Process {
        command: ["bluetoothctl", "devices", "Connected"]
        property string buffer: ""
        onStarted: buffer = ""
        stdout: SplitParser {
            onRead: data => _connectedProc.buffer += data + "\n"
        }
        onExited: {
            var lines = _connectedProc.buffer.split("\n");
            var connectedMacs = [];
            for (var i = 0; i < lines.length; i++) {
                var match = lines[i].match(/Device\s+([0-9A-Fa-f:]+)/);
                if (match)
                    connectedMacs.push(match[1]);
            }
            // Update devices
            var updated = root.devices.map(d => ({
                        mac: d.mac,
                        name: d.name,
                        paired: d.paired,
                        connected: connectedMacs.indexOf(d.mac) >= 0
                    }));
            root.devices = updated;
        }
    }

    // Refresh timer
    property Timer _timer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!_statusProc.running)
                _statusProc.running = true;
            if (!_refreshProc.running)
                _refreshProc.running = true;
        }
    }
}
