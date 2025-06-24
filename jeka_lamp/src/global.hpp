#ifndef __GLOBAL_H__
#define __GLOBAL_H__

#include "include.h"

#if (DISPLAY_DEBUG == 1)
GyverOLED<SSD1306_128x64> oled;
#endif

LampSettings lampSettings;


#endif // __GLOBAL_H__