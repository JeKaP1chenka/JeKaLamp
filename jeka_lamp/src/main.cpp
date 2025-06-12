#include <bitset>
#include <main.hpp>

#include "AsyncHTTP/async_http_client.h"
#include "WiFiMulti.h"
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
  //! timeTick();
#if (DISPLAY_DEBUG == 1)
  updateDisplay();
#endif

  if (BLE::deviceConnected) {
  }
}
void sendQuery();
void btnUpdate() {
  static timerMillis tmr(100, true);
  if (!tmr.isReady()) return;
  auto btn = digitalRead(17);
  // Serial.printf("%d %d\n", switchBtn, btn);
  if (!btn and switchBtn) {
    switchBtn = false;
    debugDataUpdate();
    sendQuery();
  } else if (btn and !switchBtn) {
    switchBtn = true;
  }
}
void onResponse(int httpCode, String response) {
  Serial.printf("Ответ HTTP %d: %s\n", httpCode, response.c_str());
}
bool done;
WiFiMulti wifiMulti;
void sendQuery() {
  AsyncHTTPClient http;
  done = false;
  if ((WiFi.status() == WL_CONNECTED)) {
    Serial.print("IP address of Device: ");
    Serial.println(WiFi.localIP().toString().c_str());

    String output;

    auto connection_handler = [&](HTTPConnectionState state) {
      Serial.print("New state: ");
      Serial.println((int)state);
      Serial.flush();

      switch (state) {
        case HTTPConnectionState::ERROR:
          Serial.print("Received error: ");
          Serial.println(http.error_string(http.last_error()));
          http.close();
          break;
        case HTTPConnectionState::DONE:
          Serial.println("ALL DONE");
          output = http.response().str();
          Serial.println(output);
          http.close();
          break;
        default:
          break;
      }
    };

    Serial.print("[HTTP] begin...\n");
    http.begin("http://httpbin.org/robots.txt");  // HTTP

    http.connect_timeout(2000);
    http.response_timeout(2000);

    http.reuse(true);

    Serial.print("[HTTP] GET...\n");
    // start connection and send HTTP header
    http.GET(connection_handler);

  }
  // Serial.println("start sendQuery");
  // // asyncHttpGet("https://httpbin.org/get", onResponse);
  // HTTPClient http;
  // http.setTimeout(20000);
  // http.begin("http://192.168.0.39:9999/send_signal/asd");

  // String httpResponse = "";
  // int httpCode = 0;
  // // Делаем запрос (синхронно, но вызывается из таймера, не из loop)
  // httpCode = http.GET();
  // if (httpCode > 0) {
  //   httpResponse = http.getString();
  // } else {
  //   httpResponse = "Error: " + http.errorToString(httpCode);
  // }

  // http.end();
  // Serial.printf("HTTP Code: %d\nResponse:\n%s\n", httpCode,
  // httpResponse.c_str());

  // Serial.println("end sendQuery");
}

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