# Load a source catalog
catalog = Catalog("/valid/path/to/catalog.cat")

# < … rest of observing script here, as in example above >

vegas_config_fold = """
swmode              = 'tp_nocal'
noisecal            = 'off'
vegas.obsmode       = 'coherent_fold'
vegas.fold_parfile  = '%s'
"""

# < … rest of observing script here, as in example above >

for i, source in enumerate(catalog.keys()):
    # Only perform AutoPeakFocus() for first source
    if i == 0:
        AutoPeakFocus(location=source)
    Slew(source)

    # Configure for calibration observation
    Configure(config_common + config_LBand + config_vegas_common + vegas_config_cal)

    # Balance the IF system
    Balance()
    Balance()

    # Take calibration data
    Track(source, None, cal_scan_length)

    # Configure for pulsar observation
    Configure(config_common + config_LBand + config_vegas_common + vegas_config_fold%catalog[source][‘parfile’])

    # Take pulsar data
    Track(source, None, pulsar_scan_length)
