config_common = """
obstype = 'Pulsar'
backend = 'VEGAS'
deltafreq = 0.0
swtype = 'none'
swper = 0.04
swfreq = 0
swmode = 'tp_nocal' 
noisecal = 'off'
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


# Load a source catalog
catalog = Catalog(pulsars_all_GBT)

# Specify several sources in a list
sources = ['J1713+0747', 'B1937+21', 'B1929+10']

# Observe each pulsar for 30 minutes
pulsar_scan_length = 60 * 30


< rest of observing script here, as in example above >

# Note the use of string substitution to dynamically specify the parfile name
vegas_config_search = """
swmode = 'tp_nocal' 
noisecal = 'off' 
vegas.obsmode = 'coherent_search' 
vegas.dm = %f
"""

< rest of observing script here, as in example above >


# Pointing/focus corrections using a source close to the first pulsar
AutoPeakFocus(location = sources[0])

# Loop over all sources defined above
for source in sources:
      Slew(source)

      # Configure for calibration observation
      Configure(config_common + config_LBand + vegas_config_cal)

      # Balance the IF system
      Balance()
      Balance()

      # Take calibration data
      Track(source, None, cal_scan_length)

      # Configure for pulsar observation
      Configure(config_common + config_LBand +       config_coherent_search%dm)
      
      # Take pulsar data
      Track(source, None, pulsar_scan_length)




format = spherical
coordmode = J2000
head = name 	ra                  	dec                 	dm
J1713+0747  	17:13:49.5335615    	+07:47:37.482501    	15.9904
B1937+21    	19:39:38.561224     	+21:34:59.12570     	71.0151
B1929+10    	19:32:13.9497       	+10:59:32.420       	3.1832


# Load a source catalog
catalog = Catalog('valid/path/to/catalog.cat')

< rest of observing script here, as in example above >

vegas_config_search = """
swmode = 'tp_nocal' 
noisecal = 'off' 
vegas.obsmode = 'coherent_search' 
vegas.dm = %f
"""

< rest of observing script here, as in example above >

for i, source in enumerate(catalog.keys()):
      # Only perform AutoPeakFocus() for first source
      if i == 0:
            AutoPeakFocus(location=source)
      Slew(source)

      # Configure for calibration observation
      Configure(config_common + config_LBand +       vegas_config_cal)

      # Balance the IF system
      Balance()
      Balance()

      # Take calibration data
      Track(source, None, cal_scan_length)

      # Configure for pulsar observation
      Configure(config_common + config_LBand +       vegas_config_fold%float(catalog[source]['dm']))

      # Take pulsar data
      Track(source, None, pulsar_scan_length)


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













