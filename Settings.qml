import QtQuick 2.0
import Ubuntu.Components 1.2
import Ubuntu.Components.Popups 1.0

Dialog {
    id: dialogue

    title: qsTr("Settings")

    states: [
        State {
            name: "LOGIN"
            PropertyChanges { target: setting; logined: true }
            PropertyChanges { target: logoutAct; visible: true }
            PropertyChanges { target: toolbar; active: true }
            PropertyChanges { target: info; opacity: 1 }
            PropertyChanges { target: loginForm; opacity: 0 }
        },
        State {
            name: "LOGOUT"
            PropertyChanges { target: setting; logined: false }
            PropertyChanges { target: errMsg; text: " " }
            PropertyChanges { target: logoutAct; visible: false }
            PropertyChanges { target: captcha; text: "" }
            PropertyChanges { target: captchaImg; source: "" }
            PropertyChanges { target: info; opacity: 0 }
            PropertyChanges { target: loginForm; opacity: 1 }
        }
    ]
    state: "LOGOUT"
    transitions: Transition {
        NumberAnimation { property: "opacity"; duration: 500 }
    }

    Column {
        id: loginForm
        width: parent.width
        spacing: units.gu(1)
        Label {
            id: errMsg
            color: UbuntuColors.red
            text: ""
        }
        Captions {
            title: qsTr("用户名:")
        }
        TextField {
            id: username
            KeyNavigation.tab: password
            placeholderText: qsTr("用户名/邮箱地址")
        }
        Captions {
            text: qsTr("验证码:")
        }
        TextField {
            id: captcha
            KeyNavigation.tab: username
            KeyNavigation.backtab: password
        }

    }


    Row {
        id: row
        width: parent.width
        spacing: units.gu(1)
        Button {
            width: parent.width/2
            text: "Cancel"
            onClicked: PopupUtils.close(dialogue)
        }
        Button {
            width: parent.width/2
            text: "Confirm"
            color: UbuntuColors.green
            onClicked: PopupUtils.close(dialogue)
        }
    }
}

