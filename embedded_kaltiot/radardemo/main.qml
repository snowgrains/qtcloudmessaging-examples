import QtQuick 2.6
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import "."
Window {
    visible: true
    width: 1280
    height: 800
    minimumWidth: 1280
    minimumHeight: 800
    title: qsTr("Kaltiot - Push Messaging Demo v0.6")

    property int header_height: height*.12
    property var installed_radars: [0,0,0,0]
    property bool update_installations : true
    property bool started : false
    property string clientID : ""
    property string rid:""
    property var selected_radar_index: 0

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
        height: header_height
        font.pixelSize: Styles.fonts.large
        text: qsTr("CAR RADAR CONFIGURATION")
    }


    TextEdit {
        id: bottomText
        anchors {
            left: parent.left
            bottom: parent.bottom
            leftMargin: Styles.margins.small
        }
        font.family: Styles.fonts.lightFont
        color: Styles.colors.white
        height: header_height
        font.pixelSize: Styles.fonts.small
        text: qsTr("RID:%1").arg(rid)
        selectByMouse: true
        mouseSelectionMode: TextEdit.SelectCharacters

    }

    /**
      * RIGHT SIDE AVAILABLE RADARS AREA
      */
    Item {
        id: _available_radars_area
        width: parent.width*0.5
        anchors {
            right: parent.right
            top:parent.top
            topMargin: header_height

            bottom: parent.bottom
            bottomMargin: parent.height * .4
            margins: Styles.margins.small
        }

        Column {
            anchors.fill: parent
            anchors.margins: Styles.margins.small
            spacing: Styles.margins.small
            KText {
                text: qsTr("ACTIVATED RADARS (power on)")
            }
            ListModel {
                id: available_radars

            }

            GridView {
                id: _grid
                clip: true
                width: parent.width
                height: parent.height*.5
                cellHeight: width*.333/3+Styles.margins.small
                cellWidth:width*.4+Styles.margins.small

                // Repeater {

                model: available_radars
                delegate: Item {
                    width: _grid.cellWidth-Styles.margins.gap
                    height: _grid.cellHeight-Styles.margins.gap


                    Rectangle {
                        anchors.fill: parent
                        color: installed ? "green" : radarColor
                        border.width: 2
                        border.color: selected_radar_index > 0 && selected_radar_index-1 == index ? "green" : "transparent"

                    }
                    Row {
                        anchors.fill: parent
                        anchors.margins: Styles.margins.small
                        spacing: Styles.margins.gap
                        Image {
                            height: parent.height*.5
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                            source: "./images/icon_radar.png"

                        }
                        KText {
                            height: parent.height
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: Styles.fonts.small
                            text: name
                            wrapMode: Text.WrapAnywhere
                            width: parent.width-Styles.margins.gap*2

                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            selected_radar_index = index+1
                        }
                    }

                    //  }
                }
            }
        }
    }
    function next_available_wave() {
        for ( var i=0; i < installed_radars.length; i++) {
            if ( installed_radars[i] === 0) {
                installed_radars[i] = 1;
                return i;
            }
        }

    }
    function update_installed_waves() {
        for ( var i=0; i < installed_radars.length; i++ ) {
            if ( installed_radars[i] === 1 ) {
                switch ( i ) {
                case 0: _left_front_radar_wave.color = Styles.colors.installed_wave; break;
                case 1: _right_front_radar_wave.color = Styles.colors.installed_wave; break;
                case 2: _left_back_radar_wave.color = Styles.colors.installed_wave; break;
                case 3: _right_back_radar_wave.color = Styles.colors.installed_wave; break;
                }
            } else {
                switch ( i ) {
                case 0: _left_front_radar_wave.color = Styles.colors.not_installed_wave; break;
                case 1: _right_front_radar_wave.color = Styles.colors.not_installed_wave; break;
                case 2: _left_back_radar_wave.color = Styles.colors.not_installed_wave; break;
                case 3: _right_back_radar_wave.color = Styles.colors.not_installed_wave; break;
                }
            }
        }
    }
    function get_installed_wave(pos) {
        switch ( pos ) {
        case 0: return _left_front_radar_wave; break;
        case 1: return _right_front_radar_wave; break;
        case 2: return _left_back_radar_wave; break;
        case 3: return _right_back_radar_wave; break;
        }
    }

    function update_installed_radars() {
        for ( var i=0; i < available_radars.count; i++ ) {
            if (  available_radars.get(i).installed === false) {

                var pos = available_radars.get(i).installation_position
                if (pos > -1) {
                    installed_radars[pos] = 0
                    available_radars.get(i).installation_position = -1
                }

                /*switch ( pos ) {
                case 0: _left_front_radar_wave.color = Styles.colors.not_installed_wave; break;
                case 1: _right_front_radar_wave.color = Styles.colors.not_installed_wave; break;
                case 2: _left_back_radar_wave.color = Styles.colors.not_installed_wave; break;
                case 3: _right_back_radar_wave.color = Styles.colors.not_installed_wave; break;
                }*/
            }
            if (  available_radars.get(i).installed === true) {

                var pos = available_radars.get(i).installation_position
                if (pos > -1)
                    installed_radars[pos] = 1
                /*                switch ( pos ) {
                case 0: _left_front_radar_wave.color = Styles.colors.installed_wave; break;
                case 1: _right_front_radar_wave.color = Styles.colors.installed_wave; break;
                case 2: _left_back_radar_wave.color = Styles.colors.installed_wave; break;
                case 3: _right_back_radar_wave.color = Styles.colors.installed_wave; break;
                }*/
            }

        }
       update_installed_waves()
    }

    /**
      * LEFT SIDE INSTALLED RADARS AREA
      */
    Item {

        id: _installed_radars_area

        anchors {
            right: _available_radars_area.left
            top:parent.top
            topMargin: header_height
            left: parent.left
            bottom: parent.bottom
            margins: Styles.margins.small
            rightMargin: Styles.margins.big*2
        }

        Column {
            anchors.fill: parent
            anchors.margins: Styles.margins.small
            spacing: Styles.margins.small
            KText {
                text: qsTr("INSTALLED RADARS")
            }

            Item {
                width: parent.width
                height: 50
            }

            Item {
                width: parent.width*.9
                anchors.horizontalCenter: parent.horizontalCenter
                height: parent.height*.6
                clip: true
                Image {
                    id: _car
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    source: "./images/car.png"

                }
                Image {
                    id: _left_front_radar_wave
                    anchors.right: _car.left
                    anchors.leftMargin: -(_car.width - _car.paintedWidth) - Styles.margins.gap
                    anchors.bottom: _car.top
                    anchors.bottomMargin:-(_car.height - _car.paintedHeight)+Styles.margins.small

                    height: parent.height*.20
                    fillMode: Image.PreserveAspectFit
                    source: "./images/radar_wave.png"
                    rotation: -90
                    property bool installation: false
                    property alias color : _overlay1.color
                    ColorOverlay {
                        id: _overlay1
                        anchors.fill: parent
                        source: parent
                        color: Styles.colors.not_installed_wave
                    }
                }
                Image {
                    id: _right_front_radar_wave
                    anchors.left: _car.right
                    anchors.rightMargin: -(_car.width - _car.paintedWidth) - Styles.margins.gap
                    anchors.bottom: _car.top
                    anchors.bottomMargin:-(_car.height - _car.paintedHeight)+Styles.margins.small

                    height: parent.height*.20
                    fillMode: Image.PreserveAspectFit
                    source: "./images/radar_wave.png"
                    property bool installation: false
                    property alias color : _overlay2.color
                    ColorOverlay {
                        id: _overlay2
                        anchors.fill: parent
                        source: parent
                        color: Styles.colors.not_installed_wave
                    }
                }
                Image {
                    id: _left_back_radar_wave
                    anchors.right: _car.left
                    anchors.leftMargin: -(_car.width - _car.paintedWidth) - Styles.margins.gap
                    anchors.top: _car.bottom
                    anchors.topMargin:-(_car.height - _car.paintedHeight)+Styles.margins.small

                    height: parent.height*.20
                    fillMode: Image.PreserveAspectFit
                    source: "./images/radar_wave.png"
                    rotation: -180
                    property bool installation: false
                    property alias color : _overlay3.color
                    ColorOverlay {
                        id: _overlay3
                        anchors.fill: parent
                        source: parent
                        color:  Styles.colors.not_installed_wave
                    }
                }
                Image {
                    id: _right_back_radar_wave
                    anchors.left: _car.right
                    anchors.rightMargin: -(_car.width - _car.paintedWidth) - Styles.margins.gap
                    anchors.top: _car.bottom
                    rotation: 90
                    anchors.topMargin:-(_car.height - _car.paintedHeight)+Styles.margins.small

                    height: parent.height*.20
                    fillMode: Image.PreserveAspectFit
                    source: "./images/radar_wave.png"
                    property bool installation: false
                    property alias color : _overlay4.color
                    ColorOverlay {
                        id: _overlay4
                        anchors.fill: parent
                        source: parent
                        color: Styles.colors.not_installed_wave
                    }
                }

            }
        }

    }
    KText {
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: Styles.margins.small
        }
        height: parent.height*.12
        font.pixelSize: Styles.fonts.large
        text: qsTr("CAR RADAR CONFIGURATION")
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var payload=[{"payload_type":"STRING","payload":"{\"command\":\"ADD_RADAR\",\"installed\": false, \"radarColor\": \"#252525\", \"name\": \"Radar #1\", \"id\":\"0001\" }"}]
                console.log(JSON.stringify(payload));
                var p = "payload="+JSON.stringify(payload);
                m_pushServices.sendMessage(p,"KaltiotService","","","RadarChannel");

            }
        }
    }

    /**
      * RIGHT BOTTOM AREA FOR SELECTED RADAR
      */
    Column {
        id: _selected_radar_area
        visible: selected_radar_index > 0 ? true : false
        anchors {
            right: parent.right
            bottom: parent.bottom
            left: _available_radars_area.left
            top: _available_radars_area.bottom
            margins: Styles.margins.small
        }
        spacing: Styles.margins.small
        KText {
            text: qsTr("SELECTED RADAR")
        }
        KText {
            text: selected_radar_index > 0 ? available_radars.get(selected_radar_index-1).id : ""
            state:"small"
        }

        KButton {
            width: parent.width

            text: selected_radar_index > 0 && available_radars.get(selected_radar_index-1).installed ? "UnInstall from the car" : "Install to car"
            onClicked: {
                var installed = available_radars.get(selected_radar_index-1).installed
                if ( installed ) {
                    available_radars.setProperty(selected_radar_index-1,"installed", false)

                    sendInstallationInfo( available_radars.get(selected_radar_index-1), "false")
                    var olds = selected_radar_index
                    selected_radar_index=0
                    selected_radar_index=olds

                } else {

                    available_radars.setProperty(selected_radar_index-1,"installed", true)
                    available_radars.setProperty(selected_radar_index-1,"installation_position",next_available_wave())
                    sendInstallationInfo( available_radars.get(selected_radar_index-1), "true")
                    var olds = selected_radar_index
                    selected_radar_index=0
                    selected_radar_index=olds
                }
                update_installed_radars();
            }
        }

    }

    /** SERVER COMMUNICATIONS
      *
      */
    function sendInstallationInfo(data, installed_info){
        var payload = {command:"INSTALLATION_INFO",installed: installed_info, id:data.id }
        var payload_array = [{"rid":data.id,"payload_type":"STRING","payload": encodeURI(JSON.stringify(payload))}]
        var p = "payload="+JSON.stringify(payload_array);
        console.log(p);
        m_pushServices.sendMessage(p,"KaltiotService","",data.id,"use_rest");
    }

    // Broadcast power off for all
    function sendPowerOff() {
        var payload = {command:"POWER_OFF" }
        var payload_array = [{"payload_type":"STRING","payload": encodeURI(JSON.stringify(payload))}]
        var p = "payload="+JSON.stringify(payload_array);

        m_pushServices.sendMessage(p,"KaltiotService","","","RadarChannel");
    }

    Connections {
        target:started ? m_pushServices : null
        ignoreUnknownSignals: true
        onMessageReceived: {
            var data = JSON.parse(decodeURI(message));
            console.log(message)

            switch (data.command) {
            case "ADD_RADAR":
                /**
                      * {"command":"ADD_RADAR","installed": false, "radarColor": "#252525", "name": "Radar #1", "id":"0001" }

                      */

                data.name = "Radar\n"+data.id
                data.installation_position = -1
                available_radars.append(data)
                break;
            case "INSTALLATION_INFO":
                console.log("INSTALLATION INFO")

                break;

            case "UPDATE_RADAR":
                /**
                      * {"command":"UPDATE_RADAR","installed": true, "radarColor": "#252525", "name": "Radar #1", "id":"0001" }

                      */
                for ( var i = 0; i < available_radars.count; i++) {
                    if (available_radars.get(i).id === data.id) {
                        console.log("UPDATING DATA!")
                        available_radars.set(i,data)
                    }
                }

                _grid.update();
                update_installed_radars()


                break;
            case "DELETE_RADAR":
                for ( var i = 0; i < available_radars.count; i++) {
                    var  radar_id = ""+available_radars.get(i).id
                    var  data_id = ""+data.id
                    if (radar_id === data_id) {
                        if ( i === selected_radar_index-1) selected_radar_index = 0

                        var pos = available_radars.get(i).installation_position
                        if ( pos > -1) {
                            installed_radars[pos]=0;
                            var wave = get_installed_wave(pos)
                            _blinkWave.wave = wave;
                            _blinkWave.running = false

                        }

                        available_radars.setProperty(i,"installed", false)
                        update_installed_radars()
                        available_radars.remove(i)
                        _grid.update()
                        break;

                    }
                }





                break;
            case "RADAR_COLLISION":
                update_installed_radars()
                for ( var i = 0; i < available_radars.count; i++) {

                    if (available_radars.get(i).id === data.id) {
                        var pos = available_radars.get(i).installation_position
                        if ( pos > -1) {
                           var wave = get_installed_wave(pos)
                            _blinkWave.wave = wave;
                            _blinkWave.running = _blinkWave.running ? false : true
                             break;
                        }
                    }
                }
                break;
            case "RADAR_MALFUNCTION":
                update_installed_radars()
                for ( var i = 0; i < available_radars.count; i++) {

                    if (available_radars.get(i).id === data.id) {
                        var pos = available_radars.get(i).installation_position
                        if ( pos > -1) {
                           var wave = get_installed_wave(pos)
                            _blinkWave.wave = wave;
                            wave.color = Styles.colors.malfunction

                             break;
                        }
                    }
                }
                break;
            }

        }
        onClientTokenReceived: {
            rid = token;
            console.log("RID:"+rid)

        }
    }
    SequentialAnimation {
        id: _blinkWave
        running: false
        property QtObject wave: null
        loops: Animation.Infinite
        onRunningChanged: {
            if (!running) {
                if ( wave !== null ) wave.opacity = 1
            }
        }

        PropertyAnimation { target: _blinkWave.wave; property:"opacity"; from: 1; to: 0; duration: 500 }
        PropertyAnimation { target: _blinkWave.wave; property:"opacity"; from: 1; to: 0; duration: 500 }

    }

    // Parameters for connection:
    property variant params:{"address":"RadarConsole","version":"0.1", "channels":["RadarChannel","temperature"],"customer_id":"Kaltiot"}

    Component.onCompleted: {

        // connection done in C++ this time.
        // m_pushServices.qConnectClient("KaltiotService","RadarConsole",params);
        started = true


    }
}
