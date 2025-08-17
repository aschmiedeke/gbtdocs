# Astrid setup script for X-band planetary radar
ResetConfig()
Catalog('/home/astro-util/GBTog/cats/asteroidephemexample.astrid')
obj = '1999JV6'

Xsetup = '''
receiver  = 'Rcvr8_10' # select receiver
obstype   = 'Radar'    # select observing type
backend   = 'Radar'    # select type of backend
nwin      = 1
restfreq  = 8560       # observing frequency
bandwidth = 80         # see note below
swmode    = 'tp_nocal'
swper     = 0.2
tint      = 0.2        # see note below
vframe    = 'topo'     # see note below
vdef      = 'Radio'
noisecal  = 'off'
pol       = 'Circular'
'''

Configure(Xsetup)
Slew(obj)
AutoPeakFocus()
Break('Check peak')

Configure(Xsetup)    # need to configure after the AutoPeakFocus
Slew(obj)
Balance() # adjust power levels
Break('Set Radar Levels')

# when tracking the object, adjust power levels in the back end.
Track(obj, None, 3600) # track object for one hour
Track(obj, None, stopTime='2016-01-09 07:00:00') # Track until UT stop time
