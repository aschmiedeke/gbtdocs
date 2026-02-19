# Load the built-in Astrid catalogs
fluxcal = Catalog(fluxcal)
pulsars = Catalog(pulsars_bright_MSPs_GBT)

# Define some variables to be used elsewhere in the script
fluxcal_source = "3C286"
pulsar_source = "B1937+21"
cal_scan_length = 95.0
pulsar_scan_length = 3605.0

# Define the calibration configuration
config_cs_cal = """
obstype = 'Pulsar'
receiver = 'Rcvr1_2'
restfreq = 1500.0
nwin = 1
pol = 'Linear'
backend = 'VEGAS'
bandwidth = 800.0
tint = 16*512/800e6
deltafreq = 0.0
noisecal = 'lo' 
swmode = 'tp' 
swtype = 'none'
swper = 0.04
swfreq = 0
vlow = 0.0
vhigh = 0.0
vframe = 'topo'
vdef = 'Radio'
vegas.obsmode = 'coherent_cal' 
vegas.polnmode = 'full_stokes'
vegas.numchan = 512
vegas.scale = 1200
vegas.outbits = 8
vegas.fold_bins = 2048
vegas.fold_dumptime = 10.0
vegas.cycspec = 1
vegas.ncyc = 128
vegas.cycspec_num_bins = 512
vegas.cycspec_fold_dumptime = 10
"""


# Define the pulsar configuration
config_cs_pulsar = """
obstype = 'Pulsar'
receiver = 'Rcvr1_2'
restfreq = 1500.0
nwin = 1
pol = 'Linear'
backend = 'VEGAS'
bandwidth = 800.0
tint = 16*512/800e6
deltafreq = 0.0
noisecal = 'off' 
swmode = 'tp_nocal' 
swtype = 'none'
swper = 0.04
swfreq = 0
vlow = 0.0
vhigh = 0.0
vframe = 'topo'
vdef = 'Radio'
vegas.obsmode = 'coherent_fold' 
vegas.polnmode = 'full_stokes'
vegas.numchan = 512
vegas.scale = 1200
vegas.outbits = 8
vegas.fold_parfile = '/home/gpu/tzpar/B1937+21.par'
vegas.fold_bins = 2048
vegas.fold_dumptime = 10.0
vegas.cycspec = 1
vegas.ncyc = 128
vegas.cycspec_num_bins = 512
vegas.cycspec_fold_dumptime = 10
"""

# Slew to the flux calibration source
Slew(fluxcal_source)

# Measure and apply peak/focus corrections
AutoPeakFocus()

# Configure for the flux calibration scan
Configure(config_cs_cal)
# Balance the IF system
Balance()
# Take on and off source data
OnOff(fluxcal_source, Offset("AzEl",1.0,0.0,cosv=True), cal_scan_length)

# Slew to the pulsar
Slew(pulsar_source)

# Configure for the polarizatoin calibration scan.
Configure(config_cs_cal)
# Balance the IF system
Balance()

# Take a single polarization scan
Track(pulsar_source, None, cal_scan_length)

# Configure for the pulsar scan
Configure(config_cs_pulsar)

# Take the main scan.  Note that we do *not* balance again
Track(pulsar_source, None, pulsar_scan_length)
