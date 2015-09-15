import QtQuick 2.0

QtObject {
    id: songObject
    objectName: "SongObject"

    signal songChanged

    property var songInfo: ({
                                albumtitle      : "",
//                                company         : "",
//                                rating_avg      : 0.0,
//                                public_time     : "",
                                ssid            : "",
                                album           : "",
                                picture         : "",
                                like            : 0,
                                artist          : "",
                                url             : "",
                                title           : "",
                                subtype         : "",
                                length          : 0,
                                sid             : "",
                                alert_msg       : "",
//                                songlists_count : 0,
                                status          : "",
                                aid             : "",
                                sha256          : "",
                                kbps            : "",
                                file_ext        : ""
                            })

    property url albumSource
    property url picSource
    property string ssid
    property string artist
    property url source
//    property var company
    property string name
//    property real rating_avg
    property int length
    property string alert_msg
    property string subtype
    property string publicTime
//    property int songlists_count
    property string status
    property string sid
    property string aid
    property string sha256
    property string kbps
    property string albumtitle
    property bool like

    onSongInfoChanged: {
        if (songInfo) {
            ssid            = songInfo.ssid
            sid             = songInfo.sid
//            company         = songInfo.company
//            rating_avg      = songInfo.rating_avg
            length          = songInfo.length
            alert_msg       = songInfo.alert_msg
            subtype         = songInfo.subtype
//            songlists_count = songInfo.songlists_count
            status          = songInfo.status
            aid             = songInfo.aid
            sha256          = songInfo.sha256
            kbps            = songInfo.kbps
            source          = songInfo.url
            picSource       = songInfo.picture.replace(/mpic/, "lpic")
            albumtitle      = songInfo.albumtitle
            albumSource     = songInfo.album
            name            = songInfo.title
            artist          = songInfo.artist
//            publicTime      = songInfo.public_time
            like            = songInfo.like

            songObject.songChanged();
        }
    }
}
