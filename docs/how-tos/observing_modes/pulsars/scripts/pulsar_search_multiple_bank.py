# Load a source catalog
# pulsars_all_GBT is a built-in catalog
psr_catalog = Catalog(pulsars_all_GBT)
# load in your catalog of globular clusters
gc_catalog = Catalog('valid/path/to/my_gc_catalog.cat')


# test scan source
test_source = 'B1933+16'
# target of interest
gc_source = 'GlobClusterX'

# Search for pulsars for 30 minutes or until a UTC stop time
use_stop_time = True
pulsar_scan_length = 60 * 30
stop_time = '21:00:00'


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

config_CBand = """
receiver = 'Rcvr4_6'
pol = 'Linear'
restfreq = 7687.5, 6562.5, 5437.5, 4312.5
dopplertrackfreq = 6000.0
bandwidth = 1500.0
"""

config_incoherent_search = """
vegas.obsmode = 'search'
swmode = 'tp_nocal' 
noisecal = 'off'
tint = 40.96e-6
vegas.numchan = 2048
vegas.scale = 13035
vegas.polnmode = 'total_intensity'
"""

ResetConfig()

# Pointing/focus corrections using a source close to the pulsar
AutoPeakFocus(location = source)

Slew(source)

# Configure for VEGAS observations
Configure(config_common + config_LBand + config_incoherent_search)

# Balance the IF system
Balance()
Balance()

# Take pulsar search data
if use_stop_time:
      Track(source, None, stopTime = stop_time)
else:
      Track(source, None, pulsar_scan_length)
