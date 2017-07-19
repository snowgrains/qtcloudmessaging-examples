import QtQuick 2.0
import "."
Item {
    id: _btnRoot

    width: 100
    height: 40
    property alias text: _text.text
    property alias color: _color.color
    property bool hovered: false


    signal clicked()

    Rectangle {
        id: _color
        anchors.fill: parent
        color: hovered ? Styles.buttons.hovered : Styles.buttons.normal
    }

    KText {
        id: _text
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Styles.fonts.normal
        verticalAlignment: Text.AlignVCenter

        height: parent.height
        width: parent.width
        text: ""
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onHoveredChanged: {
            _btnRoot.hovered = containsMouse
        }
        onClicked: {
            _btnRoot.clicked();
        }
    }
}
