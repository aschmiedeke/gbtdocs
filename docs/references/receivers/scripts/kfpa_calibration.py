execfile('/home/astro-util/projects/GBTog/configs/kfpa_config.py')
Catalog(fluxcal)
Catalog(kband_pointing)
src = '3C286'                   # Do not use extended 3C sources

Configure(kfpa_config)          # Configure for KFPA receiver
AutoPeakFocus(src)              # Automatically slews, balances,
                                # and configures for continuum.

# Reconfigure for VEGAS+KFPA using the same configuration 
# you would use for your science observations

Configure(kfpa_config)          
Slew(src)
Balance()

# The following combination of Nod scans cover all 7 beams
# edit them as necessary for other beam configurations.

Nod(src, '3', '7', scanDuration=30.0)
Nod(src, '2', '6', scanDuration=30.0) 
Nod(src, '4', '1', scanDuration=30.0) 
Nod(src, '1', '5', scanDuration=30.0)
