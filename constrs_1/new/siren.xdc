## ============================================================
## Clock (Nexys A7 onboard oscillator = 100 MHz)
## ============================================================

create_clock -name clk_50MHz -period 10.000 [get_ports clk_50MHz]
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports clk_50MHz]


## ============================================================
## Push Button Inputs
## ============================================================

# btnU
set_property -dict { PACKAGE_PIN M18 IOSTANDARD LVCMOS33 } [get_ports btnU]


## ============================================================
## PMOD JA → DAC (Pmod I2S or I2S2)
## JA pinout from Nexys A7 Master XDC:
##
## ja1 = C17
## ja2 = D18
## ja3 = E18
## ja4 = G17
## ja7 = D17
## ============================================================

# JA1 → dac_MCLK
set_property -dict { PACKAGE_PIN C17 IOSTANDARD LVCMOS33 } [get_ports { dac_MCLK }]

# JA2 → dac_LRCK
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVCMOS33 } [get_ports { dac_LRCK }]

# JA3 → dac_SCLK
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVCMOS33 } [get_ports { dac_SCLK }]

# JA4 → dac_SDIN
set_property -dict { PACKAGE_PIN G17 IOSTANDARD LVCMOS33 } [get_ports { dac_SDIN }]

# JA7 → adc_SDOUT (THIS IS NOW CORRECT)
set_property -dict { PACKAGE_PIN D17 IOSTANDARD LVCMOS33 } [get_ports { adc_SDOUT }]


## ============================================================
## LEDs (debug indicators)
## ============================================================

set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS33 } [get_ports { LED[0] }]
set_property -dict { PACKAGE_PIN K15 IOSTANDARD LVCMOS33 } [get_ports { LED[1] }]


set_property -dict { PACKAGE_PIN J15 IOSTANDARD LVCMOS33 } [get_ports { SW[0] }]
set_property -dict { PACKAGE_PIN L16 IOSTANDARD LVCMOS33 } [get_ports { SW[1] }]
set_property -dict { PACKAGE_PIN M13 IOSTANDARD LVCMOS33 } [get_ports { SW[2] }]
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 } [get_ports { SW[3] }]
set_property -dict { PACKAGE_PIN R17 IOSTANDARD LVCMOS33 } [get_ports { SW[4] }]
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { SW[5] }]
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { SW[6] }]
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 } [get_ports { SW[7] }]
