#ifndef __FIRE_H__
#define __FIRE_H__

#include "../include.h"
#include "pallets.hpp"

#define NOISE_HEIGHT WIDTH * 4
byte noises[WIDTH * NOISE_HEIGHT];  // precalculated noise table
byte colorfade[HEIGHT];             // simple colorfade table for speedup

DEFINE_GRADIENT_PALETTE(firepal){
    // define fire palette
    0,   0,   0,   0,   // black
    32,  255, 0,   0,   // red
    190, 255, 255, 0,   // yellow
    255, 255, 255, 255  // white
};

CRGBPalette16 myPal = firepal;
byte a = 0;

bool loading = true;


void fireTick(byte scale, int len) {
  // static int len = 16; //! для светомузыки
  // static int scale = 100; 
  static uint8_t deltaValue;
  static uint8_t deltaHue;
  static uint8_t step;
  static uint8_t shiftHue[50];
  static float trackingObjectPosX[100];
  static float trackingObjectPosY[100];
  static uint16_t ff_x, ff_y, ff_z;


  if (loading) {
    loading = false;
    //deltaValue = (((scale - 1U) % 11U + 1U) << 4U) - 8U; // ширина языков пламени (масштаб шума Перлина)
    deltaValue = map(scale, 0, 255, 8, 168);
    deltaHue = map(deltaValue, 8U, 168U, 8U, 84U); // высота языков пламени должна уменьшаться не так быстро, как ширина
    step = map(255U - deltaValue, 87U, 247U, 4U, 32U); // вероятность смещения искорки по оси ИКС
    for (uint8_t j = 0; j < HEIGHT; j++) {
      shiftHue[j] = (HEIGHT - 1 - j) * 255 / (HEIGHT - 1); // init colorfade table
    }

    for (uint8_t i = 0; i < WIDTH / 8; i++) {
      trackingObjectPosY[i] = random8(HEIGHT);
      trackingObjectPosX[i] = random8(WIDTH);
    }
  }
  for (uint8_t i = 0; i < WIDTH; i++) {
    for (uint8_t j = 0; j < len; j++) {
      leds[getPixelNumber(i, len - 1U - j)] = ColorFromPalette(
        paletteArr[1], 
        qsub8(inoise8(i * deltaValue, (j + ff_y + random8(2)) * deltaHue, ff_z), shiftHue[j]), 
        // 255U
        255U
        );
    }
  }

  //вставляем искорки из отдельного массива
  for (uint8_t i = 0; i < WIDTH / 8; i++) {
    if (trackingObjectPosY[i] > 3U) {
      leds[getPixelNumber(trackingObjectPosX[i], trackingObjectPosY[i])] = leds[getPixelNumber(trackingObjectPosX[i], 3U)];
      leds[getPixelNumber(trackingObjectPosX[i], trackingObjectPosY[i])].fadeToBlackBy( trackingObjectPosY[i] * 2U );
    }
    trackingObjectPosY[i]++;
    if (trackingObjectPosY[i] >= len) {
      trackingObjectPosY[i] = random8(4U);
      trackingObjectPosX[i] = random8(WIDTH);
    }
    if (!random8(step))
      trackingObjectPosX[i] = (WIDTH + (uint8_t)trackingObjectPosX[i] + 1U - random8(3U)) % WIDTH;
  }
  ff_y++;
  if (ff_y & 0x01) ff_z++;

}
#endif  // __FIRE_H__