#ifndef __BLE_H__
#define __BLE_H__

#include <include.h>

#include <LampSettings.hpp>
#include <data.hpp>
#include <wifiFunc.hpp>

namespace BLE {

namespace Callbacks {

class ServerCallbacks : public BLEServerCallbacks {
 public:
  void onConnect(BLEServer *pServer) override {
    deviceConnected = true;
#if (SERIAL_LOG == 1)
    Serial.println("Устройство подключено.");
#endif
    // updateDisplay(true, false);
  }
  void onDisconnect(BLEServer *pServer) override {
    deviceConnected = false;
#if (SERIAL_LOG == 1)

    Serial.println("Устройство отключено.");
    Serial.println("Рекламирование BLE перезапущено.");
    pServer->getAdvertising()->start();
#endif

    // updateDisplay(false, true);
  }
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
#if (SERIAL_LOG == 1)

      Serial.printf(
          "LampState accepts a 1 uint8_t parameteк, and it was passed %d\n",
          length);
#endif
    }
  }
  void onRead(BLECharacteristic *pCharacteristic) override {
    uint8_t temp1[1]{_lampSettings->onOff};

    pCharacteristic->setValue(temp1, 1);
  }
};

class EffectParametersCallbacks : public BLECharacteristicCallbacks {
  LampSettings *_lampSettings;

 public:
  EffectParametersCallbacks(LampSettings *lampSettings) {
    _lampSettings = lampSettings;
  }
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
#if (SERIAL_LOG == 1)

      Serial.printf(
          "EffectState accepts 5 uint8_t parameters, and it has been passed "
          "%d\n",
          length);
#endif
    }
  }
  void onRead(BLECharacteristic *pCharacteristic) override {
    uint8_t temp[5] = {_lampSettings->effectType, _lampSettings->brightness,
                       _lampSettings->speed, _lampSettings->effectParameter,
                       _lampSettings->microphone};
    pCharacteristic->setValue(temp, 5);
  }
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
#if (SERIAL_LOG == 1)

      Serial.printf(
          "AlarmState accepts 17 uint8_t parameters, and it has been "
          "passed%d\n",
          length);
#endif
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

    if (length > 3) {
      uint8_t p = 0;
      char *temp_ptr = lampSettings.wifiName;
      for (size_t i = 0; i < length; ++i) {
        if ((char)data[i] == '|') {
          temp_ptr[p] = '\0';
          temp_ptr = lampSettings.wifiPassword;
          p = 0;
          continue;
        }
        temp_ptr[p++] = (char)data[i];
      }
      temp_ptr[p] = '\0';
#if (SERIAL_LOG == 1)
      Serial.printf("--------------------\n\t%s\n\t%s\n--------------------\n",
                    lampSettings.wifiName, lampSettings.wifiPassword);
      Serial.println("Настройки WiFi обновлены!");
#endif
      updateData();
      wifiInit();
      networkInit();
    } else {
#if (SERIAL_LOG == 1)
      Serial.printf(
          "NetworkState accepts string parameters, and it was passed an "
          "incorrect starting parameter");
#endif
    }
  }
  void onRead(BLECharacteristic *pCharacteristic) override {
    std::string temp = std::string(lampSettings.wifiName) + "|" +
                       std::string(lampSettings.wifiPassword);
    //  std::string(lampSettings.wifiPassword) + "|" +
    //  std::string(lampSettings.connectionLamp);

    pCharacteristic->setValue(temp);
  }
};

