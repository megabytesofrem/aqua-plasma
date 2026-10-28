pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    // Disable the dark plasma background frame
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    // Define the size of the plasmoid
    width: Kirigami.Units.gridUnit * 24
    height: Kirigami.Units.gridUnit * 8
    implicitWidth: width
    implicitHeight: height

    // Set the preferred representation for the plasmoid
    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        id: dockShelf
        anchors.fill: parent

        // Task manager model for the dock items
        TaskManager.TasksModel {
            id: tasksModel
            groupMode: TaskManager.TasksModel.GroupDisabled
            sortMode: TaskManager.TasksModel.SortAlpha
            screenGeometry: root.screenGeometry
            virtualDesktop: virtualDesktopInfo.currentDesktop
            activity: activityInfo.currentActivity
            launcherList: {
                const launchers = [];
                for (let i = 0; i < dockItemModel.count; ++i) {
                    launchers.push(dockItemModel.get(i).launcherUrl);
                }
                return launchers;
            }
        }

        TaskManager.VirtualDesktopInfo {
            id: virtualDesktopInfo
        }

        TaskManager.ActivityInfo {
            id: activityInfo
        }

        function activateLauncher(launcherUrl: string) {
            let launcherIndex = null;
            for (let row = 0; row < tasksModel.count; ++row) {
                const taskIndex = tasksModel.makeModelIndex(row);
                const taskUrl = tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.LauncherUrlWithoutIcon);
                if (taskUrl.toString() !== launcherUrl) {
                    continue;
                }
                if (tasksModel.data(taskIndex, TaskManager.AbstractTasksModel.IsWindow)) {
                    tasksModel.requestActivate(taskIndex);
                    return;
                }
                launcherIndex = taskIndex;
            }
            if (launcherIndex !== null) {
                tasksModel.requestActivate(launcherIndex);
            } else {
                console.warn("Aqua Glass Dock: no task or installed launcher found for", launcherUrl);
            }
        }

        // Icons in the dock (horizontal list)
        ListModel {
            id: dockItemModel

            ListElement {
                name: "Dolphin"
                iconSource: "system-file-manager"
                launcherUrl: "applications:org.kde.dolphin.desktop"
            }

            ListElement {
                name: "Firefox"
                iconSource: "firefox"
                launcherUrl: "applications:org.mozilla.firefox.desktop"
                isRunning: true
            }
        }

        ListView {
            id: dockListView
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: frontBevel.top
            anchors.bottomMargin: Kirigami.Units.smallSpacing

            width: Math.min(contentWidth, dockShelf.width)
            height: Kirigami.Units.iconSizes.large * 1.8 + 20
            z: 1
            clip: true
            interactive: false
            model: dockItemModel
            orientation: ListView.Horizontal

            delegate: DockItem {
                baseSize: Kirigami.Units.iconSizes.large
                onLaunchRequested: launcherUrl => dockShelf.activateLauncher(launcherUrl)
            }
        }

        // 3D background for the dock shelf
        Rectangle {
            id: shelfBase
            anchors.fill: parent

            gradient: Gradient {
                // Crisp translucent highlight line right at the back top edge
                GradientStop {
                    position: 0.00
                    color: "#90EAF0F6" // ~56% opacity
                }
                GradientStop {
                    position: 0.02
                    color: "#60C6CED7" // ~37% opacity
                }

                // Smooth translucent reflection across the middle glass plane
                GradientStop {
                    position: 0.15
                    color: "#40A8B2BD" // ~25% opacity
                }
                GradientStop {
                    position: 0.70
                    color: "#357B8591" // ~20% opacity
                }

                // Darker glass transition near the front lip
                GradientStop {
                    position: 0.92
                    color: "#505F6771" // ~31% opacity
                }
                GradientStop {
                    position: 1.00
                    color: "#703B4047" // ~44% opacity
                }
            }

            // Crisp white spec edge on top
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: 1
                color: "#FFFFFF"
                opacity: 0.85
            }

            transform: Rotation {
                origin.x: shelfBase.width / 2
                origin.y: shelfBase.height
                axis {
                    x: 1
                    y: 0
                    z: 0
                }

                // Angle of rotation for the shelf tilt
                angle: 60
            }
        }

        Rectangle {
            id: frontBevel
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 6

            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#B04B5159" // ~69% opacity
                }
                GradientStop {
                    position: 0.5
                    color: "#C02B2E33" // ~75% opacity
                }
                GradientStop {
                    position: 1.0
                    color: "#D01E2024" // ~81% opacity
                }
            }

            // Subtle dark drop shadow under the lip
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.bottom
                height: 2
                color: '#5e8c8c8c'
                opacity: 0.4
            }
        }
    }
}
