pragma Singleton
import QtQuick

QtObject {
    id: root

    // Tooltip state
    property string text: ""
    property real anchorX: 0
    property bool visible: text !== ""

    // API
    function show(text: string, globalX: real) {
        root.text = text;
        root.anchorX = globalX;
    }

    function hide() {
        root.text = "";
    }
}
