import os
from datetime import datetime
from PySide6.QtCore import QObject, Property, Signal, Slot, QStringListModel

class Controller(QObject):
    # Сигналы
    logsChanged = Signal()
    availableLogDatesChanged = Signal()
    warningMessageChanged = Signal(str)
    frequencyRangeChanged = Signal(str)
    batteryLevelChanged = Signal(int)
    soundToggled = Signal()
    enableSignal = Signal()
    timerDurationChanged = Signal(int)

    def __init__(self):
        super().__init__()
        self._batteryLevel = 75
        self._soundOn = True
        self._enableOn = False
        self._timerDuration = self.load_timer_duration()
        self._logs = QStringListModel()  # Модель для логов
        self._availableLogDates = QStringListModel()
        self.load_available_log_dates()
        self.load_logs_for_selected_date(self.get_log_file_name())

    # Свойство для отображения логов
    @Property('QVariant', notify=logsChanged)
    def logs(self):
        return self._logs

    @Slot()
    def check_hardware(self):
        print("Проверка происходит")
        self.add_log("Проверка оборудования выполнена успешно.")

    # Свойство для отображения доступных дат логов
    @Property('QVariant', notify=availableLogDatesChanged)
    def availableLogDates(self):
        return self._availableLogDates

    def load_available_log_dates(self):
        """Загружает список доступных дат логов из директории 'logs'."""
        log_dir = "logs"
        dates = []
        if os.path.exists(log_dir):
            dates = [
                f for f in os.listdir(log_dir)
                if os.path.isfile(os.path.join(log_dir, f)) and f.startswith("logs_") and f.endswith(".txt")
            ]
            dates.sort(reverse=True)  # Сортируем даты по убыванию
        self._availableLogDates.setStringList(dates)
        self.availableLogDatesChanged.emit()

    @Slot(str)
    def load_logs_for_selected_date(self, selected_date):
        """Загружает логи для выбранной даты."""
        log_file_path = os.path.join("logs", selected_date)
        if os.path.exists(log_file_path) and os.path.isfile(log_file_path):
            with open(log_file_path, "r") as file:
                logs = [line.strip() for line in file.readlines()]
                self._logs.setStringList(logs)
        else:
            self._logs.setStringList(["Логи не найдены"])
        self.logsChanged.emit()

    @Slot()
    def loadLogs(self):
        """Загружает все логи из директории 'logs'."""
        log_dir = "logs"
        all_logs = []
        if os.path.exists(log_dir):
            log_files = [f for f in os.listdir(log_dir) if f.startswith("logs_") and f.endswith(".txt")]
            for log_file in log_files:
                log_data = self.load_log(log_file)
                if log_data:
                    all_logs.extend(log_data)

        if all_logs:
            self._logs.setStringList(all_logs)
        else:
            self._logs.setStringList(["Нет доступных логов."])
        self.logsChanged.emit()

    def load_log(self, log_file):
        """Загружает содержимое указанного лог-файла."""
        log_file_path = os.path.join("logs", log_file)
        if os.path.exists(log_file_path):
            with open(log_file_path, "r") as file:
                return [line.strip() for line in file.readlines()]
        return []

    def get_log_file_name(self):
        """Получает имя файла лога для текущей даты."""
        today_date = datetime.now().strftime("%Y-%m-%d")
        return f"logs_{today_date}.txt"

    def get_log_file_path(self):
        """Возвращает путь к файлу логов с названием по текущей дате"""
        return os.path.join("logs", self.get_log_file_name())

    def write_log_to_file(self, log_entry):
        """Запись логов в файл с именем по текущей дате"""
        log_file_path = self.get_log_file_path()
        os.makedirs("logs", exist_ok=True)
        with open(log_file_path, "a") as file:
            file.write(log_entry + "\n")
        self.load_available_log_dates()

    @Slot(str)
    def add_log(self, log_entry):
        """Добавление новой записи в логи с временной меткой"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        full_log_entry = f"{timestamp} - {log_entry}"
        logs_list = self._logs.stringList()
        logs_list.append(full_log_entry)
        self._logs.setStringList(logs_list)
        self.logsChanged.emit()
        self.write_log_to_file(full_log_entry)

    # Таймер
    @Property(int, notify=timerDurationChanged)
    def timerDuration(self):
        return self._timerDuration

    @timerDuration.setter
    def timerDuration(self, value):
        self._timerDuration = value
        self.timerDurationChanged.emit(value)
        self.save_timer_duration(value)
        self.add_log(f"Время таймера изменено на {value} мс")

    def load_timer_duration(self):
        """Загрузка значения таймера из файла settings.txt"""
        if os.path.exists("settings.txt"):
            with open("settings.txt", "r") as file:
                for line in file:
                    if line.startswith("timerDuration:"):
                        try:
                            return int(line.split(":")[1].strip())
                        except ValueError:
                            return 5000  # Значение по умолчанию, если произошла ошибка
        return 5000

    def save_timer_duration(self, value):
        """Сохранение значения таймера в файл settings.txt"""
        with open("settings.txt", "w") as file:
            file.write(f"timerDuration: {value}")

    # Дополнительные свойства и методы
    @Property(int, notify=batteryLevelChanged)
    def batteryLevel(self):
        return self._batteryLevel

    @batteryLevel.setter
    def batteryLevel(self, value):
        if 0 <= value <= 100:
            self._batteryLevel = value
            self.batteryLevelChanged.emit(value)

    @Property(bool, notify=soundToggled)
    def soundOn(self):
        return self._soundOn

    @soundOn.setter
    def soundOn(self, value):
        self._soundOn = value
        self.soundToggled.emit()

    @Property(bool, notify=enableSignal)
    def enableOn(self):
        return self._enableOn

    @enableOn.setter
    def enableOn(self, value):
        self._enableOn = value
        self.enableSignal.emit()

    @Slot(int)
    def process_data(self, value):
        if value == 1:
            self.warningMessageChanged.emit("Внимание, обнаружен дрон!")
            self.frequencyRangeChanged.emit("Диапазон частот: 10 Hz - 20 Hz")
            self.add_log("Обнаружен дрон с диапазоном: 10 Hz - 20 Hz")
        elif value == 2:
            self.warningMessageChanged.emit("Внимание, обнаружен дрон!")
            self.frequencyRangeChanged.emit("Диапазон частот: 50 Hz - 60 Hz")
            self.add_log("Обнаружен дрон с диапазоном: 50 Hz - 60 Hz")
        elif value == 0:
            self.warningMessageChanged.emit("")
            self.frequencyRangeChanged.emit("")
            self.add_log("Система очищена.")
        else:
            print("Неверный ввод. Введите 0, 1 или 2.")

    @Slot()
    def toggle_sound(self):
        self.soundOn = not self.soundOn
        log_message = "Звук переключен: " + ("включен" if self.soundOn else "выключен")
        print(log_message)
        self.add_log(log_message)

    @Slot()
    def auto_enable_sound(self):
        """Метод для автоматического включения звука, вызывается таймером"""
        if not self._soundOn:
            self.soundOn = True
            self.add_log("Автоматическое включение звука")

    @Slot()
    def toggle_enable(self):
        self.enableOn = not self.enableOn
        print(f"Устройство: {'Включено' if self.enableOn else 'Выключено'}")
        self.add_log("Устройство " + ("включено" if self.enableOn else "выключено"))

    @Slot()
    def log_page_transition(self, page_name):
        """Запись логов переходов на страницу"""
        self.add_log(f"Переход на страницу: {page_name}")

    @Slot()
    def log_program_start(self):
        """Логирование запуска программы"""
        self.add_log("Программа запущена")

    @Slot()
    def log_program_exit(self):
        """Логирование выхода из программы"""
        self.add_log("Программа завершена")

    @Slot(str)
    def log_event(self, event_message):
        """Метод для записи событий в лог."""
        self.add_log(event_message)
