ResetConfig()

config="""
receiver            = 'RcvrArray18_26'
beam                = 'All'
obstype             = 'Spectroscopy'
backend             = 'VEGAS' 
restfreq            = 23694.5
bandwidth           = 23.44
dopplertrackfreq    = 23694.5
nchan               = 16384
swmode              = 'tp'
swtype              = 'none'
swper               = 1.0
tint                = 1.0
vlow                = 0
vhigh               = 0
vframe              = 'lsrk'
vdef                = 'Radio' 
noisecal            = 'lo'
pol                 = 'Circular'
"""

Configure(config)

W51Source = Location('Galactic', 49.445, -0.35)
AutoPeakFocus(source=None, location=W51Source)

