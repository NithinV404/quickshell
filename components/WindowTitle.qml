// components/WindowTitle.qml
import QtQuick

Item {
    id: root

    required property var colorScheme

    implicitWidth: titleText.implicitWidth
    implicitHeight: titleText.implicitHeight

    Text {
        id: titleText
        anchors.horizontalCenter: parent.horizontalCenter
        color: root.colorScheme.getColor("primary_container")
        text: niri.focusedWindow?.title ?? ""
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font {
            pixelSize: 12
            family: "Adwaita Sans"
            weight: Font.Medium
        }

        elide: Text.ElideMiddle
        width: parent.width

        opacity: text ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }

        Behavior on text {
            SequentialAnimation {
                NumberAnimation {
                    target: titleText
                    property: "opacity"
                    to: 0.5
                    duration: 50
                }
                PropertyAction {}
                NumberAnimation {
                    target: titleText
                    property: "opacity"
                    to: 1
                    duration: 100
                }
            }
        }
    }
}
