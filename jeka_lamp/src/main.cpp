#include <bitset>
#include <main.hpp>

// Глобальные переменные

// uint8_t myData[2] = {0, 0};
// int idx = 0;

bool switchBtn = true;
Time now;
static void btnUpdate();
static void debugDataUpdate();

void setup() {
  loadData();
  wifiInit();
  setupTask();

  // Serial init
#if (SERIAL_LOG == 1)

  Serial.begin(115200);
#endif
  // BLE init
  BLE::initBLE(&lampSettings);

  // led matrix init
  FastLED.addLeds<WS2812B, LED_PIN, COLOR_ORDER>(
      leds, NUM_LEDS) /*.setCorrection( TypicalLEDStrip )*/;
  FastLED.setBrightness(250);
  if (CURRENT_LIMIT > 0)
    FastLED.setMaxPowerInVoltsAndMilliamps(5, CURRENT_LIMIT);
  FastLED.show();

  soundSetup();

  pinMode(17, INPUT_PULLUP);

#if (DISPLAY_DEBUG == 1)
  initDisplay();
#endif
}

void loop() {
  // Serial.print(1);
  // Основной цикл
  saveData();
  btnUpdate();
  effectTick();
  sound.tick();
  yield();
  wiFiStatusTick();
  //! timeTick();
  checkSignal();
  blinkTick();
#if (DISPLAY_DEBUG == 1)
  updateDisplay();
#endif

  if (BLE::deviceConnected) {
  }
}
// void sendQuery(void *parameter);

volatile bool done = true;
void callback(int httpCode, String response) {
  Serial.printf("HTTP Code: %d\nResponse:\n%s\n", httpCode, response.c_str());
  done = true;
}

void btnUpdate() {
  static timerMillis tmr(100, true);
  if (!tmr.isReady()) return;
#if (DD == 1)
  auto btn = digitalRead(17);
#else
  auto btn = digitalRead(2);
#endif
  // Serial.printf("%d %d\n", switchBtn, btn);
  if (!btn and switchBtn) {
    switchBtn = false;
    // debugDataUpdate();
    blink(123, 2000);

    sendSignal();
  } else if (btn and !switchBtn) {
    switchBtn = true;
  }
}
void onResponse(int httpCode, String response) {
  Serial.printf("Ответ HTTP %d: %s\n", httpCode, response.c_str());
}
// void sendQuery(void *parameter) {
//   if (WiFi.isConnected()) {
//     Serial.println("start sendQuery");
//     HTTPClient http;
//     http.setTimeout(20000);
//     http.begin("http://192.168.1.7:9999/send_signal/asd");

//     String httpResponse = "";
//     int httpCode = 0;
//     httpCode = http.GET();
//     if (httpCode > 0) {
//       httpResponse = http.getString();
//     } else {
//       httpResponse = "Error: " + http.errorToString(httpCode);
//     }

//     http.end();
//     Serial.printf("HTTP Code: %d\nResponse:\n%s\n", httpCode,
//                   httpResponse.c_str());

//     Serial.println("end sendQuery");
//   }
//   done = true;
//   vTaskDelete(NULL);  // удалить задачу после завершения
// }

void debugDataUpdate() {
  lampSettings.effectType = rand() % 10;
  lampSettings.brightness = rand() % 256;
  lampSettings.speed = rand() % 256;
  lampSettings.effectParameter = rand() % 256;
  lampSettings.microphone = rand() % 2;
  uint8_t temp[5] = {
      lampSettings.effectType,      lampSettings.brightness, lampSettings.speed,
      lampSettings.effectParameter, lampSettings.microphone,
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
}