// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtone_generator.h for the primary calling header

#include "Vtone_generator.h"
#include "Vtone_generator__Syms.h"


//--------------------
// STATIC VARIABLES


//--------------------

VL_CTOR_IMP(Vtone_generator) {
    Vtone_generator__Syms* __restrict vlSymsp = __VlSymsp = new Vtone_generator__Syms(this, name());
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    _ctor_var_reset();
}

void Vtone_generator::__Vconfigure(Vtone_generator__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Vtone_generator::~Vtone_generator() {
    delete __VlSymsp; __VlSymsp=NULL;
}

//--------------------


void Vtone_generator::eval() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtone_generator::eval\n"); );
    Vtone_generator__Syms* __restrict vlSymsp = this->__VlSymsp;  // Setup global symbol table
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
#ifdef VL_DEBUG
    // Debug assertions
    _eval_debug_assertions();
#endif  // VL_DEBUG
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
	VL_DEBUG_IF(VL_DBG_MSGF("+ Clock loop\n"););
	vlSymsp->__Vm_activity = true;
	_eval(vlSymsp);
	if (VL_UNLIKELY(++__VclockLoop > 100)) {
	    // About to fail, so enable debug to see what's not settling.
	    // Note you must run make with OPT=-DVL_DEBUG for debug prints.
	    int __Vsaved_debug = Verilated::debug();
	    Verilated::debug(1);
	    __Vchange = _change_request(vlSymsp);
	    Verilated::debug(__Vsaved_debug);
	    VL_FATAL_MT(__FILE__,__LINE__,__FILE__,"Verilated model didn't converge");
	} else {
	    __Vchange = _change_request(vlSymsp);
	}
    } while (VL_UNLIKELY(__Vchange));
}

void Vtone_generator::_eval_initial_loop(Vtone_generator__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    // Evaluate till stable
    int __VclockLoop = 0;
    QData __Vchange = 1;
    do {
	_eval_settle(vlSymsp);
	_eval(vlSymsp);
	if (VL_UNLIKELY(++__VclockLoop > 100)) {
	    // About to fail, so enable debug to see what's not settling.
	    // Note you must run make with OPT=-DVL_DEBUG for debug prints.
	    int __Vsaved_debug = Verilated::debug();
	    Verilated::debug(1);
	    __Vchange = _change_request(vlSymsp);
	    Verilated::debug(__Vsaved_debug);
	    VL_FATAL_MT(__FILE__,__LINE__,__FILE__,"Verilated model didn't DC converge");
	} else {
	    __Vchange = _change_request(vlSymsp);
	}
    } while (VL_UNLIKELY(__Vchange));
}

//--------------------
// Internal Methods

VL_INLINE_OPT void Vtone_generator::_sequent__TOP__1(Vtone_generator__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtone_generator::_sequent__TOP__1\n"); );
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Variables
    // Begin mtask footprint  all: 
    VL_SIG64(__Vdly__tone_generator__DOT__counter,32,0);
    // Body
    __Vdly__tone_generator__DOT__counter = vlTOPp->tone_generator__DOT__counter;
    // ALWAYS at tone_generator.v:16
    if ((VL_ULL(1) == vlTOPp->tone_generator__DOT__counter)) {
	vlTOPp->tone_generator__DOT__pwm_out = (1U 
						& (~ (IData)(vlTOPp->tone_generator__DOT__pwm_out)));
	__Vdly__tone_generator__DOT__counter = (QData)((IData)(vlTOPp->tone_switch_period));
    } else {
	__Vdly__tone_generator__DOT__counter = (VL_ULL(0x1ffffffff) 
						& (vlTOPp->tone_generator__DOT__counter 
						   - VL_ULL(1)));
    }
    vlTOPp->tone_generator__DOT__counter = __Vdly__tone_generator__DOT__counter;
    vlTOPp->_counter = vlTOPp->tone_generator__DOT__counter;
    vlTOPp->square_wave_out = vlTOPp->tone_generator__DOT__pwm_out;
}

void Vtone_generator::_initial__TOP__2(Vtone_generator__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtone_generator::_initial__TOP__2\n"); );
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // INITIAL at tone_generator.v:10
    vlTOPp->tone_generator__DOT__counter = VL_ULL(1);
    // INITIAL at tone_generator.v:11
    vlTOPp->tone_generator__DOT__pwm_out = 0U;
}

void Vtone_generator::_settle__TOP__3(Vtone_generator__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtone_generator::_settle__TOP__3\n"); );
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_counter = vlTOPp->tone_generator__DOT__counter;
    vlTOPp->square_wave_out = vlTOPp->tone_generator__DOT__pwm_out;
}

void Vtone_generator::_eval(Vtone_generator__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtone_generator::_eval\n"); );
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((IData)(vlTOPp->clk) ^ (IData)(vlTOPp->__Vclklast__TOP__clk))) {
	vlTOPp->_sequent__TOP__1(vlSymsp);
	vlTOPp->__Vm_traceActivity = (2U | vlTOPp->__Vm_traceActivity);
    }
    // Final
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

void Vtone_generator::_eval_initial(Vtone_generator__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtone_generator::_eval_initial\n"); );
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
    vlTOPp->_initial__TOP__2(vlSymsp);
    vlTOPp->__Vm_traceActivity = (1U | vlTOPp->__Vm_traceActivity);
}

void Vtone_generator::final() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtone_generator::final\n"); );
    // Variables
    Vtone_generator__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vtone_generator::_eval_settle(Vtone_generator__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtone_generator::_eval_settle\n"); );
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    vlTOPp->_settle__TOP__3(vlSymsp);
}

VL_INLINE_OPT QData Vtone_generator::_change_request(Vtone_generator__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtone_generator::_change_request\n"); );
    Vtone_generator* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}

#ifdef VL_DEBUG
void Vtone_generator::_eval_debug_assertions() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtone_generator::_eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((clk & 0xfeU))) {
	Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((output_enable & 0xfeU))) {
	Verilated::overWidthError("output_enable");}
    if (VL_UNLIKELY((tone_switch_period & 0xff000000U))) {
	Verilated::overWidthError("tone_switch_period");}
    if (VL_UNLIKELY((volume & 0xfeU))) {
	Verilated::overWidthError("volume");}
}
#endif // VL_DEBUG

void Vtone_generator::_ctor_var_reset() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtone_generator::_ctor_var_reset\n"); );
    // Body
    clk = VL_RAND_RESET_I(1);
    output_enable = VL_RAND_RESET_I(1);
    tone_switch_period = VL_RAND_RESET_I(24);
    volume = VL_RAND_RESET_I(1);
    square_wave_out = VL_RAND_RESET_I(1);
    _counter = VL_RAND_RESET_Q(33);
    tone_generator__DOT__counter = VL_RAND_RESET_Q(33);
    tone_generator__DOT__pwm_out = VL_RAND_RESET_I(1);
    __Vm_traceActivity = VL_RAND_RESET_I(32);
}
