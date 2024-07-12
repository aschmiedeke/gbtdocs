# Load a source catalog
# pulsars_all_GBT is a built-in catalog
catalog = Catalog(pulsars_all_GBT)

source = 'J1713+0747'

# Observe the pulsar for 30 minutes or until a UTC stop time
use_stop_time = True
pulsar_scan_length = 60 * 30
stop_time = '21:00:00'

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
vegas.scale         = 1000
vegas.outbits       = 8
vegas.fold_bins     = 2048
vegas.fold_dumptime = 10.0
vegas.polnmode      = 'full_stokes'
"""

vegas_config_fold = """
swmode              = 'tp_nocal'
noisecal            = 'off'
vegas.obsmode       = 'coherent_fold'
vegas.fold_parfile  = '/home/gpu/tzpar/B1937+21.par'
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
Track(source, None, cal_scan_length)

# Configure for pulsar observation
Configure(config_common + config_LBand + config_vegas_common + vegas_config_fold)

# Take pulsar data
if use_stop_time:
    Track(source, None, stopTime = stop_time)
else:
    Track(source, None, pulsar_scan_length)
