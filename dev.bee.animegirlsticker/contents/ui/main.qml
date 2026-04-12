import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    readonly property int defaultDisplayHeight: 480
    readonly property int minimumDisplayHeight: 128
    readonly property int emptyStateWidth: 280
    readonly property int emptyStateHeight: 112
    readonly property string configuredImageUrl: Plasmoid.configuration.imageUrl ? Plasmoid.configuration.imageUrl.toString() : ""
    readonly property bool hasConfiguredImage: configuredImageUrl !== ""
    readonly property bool imageReady: sticker.status === Image.Ready
    readonly property bool imageFailed: hasConfiguredImage && sticker.status === Image.Error
    readonly property int configuredHeight: Math.max(minimumDisplayHeight, Number(Plasmoid.configuration.displayHeight) || defaultDisplayHeight)
    readonly property real fallbackAspectRatio: 0.62
    readonly property real effectiveAspectRatio: imageReady && sticker.implicitHeight > 0
        ? sticker.implicitWidth / sticker.implicitHeight
        : fallbackAspectRatio
    readonly property int stickerWidth: Math.max(1, Math.round(configuredHeight * effectiveAspectRatio))

    implicitWidth: hasConfiguredImage ? stickerWidth : emptyStateWidth
    implicitHeight: hasConfiguredImage ? configuredHeight : emptyStateHeight

    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.title: i18n("Anime Girl Sticker")
    Plasmoid.icon: "preferences-desktop-wallpaper"
    Plasmoid.configurationRequired: !hasConfiguredImage || imageFailed
    toolTipSubText: hasConfiguredImage
        ? configuredImageUrl
        : i18n("Choose a transparent PNG or WebP image in the widget settings.")

    Image {
        id: sticker
        anchors.fill: parent
        asynchronous: true
        cache: true
        fillMode: Image.PreserveAspectFit
        horizontalAlignment: Image.AlignHCenter
        mipmap: true
        smooth: true
        source: root.configuredImageUrl
        verticalAlignment: Image.AlignBottom
        visible: root.hasConfiguredImage && !root.imageFailed
    }

    Item {
        anchors.fill: parent
        visible: !root.hasConfiguredImage || root.imageFailed

        ColumnLayout {
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing
            width: Math.min(parent.width, Kirigami.Units.gridUnit * 16)

            Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.imageFailed
                    ? i18n("The selected image could not be loaded.")
                    : i18n("Choose a transparent PNG or WebP image.")
                wrapMode: Text.WordWrap
            }

            Button {
                Layout.alignment: Qt.AlignHCenter
                enabled: Plasmoid.internalAction("configure") !== null
                icon.name: "document-open"
                text: root.imageFailed
                    ? i18n("Choose Another Image")
                    : i18n("Choose Image")

                onClicked: {
                    const configureAction = Plasmoid.internalAction("configure");
                    if (configureAction) {
                        configureAction.trigger();
                    }
                }
            }
        }
    }
}
