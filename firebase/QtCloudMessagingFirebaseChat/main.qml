/*!
  \brief Qt Cloud Messaging demo using Google's Firebase as service provider.
  \author Ari Salmi, SnowGrains. together with Kaltiot Oy.
  \copyright All rights reserved (c) SnowGrains 2017.
  \version: 1.0
*/
import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Qt.labs.settings 1.0


Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Qt Cloud Messaging Firebase Demo")

    Image {
        anchors.fill: parent
        source:"./images/background.png"
    }
    Rectangle {
        id: header

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 50
        color: "#5ECCCC"
        Text {
            anchors.fill: parent
            anchors.margins: parent.width*.1
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: "Qt Cloud Messaging Firebase Demo\nChatRoom"
            font.pixelSize: 15
            color: "black"
        }
    }

    ListModel {
        id: messages
    }

    ListView {
        id: msgList
        anchors.top: header.bottom
        anchors.topMargin: 2
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: _msgSender.top
        clip: true
        model: messages
        delegate: Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width-5
            height:  msgArea.paintedHeight < 50 ? 50 : msgArea.paintedHeight*1.5
            color: "transparent"


            Image {
                id: msgImage
                width: source !== "" ?  parent.width*.2 : 0
                height: parent.height*.8
                anchors.margins: 8
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source:"./images/logos.png"

            }


            Text {
                id: msgArea

                width: parent.width-msgImage.width-8
                anchors.left: msgImage.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.Wrap
                anchors.margins: 4
                font.pixelSize: 16
                color: "black"
                text: message.text
            }
            Rectangle{
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 2
                color: "lightgray"
                opacity: 0.8
            }

        }
    }

    // Add text message
    Rectangle {
        id: _msgSender
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: edit.contentHeight < 50 ? 50 : edit.contentHeight*1.5
        border.color: "black"
        border.width: 4

        TextInput{
            id: edit
            anchors.right: parent.right
            anchors.margins: 8
            height: contentHeight
            anchors.left: parent.left

            wrapMode: TextInput.Wrap
            selectByMouse: true

            anchors.verticalCenter:parent.verticalCenter

            color: "black"
            font.pixelSize: 20
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            onAccepted: {
                sendMessage(edit.text)
                edit.text = "sending..."
            }
        }


        Image {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            fillMode: Image.PreserveAspectFit
            source: "./images/add.png"
            anchors.margins: parent.border.width

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    sendMessage(edit.text)
                    edit.text = "sending..."
                }
            }


        }
    }
    function sendMessage(msg){
        var data = { "data":{
                 "message": {"text":msg } },
                 "notification" : {
                    "body" : msg.slice(0,20),
                    "title" : "Qt Cloud Messaging Chat"
            }
        }

        m_qtcloudmsg.sendMessage(JSON.stringify(data),"GoogleFireBase","MobileClient","","ChatRoom");
    }


    function appendMessage(msg) {
        try {
            var appendThis = JSON.parse(msg);
            console.log(JSON.stringify(appendThis))
            messages.append(appendThis.data)
            msgList.positionViewAtEnd();
        } catch(e) {
            console.log(e);
        }

    }

    Connections{
        target:m_qtcloudmsg
        onMessageReceived:{
            if ( edit.text === "sending...") edit.text = "";
            console.log(message)

            appendMessage(message)
        }
    }
    Component.onCompleted: {

    }
}
