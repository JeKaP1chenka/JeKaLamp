#ifndef __NETWORK_H__
#define __NETWORK_H__

#include "include.h"
typedef void (*ResponseCallback)(int httpCode, String payload);
void asyncHttpGet(String url, ResponseCallback callback);
String getLampName() {
  return lampSettings.wifiName + String("|") + lampSettings.wifiPassword;
}

int registerHttpCode = 0;
int connectHttpCode = 0;
int sendHttpCode = 0;
int checkHttpCode = 0;
void connectionLamps();

void registerLampCallnack(int httpCode, String response) {
  Serial.printf("func: registerLampCallnack: result %d\n", httpCode);
  registerHttpCode = httpCode;
  if (httpCode == 201 or httpCode == 409) {
    blink(38, 2000);
  }
  connectionLamps();
}
// 201 - ok
// 409 - lamp name is create
// 500 - exception
void registerLamp() {
  if (registerHttpCode == 201 or registerHttpCode == 409) {
    Serial.printf("func: registerLamp: result return\n");
    return;
  }
  if (WiFi.isConnected()) {
    Serial.printf("func: registerLamp: result call\n");
    String temp = "http://185.255.132.196:9999/register_lamp/" + getLampName();
    asyncHttpGet(temp, registerLampCallnack);
  }
}

void connectionLampsCallback(int httpCode, String response) {
  Serial.printf("func: connectionLampsCallback: result %d\n", httpCode);
  connectHttpCode = httpCode;
  if (httpCode == 201 or httpCode == 211) {
    blink(38, 2000);
  }
}
// 201 - ok
// 210 - One or both lamps not found
// 211 - Lamps are already connected
// 500 - exception
void connectionLamps() {
  if (lampSettings.connectionLamp[0] == '\0') {
    Serial.printf("func: connectionLamps: result return1\n");

    return;
  }
  if (registerHttpCode != 201 and registerHttpCode != 409) {
    Serial.printf("func: connectionLamps: result return2\n");
    return;
  }
  if (WiFi.isConnected()) {
    Serial.printf("func: connectionLamps: result call\n");
    String temp = "http://185.255.132.196:9999/connect_lamps/" + getLampName() +
                  String("/") + String(lampSettings.connectionLamp);
    asyncHttpGet(temp, connectionLampsCallback);
  }
}

void networkInit() {
  Serial.printf("func: networkInit: 1\n");
  registerLamp();
  // while (registerHttpCode == 0)
  // {
  //   yield();
  // }

  Serial.printf("func: networkInit: 2\n");
  // connectionLamps();
  // Serial.printf("func: networkInit: 3\n");
}

volatile bool sendSignalDone = true;
void sendSignalCallback(int httpCode, String response) {
  sendHttpCode = httpCode;
  Serial.printf("func: sendSignalCallback: result %d\n", httpCode);
  sendSignalDone = true;
  if (httpCode == 200) {
    blink(38, 2000);
  }
}
// 200 - ok
// 210 - lamp not found
// 211 - connection not found
// 500 - exception
void sendSignal() {
  // static timerMillis tmr(5000, true);
  if (connectHttpCode != 201 and connectHttpCode != 211) {
    Serial.printf("func: sendSignal: result return1\n");
    return;
  }
  if (!sendSignalDone) {
    Serial.printf("func: sendSignal: result return2\n");
    return;
  }
  if (WiFi.isConnected()) {
    Serial.printf("func: sendSignal: result call\n");
    String temp = "http://185.255.132.196:9999/send_signal/" + getLampName();
    Serial.printf("func: sendSignal: %s\n", temp.c_str());
    sendSignalDone = false;
    asyncHttpGet(temp, sendSignalCallback);

  } else {
    Serial.printf("func: sendSignal: WiFiNoConecction\n");
    // no WiFi connection
  }
}
volatile bool checkSignalDone = true;
void checkSignalCallback(int httpCode, String response) {
  checkHttpCode = httpCode;
  Serial.printf("func: checkSignalCallback: result %d; %s\n", httpCode,
                response);
  if (response.equals("\"1\"")) {
    blink(38, 2000);
  }
  checkSignalDone = true;
}
// 200 - ok
// 210 - lamp not found
// 211 - connection not found
// 500 - exception
void checkSignal() {
  static timerMillis tmr(3000, true);
  if (connectHttpCode != 201 and connectHttpCode != 211) {
    // Serial.printf("func: checkSignal: result return1\n");
    return;
  }
  if (!checkSignalDone) {
    // Serial.printf("func: checkSignal: result return2\n");
    return;
  };
  if (!sendSignalDone) {
    return;
  }
  if (!tmr.isReady()) {
    // Serial.printf("func: checkSignal: result return3\n");

    return;
  }
  if (WiFi.isConnected()) {
    String temp = "http://185.255.132.196:9999/check_status/" + getLampName();
    Serial.printf("func: checkSignal: %s\n", temp.c_str());
    checkSignalDone = false;
    asyncHttpGet(temp, checkSignalCallback);
  } else {
    Serial.printf("func: checkSignal: WiFiNoConecction\n");
    // no WiFi connection
  }
}

#endif  // __NETWORK_H__