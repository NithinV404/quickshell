import QtQuick
import Quickshell.Io

QtObject {
    id: root

    // =========================================================================
    // 1. PUBLIC PROPERTIES
    // =========================================================================

    // Example Usage: ColorScheme.colors.primary.default
    property var colors: ({})

    // Example Usage: ColorScheme.palettes.neutral["50"]
    property var palettes: ({})

    property string mode: "dark"
    property bool isDarkMode: true
    property string wallpaperPath: ""

    function getColor(key) {
        var currentMode = root.mode;
        if (root.colors[key] && root.colors[key][currentMode]) {
            return Qt.color(root.colors[key][currentMode]);
        }
        return Qt.color("#000000"); // Fallback color
    }

    // =========================================================================
    // 2. INTERNAL LOGIC
    // =========================================================================

    property QtObject internal: QtObject {
        property FileView watcher: FileView {
            id: fileFile
            path: "/home/nithin/.cache/matugen/colors.json"

            // Note: In QuickShell, text is a FUNCTION. You must call it.
            onTextChanged: {
                var content = fileFile.text(); // <--- CALL IT LIKE THIS

                if (!content)
                    return;

                try {
                    // Trim to remove invisible newlines that break JSON.parse
                    var json = JSON.parse(content.trim());

                    // Bulk update
                    root.colors = json.colors || {};
                    root.palettes = json.palettes || {};
                    root.mode = json.mode || "dark";
                    root.isDarkMode = (json.is_dark_mode === true);
                    root.wallpaperPath = json.image || "";

                    console.log("[ColorScheme] Updated successfully.");
                } catch (e) {
                    console.warn("[ColorScheme] JSON Parse Error:", e);
                }
            }
        }
    }
}
