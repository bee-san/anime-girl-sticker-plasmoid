import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18nc("@title:tab", "General")
        icon: "configure"
        source: "configGeneral.qml"
    }
}
