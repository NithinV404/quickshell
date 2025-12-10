pragma Singleton
import QtQuick

QtObject {
    id: root

    // Currently active dropdown (only one can be open at a time)
    property var activeDropdown: null

    function open(dropdown) {
        if (activeDropdown && activeDropdown !== dropdown) {
            activeDropdown.close();
        }
        activeDropdown = dropdown;
    }

    function close() {
        if (activeDropdown) {
            activeDropdown.close();
            activeDropdown = null;
        }
    }
}
