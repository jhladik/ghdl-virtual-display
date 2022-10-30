all:
	ghdl -a --std=08 -frelaxed timing_generator/timing_generator.vhd virtual_display.vhd tb_virtual_display.vhd
	ghdl -e --std=08 -frelaxed -Wl,virtual_display.c -Wl,-lX11 -o tb_virtual_display tb_virtual_display

clean:
	rm -f *.o *.cf tb_virtual_display

