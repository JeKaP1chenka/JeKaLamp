#include <main.hpp>

// Глобальные переменные

// uint8_t myData[2] = {0, 0};
// int idx = 0;

GyverOLED<SSD1306_128x64> oled;

LampSettings lampSettings;


void updateDisplay(bool isConnect) {
  oled.clear();

  oled.setCursor(0, 4);
  oled.printf("%d", lampSettings.onOff);
  oled.setCursor(0, 5);
  oled.printf("%d  %d  %d  %d  %d  ", lampSettings.effectType,
              lampSettings.brightness, lampSettings.speed,
              lampSettings.effectParameter, lampSettings.microphone);

  oled.setCursor(0, 0);
  if (!isConnect) {
    oled.print("отключено");
  } else {
    oled.print("подключено");
  }

  oled.update();
}



void setup() {
  Serial.begin(115200);

  BLE::initBLE(&lampSettings);
  // enc1.setBtnLevel(LOW);
  // enc1.setClickTimeout(500);
  // enc1.setDebTimeout(50);
  // enc1.setHoldTimeout(600);
  // enc1.setStepTimeout(200);
  // enc1.setEncReverse(0);
  // // EB_STEP4_LOW, EB_STEP4_HIGH, EB_STEP2, EB_STEP1
  // enc1.setEncType(EB_STEP4_HIGH);
  // enc1.setFastTimeout(30);
  // // enc1.setType(TYPE2);

  pinMode(17, INPUT_PULLUP);

  oled.init(21, 22);
  oled.clear();
  oled.home();
  oled.autoPrintln(true);
  oled.setScale(1);
  oled.print("");
  oled.update();
}

bool switchBtn = true;
void loop() {
  // Основной цикл
  auto btn = digitalRead(17);
  // Serial.printf("%d %d\n", switchBtn, btn);
  updateDisplay(lampSettings.deviceConnected);
  if (!btn and switchBtn) {
    switchBtn = false;

    lampSettings.effectType = rand() % 10;
    lampSettings.brightness = rand() % 256;
    lampSettings.speed = rand() % 256;
    lampSettings.effectParameter = rand() % 256;
    lampSettings.microphone = rand() % 2;
    uint8_t temp[5] = {
        lampSettings.effectType,
        lampSettings.brightness,
        lampSettings.speed,
        lampSettings.effectParameter,
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
    // updateDisplay(deviceConnected, false);

  } else if (btn and !switchBtn) {
    switchBtn = true;
  }

  if (lampSettings.deviceConnected) {
    // Здесь можно обработать логику для подключенного клиента
    // oled.clear();
    // oled.home();
    // oled.autoPrintln(true);
    // oled.setScale(1);
    // // Serial.print("clear");
    // oled.print("");
    // oled.update();
  }
}
