# configuration definition for multiple spectral line observations
# using total power switching
tp_config='''
receiver  = 'Rcvr8_10'
obstype   = 'Spectroscopy'
backend   = 'VEGAS'
restfreq  = 9816.867, 9487.824, 9173.323, 8872.571, 
            9820.9, 9821.5, 9822.6, 9823.4, 9824.6
dopplertrackfreq = 8873.1
bandwidth = 23.44 
nchan     = 8192
swmode    = 'tp'
swtype    = 'none'
swper     = 1.0
tint      = 30 
vframe    = 'lsrk'
vdef      = 'Radio'
noisecal  = 'lo'
pol       = 'Circular'
'''
