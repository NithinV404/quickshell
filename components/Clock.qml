// components/Clock.qml
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

RowLayout {
    id: root

    required property var colorScheme
    property var fontFamily: "Adwaita Sans"
    spacing: 12

    // System tray indicators (optional)
    Row {
        spacing: 8
        Layout.alignment: Qt.AlignVCenter
    }

    // Separator
    Rectangle {
        width: 1
        height: 16
        color: root.colorScheme.getColor("primary_container")
        opacity: 0.3
        Layout.alignment: Qt.AlignVCenter
    }

    // Time
    Text {
        id: timeText
        color: root.colorScheme.getColor("primary_container")
        font {
            pixelSize: 12
            family: root.fontFamily
            weight: Font.Medium
        }

        // Update time
        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                let now = new Date();
                timeText.text = Qt.formatTime(now, "HH:mm");
            }
        }
    }

    // Date (subtle)
    Text {
        text: {
            let now = new Date();
            return Qt.formatDate(now, "ddd, MMM d");
        }
        verticalAlignment: Qt.AlignVCenter

        color: root.colorScheme.getColor("primary_container")
        font {
            pixelSize: 12
            family: root.fontFamily
            weight: Font.Medium
        }

        Timer {
            interval: 60000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: parent.text = Qt.formatDate(new Date(), "ddd, MMM d")
        }
    }
}
