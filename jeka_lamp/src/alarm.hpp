#ifndef __ALARM_H__
#define __ALARM_H__

#include <include.h>

void alarmTick() {
  
  if (NTP.tick()) {
    
    if (!(lampSettings.alarmState >> 7) & 1) {
      return;
    }
    if (lampSettings.timeBeforeAlarm == 0 or lampSettings.timeAfterAlarm == 0) {
      return;
    }
    uint8_t before = lampSettings.timeBeforeAlarm - 4;
    uint8_t after = lampSettings.timeAfterAlarm - 4;
    Datime dt = NTP;
    Datime dtCopy(dt);

    dtCopy.addMinutes(before);
    uint8_t weekDay = dtCopy.weekDay - 1;
    Serial.printf("func: alarm: %d\n\t%d == %d = %d\n\t%d == %d = %d\n", 
      ((lampSettings.alarmState >> weekDay) & 1),
      lampSettings.timeOfDays[weekDay * 2], dtCopy.hour, (lampSettings.timeOfDays[weekDay * 2] == dtCopy.hour),
      lampSettings.timeOfDays[weekDay * 2 + 1], dtCopy.minute, (lampSettings.timeOfDays[weekDay * 2 + 1] == dtCopy.minute)
    );
    if (((lampSettings.alarmState >> weekDay) & 1) and
        (lampSettings.timeOfDays[weekDay * 2] == dtCopy.hour) and
        (lampSettings.timeOfDays[weekDay * 2 + 1] == dtCopy.minute)) {
      auto temp = FastLED.getBrightness();
      FastLED.setBrightness(255);
      uint32_t start = millis();
      while (millis() - start < before * 60000UL) {
        uint8_t brightness =
        map(millis() - start, 0, before * 60000UL, 0, 255);
        fillAll(CHSV(45, 168, brightness));
        FastLED.show();
        delay(50); 
      }
      
      fillAll(CHSV(45, 168, 255));
      FastLED.show();
      
      start = millis();
      while (millis() - start < after * 60000UL) {
        uint8_t brightness =
        map(millis() - start, 0, after * 60000UL, 255, 0);
        fillAll(CHSV(45, 168, brightness));
        FastLED.show();
        delay(50);
      }
      
      // Гасим лампу полностью
      fillAll(CHSV(45, 168, 0));
      FastLED.show();
      FastLED.setBrightness(temp);
      NTP.updateNow();
    }
  }
}

#endif  // __ALARM_H__