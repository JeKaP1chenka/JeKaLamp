  #ifndef __LAMPSETTINGS_H__
#define __LAMPSETTINGS_H__

#include <include.h>

struct LampSettings {
  // settings lamp
  uint8_t onOff = 0;
  // settings effect
  uint8_t effectType = 0;
  uint8_t brightness = 0;
  uint8_t speed = 0;
  uint8_t effectParameter = 0;
  uint8_t microphone = 0;
  // settings alarm
  uint8_t alarmState = 0;
  uint8_t timeBeforeAlarm = 0;
  uint8_t timeAfterAlarm = 0;
  uint8_t timeOfDays[14] = {0};
  // settings wifi
  char wifiName[64] = {0};
  char wifiPassword[64] = {0};
  char connectionLamp[128] = {0};
};



#endif  // __LAMPSETTINGS_H__