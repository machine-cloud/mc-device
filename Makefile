all: test_led test_switch test_temperature

install:
	sudo cp mc-device.conf /etc/init/mc-device.conf
	git pull

test_led: src/test_led.c
	gcc -lwiringPi -o bin/$@ $<

test_switch: src/test_switch.c
	gcc -lwiringPi -o bin/$@ $<

test_temperature: src/test_temperature.c
	gcc -lwiringPi -o bin/$@ $<
