#ifndef __WIFI_H__
#define __WIFI_H__


#include "include.h"

#if (DISPLAY_DEBUG == 1)
static char loading[5] = "\\|/-";
static uint8_t loading_i = 0;
#endif

void wifiInit() {
  if (lampSettings.wifiName[0] == '\0' or lampSettings.wifiPassword[0] == '\0')
    return;
  WiFi.begin(lampSettings.wifiName, lampSettings.wifiPassword);
  unsigned long startAttemptTime = millis();

  while (WiFi.status() != WL_CONNECTED &&
         millis() - startAttemptTime < WIFI_TIMEOUT_MS) {
    delay(100);
#if (SERIAL_LOG == 1)
    Serial.print(".");
#endif
  }

  if (WiFi.status() == WL_CONNECTED) {
#if (SERIAL_LOG == 1)
    Serial.println("\nWiFi подключен!");
#endif
#if (DISPLAY_DEBUG == 1)
    oled.setCursor(5, 7);
    oled.print('Y');
#endif

    blink(127, 2000);
  } else {
#if (SERIAL_LOG == 1)
    Serial.println(
        "\nНе удалось подключиться к WiFi. Продолжаем выполнение...");
#endif
#if (DISPLAY_DEBUG == 1)
    oled.setCursor(5, 7);
    oled.print('N');
#endif

    blink(0, 2000);
  }
}

typedef void (*ResponseCallback)(int httpCode, String payload);

struct RequestData {
  String url;
  ResponseCallback callback;
};

void httpRequestTask(void* param) {
  RequestData* req = (RequestData*) param;

  HTTPClient http;
  http.begin(req->url);

  int httpCode = http.GET();
  String payload = "";

  if (httpCode > 0) {
    payload = http.getString();
  }

  // Вызываем callback с результатом
  req->callback(httpCode, payload);

  http.end();
  delete req; // Освобождаем память
  vTaskDelete(NULL);
}

// Универсальная функция для вызова из любого места
void asyncHttpGet(String url, ResponseCallback callback) {
  RequestData* req = new RequestData{url, callback};
  xTaskCreate(
    httpRequestTask,
    "httpRequestTask",
    8192,
    req,
    1,
    NULL
  );
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