// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtone_generator__Syms.h"


//======================

void Vtone_generator::traceChg(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    Vtone_generator* t=(Vtone_generator*)userthis;
    Vtone_generator__Syms* __restrict vlSymsp = t->__VlSymsp;  // Setup global symbol table
    if (vlSymsp->getClearActivity()) {
	t->traceChgThis(vlSymsp, vcdp, code);
    }
}

//======================


void Vtone_generator::traceChgThis(Vtone_generator__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	if (VL_UNLIKELY((1U & (vlTOPp->__Vm_traceActivity 
			       | (vlTOPp->__Vm_traceActivity 
				  >> 1U))))) {
	    vlTOPp->traceChgThis__2(vlSymsp, vcdp, code);
	}
	vlTOPp->traceChgThis__3(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void Vtone_generator::traceChgThis__2(Vtone_generator__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgQuad(c+1,(vlTOPp->tone_generator__DOT__counter),33);
	vcdp->chgBit(c+3,(vlTOPp->tone_generator__DOT__pwm_out));
    }
}

void Vtone_generator::traceChgThis__3(Vtone_generator__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgBit(c+4,(vlTOPp->clk));
	vcdp->chgBit(c+5,(vlTOPp->output_enable));
	vcdp->chgBus(c+6,(vlTOPp->tone_switch_period),24);
	vcdp->chgBit(c+7,(vlTOPp->volume));
	vcdp->chgBit(c+8,(vlTOPp->square_wave_out));
    }
}
