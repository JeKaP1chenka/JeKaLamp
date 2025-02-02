#ifndef __PULSE_H__
#define __PULSE_H__

#include "../include.h"

void pulseTick(byte scale, int len) {
  Serial.print(2);

  static uint8_t g = 3;
  static byte curColor = 0;

  for (int i = 0; i < WIDTH; i++) {
    for (int j = HEIGHT - 1; j >= 1 ; j--) {
      leds[getPixelNumber(i, j)] = leds[getPixelNumber(i, j-1)];
    }
  }

  if (sound.getPulse()) {
    curColor += 5;
    g = 3;
  }

  CRGB color = CHSV(curColor, 255, g * (255 / 3));

  if (g > 0) g--;

  for (int i = 0; i < WIDTH; i++) {
    leds[getPixelNumber(i, 0)] = color;
  }
  FastLED.show();
}

#endif  // __PULSE_H__