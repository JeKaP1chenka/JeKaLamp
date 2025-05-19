#ifndef __DATA_H__
#define __DATA_H__

#include <include.h>

void debugData() {
#if (SERIAL_LOG == 1)

  Serial.printf("---------------------------\n");
  Serial.printf("onOff:\t%d\n", lampSettings.onOff);
  Serial.printf("effectType:\t%d\n", lampSettings.effectType);
  Serial.printf("brightness:\t%d\n", lampSettings.brightness);
  Serial.printf("speed:\t%d\n", lampSettings.speed);
  Serial.printf("effectParameter:\t%d\n", lampSettings.effectParameter);
  Serial.printf("microphone:\t%d\n", lampSettings.microphone);
  Serial.printf("\n");
  Serial.printf("alarmState:\t%d\n", lampSettings.alarmState);
  Serial.printf("timeBeforeAlarm:\t%d\n", lampSettings.timeBeforeAlarm);
  Serial.printf("timeAfterAlarm:\t%d\n", lampSettings.timeAfterAlarm);
  for (int i = 0; i < 7; i++) {
    Serial.printf("day %d:\t%d:%d\n", i, lampSettings.timeOfDays[i * 2],
                  lampSettings.timeOfDays[i * 2 + 1]);
  }
  Serial.printf("\n");
  Serial.printf("wifiName:\t%s\n", lampSettings.wifiName);
  Serial.printf("wifiPassword:\t%s\n", lampSettings.wifiPassword);

  Serial.printf("---------------------------\n");
#endif  // SERIAL_LOG
}

#if (SAVE_DATA == 1)

volatile bool savePending = false;
unsigned long lastUpdateTime = 0;

void loadData() {
  preferences.begin("lamp", true);
  if (preferences.getBytesLength("settings") == sizeof(lampSettings)) {
    preferences.getBytes("settings", &lampSettings, sizeof(lampSettings));
#if (SERIAL_LOG == 1)

    Serial.println("Данные загружены!");
#endif
  } else {
#if (SERIAL_LOG == 1)

    Serial.println("Данные не найдены, сбрасываем на дефолтные.");
#endif

    memset(&lampSettings, 0, sizeof(lampSettings));
  }
  preferences.end();
}

void saveData() {
  if (!savePending || millis() - lastUpdateTime < SAVE_TO_FLASH_DELAY) return;

  preferences.begin("lamp", false);
  preferences.putBytes("settings", &lampSettings, sizeof(lampSettings));
  preferences.end();

  savePending = false;
#if (SERIAL_LOG == 1)

  Serial.println("Данные сохранены!");
#endif
}

void updateData() {
  lastUpdateTime = millis();
  savePending = true;
#if (SERIAL_LOG == 1)

  Serial.println("Данные обновлены, сохранение отложено...");
#endif

  debugData();
}
#else   // SAVE_DATA
void loadData() {}
void saveData() {}
void updateData() { debugData(); }
#endif  // SAVE_DATA

#endif  // __DATA_H__