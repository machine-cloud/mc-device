all: test_led test_switch test_temperature

test_led: test_led.c
	gcc -lwiringPi -o bin/$@ $<

test_switch: test_switch.c
	gcc -lwiringPi -o bin/$@ $<

test_temperature: test_temperature.c
	gcc -lwiringPi -o bin/$@ $<
