import QtQuick 2.6
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import "."
Window {
    id: root
    visible: true
    width: 300
    height: 300
    minimumWidth: 300
    minimumHeight: 300
    title: qsTr("Kaltiot - Push Messaging Demo v0.6")

    property int header_height: height*.12
    property var installed_radars: [0,0,0,0]
    property int update_installations : 0
    property bool started : false
    property string clientID : ""
    property string rid:""
    property bool installed : false
    property bool power_on: false
    property string status: "Power OFF"
    property var sensordata
    property var connection_parameters:{}
    Image {
        anchors.fill: parent
        source: "./images/background.jpg"
        fillMode: Image.Stretch
    }

    /**
      * HEADER TEXT
      */



    KText {
        id: headerText
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: Styles.margins.small
        }
        height: parent.height*.12
        font.pixelSize: Styles.fonts.medium
        text: qsTr("RADAR Component")
        MouseArea {
            anchors.fill: parent
            onClicked: {

               send_registration()
            }
        }
    }
    TextEdit {
        id: ridText
        anchors {
            left: parent.left
            top: headerText.bottom
            leftMargin: Styles.margins.small
        }
        font.family: Styles.fonts.lightFont
        color: Styles.colors.white
        height: parent.height*.12
        width: parent.width*0.3
        font.pixelSize: Styles.fonts.small
        text: qsTr("RID:%1").arg(rid)
        selectByMouse: true
        mouseSelectionMode: TextEdit.SelectCharacters

    }
    Column {
        anchors.top: ridText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: _statusArea.top
        anchors.margins: Styles.margins.small
        visible: root.installed
        spacing: Styles.margins.gap
        KButton{
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Set Radar Collision"
            width: parent.width
            height: 40

            color: Styles.buttons.normal
            onClicked: {
                send_collision()
            }
        }
        KButton{
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Set Radar Malfunction"
            width: parent.width
            height: 40
            color: Styles.buttons.normal
            onClicked: {
                send_malfunction()
            }
        }

    }

    Rectangle {
        id: _statusArea
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height*.2
        color: Styles.colors.power_off
        border.color:"white"
        border.width: 0
        KText {
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            text: status
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onHoveredChanged: {
                if (containsMouse) {
                    _statusArea.border.width=1
                } else _statusArea.border.width=0
            }

            onClicked: {
                switch ( status.toLowerCase() ) {
                    case "power off":
                        status = "Power ON"
                    break;
                    case "power on":
                        status = "Power OFF"
                        root.installed=false
                        send_deregistration()

                    break;
                    case "installed":
                        status = "Power OFF"
                        root.installed=false
                        send_uninstall()

                    break;
                    case "uninstalled":
                        status = "Power OFF"
                        send_deregistration()
                    break;


                }
            }
        }
    }
    onStatusChanged: {
        switch ( status.toLowerCase() ) {
            case "power on":
                send_registration()
                _statusArea.color = Styles.colors.power_on

            break;
            case "power off":
                _statusArea.color = Styles.colors.power_off
                send_deregistration();
            break;
            case "installed":
                _statusArea.color = Styles.colors.installed
            break;
            case "uninstalled":
                _statusArea.color = Styles.colors.not_installed
            break;
        }
    }

    /** SERVER COMMUNICATIONS
      *
      */
    Connections {
        target: m_pushServices

    }

    Connections {
        target: m_pushServices
        ignoreUnknownSignals: true
        onMessageReceived:  {
            console.log("Message received");
            var msg = decodeURI(message);
            console.log(msg);
            //msg = msg.slice(0, -1)
            var incoming = JSON.parse(msg);
            // Not for me?
            if ( incoming.id !== rid) return;

            root.sensordata = JSON.parse(msg);
            console.log(JSON.stringify(root.sensordata ))

            switch (root.sensordata.command) {
                case "ADD_RADAR":
                    /**
                      * {"command":"ADD_RADAR","installed": false, "radarColor": "#252525", "name": "Radar #1", "id":"0001" }

                      */


                break;
                case "INSTALLATION_INFO":
                    if ( root.sensordata.id === rid ) {
                        root.installed = root.sensordata.installed==="true"?true : false

                        if ( root.installed )
                            status = "Installed"
                        else
                            status ="Uninstalled"

                        console.log(status)
                    }

                break;
                case "UPDATE_RADAR":
                    /**
                      * {"command":"UPDATE_RADAR","installed": true, "radarColor": "#252525", "name": "Radar #1", "id":"0001" }

                   */
                break;
                case "POWER_OFF":
                    status = "Power OFF"
                break;
            }

        }
        onClientTokenReceived:  {
            rid = token;
            console.log("RID:"+rid)

        }
    }

    function send_registration() {
        var payload = {command:"ADD_RADAR",installed: false, radarColor: "#252525", name: root.clientID, id:""+rid }
        var payload_array = [{"payload_type":"STRING","payload": encodeURI(JSON.stringify(payload))}]
        var p = "payload="+JSON.stringify(payload_array);
        console.log(p);
        m_pushServices.sendMessage(p,"KaltiotService","","","RadarChannel");

    }
    function send_deregistration() {
        var payload = root.sensordata
        payload.command = "DELETE_RADAR"

        var payload_array = [{"payload_type":"STRING","payload": encodeURI(JSON.stringify(payload))}]
        var p = "payload="+JSON.stringify(payload_array);
        console.log(p);
        m_pushServices.sendMessage(p,"KaltiotService","","","RadarChannel");

    }
    function send_uninstall() {
        var payload = root.sensordata
        payload.command = "DELETE_RADAR"
        payload.installed = false

        var payload_array = [{"payload_type":"STRING","payload": encodeURI(JSON.stringify(payload))}]
        var p = "payload="+JSON.stringify(payload_array);
        console.log(p);
        m_pushServices.sendMessage(p,"KaltiotService","","","RadarChannel");

    }
    function send_collision() {
        var payload = root.sensordata
        payload.command = "RADAR_COLLISION"


        var payload_array = [{"payload_type":"STRING","payload": encodeURI(JSON.stringify(payload))}]
        var p = "payload="+JSON.stringify(payload_array);
        console.log(p);
        m_pushServices.sendMessage(p,"KaltiotService","","","RadarChannel");

    }
    function send_malfunction() {
        var payload = root.sensordata
        payload.command = "RADAR_MALFUNCTION"


        var payload_array = [{"payload_type":"STRING","payload": encodeURI(JSON.stringify(payload))}]
        var p = "payload="+JSON.stringify(payload_array);
        console.log(p);
        m_pushServices.sendMessage(p,"KaltiotService","","","RadarChannel");

    }

    // Parameters for connection:
    property variant params:{"address":clientID,"version":"0.1", "channels":["RadarChannel"],"customer_id":"Kaltiot"}

    Component.onCompleted: {
        var d = new Date()
        clientID = "RadarSensor";// "radar_"+d.getTime()

        // connection done in C++ this time.
       // m_pushServices.qConnectClient("KaltiotService",clientID,params);


        started = true

    }
}
