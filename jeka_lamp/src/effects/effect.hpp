#ifndef __EFFECT_H__
#define __EFFECT_H__

#include "../include.h"
#include "dynamicColor.hpp"
#include "fire.hpp"
#include "staticColor.hpp"
#include "pulse.hpp"

void effectVoid() {}

const int8_t effectsArraySize = 4;
void (*effectsArray[effectsArraySize])(byte, int) = {staticColorTick, dynamicColorTick, fireTick, pulseTick};

void effectTick() {
  byte scale = lampSettings.effectParameter;
  int len = 16;
  if (lampSettings.microphone){
    len = map(sound.getVol(), 0, 255, 1, 16);
  }

  FastLED.setBrightness(lampSettings.brightness);
  if (1 <= lampSettings.effectType && lampSettings.effectType <= effectsArraySize) {
    effectsArray[lampSettings.effectType-1](scale, len);
  }
  FastLED.show();
}

#endif  // __EFFECT_H__