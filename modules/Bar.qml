import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: bar

    QtObject {
        id: theme

        // --- PALETTE: OBSIDIAN ---
        property color bgRoot: "#0a0a0a"
        property color bgSurface: "#1c1c1c"
        property color borderMain: "#333333"
        property color textInactive: "#808080"
        property color textActive: "#f5f5f5"

        property int cornerRadius: 8
        property int paddingSmall: 8
        property int paddingLarge: 16
    }

    anchors {
        top: true
        left: true
        right: true
    }
    color: theme.bgRoot
    implicitHeight: 26

    Rectangle {
        id: workspacebox
        anchors {
            left: parent.left
            leftMargin: 8
            verticalCenter: parent.verticalCenter
        }
        color: theme.borderMain
        height: parent.height - 6
        width: niri.workspaces.count * 22 + theme.paddingSmall * 2
        radius: 4
        border.width: 1

        Row {
            id: workspaceIndicator
            anchors.centerIn: parent
            spacing: 5

            Repeater {
                model: niri.workspaces

                Rectangle {

                    property bool isActiveWorkspace: model.isActive
                    property int activeWorkspaceIndex: model.isActive ? model.index : 1

                    visible: index < 11
                    width: isActiveWorkspace ? 28 : 15
                    height: 8
                    radius: 2
                    color: isActiveWorkspace ? theme.textActive : theme.textInactive

                    Behavior on width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    // Keep click functionality for specific dots
                    MouseArea {
                        anchors.fill: parent
                        onClicked: niri.focusWorkspaceById(model.id)
                    }
                }
            }
        }
    }
}
