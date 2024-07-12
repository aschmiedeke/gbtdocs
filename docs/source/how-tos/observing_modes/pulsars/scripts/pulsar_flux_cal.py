# Load a source catalog
# pulsars_all_GBT is a built-in catalog
catalog = Catalog('/users/rlynch/Catalogs/psrchive_fluxcal.cat')

source ='3C295'
cal_scan_length = 65


# Define config strings
config_common = """
obstype     = 'Pulsar'
backend     = 'VEGAS'
deltafreq   = 0.0
swtype      = 'none'
swper       = 0.04
swfreq      = 0
vdef        = 'Radio'
vframe      = 'topo'
vlow        = 0.0
vhigh       = 0.0
"""

config_LBand = """
receiver            = 'Rcvr1_2'
pol                 = 'Linear'
notchfilter         = 'In'
nwin                = 1
restfreq            = 1500.0
dopplertrackfreq    = 1500.0
bandwidth           = 800.0
"""

config_vegas_common = """
tint                = 10.24e-6
vegas.numchan       = 512
vegas.scale         = 1585
vegas.outbits       = 8
vegas.fold_bins     = 2048
vegas.fold_dumptime = 10.0
vegas.polnmode      = 'full_stokes'
"""

vegas_config_cal = """
swmode          = 'tp'
noisecal        = 'lo'
vegas.obsmode   = 'coherent_cal'
"""


ResetConfig()

# Pointing/focus corrections using a source close to the pulsar
AutoPeakFocus(location = source)

Slew(source)

# Configure for calibration observation
Configure(config_common + config_LBand + config_vegas_common + vegas_config_cal)

# Balance the IF system
Balance()
Balance()

# Take calibration data
OnOff(source, Offset("AzEl", 1.0, 0.0, cosv=False), cal_scan_length)
