TEMPLATE = aux
#load Ubuntu specific features
load(ubuntu-click)

OTHER_FILES += \
    manifest.json \
    README.md \
    icon.png \
    main.qml \
    OverrideController.qml \
    Utils.js \
    JSONListModel.qml \
    jsonpath.js \
    SongObject.qml \
    translations/lng-zh_CN.qm \
    like.png \
    unlike.png \
    Settings.qml


addon.path = $${UBUNTU_CLICK_PLUGIN_PATH}/addon/doubanfm
addon.files += $${OTHER_FILES}
INSTALLS += addon
