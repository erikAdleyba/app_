import QtQuick 2.15
import QtQuick.Controls 2.15
import QtPositioning 5.2
import QtLocation 5.3


Window {
    visible: true
    color: "#3C4F41"
    width: 1600
    height: 900
    title: "5TC"

    

    StackView {
        id: stackView
        initialItem: homePage
        anchors.fill: parent
    }

    Component {
        id: homePage

        Item {
            property bool soundOn: true
            property int batteryLevel: 75
            property bool enableOn: false
            property string warningMessage: ""
            property string frequencyRange: ""

            

            Text {
                text: "Система 5TC"
                font.pixelSize: 40
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 20
            }

            // Блок с иконкой звука
            MouseArea {
                id: soundButtonArea
                width: 75
                height: 75
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 25
                anchors.leftMargin: 160

                Rectangle {
                    color: "transparent"
                    border.color: "#FFFFFF"
                    border.width: 2
                    radius: 10
                    width: parent.width
                    height: parent.height

                    Image {
                        id: soundIcon
                        source: soundOn ? "image/on_sound.png" : "image/off_sound.png"
                        anchors.centerIn: parent
                        width: 50
                        height: 50
                    }
                }

                Timer {
                    id: soundResetTimer
                    interval: controller.timerDuration  // Используем значение из контроллера
                    repeat: false
                    onTriggered: {
                        soundOn = true
                        controller.soundOn = true
                        controller.soundToggled()
                        controller.add_log("Звук автоматически включен")
                    }
                }

                onClicked: {
                    soundOn = !soundOn
                    soundResetTimer.start()  // Запускаем таймер после изменения состояния звука
                    controller.toggle_sound()
                }
            }

            // Кнопка включения устройства
            MouseArea {
                id: enableButtonArea
                width: 120
                height: 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: soundButtonArea.bottom
                anchors.topMargin: 30

                Rectangle {
                    color: enableOn ? "#FF7373" : "#66CC66"
                    border.color: "white"
                    border.width: 2
                    radius: 10
                    anchors.fill: parent

                    Text {
                        text: enableOn ? "Выкл" : "Вкл"
                        font.pixelSize: 20
                        color: "white"
                        anchors.centerIn: parent
                    }
                }

                onClicked: {
                    enableOn = !enableOn
                    controller.toggle_enable()
                }
            }

            // Уровень заряда батареи
            Text {
                id: batteryPercentage
                text: batteryLevel + "%"
                font.pixelSize: 50
                font.bold: true
                color: batteryLevel > 60 ? "lightgreen" : batteryLevel >= 20 ? "yellow" : "red"
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 160
                anchors.topMargin: 25
            }

            // Предупреждение о дроне
            Rectangle {
                id: warningBox
                color: warningMessage !== "" ? "#FF4C4C" : "transparent"
                width: 400
                height: 150
                border.color: warningMessage !== "" ? "#FF0000" : "transparent"
                border.width: 2
                radius: 10
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                visible: warningMessage !== ""

                Column {
                    anchors.centerIn: parent

                    Text {
                        text: warningMessage
                        font.pixelSize: 30
                        color: "white"
                        font.bold: true
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: frequencyRange
                        font.pixelSize: 18
                        color: "white"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }

            // Кнопки для переходов
            Row {
                spacing: 50
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 50
                anchors.horizontalCenter: parent.horizontalCenter

                MouseArea {
                    id: mapButton
                    width: 75
                    height: 75

                    Image {
                        source: "image/map.png"
                        anchors.fill: parent
                    }

                    onClicked: controller.log_event("Переход на карту")
                }

                MouseArea {
                    id: settingsButton
                    width: 75
                    height: 75

                    Image {
                        source: "image/setting.png"
                        anchors.fill: parent
                    }

                    onClicked: {
                        controller.log_event("Переход к настройкам")
                        stackView.push(Qt.createComponent("settings.qml"))
                    }
                }

                MouseArea {
                    id: logsButton
                    width: 75
                    height: 75

                    Image {
                        source: "image/log1.png"
                        anchors.fill: parent
                    }

                    onClicked: {
                        controller.log_event("Переход к логам")
                        stackView.push(Qt.createComponent("LogsPage.qml"))
                    }
                }
            }

            Connections {
                target: controller

                function onWarningMessageChanged(newMessage) {
                    warningMessage = newMessage
                }

                function onFrequencyRangeChanged(newRange) {
                    frequencyRange = newRange
                }

                function onSoundToggled() {
                    soundOn = controller.soundOn
                }

                function onEnableSignal() {
                    enableOn = controller.enableOn
                }
            }
        }
    }
}
