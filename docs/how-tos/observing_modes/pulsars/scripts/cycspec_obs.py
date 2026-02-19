# Load source catalog
# pulsars_all_GBT is a built-in catalog
pulsars = Catalog(pulsars_all_GBT)
# psrchive_fluxcal contains standard PSRCHIVE flux calibrators
fluxcal = Catalog("/users/rlynch/Catalogs/psrchive_fluxcal.cat")

# Choose pulse and flux calibration sources; make sure both sources
# are above the horizon during your session
pulsar_source = "B1937+21"
fluxcal_source = "3C295"

# Observe the pulsar for 1 hour (3600 seconds)
pulsar_scan_length = 3600

# Use 95 second scans for calibration observations
cal_scan_length = 95


# Define config strings
config_common = """
obstype     = 'Pulsar'
backend     = 'VEGAS'
deltafreq   = 0.0
swtype      = 'none'
swper       = 0.04
swfreq      = 0
vdef        = 'Radio'
vframe      = 'topo'
vlow        = 0.0
vhigh       = 0.0
"""

config_UWBR = """
receiver            = 'Rcvr_2500'
pol                 = 'Linear'
nwin                = 3
restfreq            = 1225.0,2350.0,3475.0
if0freq             = 6875.0
bandwidth           = 1500.0
"""

config_vegas_common = """
tint                = 16*1024/1500e6
vegas.numchan       = 1024
vegas.scale         = 1000
vegas.outbits       = 8
vegas.fold_bins     = 2048
vegas.fold_dumptime = 10.0
vegas.polnmode      = 'full_stokes'
"""

config_fold = """
swmode              = 'tp_nocal'
noisecal            = 'off'
vegas.obsmode       = 'coherent_fold'
vegas.fold_parfile  = '/home/gpu/tzpar/B1937+21.par'
"""

config_cal = """
swmode          = 'tp'
noisecal        = 'lo'
vegas.obsmode   = 'coherent_cal'
"""

config_cycspec = """
vegas.cycspec = 1
vegas.ncyc = 128
vegas.cycspec_num_bins = 512
vegas.cycspec_fold_dumptime = 10.0
"""

ResetConfig()

# Pointing/focus corrections using the flux calibration source
AutoPeakFocus(source=fluxcal_source)

# Move the telescope back to the flux calibration source
Slew(source)

# Configure for calibration observation
Configure(config_common+config_UWBR+config_vegas_common+config_cal+config_cycspec)

# Balance the IF system
Balance()

# Take flux calibration data
OnOff(source, Offset("AzEl",1.0,0.0), cal_scan_length)

# Move the telescope to the pulsar
Slew(pulsar_source)

# Configure for the polarization calibration observation
Configure(config_common+config_UWBR+config_vegas_common+config_cal+config_cycspec)

# Balance the IF system
Balance()

# Take polarization calibration data
Track(pulsar_source, None, cal_scan_length)

# Configure for the pulsar observation
Configure(config_common+config_UWBR+config_vegas_common+config_fold+config_cycspec)

# Take pulsar data
Track(source, None, pulsar_scan_length)
