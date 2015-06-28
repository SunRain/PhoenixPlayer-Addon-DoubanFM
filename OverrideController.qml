import QtQuick 2.0
import com.sunrain.phoenixplayer.qmlplugin 1.0

import "Utils.js" as Utils

Item {
    id: controller

    QtObject {
        id: internal
        property bool rapidLoad: true

        ////musicPlayer Common 为系统提供组件
        property bool isPlaying: musicPlayer.playBackendState == Common.PlayBackendPlaying

        property real playTickPercent: 0
        property int playTickActualSec: 0
        property int playBackendState: Common.PlayBackendStopped
        property int length: 0
        property url picSource
        property string trackName
        property string artist
        property string album
        property string forwardTrackName
        property string forwardTrackInfo
    }

    property bool isLoading: false
    property bool like: false

    SongObject {
        id: song
        onSongChanged: {
            musicPlayer.playFromNetwork(song.source);
            ///playerController为系统提供可调用函数，发送trackChanged以告知系统歌曲已经改变
            playerController.trackChanged();
        }
    }

    JSONListModel {
        id: statusModel
        query: "$"

        onJsonChanged: {
            if (count > 0) {
                var o = model.get(0);
                if (o.r === 0) {
                    songModel.json = json;
                } else {
                    Utils.log(o.err);
                    overrideController.isLoading = false;
                }
            } else {
                console.log(json);
                overrideController.isLoading = false;
            }
        }
    }

    JSONListModel {
        id: songModel
        query: "$.song[*]"
        clear: false

        onJsonChanged: {
            Utils.log("=== onJsonChanged " + songModel.json)
            overrideController.isLoading = false;
            if (count > 0) {
                overrideController.nextSong();
            } else {
                Utils.log("error, no song in list");
            }
        }
    }
    function request(type) {
        overrideController.isLoading = true
        var url = "http://douban.fm/j/mine/playlist?" + parameter(type);
        Utils.log(url)
        if (type !== "e") {
            Utils.log("song list clear");
            songModel.model.clear();
        }
        statusModel.source = url;
    }

    function parameter(type) {
        var r = Number(Math.round(Math.random() * 0xF000000000) + 0x1000000000).toString(16);
        var s = "";
        s += ("type=" + type);
        s += ("&channel=" + doubanMainItem.cid);
        s += ("&sid=" + song.sid);
        s += ("&pt=" + Math.round(internal.playTickActualSec / 1000));
        s += ("&r=" + r);
        s += ("&pb=64&from=mainsite");
        return s;
    }

    function newChannel() {
        console.log("=== newChannel ");
        internal.rapidLoad = true
        request("n");
    }

    function nextSong() {
        if (songModel.count == 0) {
            overrideController.newSongs();  // song list is empty, request new song list.
            return false;
        }

        Utils.log("song list: " + songModel.count);

        if (!internal.rapidLoad) {
            return false;
        }

        overrideController.like = songModel.model.get(0).like;
        //TODO: 此方式不提供跳转到上一首曲目功能
        internal.length = songModel.model.get(0).length;
        internal.picSource = songModel.model.get(0).picture.replace(/mpic/, "lpic");
        internal.trackName = songModel.model.get(0).title;
        internal.artist = songModel.model.get(0).artist;
        internal.album = songModel.model.get(0).album;

        if (songModel.count > 1) {
            internal.forwardTrackName = songModel.model.get(1).title;
            var a = songModel.model.get(1).artist;
            var t = songModel.model.get(1).length;
            internal.forwardTrackInfo = a + "/" + util.formateSongDuration(t);
        }
        song.songInfo = songModel.model.get(0);
        songModel.model.remove(0);

//        ///playerController为系统提供可调用函数，发送trackChanged以告知系统歌曲已经改变
//        playerController.trackChanged();

        return true;
    }

    function newSongs() {
        internal.rapidLoad = true;
        request("p")
    }

    function rate(like) {
        internal.rapidLoad = false;
        if (like) {
            request("r");
        } else {
            request("u");
        }
    }

    function ban() {
        internal.rapidLoad = true;
        request("b");
    }

    //// 以下为可以直接使用的系统组件
    Connections {
        target: musicPlayer
        onPlayBackendStateChanged: { //int state
            internal.playBackendState = state;
            if (state == Common.PlayBackendPlaying) {
                internal.isPlaying = true;
            } else {
                internal.isPlaying = false;
            }
//            console.log("====== OverrideController.qml onPlayBackendStateChanged " + internal.playBackendState + internal.isPlaying);
            //playerController由系统提供
            playerController.playBackendStateChanged();
        }
        //void playTickPercent(int percent);
        onPlayTickPercent: {
            internal.playTickPercent = percent / 100
            playerController.playTickChanged();
        }
        onPlayTickActual: {
            //sec
            internal.playTickActualSec = sec;
            playerController.playTickChanged()
        }
        onTrackChanged: {
//            internal.playingSongHash = musicLibraryManager.playingSongHash();
        }
        onPlayTrackFinished: {
            console.log("====== OverrideController.qml onPlayTrackFinished")
            nextSong();
        }
        onPlayTrackFailed: {
            console.log("====== OverrideController.qml onPlayTrackFailed")
            nextSong();
        }
    }
    //////// 以上为可以直接使用的系统组件

    ////////////////////////////// 覆写以下方法提供系统调用
    function isPlaying() {
        return internal.isPlaying
    }
    function isLocalMusic() {
        return false;
    }
    function getTrackUUID() {
        return util.calculateHash(internal.trackName);
    }
    function getPlayBackendState() {
        return internal.playBackendState;
    }
    function getTrackLength() {
        return internal.length;
    }
    function getCoverUri(defaultUri) {
        if (internal.picSource == undefined || internal.picSource == "")
            return defaultUri;
        return internal.picSource;
    }
    function trackTitle() {
        return internal.trackName;
    }
    function trackArtist() {
        return internal.artist;
    }
    function trackAlbum() {
        return internal.album
    }
    function playTickPercent() {
        return internal.playTickPercent;
    }
    function playTickActualSec() {
        return internal.playTickActualSec;
    }
    function togglePlayPause() {
        //musicPlayer 为系统提供组件
        musicPlayer.togglePlayPause();
    }
    function skipForward() {
        nextSong();
    }
    function skipBackward() {
        showNotification({"text":qsTr("Not supported")});
    }

    function forwardTrackName() {
        return internal.forwardTrackName;
    }
    function forwardTrackInfo() {
        return internal.forwardTrackInfo;
    }
    function backwardTrackName() {
        return qsTr("UnKnow")
    }
    function backwardTrackInfo() {
    }

    function getPlayQueuePopoverUri() {
        showNotification({"text":qsTr("Not supported")});
    }
    ///////////////////////////// 覆写以上方法供系统调用
}
