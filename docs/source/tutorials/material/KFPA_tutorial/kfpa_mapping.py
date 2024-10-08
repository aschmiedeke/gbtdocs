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
swper               = 0.417
tint                = 0.834
vlow                = 0
vhigh               = 0
vframe              = 'lsrk'
vdef                = 'Radio' 
noisecal            = 'lo'
pol                 = 'Circular'
"""

Configure(config)

W51Source = Location('Galactic', 49.445, -0.35)
W51Off = Location('Galactic', 49.483, 0.642)

Slew(W51Off)
Balance()

Track(location=W51Off, 
      endOffset=None,
      scanDuration=30.0,
      beamName='1')

RALongMap(location=W51Source, 
          hlength=Offset('J2000', 15.6/60., 0.0, cosv=True),
          vlength=Offset('J2000', 0.0, 12.48/60., cosv=True),
          vDelta=Offset('J2000', 0.0, 12.91/3600., cosv=True),
          scanDuration=120,
          start=1,
          stop=59)

Track(location=W51Off, 
      endOffset=None,
      scanDuration=30.0,
      beamName='1')
