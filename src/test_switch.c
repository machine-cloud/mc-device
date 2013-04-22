#include <stdio.h>
#include <wiringPi.h>

#define SWITCH_PIN 24

#define DELAY 250

void setup_switch() {
  if (wiringPiSetupGpio() < 0) {
    error("could not set up gpio");
  }
}

int main(){
  setup_switch();

  while(1) {
    printf("switch: %d\n", digitalRead(SWITCH_PIN));
    delay(DELAY);
  }
}
