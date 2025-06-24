#ifndef __DEFINE_H__
#define __DEFINE_H__

#include "include.h"

// #define DD 1

// настройка BLE сурвера
#if (DD == 1)
#define BLE_SERVER_NAME "JeKaLamp_REV1_debug"
#else
#define BLE_SERVER_NAME "JeKaLamp_REV1"
#endif

// UUID сервисов и характеристик
#define LAMP_STATE_SERVICE_UUID "1234"
#define ON_OFF_CHARACTERISTIC_UUID "1234"
#define PARAMETERS_CHARACTERISTIC_UUID "1235"
#define ALARM_CHARACTERISTIC_UUID "1236"


#define LAMP_NETWORK_STATE_SERVICE_UUID "1235"
#define NETWORK_CHARACTERISTIC_UUID "1234"
#define CONNECTION_LAMP_CHARACTERISTIC_UUID "1235"
#define WIFI_STATUS_CHARACTERISTIC_UUID "1236"

#define SAVE_TO_FLASH_DELAY 30000

#define SEGMENTS 1

#define COLOR_ORDER GRB
#define CURRENT_LIMIT 2000
#define BRIGHTNESS 5

#define LED_PIN 4     // пин ленты
#define BTN_PIN 2     // пин кнопки
#define SOUND_PIN 33  // пин звука

#define WIDTH 16   // ширина матрицы
#define HEIGHT 16  // высота матрицы
#define NUM_LEDS WIDTH* HEIGHT
#define P_SPEED 1

#define CONNECTION_ANGLE 2
#define STRIP_DIRECTION 2
#define MATRIX_TYPE 0

#define SERIAL_DEBUG 1
#define DISPLAY_DEBUG 1
#define SAVE_DATA 0
#define SERIAL_LOG 1

// wifi
const char* url = "http://185.221.215.59:9999/";
#define WIFI_TIMEOUT_MS 10000

namespace BLE {

bool deviceConnected = false;
BLEServer *pServer;
BLEService *pService;
BLECharacteristic *onOffCharacteristic;
BLECharacteristic *parametersCharacteristic;
BLECharacteristic *alarmCharacteristic;
BLECharacteristic *TimeCharacteristic;

BLEService *pServiceNetwork;
BLECharacteristic *NetworkCharacteristic;
BLECharacteristic *ConnectionLampCharacteristic;
BLECharacteristic *WiFiStatusCharacteristic;
}

#endif  // __DEFINE_H__