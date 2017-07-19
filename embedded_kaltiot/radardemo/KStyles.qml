pragma Singleton

import QtQuick 2.0

Item {

    /** Colors
      *
      */
    property QtObject colors: QtObject {
        property color white: "white"
        property color not_installed_wave: "#777575"
        property color installed_wave : "white"
        property color not_installed : "#9900FF00"
        property color installed : "#990000FF"
        property color power_on: "#9900FF00"
        property color power_off: "#11FFFFFF"
         property color malfunction: "#AAFF0000"
    }
    /** Margins
      *
      */
    property QtObject margins: QtObject {
        property int gap: 5
        property int small: 20
        property int medium: 30
        property int big: 50
    }

    /** Font styles
      * Fonts and sizes
      */
    property QtObject fonts : QtObject {
        property int tiny: 10
        property int small: 14
         property int normal: 18
        property int medium : 24
        property int large: 30
        property int header: 50

        property string lightFont : lightFont.name
        property string normalFont : normalFont.name
        property string thinFont : thinFont.name

    }
    property QtObject buttons: QtObject {
        property color hovered: "#9900FF00"
        property color normal: "#777575"
    }

    FontLoader {
        id: thinFont
        source: "./fonts/Montserrat-Thin.ttf"
        name: "MontserratThin"

    }
    FontLoader {
        id: lightFont
        source: "./fonts/Montserrat-Light.ttf"
        name: "MontserratThin"
    }
    FontLoader {
        id: normalFont
        source: "./fonts/Montserrat-Regular.ttf"
        name: "MontserratReqular"
    }

}
