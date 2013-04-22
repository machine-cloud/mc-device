#!/usr/bin/env node

/* blinkin.js
**
** Copyright (c) 2012 Meadhbh S. Hamrick, All Rights Reserved
**
** @License( https://raw.github.com/OhMeadhbh/node-wiringpi/master/LICENSE )
**
** This is a simple example of the node-wiringpi package. It assumes you have
** LEDs attached to pins 0, 1 & 2. Check out this URL for a good guide to 
** hooking up LEDs to a Raspberry Pi:
**
**   https://projects.drogon.net/raspberry-pi/gpio-examples/tux-crossing/gpio-examples-1-a-single-led/
**
*/

var wiringpi = require( 'node-wiringpi' );

var RED_PIN = 4
var GREEN_PIN = 25;
var BLUE_PIN  = 23;

var SWITCH_PIN = 24; 

var MCP_CHANNEL =  0;
var MCP_FREQUENCY = 100000;
var TEMP_CHANNEL = 7;

wiringpi.pin_mode( RED_PIN, wiringpi.PIN_MODE.OUTPUT );
wiringpi.pin_mode( BLUE_PIN, wiringpi.PIN_MODE.OUTPUT );
wiringpi.pin_mode( GREEN_PIN, wiringpi.PIN_MODE.OUTPUT );

if(wiringpi.setup_spi(MCP_CHANNEL, MCP_FREQUENCY) == -1){
  console.log("MCP setup error")
  process.exit(1)
}

var HIGH = wiringpi.WRITE.HIGH;
var LOW  = wiringpi.WRITE.LOW;

var pins = [4,23,25];
var pattern = [
  [ LOW , LOW , LOW  ],
  [ LOW , LOW , HIGH ],
  [ LOW , HIGH, HIGH ],
  [ LOW , HIGH, LOW  ],
  [ HIGH, HIGH, LOW  ],
  [ HIGH, LOW , LOW  ],
  [ HIGH, LOW , HIGH ],
  [ HIGH, HIGH, HIGH ]
];

var index = 0;

//blink lights
setInterval( function () {
  var current = pattern[ index ];

  for( var i = 0, il = current.length; i < il; i++ ) {
    wiringpi.digital_write( pins[i], current[i] );    
  }

  index = ( index + 1 ) % pattern.length;

}, 250 );

//read switch
setInterval( function () {
  console.log("Switch: " + wiringpi.digital_read(SWITCH_PIN));
}, 250 );

//read temp
setInterval( function () {
  var mcp_value = wiringpi.mcp_read_channel(MCP_CHANNEL, TEMP_CHANNEL);
  var temp_value = ((((mcp_value * ( 3300.0 / 1023.0 )) - 100) / 10.0) - 40.0);
  console.log("Temp: " + temp_value);
}, 250 );

process.on('SIGINT', function(){
  wiringpi.digital_write( RED_PIN, LOW);    
  wiringpi.digital_write( BLUE_PIN, LOW);    
  wiringpi.digital_write( GREEN_PIN, LOW);    
  process.exit(0);
})
