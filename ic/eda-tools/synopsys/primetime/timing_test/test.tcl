set test_cell top_cell
set lib_file test
set search_path "."
set link_path "* ./test.lib"

read_verilog test.v
read_sdf test.sdf
current_design top_cell
link_design

set clk CK
create_clock -period 0.8 -waveform {0 6} $clk
set_propagated_clock [get_ports $clk]
set_clock_uncertainty 0.03 $clk
set_clock_transition 0.08 $clk

# SDC(约束)
# read_sdc test.sdc
set_input_delay 0.30 -clock $clk [remove_from_collection [all_inputs] $clk]
set_output_delay 0.30 -clock $clk [all_outputs]
set_driving_cell -library $lib_file -lib_cell $test_cell [remove_from_collection [all_inputs] $clk]
set_max_delay 1.0 -from INPUT_PIN -to inst/OUT_PIN
set_load 0.001547 [all_outputs]

# report_constraint -all_violators
check_timing
update_timing
report_timing

quit
