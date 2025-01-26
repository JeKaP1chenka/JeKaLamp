#ifndef __BLE_H__
#define __BLE_H__

#include <include.h>

namespace BLE {

BLEServer *pServer;
BLEService *pService;
BLECharacteristic *onOffCharacteristic;
BLECharacteristic *parametersCharacteristic;

namespace Callbacks {

class ServerCallbacks : public BLEServerCallbacks {
  LampSettings *_lampSettings;

 public:
  ServerCallbacks(LampSettings *lampSettings) { _lampSettings = lampSettings; };
  void onConnect(BLEServer *pServer) override {
    _lampSettings->deviceConnected = true;
    Serial.println("Устройство подключено.");
    // updateDisplay(true, false);
  };
  void onDisconnect(BLEServer *pServer) override {
    _lampSettings->deviceConnected = false;
    Serial.println("Устройство отключено.");
    Serial.println("Рекламирование BLE перезапущено.");
    pServer->getAdvertising()->start();
    // updateDisplay(false, true);
  };
};

class LampOnOffCallbacks : public BLECharacteristicCallbacks {
  LampSettings *_lampSettings;

 public:
  LampOnOffCallbacks(LampSettings *lampSettings) {
    _lampSettings = lampSettings;
  };
  void onWrite(BLECharacteristic *pCharacteristic) override {
    uint8_t *data = pCharacteristic->getData();
    auto length = pCharacteristic->getLength();

    if (length == 1) {
      _lampSettings->onOff = data[0];
      // updateDisplay(true, false);
    } else {
      Serial.printf(
          "LampState accepts a 1 uint8_t parameteк, and it was passed %d",
          length);
    }
  };
  void onRead(BLECharacteristic *pCharacteristic) override {
    uint8_t temp1[1]{
        _lampSettings->onOff,
    };

    pCharacteristic->setValue(temp1, 1);
  };
};

class EffectParametersCallbacks : public BLECharacteristicCallbacks {
  LampSettings *_lampSettings;

 public:
  EffectParametersCallbacks(LampSettings *lampSettings) {
    _lampSettings = lampSettings;
  };
  void onWrite(BLECharacteristic *pCharacteristic) override {
    uint8_t *data = pCharacteristic->getData();
    auto length = pCharacteristic->getLength();

    if (length == 5) {
      /**
       * 0 - effectType
       * 1 - brightness (яркость)
       * 2 - speed
       * 3 - effectParameter
       */
      _lampSettings->effectType = data[0];
      _lampSettings->brightness = data[1];
      _lampSettings->speed = data[2];
      _lampSettings->effectParameter = data[3];
      _lampSettings->microphone = data[4];

      // updateDisplay(true, false);
    } else {
      Serial.printf(
          "EffectState accepts 5 uint8_t parameters, and it has been passed %d",
          length);
    }
  };
  void onRead(BLECharacteristic *pCharacteristic) override {
    uint8_t temp[5] = {
        _lampSettings->effectType,
        _lampSettings->brightness,
        _lampSettings->speed,
        _lampSettings->effectParameter,
        _lampSettings->microphone,
    };
    pCharacteristic->setValue(temp, 5);
  };
};

}  // namespace Callbacks
void initBLE(LampSettings *lampSettings) {
  Serial.println("Запуск BLE-сервера...");
  BLEDevice::init(BLE_SERVER_NAME);

  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new Callbacks::ServerCallbacks(lampSettings));

  pService = pServer->createService(LAMP_STATE_SERVICE_UUID);

  onOffCharacteristic = pService->createCharacteristic(
      ON_OFF_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
                                      BLECharacteristic::PROPERTY_WRITE |
                                      BLECharacteristic::PROPERTY_NOTIFY);
  onOffCharacteristic->setCallbacks(
      new Callbacks::LampOnOffCallbacks(lampSettings));
  onOffCharacteristic->addDescriptor(new BLE2902());

  parametersCharacteristic = pService->createCharacteristic(
      PARAMETERS_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
                                          BLECharacteristic::PROPERTY_WRITE |
                                          BLECharacteristic::PROPERTY_NOTIFY);
  parametersCharacteristic->setCallbacks(
      new Callbacks::EffectParametersCallbacks(lampSettings));
  parametersCharacteristic->addDescriptor(new BLE2902());

  pService->start();

  pServer->getAdvertising()->start();
  Serial.println("BLE-сервер запущен и ожидает подключений.");
}
}  // namespace BLE

#endif  // __BLE_H__