#include <stdlib.h>
#include "Vtone_generator_testbench.h"
#include "verilated.h"
//#include "verilated_vcd_c.h"

//#define TONE_SWITCH_PERIOD 284091
//#define TONE_SWITCH_PERIOD 5

int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);
    Vtone_generator_testbench* dut = new Vtone_generator_testbench;

    //Verilated::traceEverOn(true);
    //VerilatedVcdC* tfp = new VerilatedVcdC;
    //dut->trace(tfp, 99);
    //tfp->open("tone_generator.vcd");

    //dut->clk = 0;
    //dut->output_enable = 1;
    //dut->tone_switch_period = TONE_SWITCH_PERIOD;
    
    while(!Verilated::gotFinish()) {
        tb->eval();
    }
    exit(0);
}
