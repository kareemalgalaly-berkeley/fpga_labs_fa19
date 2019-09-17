#!/bin/sh


# cleanup
rm -rf obj_dir
rm -f  tone_generator.vcd


# run Verilator to translate Verilog into C++, include C++ testbench
verilator -Wall --cc --trace tone_generator.v --exe tone_generator_tb.cpp
# build C++ project
make -j -C obj_dir/ -f Vtone_generator.mk Vtone_generator
# run executable simulation
obj_dir/Vtone_generator


# view waveforms
gtkwave tone_generator.vcd tone_generator.sav &

