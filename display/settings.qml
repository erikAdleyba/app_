import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: parent ? parent.width : 800  // Задаем начальные значения, если parent не определен
    height: parent ? parent.height : 600

    // Заголовок
    Text {
        text: "Настройки"
        font.pixelSize: 40
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
    }

    Column {
        spacing: 30
        anchors.centerIn: parent
        width: parent.width * 0.6

        // Настройка таймера (часы, минуты, секунды)
        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "Длительность таймера:"
                font.pixelSize: 24
                color: "white"
                verticalAlignment: Text.AlignVCenter
            }

            Column {
                spacing: 5
                Row {
                    SpinBox {
                        id: hoursSpinBox
                        from: 0
                        to: 23
                        stepSize: 1
                        value: Math.floor(controller ? controller.timerDuration / 3600000 : 0)  // Преобразуем миллисекунды в часы
                        width: 60
                        onValueModified: updateTimerDuration()
                    }
                    Text {
                        text: "ч"
                        font.pixelSize: 16
                        color: "white"
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Row {
                    SpinBox {
                        id: minutesSpinBox
                        from: 0
                        to: 59
                        stepSize: 1
                        value: Math.floor((controller ? controller.timerDuration % 3600000 : 0) / 60000)  // Преобразуем миллисекунды в минуты
                        width: 60
                        onValueModified: updateTimerDuration()
                    }
                    Text {
                        text: "мин"
                        font.pixelSize: 16
                        color: "white"
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                Row {
                    SpinBox {
                        id: secondsSpinBox
                        from: 0
                        to: 59
                        stepSize: 1
                        value: Math.floor((controller ? controller.timerDuration % 60000 : 0) / 1000)  // Преобразуем миллисекунды в секунды
                        width: 60
                        onValueModified: updateTimerDuration()
                    }
                    Text {
                        text: "сек"
                        font.pixelSize: 16
                        color: "white"
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
        // Кнопка для проверки оборудования
        Row {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.6

            Text {
                text: "Проверка оборудования:"
                font.pixelSize: 24
                color: "white"
                verticalAlignment: Text.AlignVCenter
            }

            Button {
                text: "Запустить проверку"
                font.pixelSize: 20
                onClicked: {
                    if (controller && controller.check_hardware) {
                        controller.check_hardware()
                        controller.add_log("Начата проверка оборудования")
                    } else {
                        console.log("Ошибка: Функция check_hardware не найдена в controller")
                    }
                }
            }
        }

        // Кнопка возврата на главный экран
        Button {
            text: "Назад"
            font.pixelSize: 20
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: stackView.pop()
        }
    }

    // Функция для обновления значения таймера
    function updateTimerDuration() {
        if (!controller) {
            console.log("Ошибка: controller не инициализирован");
            return;
        }
        var newDuration = (hoursSpinBox.value * 3600000) + (minutesSpinBox.value * 60000) + (secondsSpinBox.value * 1000)
        controller.timerDuration = newDuration
        controller.add_log("Длительность таймера изменена на " + hoursSpinBox.value + " ч " + minutesSpinBox.value + " мин " + secondsSpinBox.value + " сек")
    }
}
