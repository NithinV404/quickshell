// shell.qml
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import "./components"
import "./services"
import Niri

ShellRoot {
    id: root

    // Global color scheme from wallpaper
    ColorScheme {
        id: colors
    }

    Process {
        id: pkillProcess
    }
    Process {
        id: setWallpaper
    }
    Process {
        id: generateMutagenColors
    }

    // Function to set wallpaper and regenerate colors
    function setWallpaperAndColors() {
        const wallpaperPath = "/home/nithin/Pictures/Wallpapers/wallhaven-e8xml8_3840x2160.png";
        // Set new wallpaper
        setWallpaper.exec(["swaybg", "-i", wallpaperPath]);
        // Generate colors
        generateMutagenColors.exec(["matugen", "image", wallpaperPath]);
    }

    Component.onCompleted: setWallpaperAndColors()  // Run on Quickshell

    Niri {
        id: niri
        Component.onCompleted: connect()

        onConnected: console.log("Connected to niri")
        onErrorOccurred: function (error) {
            console.error("Error:", error);
        }
    }

    // Bar on each screen
    Variants {
        model: Quickshell.screens

        Bar {
            id: bar
            property var modelData
            screen: modelData
            colorScheme: colors
        }
    }
}
