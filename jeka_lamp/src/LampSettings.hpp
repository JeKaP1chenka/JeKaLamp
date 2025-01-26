#ifndef __LAMPSETTINGS_H__
#define __LAMPSETTINGS_H__

#include <include.h>

struct LampSettings {
  bool deviceConnected = false;
  // settings lamp
  uint8_t onOff = 0;
  // settings effect
  uint8_t effectType = 0;
  uint8_t brightness = 0;
  uint8_t speed = 0;
  uint8_t effectParameter = 0;
  uint8_t microphone = 0;

} ;


#endif // __LAMPSETTINGS_H__