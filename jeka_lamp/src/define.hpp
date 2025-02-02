#ifndef __DEFINE_H__
#define __DEFINE_H__


// настройка BLE сурвера
#define BLE_SERVER_NAME "JeKaLamp_REV1"

// UUID сервисов и характеристик
#define LAMP_STATE_SERVICE_UUID "1234"
#define ON_OFF_CHARACTERISTIC_UUID "1234"
#define PARAMETERS_CHARACTERISTIC_UUID "1235"
#define ALARM_CHARACTERISTIC_UUID "1236"

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


#endif  // __DEFINE_H__