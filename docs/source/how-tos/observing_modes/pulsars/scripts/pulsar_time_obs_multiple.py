# Load a source catalog
catalog = Catalog(pulsars_all_GBT)

# Specify several sources in a list
sources = ['J1713+0747', 'B1937+21', 'B1929+10']

# Observe each pulsar for 30 minutes
pulsar_scan_length = 60 * 30


# < … rest of observing script here, as in example above >

# Note the use of string substitution to dynamically specify the parfile name
vegas_config_fold = """
swmode              = 'tp_nocal'
noisecal            = 'off'
vegas.obsmode       = 'coherent_fold'
vegas.fold_parfile  = '/home/gpu/tzpar/%s.par'
"""

# < … rest of observing script here, as in example above >


# Pointing/focus corrections using a source close to the first pulsar
AutoPeakFocus(location = sources[0])

# Loop over all sources defined above
for source in sources:
    Slew(source)

    # Configure for calibration observation
    Configure(config_common + config_LBand + config_vegas_common + vegas_config_cal)

    # Balance the IF system
    Balance()
    Balance()

    # Take calibration data
    Track(source, None, cal_scan_length)

    # Configure for pulsar observation
    Configure(config_common + config_LBand + config_vegas_common + vegas_config_fold%source)

    # Take pulsar data
    Track(source, None, pulsar_scan_length)
