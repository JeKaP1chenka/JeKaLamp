#ifndef __DATA_H__
#define __DATA_H__

#include <include.h>

#include <LampSettings.hpp>

void debugData() {
#if (SERIAL_LOG == 1)

  Serial.printf("---------------------------\n");
  Serial.printf("onOff:  %d\t", lampSettings.onOff);
  Serial.printf("effect: %d\t", lampSettings.effectType);
  Serial.printf("bright: %d\n", lampSettings.brightness);
  Serial.printf("speed:  %d\t", lampSettings.speed);
  Serial.printf("effPar: %d\t", lampSettings.effectParameter);
  Serial.printf("micro:  %d\n", lampSettings.microphone);
  Serial.printf("\n");
  Serial.printf("alarmState:\t%d\t", lampSettings.alarmState);
  Serial.printf("timeBeforeAlarm: %d\t", lampSettings.timeBeforeAlarm);
  Serial.printf("timeAfterAlarm: %d\n", lampSettings.timeAfterAlarm);
  for (int i = 0; i < 7; i++) {
    Serial.printf("day %d:\t%d:%d\t", i, lampSettings.timeOfDays[i * 2],
                  lampSettings.timeOfDays[i * 2 + 1]);
    if (i == 3) Serial.println();
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
#else
void loadData() {}
void saveData() {}
void updateData() { debugData(); }
#endif

#endif  // __DATA_H__