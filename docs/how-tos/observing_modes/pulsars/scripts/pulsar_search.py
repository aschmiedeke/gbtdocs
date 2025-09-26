# Load a source catalog
# pulsars_all_GBT is a built-in catalog
psr_catalog = Catalog(pulsars_all_GBT)
# load in your catalog of globular clusters
gc_catalog = Catalog('valid/path/to/my_gc_catalog.cat')

# flux cal source
fluxcal_source = '3C348'
# test scan source
test_source = 'B1933+16'
# target of interest
gc_source = 'GlobClusterX'

# Search for pulsars for 30 minutes or until a UTC stop time
use_stop_time = True
pulsar_scan_length = 60 * 30
stop_time = '21:00:00'

cal_scan_length = 65


# Define config strings
config_common = """
obstype = 'Pulsar'
backend = 'VEGAS'
deltafreq = 0.0
swtype = 'none'
swper = 0.04
swfreq = 0
vdef = 'Radio'
vframe = 'topo'
vlow = 0.0
vhigh = 0.0 
vegas.outbits = 8
"""

config_LBand = """
receiver = 'Rcvr1_2'
pol = 'Linear'
notchfilter = 'In'
nwin = 1
restfreq = 1500.0
dopplertrackfreq = 1500.0
bandwidth = 800.0
"""

config_coherent_search = """
vegas.obsmode = 'coherent_search'
swmode = 'tp_nocal' 
noisecal = 'off'
tint = 10.24e-6
vegas.numchan = 512
vegas.scale = 1585
vegas.polnmode = 'full_stokes'
vegas.dm = 100
"""

config_incoherent_search = """
vegas.obsmode = 'search'
tint = 81.92e-6
vegas.numchan = 2048
vegas.scale = 7495
vegas.polnmode = 'total_intensity'
"""

vegas_config_cal = """
swmode = 'tp' 
noisecal = 'lo' 
vegas.obsmode = 'coherent_cal'
vegas.fold_bins = 2048
vegas.fold_dumptime = 10.0
"""


ResetConfig()

# Pointing/focus corrections using a source close to the pulsar
Slew(fluxcal_source)
AutoPeakFocus(fluxcal_source)

Slew(fluxcal_source)

# Configure for flux cal observations
Configure(config_common + config_LBand + vegas_config_cal)

# Balance the IF system
Balance()
Balance()

# Take calibration data
Track(source, None, cal_scan_length)

Slew(test_source)

# Configure for VEGAS observations
Configure(config_common + config_LBand + config_coherent_search)

# Take test data
Track(source, None, cal_scan_length)


# Take pulsar search data
if use_stop_time:
      Track(source, None, stopTime = stop_time)
else:
      Track(source, None, pulsar_scan_length)

