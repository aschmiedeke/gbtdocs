sources = Catalog("ods.cat") # Replace with the full path to your catalog

config = """
obstype = 'Pulsar'
receiver = '%s'
pol = 'Linear'
restfreq = 1225.0, 2350.0, 3475.0
if0freq = 6875.0
bandwidth = 1500.0
tint = 64*2048/1500e6
noisecal = 'off'
swmode = 'tp_nocal'
swtype = 'none'
swper = 0.04
swfreq = 0.0
deltafreq = 0
vlow = 0
vhigh = 0
vframe = 'topo'
vdef = 'Radio'
backend = 'VEGAS'
vegas.obsmode = 'search'
vegas.numchan = 2048
vegas.polnmode = 'full_stokes'
vegas.scale = 13035
vegas.outbits = 8
""" % RECEIVER

ResetConfig()

from mx import DateTime

for source in sources.keys():
    start = DateTime.ISO.ParseDateTime(sources[source]["start"])
    stop = DateTime.ISO.ParseDateTime(sources[source]["stop"])
    if stop < DateTime.now():
        print("Stop time for %s has passed; skipping" % source)
    else:
        Slew(source)
        Configure(config)
        Balance()
        if start <= DateTime.now() + DateTime.DateTimeDelta(0,0,5,0):
            start = None
        Track(source, None, startTime=start, stopTime=stop)
