#ifndef __LEDMATRIX_H__
#define __LEDMATRIX_H__

#include "include.h"

CRGB leds[NUM_LEDS];

uint16_t getPixelNumber(int8_t x, int8_t y);

void fillAll(CRGB color) {
  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i] = color;
  }
}

void fillAll(CHSV color) {
  for (int i = 0; i < NUM_LEDS; i++) {
    leds[i] = color;
  }
}
// void blink(uint8_t hue, uint32_t ms) {
//   auto d = ms / 30;
//   for (int i = 0; i <= 15; i++) {
//     fillAll(CHSV(hue, 255, (255 / 15) * i));
//     FastLED.show();
//     delay(d);
//   }
//   for (int i = 15; i >= 0; i--) {
//     fillAll(CHSV(hue, 255, (255 / 15) * i));
//     FastLED.show();
//     delay(d);
//   }
// }
static int blinkHue = -1;
static uint32_t blinkDurationMs;
void blink(uint8_t hue, uint32_t duration_ms) {
  blinkHue = hue;
  blinkDurationMs - duration_ms;
}

void blinkTick() {
  if (blinkHue != -1) {
    const uint8_t steps = 100;
    const uint16_t delay_time = blinkDurationMs / (steps * 2);
    const auto temp = FastLED.getBrightness();
    FastLED.setBrightness(255);
    Serial.printf("func: blink: start\n");
    Serial.printf("func: blink: for1\n");
    for (int i = 0; i <= steps; i++) {
      uint8_t brightness = map(i, 0, steps, 0, 100);
      fillAll(CHSV(blinkHue, 255, brightness));
      delay(delay_time);
      FastLED.show();
    }

    // Плавное уменьшение яркости
    Serial.printf("func: blink: for2\n");
    for (int i = steps; i >= 0; i--) {
      uint8_t brightness = map(i, 0, steps, 0, 100);
      fillAll(CHSV(blinkHue, 255, brightness));
      delay(delay_time);
      FastLED.show();
    }

    // Очистка (необязательно, зависит от логики программы)
    // fillAll(CRGB::Black);
    FastLED.show();
    FastLED.setBrightness(temp);
    blinkHue = -1;
  }
}

// функция отрисовки точки по координатам X Y
void drawPixelXY(int8_t x, int8_t y, CRGB color) {
  if (x < 0 || x > WIDTH - 1 || y < 0 || y > HEIGHT - 1) return;
  int thisPixel = getPixelNumber(x, y) * SEGMENTS;
  for (byte i = 0; i < SEGMENTS; i++) {
    leds[thisPixel + i] = color;
  }
}

// функция получения цвета пикселя по его номеру
uint32_t getPixColor(int thisSegm) {
  int thisPixel = thisSegm * SEGMENTS;
  if (thisPixel < 0 || thisPixel > NUM_LEDS - 1) return 0;
  return (((uint32_t)leds[thisPixel].r << 16) | ((long)leds[thisPixel].g << 8) |
          (long)leds[thisPixel].b);
}

// функция получения цвета пикселя в матрице по его координатам
uint32_t getPixColorXY(int8_t x, int8_t y) {
  return getPixColor(getPixelNumber(x, y));
}

// **************** НАСТРОЙКА МАТРИЦЫ ****************
#if (CONNECTION_ANGLE == 0 && STRIP_DIRECTION == 0)
#define _WIDTH WIDTH
#define THIS_X x
#define THIS_Y y

#elif (CONNECTION_ANGLE == 0 && STRIP_DIRECTION == 1)
#define _WIDTH HEIGHT
#define THIS_X y
#define THIS_Y x

#elif (CONNECTION_ANGLE == 1 && STRIP_DIRECTION == 0)
#define _WIDTH WIDTH
#define THIS_X x
#define THIS_Y (HEIGHT - y - 1)

#elif (CONNECTION_ANGLE == 1 && STRIP_DIRECTION == 3)
#define _WIDTH HEIGHT
#define THIS_X (HEIGHT - y - 1)
#define THIS_Y x

#elif (CONNECTION_ANGLE == 2 && STRIP_DIRECTION == 2)
#define _WIDTH WIDTH
#define THIS_X (WIDTH - x - 1)
#define THIS_Y (HEIGHT - y - 1)

#elif (CONNECTION_ANGLE == 2 && STRIP_DIRECTION == 3)
#define _WIDTH HEIGHT
#define THIS_X (HEIGHT - y - 1)
#define THIS_Y (WIDTH - x - 1)

#elif (CONNECTION_ANGLE == 3 && STRIP_DIRECTION == 2)
#define _WIDTH WIDTH
#define THIS_X (WIDTH - x - 1)
#define THIS_Y y

#elif (CONNECTION_ANGLE == 3 && STRIP_DIRECTION == 1)
#define _WIDTH HEIGHT
#define THIS_X y
#define THIS_Y (WIDTH - x - 1)

#else
#define _WIDTH WIDTH
#define THIS_X x
#define THIS_Y y
#pragma message "Wrong matrix parameters! Set to default"

#endif

// получить номер пикселя в ленте по координатам
uint16_t getPixelNumber(int8_t x, int8_t y) {
  if ((THIS_Y % 2 == 0) || MATRIX_TYPE) {  // если чётная строка
    return (THIS_Y * _WIDTH + THIS_X);
  } else {  // если нечётная строка
    return (THIS_Y * _WIDTH + _WIDTH - THIS_X - 1);
  }
}

#endif  // __LEDMATRIX_H__