class ConnectionLampParametersCallbacks : public BLECharacteristicCallbacks {
 public:
  void onWrite(BLECharacteristic *pCharacteristic) override {
    // uint8_t *data = pCharacteristic->getData();
    // auto length = pCharacteristic->getLength();
    auto str = pCharacteristic->getValue();
    if (!str.empty()) {
      // auto s1 = str.substr(0, first);
      // auto s2 = str.substr(first + 1, str.size() - first - 1);
      // auto s3 = str.substr(second + 1, str.size() - second - 1);
      // Копируем строки в lampSettings
      // strncpy(lampSettings.wifiName, s1.c_str(),
      //         sizeof(lampSettings.wifiName) - 1);
      // strncpy(lampSettings.wifiPassword, s2.c_str(),
      //         sizeof(lampSettings.wifiPassword) - 1);
      strncpy(lampSettings.connectionLamp, str.c_str(), str.size());

      // Гарантируем, что строки завершены нулём
      // lampSettings.wifiName[sizeof(lampSettings.wifiName) - 1] = '\0';
      // lampSettings.wifiPassword[sizeof(lampSettings.wifiPassword) - 1] =
      // '\0';
      lampSettings.connectionLamp[str.size()] = '\0';
#if (SERIAL_LOG == 1)

      Serial.println("Настройки WiFi обновлены!");
      Serial.printf("--------------------\n\t%s\n--------------------\n",
                    lampSettings.connectionLamp);
#endif
      connectionLamps();
      updateData();
    } else {
#if (SERIAL_LOG == 1)

      Serial.printf(
          "NetworkState accepts string parameters, and it was passed an "
          "incorrect starting parameter");
#endif
    }
  }
  void onRead(BLECharacteristic *pCharacteristic) override {
    std::string temp = std::string(lampSettings.connectionLamp);
    //  std::string(lampSettings.wifiPassword) + "|" +

    pCharacteristic->setValue(temp);
  }
};

class WiFiStatusCallbacks : public BLECharacteristicCallbacks {
 public:
  void onWrite(BLECharacteristic *pCharacteristic) override {}
  void onRead(BLECharacteristic *pCharacteristic) override {
    uint16_t temp = static_cast<uint16_t>(WiFi.status());
    pCharacteristic->setValue(temp);
  }
};

// class TimeParametersCallbacks : public BLECharacteristicCallbacks {

//  public:
//   void onWrite(BLECharacteristic *pCharacteristic) override {
//     uint8_t *data = pCharacteristic->getData();
//     auto length = pCharacteristic->getLength();

//     if (length == 4) {
//       now.sec = ;
//       now.min = ;
//       now.hour = ;
//       now.day = ;
//       now.setMs(0)
//     } else {
//       Serial.printf(
//           "TimeState accepts 17 uint8_t parameters, and it has been "
//           "passed%d\n",
//           length);
//     }
//   }
//   // void onRead(BLECharacteristic *pCharacteristic) override {
//   // }
// };

}  // namespace Callbacks
void initBLE(LampSettings *lampSettings) {
#if (SERIAL_LOG == 1)

  Serial.println("Запуск BLE-сервера...");
#endif

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

  pServiceNetwork = pServer->createService(LAMP_NETWORK_STATE_SERVICE_UUID);

  //
  NetworkCharacteristic = pServiceNetwork->createCharacteristic(
      NETWORK_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
                                       BLECharacteristic::PROPERTY_WRITE |
                                       BLECharacteristic::PROPERTY_NOTIFY);
  NetworkCharacteristic->setCallbacks(
      new Callbacks::NetworkParametersCallbacks());
  NetworkCharacteristic->addDescriptor(new BLE2902());

  //* Connection Lamp string
  ConnectionLampCharacteristic = pServiceNetwork->createCharacteristic(
      CONNECTION_LAMP_CHARACTERISTIC_UUID,
      BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_WRITE |
          BLECharacteristic::PROPERTY_NOTIFY);
  ConnectionLampCharacteristic->setCallbacks(
      new Callbacks::ConnectionLampParametersCallbacks());
  ConnectionLampCharacteristic->addDescriptor(new BLE2902());

  //* WiFi Status
  WiFiStatusCharacteristic = pServiceNetwork->createCharacteristic(
      WIFI_STATUS_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
                                           BLECharacteristic::PROPERTY_WRITE |
                                           BLECharacteristic::PROPERTY_NOTIFY);
  WiFiStatusCharacteristic->setCallbacks(new Callbacks::WiFiStatusCallbacks());
  WiFiStatusCharacteristic->addDescriptor(new BLE2902());
  // TimeCharacteristic = pService->createCharacteristic(
  //     ALARM_CHARACTERISTIC_UUID, BLECharacteristic::PROPERTY_READ |
  //                                    BLECharacteristic::PROPERTY_WRITE |
  //                                    BLECharacteristic::PROPERTY_NOTIFY);
  // TimeCharacteristic->setCallbacks(
  //     new Callbacks::TimeParametersCallbacks());
  // TimeCharacteristic->addDescriptor(new BLE2902());

  pService->start();
  pServiceNetwork->start();

  pServer->getAdvertising()->start();
#if (SERIAL_LOG == 1)

  Serial.println("BLE-сервер запущен и ожидает подключений.");
#endif
}
}  // namespace BLE

#endif  // __BLE_H__