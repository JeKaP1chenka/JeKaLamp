#include <bitset>
#include <main.hpp>
// Глобальные переменные

// uint8_t myData[2] = {0, 0};
// int idx = 0;

bool switchBtn = true;

void btnUpdate();

void setup() {
  loadData();
  Serial.begin(115200);

  BLE::initBLE(&lampSettings);

  pinMode(17, INPUT_PULLUP);

#if (DISPLAY_DEBUG == 1)
  initDisplay();
#endif
}

void loop() {
  // Основной цикл
  saveData();
  btnUpdate();
  //! effectTick();
  //! timeTick();
#if (DISPLAY_DEBUG == 1)
  updateDisplay();
#endif

  if (BLE::deviceConnected) {
  }
}

void btnUpdate() {
  auto btn = digitalRead(17);
  // Serial.printf("%d %d\n", switchBtn, btn);
  if (!btn and switchBtn) {
    switchBtn = false;

    lampSettings.effectType = rand() % 10;
    lampSettings.brightness = rand() % 256;
    lampSettings.speed = rand() % 256;
    lampSettings.effectParameter = rand() % 256;
    lampSettings.microphone = rand() % 2;
    uint8_t temp[5] = {
        lampSettings.effectType, lampSettings.brightness,
        lampSettings.speed,      lampSettings.effectParameter,
        lampSettings.microphone,
    };
    BLE::parametersCharacteristic->setValue(temp, 5);
    BLE::parametersCharacteristic->notify();

    lampSettings.onOff = !lampSettings.onOff;
    uint8_t temp1[1]{
        lampSettings.onOff,
    };

    BLE::onOffCharacteristic->setValue(temp1, 1);
    BLE::onOffCharacteristic->notify();

    lampSettings.alarmState = rand() % 256;
    lampSettings.timeBeforeAlarm = (rand() % 12) * 5 + 5;
    lampSettings.timeAfterAlarm = (rand() % 12) * 5 + 5;
    for (int i = 0; i < 7; ++i) {
      lampSettings.timeOfDays[i * 2] = rand() % 24;
      lampSettings.timeOfDays[i * 2 + 1] = rand() % 60;
    }

    uint8_t temp2[17] = {
        lampSettings.alarmState,
        lampSettings.timeBeforeAlarm,
        lampSettings.timeAfterAlarm,
    };
    for (int i = 3; i < 17; ++i) {
      temp2[i] = lampSettings.timeOfDays[i - 3];
    }

    BLE::alarmCharacteristic->setValue(temp2, 17);
    BLE::alarmCharacteristic->notify();
    updateData();
  } else if (btn and !switchBtn) {
    switchBtn = true;
  }
}