#Clockconstraints
create_clock -name "SystemClock" -period 20.000ns [get_ports {clk_pin}]
#AutomaticallyconstrainPLLandothergeneratedclocks
derive_pll_clocks -create_base_clocks
#Automaticallycalculateclockuncertaintytojitterandothereffects.
derive_clock_uncertainty
