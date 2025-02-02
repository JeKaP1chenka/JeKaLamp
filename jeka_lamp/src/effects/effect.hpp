#ifndef __EFFECT_H__
#define __EFFECT_H__

#include "../include.h"
#include "fire.hpp"

const int8_t effectsArraySize = 1;
void (*effectsArray[effectsArraySize])() = {fireTick};

void effectTick() {
  if (lampSettings.effectType == 5){
    effectsArray[0]();
  }
  FastLED.show();
}

#endif  // __EFFECT_H__