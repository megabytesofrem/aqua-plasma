import QtQuick
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

Item {
    id: root

    required property string iconSource
    required property string name
    required property string launcherUrl

    signal launchRequested(string launcherUrl)

    property bool isRunning: false

    // Base dimensions & scaling logic
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
            // Launch the application associated with this dock item
            root.launchRequested(root.launcherUrl);

            iconBounce.restart();
        }
    }
}
