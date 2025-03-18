config="""
receiver            = 'RcvrArray18_26'
beam                = 'All'
obstype             = 'Spectroscopy'
backend             = 'VEGAS' 
restfreq            = 23694.5, 23722.63
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

W51Peak = Location('Galactic', 49.483, -0.358)
W51Off = Location('Galactic', 49.483, 0.642)

Slew(W51Off)
Balance()
OnOff(location=W51Peak, 
      referenceOffset=W51Off, 
      scanDuration=30.0, 
      beamName='1')
