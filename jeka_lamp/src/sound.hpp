#ifndef __SOUND_H__
#define __SOUND_H__

#include "include.h"

VolAnalyzer sound(SOUND_PIN);

void soundSetup(){
    // sound init
  sound.setVolK(15);        // снизим фильтрацию громкости (макс. 31)
  sound.setVolMax(255);     // выход громкости 0-255
  // sound.setPulseMax(200);   // сигнал пульса
  // sound.setPulseMin(150);   // перезагрузка пульса
  // sound.setVolMin(20);
  sound.setTrsh(150);
  // sound.setPulseTimeout(10);
  sound.setAmpliDt(14);

}

#endif // __SOUND_H__