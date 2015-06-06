import QtQuick 2.2
import Ubuntu.Components 1.2
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Popups 1.0

import "Utils.js" as Utils

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
                if (doubanMainItem.logined && overrideController.like) {
                    ++user.liked;
                } else {
                    --user.liked;
                }
            }
        },
        Action {
            text: qsTr("Ban")
            name: qsTr("Ban")
            iconName: "delete"
            onTriggered: {
                overrideController.ban();
                if (doubanMainItem.logined) {
                    ++user.banned;
                } else {
                    --user.banned;
                }
            }
        },
        Action {
            text: qsTr("Settings")
            name: qsTr("Settings")
            iconName: "settings"
            onTriggered: {
                flipable.flipped = !flipable.flipped;
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
    property bool logined: false

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

    User { id: user }

    JSONListModel {
        id: userModel
        query: "$.user_info"
        onJsonChanged: {
            if (count > 0) { // Login
                user.userInfo = userModel.model.get(0);
                settings.state = "LOGIN";
            }
        }
    }

    JSONListModel {
        id: statusModel
        query: "$"
        onJsonChanged: {
            if (count > 0) {
                var o = model.get(0);
                if (o.r === 0) {
                    userModel.json = json;
                } else {
                    errMsg.text = o.err_msg;
                    if (o.err_no === 1011) {    // captcha error
                        Utils.getCaptcha(captchaImg);
                    }
                }
            } else {
                Utils.log(json);
            }
        }
    }
    Flipable {
        id: flipable
        anchors.fill: parent

        property bool flipped: false

        transform: Rotation {
            id: rotation
            origin.x: flipable.width/2
            origin.y: flipable.height/2
            axis.x: 1; axis.y: 0; axis.z: 0     // set axis.x to 1 to rotate around x-axis
            angle: 0    // the default angle
        }
        states: State {
            name: "back"
            PropertyChanges { target: rotation; angle: 180 }
            when: flipable.flipped
        }

        transitions: Transition {
            NumberAnimation { target: rotation; property: "angle"; duration: 500 }
        }

        //////////////////////
        front: UbuntuListView {
            id: channelList
            anchors.fill: parent
            model: channelModel
            clip: true
            enabled: !flipable.flipped
            delegate: ListItem.Standard {
                text: qsTr(model.name) + " MHz"
                selected: ListView.isCurrentItem
                onClicked: { ListView.view.currentIndex = index; }
            }
            /*pullToRefresh*/PullToRefresh {
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
                onRefresh: { overrideController.newSongs(); }
            }
            section.property: "type"
            section.criteria: ViewSection.FullString
            section.labelPositioning: ViewSection.CurrentLabelAtStart | ViewSection.InlineLabels
            section.delegate: Captions {
                title.text: qsTr(section)
            }
            Component.onCompleted: { currentIndex = 2; }
            Scrollbar { flickableItem: parent }
        }

        /////////////////////////////////////
        back: Flickable {
            id: settings
            anchors.fill: parent
            contentHeight: column.height
            boundsBehavior: Flickable.StopAtBounds
            enabled: flipable.flipped
            clip: true
            states: [
                State {
                    name: "LOGIN"
                    PropertyChanges { target: doubanMainItem; logined: true }
                    PropertyChanges { target: info; opacity: 1; visible: true }
                    PropertyChanges { target: loginForm; opacity: 0; visible: false }
                },
                State {
                    name: "LOGOUT"
                    PropertyChanges { target: doubanMainItem; logined: false }
                    PropertyChanges { target: errMsg; text: " " }
                    PropertyChanges { target: captcha; text: "" }
                    PropertyChanges { target: captchaImg; source: "" }
                    PropertyChanges { target: info; opacity: 0; visible: false }
                    PropertyChanges { target: loginForm; opacity: 1; visible: true }
                }
            ]
            state: "LOGOUT"
            transitions: Transition {
                UbuntuNumberAnimation { property: "opacity"; }
            }
            Column {
                id: column
                spacing: units.gu(0.25)
                width: parent.width

                /////////////////////////////
                Column {
                    id: loginForm
                    width: parent.width - units.gu(2)
                    x: units.gu(1)
                    spacing: units.gu(1)
                    Label {
                        id: errMsg
                        color: UbuntuColors.red
                        text: ""
                    }
                    Captions { title.text: qsTr("UserName:") }
                    TextField {
                        id: username
                        width: parent.width
                        KeyNavigation.tab: password
                        placeholderText: qsTr("UserName/E-mail")
                    }
                    Captions { title.text: qsTr("Password:") }
                    TextField {
                        id: password
                        width: parent.width
                        echoMode: TextInput.Password
                        KeyNavigation.tab: captcha
                        KeyNavigation.backtab: username
                    }
                    Captions { title.text: qsTr("Captcha:") }
                    TextField {
                        id: captcha
                        width: parent.width
                        KeyNavigation.tab: username
                        KeyNavigation.backtab: password
                    }
                    ListItem.Empty {
                        width: parent.width
                        showDivider: false
                        Row {
                            height: parent.height
                            spacing: units.gu(2)
                            ActivityIndicator {
                                id: captchaIndicator
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: captchaIndicator.running ? 1 : 0
                                running: false
                            }
                            Label {
                                id: captchaInfo
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: captchaImg.status == Image.Ready ? 0 : 1
                                text: qsTr("Click to get captcha image")
                            }
                        }
                        Image {
                            id: captchaImg
                            property string captchaId: ""
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            onStatusChanged: {
                                if (status == Image.Ready)
                                    captchaIndicator.running = false;
                            }
                        }
                        onClicked: {
                            captchaIndicator.running = true;
                            Utils.getCaptcha(captchaImg);
                        }
                    }
                    Button {
                        text: qsTr("Login")
                        width: parent.width /2
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            Utils.login(username.text,
                                        password.text,
                                        captcha.text,
                                        captchaImg.captchaId,
                                        statusModel)
                        }
                    }
                }
                /////////////////////////////////////////////////
                Column {
                    id: info
                    width: parent.width - units.gu(2)
                    x: units.gu(1)
                    spacing: units.gu(1)
                    opacity: 0
                    ListItem.SingleValue {
                        text: qsTr("NickName")
                        value: user.name
                    }
                    ListItem.SingleValue {
                        text: qsTr("DJ")
                        value: user.isDJ ? qsTr("yes") : qsTr("no")
                    }
                    ListItem.SingleValue {
                        text: qsTr("PRO")
                        value: user.isPro ? qsTr("yes") : qsTr("no")
                    }
                    ListItem.SingleValue {
                        text: qsTr("TotalTrack")
                        value: user.played + qsTr("Tracks")
                    }
                    ListItem.SingleValue {
                        text: qsTr("Like")
                        value: user.liked + qsTr("Tracks")
                    }
                    ListItem.SingleValue {
                        text: qsTr("Ban")
                        value: user.banned + qsTr("Tracks")
                    }
                    Button {
                        text: qsTr("Logout")
                        width: parent.width /2
                        anchors.horizontalCenter: parent.horizontalCenter
                        onClicked: {
                            Utils.logout(userModel.model.get(0).ck);
                            settings.state = "LOGOUT";
                        }
                    }
                }
            }
        }
    }
}
