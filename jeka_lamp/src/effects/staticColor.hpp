#ifndef __STATICCOLOR_H__
#define __STATICCOLOR_H__

#include "../include.h"

// int16_t a;

void staticColorTick(byte scale, int len) {
  for (int i = 0; i < WIDTH; i++) {
    for (int j = 0; j < HEIGHT; j++) {
      // leds[getPixelNumber(i, j)] = CRGB(255,0,0);
      leds[getPixelNumber(i, j)] =
          CHSV(lampSettings.effectParameter, lampSettings.speed, 255);
    }
  }
  FastLED.show();
}

#endif  // __STATICCOLOR_H__