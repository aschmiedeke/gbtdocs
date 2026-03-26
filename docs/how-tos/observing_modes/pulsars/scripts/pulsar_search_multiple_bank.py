# Load a source catalog
# pulsars_all_GBT is a built-in catalog
psr_catalog = Catalog(pulsars_all_GBT)
# Load in your catalog of globular clusters; update this to point to
# your catalog
gc_catalog = Catalog('valid/path/to/my_gc_catalog.cat')

# Test scan source
test_source = 'B1933+16'
# Target of interest
source = 'GlobClusterX'

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

config_incoherent_cal = """
vegas.obsmode = 'cal'
swmode = 'tp' 
noisecal = 'lo'
tint = 40.96e-6
vegas.numchan = 2048
vegas.scale = 13035
vegas.polnmode = 'total_intensity'
"""

ResetConfig()

# Pointing/focus corrections using a source close to the pulsar
AutoPeakFocus(location = test_source)


# Slew to the test source
Slew(test_source)
# Configure for a calibration scan
Configure(config_common + config_CBand + config_incoherent_cal)
# Balance the IF system
Balance()
Balance()
# Take a calibration scan
Track(test_source, None, cal_scan_length)

# Configure for a search-mode scan
Configure(config_common + config_CBand + config_incoherent_search)
# Take test data
Track(test_source, None, cal_scan_length)


# Slew to the pulsar source
Slew(source)
# Configure for a calibration scan
Configure(config_common + config_CBand + config_incoherent_cal)
# Balance the IF system
Balance()
Balance()
# Take a calibration scan
Track(source, None, cal_scan_length)

# Configure for a search-mode scan
Configure(config_common + config_CBand + config_incoherent_search)
# Take pulsar search data
if use_stop_time:
      Track(source, None, stopTime=stop_time)
else:
      Track(source, None, pulsar_scan_length)

