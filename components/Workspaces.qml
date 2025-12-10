pragma ComponentBehavior: Bound
// components/Workspaces.qml
import QtQuick
import QtQuick.Layouts

Row {
    id: root

    required property var colorScheme
    spacing: 4

    Rectangle {
        width: (niri?.workspaces.count ?? 0) * 26
        implicitHeight: 20 // Set explicit height so it's visible
        radius: 4
        color: root.colorScheme.getColor("primary_container")

        Row {
            anchors.centerIn: parent  // Center the row of buttons in the rectangle
            spacing: 6

            Repeater {
                // qml-niri exposes workspaces through Niri.workspaces
                model: niri?.workspaces ?? 0

                Rectangle {
                    id: wsButton

                    required property var modelData
                    property var isActive: wsButton.modelData.isActive
                    property bool hasWindows: modelData.windowCount > 0

                    width: {
                        if (isActive) {
                            return 20;
                        }
                        return 12;
                    }
                    height: 8
                    radius: 2

                    color: {
                        if (isActive)
                            return root.colorScheme.getColor("on_tertiary_container");
                        else
                            (hasWindows);
                        return root.colorScheme.getColor("primary");
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: niri.focusWorkspaceById(wsButton.modelData.id)
                    }
                }
            }
        }
    }
}
