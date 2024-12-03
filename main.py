import sys
import threading
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from controller import Controller

def console_input(controller):
    """Функция для приема данных с консоли и их отправки в контроллер."""
    while True:
        try:
            user_input = input("Введите 0, 1 или 2 для изменения частоты: ")
            if user_input in ['0', '1', '2']:
                controller.process_data(int(user_input))
            else:
                print("Неверный ввод, введите 0, 1 или 2.")
        except Exception as e:
                print(f"Ошибка: {e}")

if __name__ == "__main__":  # Исправлено с name на __name__
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    controller = Controller()
    engine.rootContext().setContextProperty("controller", controller)

    engine.load("display/main.qml")

    if not engine.rootObjects():
        sys.exit(-1)

    input_thread = threading.Thread(target=console_input, args=(controller,), daemon=True)
    input_thread.start()

    try:
        sys.exit(app.exec())
    finally:
        controller.log_event("Программа завершена")  # Логирование при завершении программы
