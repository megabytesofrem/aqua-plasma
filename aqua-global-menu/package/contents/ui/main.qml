import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    toolTipMainText: i18n("Aqua Global Menu")
    toolTipSubText: i18n("Development scaffold; application menu integration is not implemented yet.")
    preferredRepresentation: fullRepresentation

    fullRepresentation: Item {
        implicitWidth: Kirigami.Units.gridUnit * 16
        implicitHeight: Kirigami.Units.gridUnit * 2
        Layout.minimumWidth: Kirigami.Units.gridUnit * 8
        Layout.minimumHeight: Kirigami.Units.gridUnit * 2
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight

        QQC2.Label {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.smallSpacing
            text: i18n("Aqua Global Menu")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }
}
