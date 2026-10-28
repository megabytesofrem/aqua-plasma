import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Item {
    id: root

    required property string iconSource
    required property string name
    required property string launcherUrl

    // Whether this dock item represents a special folder (e.g., Trash)
    required property bool isSpecialFolder

    property bool isStack: false // Whether this dock item represents a stack
    property bool isRunning: false // Whether the application associated with this dock item is running

    signal launchRequested(string launcherUrl)

    // Base dimensions & scaling logic, used for hover scaling and icon sizing
    property real baseSize: 64
    property real hoverScale: mouseArea.containsMouse ? 1.8 : 1.0

    width: baseSize * hoverScale
    height: ListView.view ? ListView.view.height : baseSize * 1.8

    // Animations for icon hover
    Behavior on width {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    // Animations for bounce launch (OS X app icon bounce effect)
    SequentialAnimation {
        id: iconBounce
        loops: 2

        NumberAnimation {
            target: bounceOffset
            property: "y"
            from: 0
            to: -20
            duration: 250
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: bounceOffset
            property: "y"
            to: 0
            duration: 380
            easing.type: Easing.OutBounce
        }
    }

    Item {
        id: iconContainer
        anchors.fill: parent

        // Apply the bounce offset transform for the icon bounce animation
        transform: Translate {
            id: bounceOffset
        }

        ColumnLayout {
            id: iconColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: root.baseSize * root.hoverScale
            spacing: 2

            // Animate the height of the icon container when hover scaling changes
            Behavior on height {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutQuad
                }
            }

            Kirigami.Icon {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.fillWidth: true
                Layout.fillHeight: true
                source: root.iconSource
                Accessible.name: root.name
            }

            // Classic Leopard Blue Running Light
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 4
                implicitHeight: 4
                radius: 2
                color: "#00C3FF"
                visible: root.isRunning
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.baseSize * root.hoverScale
        hoverEnabled: true
        onClicked: {
            iconBounce.restart();

            if (root.isSpecialFolder) {
                if (!Qt.openUrlExternally(root.launcherUrl)) {
                    console.warn("Aqua Glass Dock: could not open", root.launcherUrl);
                }
                return;
            } else {
                root.launchRequested(root.launcherUrl);
            }
        }
    }
}
