import QtQuick
import "../services"

// Wrap any item to give it tooltip behavior
MouseArea {
    id: root

    property string tooltipText: ""

    anchors.fill: parent
    hoverEnabled: true

    onEntered: {
        if (tooltipText) {
            // Map center of parent to global coordinates
            var globalPos = parent.mapToItem(null, parent.width / 2, 0);
            TooltipService.show(tooltipText, globalPos.x);
        }
    }

    onExited: {
        TooltipService.hide();
    }
}
