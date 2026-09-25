
#source defined from a catalogue

ResetConfig()

Configure("""
receiver        = 'RcvrArray75_115'
beam            = 'all'
obstype         = 'Spectroscopy'
backend         = 'VEGAS'
restfreq        = 93173.704
bandwidth       = 187.5
swmode          = 'sp_nocal'
swtype          = 'fsw'
swper           = 0.4
swfreq          = -12.5, 12.5
tint            = 0.4
vframe          = 'lsrk'
vdef            = 'Radio'
pol             = 'Linear'
nchan           = 65536
sideband        = 'LSB'
vegas.subband   = 1 
""")


source_catalog = """
format=spherical
coordmode=J2000
HEAD = NAME RA DEC
DR21   20:39:01.01 +42:22:50.2
DR21_2 20:39:00.27 +42:23:42.9
"""

Catalog(source_catalog)         # Only needed for validation purposes in AstrID.


Balance()

yigvolt, sampleTime = GetSample("RcvrArray75_115", "YIGData,lo_power")
print "" 
print "******************************" 
print "YIG voltage:   ", yigvolt
print "Sample time: ", sampleTime
print "******************************"
print "" 
Break("Check YIG LO power (if <0.1 V, then reconfigure)" )

source = "DR21_2"
Slew (source)

execfile("/home/astro-util/projects/Argus/OBS/argus_vanecal")

#map the region
RALongMap(source,
	  Offset("J2000",120./3600., 0.0, cosv=True),
	  Offset("J2000", 0.0, 120./3600., cosv=True),
	  Offset("J2000", 0.0, 5.0/3600., cosv=True),
	  scanDuration=30.0, beamName='C' ,start=1, stop=24)

execfile("/home/astro-util/projects/Argus/OBS/argus_vanecal")
