import QtQuick 2.2
import Ubuntu.Components 1.2

import com.sunrain.phoenixplayer.qmlplugin 1.0

Item {
    id: mainItem
//    anchors.fill: parent

    property bool bindController: true
    property Item bindItem: mainItem
    property string pageTitle: "Douban.FM"

    Rectangle {
        color: "#ca1313"
        anchors.fill: parent
    }
}
