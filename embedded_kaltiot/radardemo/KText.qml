import QtQuick 2.0
import "."

Text {
    height: paintedHeight
    width: paintedWidth
    verticalAlignment: Text.AlignVCenter
    font.pixelSize: Styles.fonts.medium
    font.family: Styles.fonts.lightFont
    color: Styles.colors.white
    text: ""

    property string state : "medium"

    onStateChanged: {
     switch ( state ) {
         case "normal":
             color = Styles.colors.white
             font.pixelSize = Styles.fonts.normal
         break;
         case "medium":
             color = Styles.colors.white
             font.pixelSize = Styles.fonts.medium
         break;
         case "small":
             color = Styles.colors.white
             font.pixelSize = Styles.fonts.small
         break;
         case "large":
             color = Styles.colors.white
             font.pixelSize = Styles.fonts.large
         break;
         case "tiny":
             color = Styles.colors.white
             font.pixelSize = Styles.fonts.tiny
         break;
     }
    }
}
