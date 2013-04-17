#include <stdio.h>
#include <wiringPi.h>

#define RED_PIN   23
#define GREEN_PIN 25
#define BLUE_PIN  4

int main(){

  if( wiringPiSetupGpio() == -1 )
    return 1;

  pinMode(RED_PIN,   OUTPUT);
  pinMode(BLUE_PIN,  OUTPUT);
  pinMode(GREEN_PIN, OUTPUT);

  while(1) {
    // Blink RGB LED
    digitalWrite(RED_PIN,   HIGH);
    delay(500);
    digitalWrite(RED_PIN,   LOW);
    digitalWrite(GREEN_PIN, HIGH);
    delay(500);
    digitalWrite(GREEN_PIN, LOW);
    digitalWrite(BLUE_PIN,  HIGH);
    delay(500);
    digitalWrite(BLUE_PIN,  LOW);
    delay(1000);
  }
}
