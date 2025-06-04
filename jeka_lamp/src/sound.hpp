#ifndef __SOUND_H__
#define __SOUND_H__

#include "vol/VolAnalyzer.h"
#include "include.h"

VolAnalyzer sound(SOUND_PIN);
VolAnalyzer high;

void soundSetup(){
  // sound.setDt(700);
  // sound.setPeriod(5);
  // sound.setWindow(map(300, 300, 900, 20, 1));
  // sound.setVolK(26);
  // sound.setTrsh(50);
  // sound.setVolMin(0);
  // sound.setVolMax(255);

  sound.setVolK(3);
  sound.setVolMax(255);
  sound.setTrsh(150);
  sound.setAmpliDt(14);
  // sound.setAmpliDt(50);


  // sound.setVolK(15); 
  // sound.setVolMax(255);
  // sound.setTrsh(150);
  // sound.setAmpliDt(14);

}

#endif // __SOUND_H__