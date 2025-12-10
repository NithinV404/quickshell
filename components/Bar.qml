// components/Bar.qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    required property var colorScheme

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 4
        left: 4
        right: 4
        bottom: 0
    }

    implicitHeight: 36
    color: "transparent"

    // Global tooltip popup
    TooltipPopup {
        parentWindow: bar
        colorScheme: bar.colorScheme
    }

    // Main bar container
    Rectangle {
        id: container
        anchors.fill: parent
        radius: 8
        color: bar.colorScheme.getColor("primary")

        Item {
            anchors.fill: parent
            anchors.margins: 8

            Workspaces {
                id: workspaces
                colorScheme: bar.colorScheme
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            WindowTitle {
                colorScheme: bar.colorScheme
                anchors.centerIn: parent
                width: Math.max(200, parent.width - workspaces.width - clock.width - 48)
            }

            SystemTray {
                colorScheme: bar.colorScheme
                anchors.right: clock.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
            }

            Clock {
                id: clock
                colorScheme: bar.colorScheme
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
