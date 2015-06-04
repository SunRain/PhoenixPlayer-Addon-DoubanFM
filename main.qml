import QtQuick 2.2
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem

import com.sunrain.phoenixplayer.qmlplugin 1.0

Item {
    id: doubanMainItem
    //    anchors.fill: parent

    /////// 设置下面属性以注册插件基本功能
    property bool bindController: true
    property Item bindItem: overrideController
    property string pageTitle: qsTr("Douban.FM")
    property bool musicPlayerAutoSkipForwad: false
    ////// 设置以上属性以注册插件基本功能

    ///OverrideController用于提供被程序调用的qml相关方式
    OverrideController {
        id: overrideController
    }

    ////////////////////// 以下为插件自身代码
    property int cid: channelModel.get(channelList.currentIndex).cid
    property string name: channelModel.get(channelList.currentIndex).name

    // song start playing from here
    onCidChanged: {
        overrideController.newChannel()
    }

    ListModel {
        id: channelModel

        ListElement { cid: 0; name: "我的私人"; type: "私人电台" }
        ListElement { cid: -3; name: "我的红星"; type: "私人电台" }

        ListElement { cid: 1; name: "华语"; type: "公共电台" }
        ListElement { cid: 6; name: "粤语"; type: "公共电台" }
        ListElement { cid: 2; name: "欧美"; type: "公共电台" }
        ListElement { cid: 22; name: "法语"; type: "公共电台" }
        ListElement { cid: 17; name: "日语"; type: "公共电台" }
        ListElement { cid: 18; name: "韩语"; type: "公共电台" }
        ListElement { cid: 3; name: "70"; type: "公共电台" }
        ListElement { cid: 4; name: "80"; type: "公共电台" }
        ListElement { cid: 5; name: "90"; type: "公共电台" }
        ListElement { cid: 7; name: "摇滚"; type: "公共电台" }
        ListElement { cid: 8; name: "民谣"; type: "公共电台" }
        ListElement { cid: 9; name: "轻音乐"; type: "公共电台" }
        ListElement { cid: 10; name: "电影原声"; type: "公共电台" }
        ListElement { cid: 13; name: "爵士"; type: "公共电台" }
        ListElement { cid: 14; name: "电子"; type: "公共电台" }
        ListElement { cid: 15; name: "说唱"; type: "公共电台" }
        ListElement { cid: 16; name: "R&B"; type: "公共电台" }
        ListElement { cid: 20; name: "女生"; type: "公共电台" }
    }
    ListView {
        id: channelList
        anchors.fill: parent
        model: channelModel
        clip: true
        delegate: ListItem.Standard {
            text: qsTr(model.name) + " MHz"
            selected: ListView.isCurrentItem
            onClicked: {
                ListView.view.currentIndex = index
            }
        }

        section.property: "type"
        section.criteria: ViewSection.FullString
        section.labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels
        section.delegate: ListItem.Caption {
            text: section
        }

        Component.onCompleted: {
            console.log(">>>>>>>>>>>>> douban.fm jump to 2nd channel");
            currentIndex = 2;
        }

        Scrollbar { flickableItem: parent }
    }

}
