#!/bin/sh


# cleanup
rm -rf obj_dir
#rm -f  tone_generator.vcd


# run Verilator to translate Verilog into C++, include C++ testbench
verilator -Wall --cc --trace tone_generator_testbench.v --exe tone_generator_testbench_tb.cpp
# build C++ project
make -j -C obj_dir/ -f Vtone_generator_testbench.mk Vtone_generator_testbench
# run executable simulation
obj_dir/Vtone_generator_testbench


# view waveforms
#gtkwave tone_generator.vcd tone_generator.sav &

