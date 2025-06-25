#ifndef __WIFI_H__
#define __WIFI_H__

#include "include.h"

#define STACK_SIZE 8192
#define QUEUE_SIZE 20

// Очередь запросов
QueueHandle_t httpQueue;

// Буферы для статической задачи
StaticTask_t httpTaskTCB;
StackType_t httpTaskStack[STACK_SIZE];

#if (DISPLAY_DEBUG == 1)
static char loading[5] = "\\|/-";
static uint8_t loading_i = 0;
#endif

void wifiInit() {
  if (lampSettings.wifiName[0] == '\0' or lampSettings.wifiPassword[0] == '\0')
    return;
  WiFi.begin(lampSettings.wifiName, lampSettings.wifiPassword);
  unsigned long startAttemptTime = millis();

  uint16_t temp = 7;
  BLE::WiFiStatusCharacteristic->setValue(temp);
  BLE::WiFiStatusCharacteristic->notify();
  while (WiFi.status() != WL_CONNECTED &&
         millis() - startAttemptTime < WIFI_TIMEOUT_MS) {
    delay(100);
#if (SERIAL_LOG == 1)
    Serial.print(".");
#endif
  }
  temp = WiFi.status();
  BLE::WiFiStatusCharacteristic->setValue(temp);
  BLE::WiFiStatusCharacteristic->notify();
  if (WiFi.status() == WL_CONNECTED) {
#if (SERIAL_LOG == 1)
    Serial.println("\nWiFi подключен!");
#endif

#if (DISPLAY_DEBUG == 1)
    oled.setCursor(5, 7);
    oled.print('Y');
#endif
    registerHttpCode = 0;
    connectHttpCode = 0;
    sendHttpCode = 0;
    checkHttpCode = 0;
    blink(146, 1000);
    NTP.begin(7);
    
  } else {
#if (SERIAL_LOG == 1)
    Serial.println(
        "\nНе удалось подключиться к WiFi. Продолжаем выполнение...");
#endif
#if (DISPLAY_DEBUG == 1)
    oled.setCursor(5, 7);
    oled.print('N');
#endif

    blink(0, 1000);
  }
}

void wiFiStatusTick() {
  static uint16_t lastStatus = WL_NO_SHIELD;
  if (WiFi.status() != lastStatus) {
    lastStatus = WiFi.status();
    Serial.printf("wifistatus %d", lastStatus);
    BLE::WiFiStatusCharacteristic->setValue(lastStatus);
    BLE::WiFiStatusCharacteristic->notify();
  }
  if (!WiFi.isConnected()){
    registerHttpCode = 0;
    connectHttpCode = 0;
    sendHttpCode = 0;
    checkHttpCode = 0;
  }
}

typedef void (*ResponseCallback)(int httpCode, String payload);

struct RequestData {
  String url;
  ResponseCallback callback;
};

void httpRequestTask(void* param) {
  RequestData* req = static_cast<RequestData*>(param);

  HTTPClient http;
  http.setTimeout(20000);
  http.begin(req->url);

  int httpCode = http.GET();
  String httpResponse = "";

  if (httpCode > 0) {
    httpResponse = http.getString();
  } else {
    httpResponse = http.errorToString(httpCode);
  }

  // Вызываем callback с результатом
  req->callback(httpCode, httpResponse);

  http.end();
  delete req;  // Освобождаем память
  vTaskDelete(NULL);
}

void httpRequestTaskV2(void* param) {
  RequestData req;

  for (;;) {
    if (xQueueReceive(httpQueue, &req, portMAX_DELAY) == pdTRUE) {
      HTTPClient http;
      http.setTimeout(20000);
      http.begin(req.url);

      int httpCode = http.GET();
      String httpResponse = "";

      if (httpCode > 0) {
        httpResponse = http.getString();
      } else {
        httpResponse = http.errorToString(httpCode);
      }

      // Вызываем callback с результатом
      req.callback(httpCode, httpResponse);

      http.end();
    }
  }
}
void setupTask() {
  httpQueue = xQueueCreate(QUEUE_SIZE, sizeof(RequestData));
  xTaskCreate(httpRequestTaskV2, "httpWorker", 8192, NULL, 1, NULL);
}

// Универсальная функция для вызова из любого места
static volatile int counter = 0;
void asyncHttpGet(String url, ResponseCallback callback) {
  // RequestData* req = new RequestData{url, callback};
  String temp = "httpRequestTask" + String(counter);
  RequestData req = {url, callback};
  BaseType_t success = xQueueSend(httpQueue, &req, 0);
  // auto r = xTaskCreate(httpRequestTask, temp.c_str(), 2048, req, 1, NULL);
  counter++;
  if (counter > 100000) {
    counter = 0;
  }
  Serial.printf("func: asyncHttpGet: task;%d success;%d, heap;%d\n",counter, success, ESP.getFreeHeap());
}

// void sendAsyncHttpRequest(const char* host, int port, String request,
//                           void (*callback)(String)) {
//   static WiFiClient client;
//   static bool requestSent = false;
//   static unsigned long requestStartTime = 0;
//   static const unsigned long timeout = 5000;  // Таймаут ожидания (5 сек)
//   static String requestData;
//   static void (*responseCallback)(String response) =
//       nullptr;  // Callback-функция

//   if (!requestSent) {
//     if (client.connect(host, port)) {
// #if (SERIAL_LOG == 1)

//       Serial.println("Подключились к серверу");
// #endif

//       // Сохраняем запрос и callback
//       requestData = request;
//       responseCallback = callback;

//       // Отправляем HTTP-запрос
//       client.print(request);

//       requestSent = true;
//       requestStartTime = millis();
//     } else {
// #if (SERIAL_LOG == 1)
//       Serial.println("Ошибка подключения к серверу");
// #endif

//       requestSent = false;
//     }
//   }

//   // Проверяем, есть ли данные в буфере
//   if (requestSent && client.available()) {
//     String response = client.readString();  // Читаем ответ
// #if (SERIAL_LOG == 1)
//     Serial.println("Ответ сервера получен.");
// #endif

//     // Вызываем callback-функцию, если она есть
//     if (responseCallback) {
//       responseCallback(response);
//     }

//     // Закрываем соединение
//     client.stop();
//     requestSent = false;
//   }

//   // Закрываем соединение, если превышен таймаут
//   if (requestSent && millis() - requestStartTime > timeout) {
// #if (SERIAL_LOG == 1)
//     Serial.println("Время ожидания истекло, закрываем соединение");
// #endif

//     client.stop();
//     requestSent = false;
//   }
// }

#endif  // __WIFI_H__
