# configuration definition for continuum observations

continuum_config='''
receiver  = 'Rcvr1_2'
beam      = '1'
obstype   = 'Continuum'
backend   = 'DCR'
nwin      = 1
restfreq  = 1400
bandwidth = 80
swmode    = 'tp'
swtype    = 'none'
swper     = 0.2
tint      = 0.2
vframe    = 'topo'
vdef      = 'Radio'
noisecal  =  'lo'
pol       = 'Linear'
'''
