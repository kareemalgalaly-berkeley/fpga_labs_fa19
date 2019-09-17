// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtone_generator__Syms.h"


//======================

void Vtone_generator::trace(VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addCallback(&Vtone_generator::traceInit, &Vtone_generator::traceFull, &Vtone_generator::traceChg, this);
}
void Vtone_generator::traceInit(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->open()
    Vtone_generator* t=(Vtone_generator*)userthis;
    Vtone_generator__Syms* __restrict vlSymsp = t->__VlSymsp;  // Setup global symbol table
    if (!Verilated::calcUnusedSigs()) {
	VL_FATAL_MT(__FILE__,__LINE__,__FILE__,"Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vcdp->scopeEscape(' ');
    t->traceInitThis(vlSymsp, vcdp, code);
    vcdp->scopeEscape('.');
}
void Vtone_generator::traceFull(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    Vtone_generator* t=(Vtone_generator*)userthis;
    Vtone_generator__Syms* __restrict vlSymsp = t->__VlSymsp;  // Setup global symbol table
    t->traceFullThis(vlSymsp, vcdp, code);
}

//======================


void Vtone_generator::traceInitThis(Vtone_generator__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    vcdp->module(vlSymsp->name());  // Setup signal names
    // Body
    {
	vlTOPp->traceInitThis__1(vlSymsp, vcdp, code);
    }
}

void Vtone_generator::traceFullThis(Vtone_generator__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vlTOPp->traceFullThis__1(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void Vtone_generator::traceInitThis__1(Vtone_generator__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->declBit(c+4,"clk",-1);
	vcdp->declBit(c+5,"output_enable",-1);
	vcdp->declBus(c+6,"tone_switch_period",-1,23,0);
	vcdp->declBit(c+7,"volume",-1);
	vcdp->declBit(c+8,"square_wave_out",-1);
	// Tracing: _counter // Ignored: Leading underscore at tone_generator.v:8
	vcdp->declBit(c+4,"tone_generator clk",-1);
	vcdp->declBit(c+5,"tone_generator output_enable",-1);
	vcdp->declBus(c+6,"tone_generator tone_switch_period",-1,23,0);
	vcdp->declBit(c+7,"tone_generator volume",-1);
	vcdp->declBit(c+8,"tone_generator square_wave_out",-1);
	// Tracing: tone_generator _counter // Ignored: Inlined leading underscore at tone_generator.v:8
	vcdp->declQuad(c+1,"tone_generator counter",-1,32,0);
	vcdp->declBit(c+3,"tone_generator pwm_out",-1);
    }
}

void Vtone_generator::traceFullThis__1(Vtone_generator__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->fullQuad(c+1,(vlTOPp->tone_generator__DOT__counter),33);
	vcdp->fullBit(c+3,(vlTOPp->tone_generator__DOT__pwm_out));
	vcdp->fullBit(c+4,(vlTOPp->clk));
	vcdp->fullBit(c+5,(vlTOPp->output_enable));
	vcdp->fullBus(c+6,(vlTOPp->tone_switch_period),24);
	vcdp->fullBit(c+7,(vlTOPp->volume));
	vcdp->fullBit(c+8,(vlTOPp->square_wave_out));
    }
}
