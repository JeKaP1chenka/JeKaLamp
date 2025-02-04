#ifndef __DISPLAY_HPP__
#define __DISPLAY_HPP__

#include <include.h>

GyverOLED<SSD1306_128x64> oled;

void updateDisplay() {
  static timerMillis tmr(500, true);
  if (!tmr.isReady()) return;

  oled.clear();

  oled.setCursor(0, 1);
  oled.printf("s:%d t:%d m:%d", lampSettings.onOff, lampSettings.effectType,
              lampSettings.microphone);
  oled.setCursor(0, 2);
  oled.printf("b:%.3d s:%.3d p:%.3d", lampSettings.brightness,
              lampSettings.speed, lampSettings.effectParameter);
  oled.setCursor(0, 3);
  oled.printf(
      "%d%d%d%d%d%d%d%d %d", (lampSettings.alarmState >> 7) & 1,
      (lampSettings.alarmState >> 6) & 1, (lampSettings.alarmState >> 5) & 1,
      (lampSettings.alarmState >> 4) & 1, (lampSettings.alarmState >> 3) & 1,
      (lampSettings.alarmState >> 2) & 1, (lampSettings.alarmState >> 1) & 1,
      (lampSettings.alarmState >> 0) & 1, lampSettings.alarmState);

  oled.setCursor(0, 4);
  oled.printf("%.2d %.2d %.2d:%.2d ", lampSettings.timeBeforeAlarm,
              lampSettings.timeAfterAlarm, lampSettings.timeOfDays[0],
              lampSettings.timeOfDays[1]);
  oled.setCursor(0, 5);
  oled.printf("%.2d:%.2d %.2d:%.2d %.2d:%.2d ", lampSettings.timeOfDays[2],
              lampSettings.timeOfDays[3], lampSettings.timeOfDays[4],
              lampSettings.timeOfDays[5], lampSettings.timeOfDays[6],
              lampSettings.timeOfDays[7]);
  oled.setCursor(0, 6);
  oled.printf("%.2d:%.2d %.2d:%.2d %.2d:%.2d", lampSettings.timeOfDays[8],
              lampSettings.timeOfDays[9], lampSettings.timeOfDays[10],
              lampSettings.timeOfDays[11], lampSettings.timeOfDays[12],
              lampSettings.timeOfDays[13]);

  oled.setCursor(0, 0);
  if (!BLE::deviceConnected) {
    oled.print("отключено");
  } else {
    oled.print("подключено");
  }

  oled.update();
}

void initDisplay() {
  oled.init(21, 22);
  oled.clear();
  oled.home();
  oled.autoPrintln(true);
  oled.setScale(1);
  oled.print("");
  oled.update();
}

#endif  // __DISPLAY_HPP__