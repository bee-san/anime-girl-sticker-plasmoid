import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import org.kde.kcmutils
import org.kde.kirigami as Kirigami

SimpleKCM {
    id: root

    property url cfg_imageUrl
    property int cfg_displayHeight

    readonly property int minHeight: 128
    readonly property int maxHeight: 2000
    readonly property int defaultHeight: 480

    function clampHeight(value) {
        const numericValue = Number(value) || defaultHeight;
        return Math.max(minHeight, Math.min(maxHeight, numericValue));
    }

    function displayPath(url) {
        const value = url ? url.toString() : "";
        return value.startsWith("file://") ? decodeURIComponent(value.substring(7)) : value;
    }

    function isSupportedImage(url) {
        const value = url ? url.toString().toLowerCase() : "";
        return value.endsWith(".png") || value.endsWith(".webp");
    }

    onCfg_displayHeightChanged: {
        const clampedHeight = clampHeight(cfg_displayHeight);

        if (cfg_displayHeight !== clampedHeight) {
            cfg_displayHeight = clampedHeight;
            return;
        }

        if (heightSlider.value !== clampedHeight) {
            heightSlider.value = clampedHeight;
        }

        if (heightSpin.value !== clampedHeight) {
            heightSpin.value = clampedHeight;
        }
    }

    Component.onCompleted: {
        cfg_displayHeight = clampHeight(cfg_displayHeight);
    }

    FileDialog {
        id: imageDialog
        fileMode: FileDialog.OpenFile
        nameFilters: [i18n("Images (*.png *.webp)")]
        title: i18n("Choose a transparent image")

        onAccepted: {
            if (root.isSupportedImage(selectedFile)) {
                root.cfg_imageUrl = selectedFile;
            }
        }
    }

    Kirigami.FormLayout {
        anchors.fill: parent

        RowLayout {
            Kirigami.FormData.label: i18n("Image:")

            Button {
                icon.name: "document-open"
                text: root.cfg_imageUrl.toString() !== ""
                    ? i18n("Replace…")
                    : i18n("Choose…")
                onClicked: imageDialog.open()
            }

            Button {
                enabled: root.cfg_imageUrl.toString() !== ""
                icon.name: "edit-clear"
                text: i18n("Clear")
                onClicked: root.cfg_imageUrl = ""
            }
        }

        Label {
            Layout.fillWidth: true
            text: root.cfg_imageUrl.toString() !== ""
                ? root.displayPath(root.cfg_imageUrl)
                : i18n("No file selected. Use a transparent PNG or WebP.")
            wrapMode: Text.WrapAnywhere
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Height:")
            Layout.fillWidth: true

            Slider {
                id: heightSlider
                Layout.fillWidth: true
                from: root.minHeight
                stepSize: 8
                to: root.maxHeight
                value: root.clampHeight(root.cfg_displayHeight)

                onMoved: {
                    root.cfg_displayHeight = Math.round(value / stepSize) * stepSize;
                }
            }

            SpinBox {
                id: heightSpin
                editable: true
                from: root.minHeight
                stepSize: 8
                to: root.maxHeight
                value: root.clampHeight(root.cfg_displayHeight)

                onValueModified: {
                    root.cfg_displayHeight = value;
                }
            }

            Label {
                text: i18nc("@item:valuesuffix", "px")
            }
        }

        Button {
            Kirigami.FormData.label: i18n("Defaults:")
            icon.name: "edit-undo"
            text: i18n("Reset height")
            onClicked: root.cfg_displayHeight = root.defaultHeight
        }

        Rectangle {
            Kirigami.FormData.label: i18n("Preview:")
            Layout.fillWidth: true
            color: "transparent"
            implicitHeight: Kirigami.Units.gridUnit * 12
            radius: Kirigami.Units.smallSpacing

            border.color: Kirigami.Theme.disabledTextColor
            border.width: 1

            Image {
                id: preview
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing
                asynchronous: true
                cache: false
                fillMode: Image.PreserveAspectFit
                smooth: true
                source: root.cfg_imageUrl
            }

            Label {
                anchors.centerIn: parent
                text: root.cfg_imageUrl.toString() === ""
                    ? i18n("No image selected")
                    : i18n("Preview unavailable")
                visible: root.cfg_imageUrl.toString() === "" || preview.status === Image.Error
            }
        }

        Label {
            Layout.fillWidth: true
            color: Kirigami.Theme.disabledTextColor
            text: i18n("Transparent pixels stay transparent on the desktop. This widget does not remove backgrounds automatically.")
            wrapMode: Text.WordWrap
        }
    }
}
