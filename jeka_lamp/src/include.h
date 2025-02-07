#ifndef __INCLUDE_H__
#define __INCLUDE_H__

#include <stdint.h>

#include <Arduino.h>
#include <Preferences.h>

Preferences preferences;
// #include <EEPROM.h>
// #include <esp_attr.h>

#include <BLE2902.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <WiFi.h>


#include <FastLED.h>
#if (DISPLAY_DEBUG == 1)
#include <GyverOLED.h>
#endif


#include <define.hpp>

#include "vol/VolAnalyzer.h"
#include "utils/timerMillis.h"
#include "utils/Time.h"
#include <LampSettings.hpp>
#include <ledMatrix.hpp>
#include "wifiFunc.hpp"
#include <sound.hpp>
#include <data.hpp>
#include <BLE.hpp>
#include <effects/effect.hpp>
#if (DISPLAY_DEBUG == 1)
#include <display.hpp>
#endif

#endif  // __INCLUDE_H__