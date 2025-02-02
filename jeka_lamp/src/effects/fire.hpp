#ifndef __FIRE_H__
#define __FIRE_H__

#include "../include.h"

#define NOISE_HEIGHT WIDTH * 4
byte noises[WIDTH * NOISE_HEIGHT]; // precalculated noise table
byte colorfade[HEIGHT];            // simple colorfade table for speedup

DEFINE_GRADIENT_PALETTE(firepal){
    // define fire palette
    0, 0, 0, 0,        // black
    32, 255, 0, 0,     // red
    190, 255, 255, 0,  // yellow
    255, 255, 255, 255 // white
};

CRGBPalette16 myPal = firepal;
byte a = 0;

void fireTick()
{

  for (int i = 0; i < WIDTH; i++)
  {
    for (int j = 0; j < HEIGHT; j++)
    {
      leds[getPixelNumber(i,j)] = ColorFromPalette (myPal, qsub8 (inoise8 (i * 60 , j * 60+ a , a /3), 
      abs8(j - (HEIGHT-1)) * 255 / (HEIGHT-1)), BRIGHTNESS);    
    }
  }
  // FastLED.delay(20);
  a++;
}
#endif // __FIRE_H__