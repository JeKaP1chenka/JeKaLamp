#ifndef __BLE_H__
#define __BLE_H__

#include <include.h>

namespace BLE {

bool deviceConnected = false;
BLEServer *pServer;
BLEService *pService;
BLECharacteristic *onOffCharacteristic;
BLECharacteristic *parametersCharacteristic;
BLECharacteristic *alarmCharacteristic;
BLECharacteristic *NetworkCharacteristic;
BLECharacteristic *TimeCharacteristic;

namespace Callbacks {

class ServerCallbacks : public BLEServerCallbacks {
 public:
  void onConnect(BLEServer *pServer) override {
    deviceConnected = true;

    Serial.println("Устройство подключено.");
    // updateDisplay(true, false);
  };
  void onDisconnect(BLEServer *pServer) override {
    deviceConnected = false;
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
      updateData();
    } else {
      Serial.printf(
          "LampState accepts a 1 uint8_t parameteк, and it was passed %d\n",
          length);
    }
  };
  void onRead(BLECharacteristic *pCharacteristic) override {
    uint8_t temp1[1]{_lampSettings->onOff};

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
      _lampSettings->effectType = data[0];
      _lampSettings->brightness = data[1];
      _lampSettings->speed = data[2];
      _lampSettings->effectParameter = data[3];
      _lampSettings->microphone = data[4];
      updateData();
    } else {
      Serial.printf(
          "EffectState accepts 5 uint8_t parameters, and it has been passed "
          "%d\n",
          length);
    }
  };
  void onRead(BLECharacteristic *pCharacteristic) override {
    uint8_t temp[5] = {_lampSettings->effectType, _lampSettings->brightness,
                       _lampSettings->speed, _lampSettings->effectParameter,
                       _lampSettings->microphone};
    pCharacteristic->setValue(temp, 5);
  };
};

class AlarmParametersCallbacks : public BLECharacteristicCallbacks {
  LampSettings *_lampSettings;

 public:
  AlarmParametersCallbacks(LampSettings *lampSettings) {
    _lampSettings = lampSettings;
  }
  void onWrite(BLECharacteristic *pCharacteristic) override {
    uint8_t *data = pCharacteristic->getData();
    auto length = pCharacteristic->getLength();

    if (length == 17) {
      _lampSettings->alarmState = data[0];
      _lampSettings->timeBeforeAlarm = data[1];
      _lampSettings->timeAfterAlarm = data[2];
      for (int i = 3; i < 17; ++i) {
        _lampSettings->timeOfDays[i - 3] = data[i];
      }
      updateData();
    } else {
      Serial.printf(
          "AlarmState accepts 17 uint8_t parameters, and it has been "
          "passed%d\n",
          length);
    }
  }
  void onRead(BLECharacteristic *pCharacteristic) override {
    uint8_t temp[17] = {_lampSettings->alarmState,
                        _lampSettings->timeBeforeAlarm,
                        _lampSettings->timeAfterAlarm};
    for (int i = 3; i < 17; ++i) {
      temp[i] = _lampSettings->timeOfDays[i - 3];
    }
    pCharacteristic->setValue(temp, 17);
  }
};

class NetworkParametersCallbacks : public BLECharacteristicCallbacks {

 public:
  void onWrite(BLECharacteristic *pCharacteristic) override {
    uint8_t *data = pCharacteristic->getData();
    auto length = pCharacteristic->getLength();

    if (length == 4) {

    } else {
      Serial.printf(
          "NetworkState accepts 17 uint8_t parameters, and it has been "
          "passed%d\n",
          length);
    }
  }
  // void onRead(BLECharacteristic *pCharacteristic) override {
  // }
};


class TimeParametersCallbacks : public BLECharacteristicCallbacks {

 public:
  void onWrite(BLECharacteristic *pCharacteristic) override {
    uint8_t *data = pCharacteristic->getData();
    auto length = pCharacteristic->getLength();

    if (length == 4) {
      now.sec = ;
      now.min = ;
      now.hour = ;
      now.day = ;
      now.setMs(0)
    } else {
      Serial.printf(
          "TimeState accepts 17 uint8_t parameters, and it has been "
          "passed%d\n",
          length);
    }
  }
  // void onRead(BLECharacteristic *pCharacteristic) override {
  // }
};



}  // namespace Callbacks
void initBLE(LampSettings *lampSettings) {
  Serial.println("Запуск BLE-сервера...");
  BLEDevice::init(BLE_SERVER_NAME);

  pServer = BLEDevice::createServer();
  pServer->setCallbacks(new Callbacks::ServerCallbacks());

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

  alarmCharacteristic = pService->createCharacteristic(
      ALARM_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
                                     BLECharacteristic::PROPERTY_WRITE |
                                     BLECharacteristic::PROPERTY_NOTIFY);
  alarmCharacteristic->setCallbacks(
      new Callbacks::AlarmParametersCallbacks(lampSettings));
  alarmCharacteristic->addDescriptor(new BLE2902());

  NetworkCharacteristic = pService->createCharacteristic(
      ALARM_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
                                     BLECharacteristic::PROPERTY_WRITE |
                                     BLECharacteristic::PROPERTY_NOTIFY);
  NetworkCharacteristic->setCallbacks(
      new Callbacks::NetworkParametersCallbacks());
  NetworkCharacteristic->addDescriptor(new BLE2902());

  TimeCharacteristic = pService->createCharacteristic(
      ALARM_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
                                     BLECharacteristic::PROPERTY_WRITE |
                                     BLECharacteristic::PROPERTY_NOTIFY);
  TimeCharacteristic->setCallbacks(
      new Callbacks::TimeParametersCallbacks());
  TimeCharacteristic->addDescriptor(new BLE2902());


  pService->start();

  pServer->getAdvertising()->start();
  Serial.println("BLE-сервер запущен и ожидает подключений.");
}
}  // namespace BLE

#endif  // __BLE_H__