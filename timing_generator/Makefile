all:
	ghdl -a --std=08 timing_generator.vhd timing_generator_tb.vhd
	ghdl --elab-run --std=08 timing_generator_tb --wave=timing_generator_tb.ghw

clean:
	rm -f *.o *.cf *.ghw timing_generator_tb

