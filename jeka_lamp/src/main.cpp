#include <Arduino.h>
#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <GyverOLED.h>
// Название BLE-сервера
#define BLE_SERVER_NAME "ESP32_BLE_Server"

// UUID сервиса и характеристики
#define SERVICE_UUID "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// Глобальные переменные
BLECharacteristic *pCharacteristic;
BLEServer *pServer;
bool deviceConnected = false;

GyverOLED<SSD1306_128x64> oled;

// Класс для обработки соединения
class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *pServer) {
    deviceConnected = true;
    Serial.println("Устройство подключено.");
    oled.clear();
    oled.setCursor(0, 1);
    oled.autoPrintln(true);
    oled.setScale(1);
    oled.print("подключено");
    oled.update();
  }

  void onDisconnect(BLEServer *pServer) {
    deviceConnected = false;
    Serial.println("Устройство отключено.");
    oled.setCursor(0, 1);
    oled.autoPrintln(true);
    oled.setScale(1);
    oled.print("отключено");
    oled.update();
    // Перезапуск рекламирования BLE
    pServer->getAdvertising()->start();
    Serial.println("Рекламирование BLE перезапущено.");
    oled.setCursor(0, 2);
    oled.autoPrintln(true);
    oled.setScale(1);
    oled.print("перезапущено");
    oled.update();
  }
};

// Класс для обработки передачи данных
class MyCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *pCharacteristic) {
    std::string value = pCharacteristic->getValue();

    if (value.length() > 0) {
      Serial.println("Получена строка от клиента:");
      Serial.println(value.c_str());
      oled.setCursor(0, 0);
      oled.autoPrintln(true);
      oled.setScale(1);
      oled.print(value.c_str());
      oled.update();
    }
  }
};

void setup() {
  Serial.begin(115200);
  oled.init(21, 22);
  oled.clear();
  oled.home();
  oled.autoPrintln(true);
  oled.setScale(1);
  // Serial.print("clear");
  oled.print("");
  oled.update();
  Serial.println("Запуск BLE-сервера...");

  // Инициализация BLE
  BLEDevice::init(BLE_SERVER_NAME);

  // Создание BLE-сервера
  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  // Создание BLE-сервиса
  BLEService *pService = pServer->createService(SERVICE_UUID);

  // Создание BLE-характеристики
  pCharacteristic = pService->createCharacteristic(
      CHARACTERISTIC_UUID,
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE);

  pCharacteristic->setCallbacks(new MyCallbacks());
  pCharacteristic->addDescriptor(new BLE2902());

  // Запуск сервиса
  pService->start();

  // Рекламирование BLE
  pServer->getAdvertising()->start();
  Serial.println("BLE-сервер запущен и ожидает подключений.");
}

void loop() {
  // Основной цикл
  if (deviceConnected) {
    // Здесь можно обработать логику для подключенного клиента
    // oled.clear();
    // oled.home();
    // oled.autoPrintln(true);
    // oled.setScale(1);
    // // Serial.print("clear");
    // oled.print("");
    // oled.update();
  }
}
