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

#include <define.hpp>

#if (DISPLAY_DEBUG == 1)
#include <GyverOLED.h>
#endif

#include <BLE.hpp>
#include <LampSettings.hpp>
#include <data.hpp>
#include <effects/effect.hpp>
#include <ledMatrix.hpp>
#include <sound.hpp>

#include "utils/Time.h"
#include "utils/timerMillis.h"
#include "vol/VolAnalyzer.h"
#include "wifiFunc.hpp"

#if (DISPLAY_DEBUG == 1)
#include <display.hpp>
#endif

#endif  // __INCLUDE_H__