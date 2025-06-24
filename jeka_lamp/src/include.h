#ifndef __INCLUDE_H__
#define __INCLUDE_H__

#include <Arduino.h>
#include <Preferences.h>
#include <stdint.h>

Preferences preferences;
// #include <EEPROM.h>
// #include <esp_attr.h>

#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <FastLED.h>
#include <WiFi.h>
#include <HTTPClient.h>

#include <define.hpp>

#if (DISPLAY_DEBUG == 1)
#include <GyverOLED.h>
#endif

#include <LampSettings.hpp>
#include "global.hpp"

#include "utils/Time.h"
#include "utils/timerMillis.h"
#include <ledMatrix.hpp>
#include "network.hpp"
#include <BLE.hpp>
#include "wifiFunc.hpp"
#include <data.hpp>
#if (DISPLAY_DEBUG == 1)
#include <display.hpp>
#endif

#include <effects/effect.hpp>
#include <sound.hpp>

#include "vol/VolAnalyzer.h"



#endif  // __INCLUDE_H__