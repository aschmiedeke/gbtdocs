# configuration definition for spectral line observations
# using a multi-beam receiver
tp_config_multi_beam = '''
receiver  = 'Rcvr40_52'
beam      = '1,2'
obstype   = 'Spectroscopy'
backend   = 'VEGAS'
restfreq  = 44580, 43751, 45410, 46250
deltafreq = 0,100,0,0
bandwidth = 1500
nchan     = 16384
swmode    = 'tp'
swtype    = 'none'
swper     = 1.0
tint      = 10
vframe    = 'lsrk'
vdef      = 'Radio'
noisecal  =  'lo'
pol       = 'Circular'
'''
