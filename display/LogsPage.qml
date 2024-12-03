import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    id: logsPage
    property var controller: null // Объявляем свойство для контроллера

    // Заголовок страницы
    Text {
        text: "Логи"
        font.pixelSize: 40
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
    }

    // Список для отображения логов
    ListView {
        id: logsListView
        model: controller ? controller.logs : [] // Используем модель логов из контроллера
        anchors.fill: parent
        anchors.topMargin: 80 // Отступ от заголовка
        delegate: Item {
            width: logsListView.width
            height: 40

            Rectangle {
                width: parent.width
                height: parent.height
                color: "#3C4F41" // Цвет фона для строк
                border.color: "white"
                border.width: 1
                radius: 5
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: modelData
                    font.pixelSize: 18
                    color: "white"
                    anchors.centerIn: parent
                }
            }
        }

        // Обработчик для обновления списка при изменении данных
        onModelChanged: {
            if (model.count > 0) {
                currentIndex = model.count - 1
            }
        }
    }

    // Кнопка назад
    Button {
        text: "Назад"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            stackView.pop() // Возврат на предыдущую страницу
        }
    }

    // Обновляем список логов при открытии страницы
    Component.onCompleted: {
        if (controller) {
            controller.loadLogs(); // Загружаем логи при открытии страницы
        } else {
            console.log("Контроллер не инициализирован.");
        }
    }
}