#include <stdlib.h>
#include "Vtone_generator.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

//#define TONE_SWITCH_PERIOD 284091
#define TONE_SWITCH_PERIOD 5

int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);
    Vtone_generator* dut = new Vtone_generator;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);
    tfp->open("tone_generator.vcd");

    dut->clk = 0;
    dut->output_enable = 1;
    dut->tone_switch_period = TONE_SWITCH_PERIOD;

    int j = 0;

    for (int i = 0; i < 50; i++) {
        dut->clk = !dut->clk;
        dut->eval();
        printf("%d, %lu\n", dut->square_wave_out, dut->_counter);

        tfp->dump(j);
        j++;
    }
    tfp->close();
    exit(0);
}
