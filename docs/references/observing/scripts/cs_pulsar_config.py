config_cs_pulsar = """
obstype = 'Pulsar'
# 'receiver' can be any GBT receiver except MUSTANG.  Here, we use Rcvr1_2, 
# aka L-Band
receiver = 'Rcvr1_2'
restfreq = 1500.0
nwin = 1
pol = 'Linear'
backend = 'VEGAS'
bandwidth = 800.0
# In CS modes tint should be 16*vegas.numchan/bandwidth (in Hz)
tint = 16*512/800e6
deltafreq = 0.0
# For 'swmode', choose 'tp' for calibration, 'tp_nocal' for pulsar 
# observation
swmode = 'tp_nocal' 
swtype = 'none'
swper = 0.04
swfreq = 0
# For 'noisecal' choose 'lo' for calibration, 'off' for pulsar observation
noisecal = 'off' 
vlow = 0.0
vhigh = 0.0
vframe = 'topo'
vdef = 'Radio'
# The following VEGAS keywords are required when using CS
# 'vegas.obsmode' can be coherent_cal, or coherent_fold
vegas.obsmode = 'coherent_fold' 
# 'vegas.polnmode' must be full stokes.
vegas.polnmode = 'full_stokes'
# 'vegas.numchan' is very flexible.  See the text for allowable values.
vegas.numchan = 512
# 'vegas.scale' is configuration specific.  Ask your project friend for
# suggestions.
vegas.scale = 1200
vegas.outbits = 8
# The parfile must be compatible with TEMPO1 in prediction mode
vegas.fold_parfile = '/home/gpu/tzpar/B1937+21.par'
# The following keywords control the parameters of the VEGAS data.
# Similar parameters control the CS data (see below).
vegas.fold_bins = 2048
vegas.fold_dumptime = 10.0
# The following keywords are required for CS.
vegas.cycspec = 1
# 'vegas.ncyc' controls the cyclic channelization factor.  See the
# text for allowable values.
vegas.ncyc = 128
# 'vegas.cycspec_num_bins' is the number of pulse phase bins in the
# CS data.  See the text for allowable values.
vegas.cycspec_num_bins = 512
# 'vegas.cycspec_fold_dumptime is the sub-integration time in the CS
# data, specified in seconds.
vegas.cycspec_fold_dumptime = 10
"""
