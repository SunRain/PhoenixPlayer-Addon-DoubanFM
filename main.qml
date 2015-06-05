import QtQuick 2.2
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0

import com.sunrain.phoenixplayer.qmlplugin 1.0

Item {
    id: doubanMainItem
    //    anchors.fill: parent

    /////// 设置下面属性以注册插件基本功能
    property bool bindController: true
    property Item bindItem: overrideController
    property string pageTitle: qsTr("Douban.FM")
    property bool musicPlayerAutoSkipForwad: false
    property list<Action> actions: [
        Action {
            text: overrideController.like ? qsTr("Like") : qsTr("UnLike")
            name: overrideController.like ? qsTr("Like") : qsTr("UnLike")
            iconSource: overrideController.like
                        ? Qt.resolvedUrl("like.png")
                        : Qt.resolvedUrl("unlike.png")
            onTriggered: {
                overrideController.like = !overrideController.like;
                overrideController.rate(overrideController.like);
            }
        },
        Action {
            text: qsTr("Ban")
            name: qsTr("Ban")
            iconName: "delete"
            onTriggered: {
                overrideController.ban();
            }
        },
        Action {
            text: qsTr("Settings")
            name: qsTr("Settings")
            iconName: "settings"
            onTriggered: {
                PopupUtils.open(Qt.resolvedUrl("Settings.qml"), doubanMainItem)
            }
        }
    ]
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

        ListElement { cid: 0; name: QT_TR_NOOP("我的私人"); type: QT_TR_NOOP("私人电台") }
        ListElement { cid: -3; name: QT_TR_NOOP("我的红星"); type: QT_TR_NOOP("私人电台") }

        ListElement { cid: 1; name: QT_TR_NOOP("华语"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 6; name: QT_TR_NOOP("粤语"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 2; name: QT_TR_NOOP("欧美"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 22; name: QT_TR_NOOP("法语"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 17; name: QT_TR_NOOP("日语"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 18; name: QT_TR_NOOP("韩语"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 3; name: QT_TR_NOOP("70"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 4; name: QT_TR_NOOP("80"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 5; name: QT_TR_NOOP("90"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 7; name: QT_TR_NOOP("摇滚"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 8; name: QT_TR_NOOP("民谣"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 9; name: QT_TR_NOOP("轻音乐"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 10; name: QT_TR_NOOP("电影原声"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 13; name: QT_TR_NOOP("爵士"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 14; name: QT_TR_NOOP("电子"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 15; name: QT_TR_NOOP("说唱"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 16; name: QT_TR_NOOP("R&B"); type: QT_TR_NOOP("公共电台") }
        ListElement { cid: 20; name: QT_TR_NOOP("女生"); type: QT_TR_NOOP("公共电台") }
    }
    UbuntuListView {
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

        PullToRefresh {
            id: ptRefresh
            refreshing: overrideController.isLoading
            content:  Item {
                height: childrenRect.height * 2
                width: channelList.width
                Label {
                    anchors.centerIn: parent
                    color: UbuntuColors.darkGrey
                    horizontalAlignment: Text.AlignHCenter
                    text: ptRefresh.releaseToRefresh ? qsTr("Release to refresh") : qsTr("Pull to refresh")
                }
            }
            onRefresh: {
                overrideController.newSongs();
            }
        }

        section.property: "type"
        section.criteria: ViewSection.FullString
        section.labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels
        section.delegate: Captions {
            title.text: qsTr(section)
        }

        Component.onCompleted: {
            currentIndex = 2;
        }

        Scrollbar { flickableItem: parent }
    }

}
