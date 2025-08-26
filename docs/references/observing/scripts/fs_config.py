# configuration definition for spectral line observations
# using frequency switching

fs_config='''
receiver  = 'Rcvr1_2'  
obstype   = 'Spectroscopy'
backend   = 'VEGAS'
restfreq  = 1420
bandwidth = 23.44 
nchan     = 65536
vegas.subband = 1
swmode    = 'sp' 
swtype    = 'fsw'
swper     = 2.0
swfreq    = 0, -5.0
tint      = 10 
vframe    = 'lsrk'
vdef      = 'Radio'
noisecal  = 'lo'
pol       = 'Linear'
'''
