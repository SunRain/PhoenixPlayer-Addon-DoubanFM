TEMPLATE = aux
#load Ubuntu specific features
load(ubuntu-click)

OTHER_FILES += \
    manifest.json \
    README.md \
    icon.png \
    main.qml


addon.path = $${UBUNTU_CLICK_PLUGIN_PATH}/addon/doubanfm
addon.files += $${OTHER_FILES}
INSTALLS += addon
