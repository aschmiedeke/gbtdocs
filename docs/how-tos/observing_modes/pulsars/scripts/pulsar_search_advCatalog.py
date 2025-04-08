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
      Configure(config_common + config_LBand + vegas_config_cal)

      # Balance the IF system
      Balance()
      Balance()

      # Take calibration data
      Track(source, None, cal_scan_length)

      # Configure for pulsar observation
      Configure(config_common + config_LBand + vegas_config_fold%float(catalog[source]['dm']))

      # Take pulsar data
      Track(source, None, pulsar_scan_length)
