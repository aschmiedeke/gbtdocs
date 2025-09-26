# Load a source catalog
# pulsars_all_GBT is a built-in catalog
psr_catalog = Catalog(pulsars_all_GBT)

# Specify several sources in a list
sources = ['J1713+0747', 'B1937+21', 'B1929+10']

# Observe each pulsar for 30 minutes
pulsar_scan_length = 60 * 30


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

# Note the use of string substitution to dynamically specify the parfile name
vegas_config_search = """
swmode = 'tp_nocal' 
noisecal = 'off' 
vegas.obsmode = 'coherent_search' 
vegas.dm = %f
"""

ResetConfig()

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
      Configure(config_common + config_LBand + config_coherent_search%dm)
      
      # Take pulsar data
      Track(source, None, pulsar_scan_length)
