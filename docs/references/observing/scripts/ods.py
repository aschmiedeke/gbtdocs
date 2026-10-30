USE_ODS = True
CATALOG = "/home/astro-util/astridcats/pulsars_all_GBT.cat"
SOURCES = {
    "pulsar1": "B1937+21",
    "pulsar2": "J1713+0747",
    "pulsar3": "B0329+54",
    "pulsar4": "B1929+10",
}
RECEIVER = "Rcvr_2500"

Catalog(CATALOG)

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

for source in SOURCES:
    Slew(SOURCES[source])
    Configure(config)
    Balance()
    Track(SOURCES[source], None, 1800.0)
