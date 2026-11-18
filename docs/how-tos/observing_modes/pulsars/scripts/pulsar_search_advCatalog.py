format = spherical
coordmode = J2000
head = name 	ra                  	dec                 	dm
J1713+0747  	17:13:49.5335615    	+07:47:37.482501    	15.9918
B1937+21    	19:39:38.561224     	+21:34:59.12570     	71.0
B1929+10    	19:32:13.9497       	+10:59:32.420       	3.18



# Load a source catalog; update this to point to your catalog
catalog = Catalog('valid/path/to/catalog.cat') 

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
swmode = 'tp_nocal' 
noisecal = 'off'
vegas.obsmode = 'coherent_search'
tint = 10.24e-6
vegas.numchan = 512
vegas.scale = 1585
vegas.polnmode = 'full_stokes'
vegas.dm = %f
"""

config_coherent_cal = """
swmode = 'tp' 
noisecal = 'lo' 
vegas.obsmode = 'coherent_cal'
tint = 10.24e-6
vegas.numchan = 512
vegas.scale = 1585
vegas.fold_bins = 2048
vegas.fold_dumptime = 10.0
"""


ResetConfig()

for i, source in enumerate(catalog.keys()):
      # Only perform AutoPeakFocus() for first source
      if i == 0:
            AutoPeakFocus(location=source)
      Slew(source)

      # Configure for calibration observation
      Configure(config_common + config_LBand + config_coherent_cal)
      # Balance the IF system
      Balance()
      Balance()
      # Take calibration data
      Track(source, None, cal_scan_length)

      # Configure for pulsar observation
      DM = float(catalog[source]['dm'])
      Configure(config_common + config_LBand + config_coherent_search%DM)
      # Take pulsar data
      Track(source, None, pulsar_scan_length)
