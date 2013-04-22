#include <stdint.h>
#include <stdio.h>
#include <wiringPi.h>
#include <wiringPiSPI.h>

#define RED_PIN      23
#define GREEN_PIN    25
#define BLUE_PIN     4
#define TEMP_CHANNEL 7

#define MCP_CHANNEL   0
#define MCP_FREQUENCY 100000
#define DELAY         250

void setup_mcp() {
  if (wiringPiSPISetup(MCP_CHANNEL, MCP_FREQUENCY) < 0) {
    error("could not set up wiringPi SPI");
  }
}

char channel_headers[] = { 0b10000000, 0b10010000, 0b10100000, 0b10110000, 0b11000000, 0b11010000, 0b11100000, 0b11110000 };
 
int read_mcp_channel(int channel) {
  uint8_t buffer[] = { 0x01, channel_headers[channel], 0x00 };
  int reading;
  wiringPiSPIDataRW(MCP_CHANNEL, buffer, 3);
  reading = ((buffer[1] & 3) << 8) + buffer[2];
  return reading;
}

int main(){
  setup_mcp();

  while(1) {
    printf("temp: %2.2f°C\n", (((read_mcp_channel(TEMP_CHANNEL) * ( 3300.0 / 1023.0 )) - 100) / 10.0) - 40.0);
    delay(DELAY);
  } 
}
