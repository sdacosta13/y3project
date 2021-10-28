.DEFAULT_GOAL := all

PLUGINS =  lib_vscreen.so lib_comp15111.so
PLUGINS += lib_fileaccess.so lib_timer.so lib_pio_keypad.so

%.so: %.c
	gcc -g -o $@ --shared $^ -fPIC

clean:
	rm $(PLUGINS)

all: $(PLUGINS)
