SIM_BUILD = median_filter_tb.vvp
SOURCES   = ../src/pixel_pkg.sv ../src/median_filter.sv ../tb/median_filter_tb.sv

.PHONY: run clean

run:
	iverilog -g2012 -Wall -o $(SIM_BUILD) $(SOURCES)
	vvp $(SIM_BUILD) +INPUT=../tb/test_vectors/input_pixels.csv +EXPECTED=../tb/test_vectors/expected_pixels.csv +OUTPUT=../tb/output_pixels.csv

clean:
	rm -f $(SIM_BUILD)
	rm -f ../tb/output_pixels.csv
