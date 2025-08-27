# Load the configuration file and the catalog file
execfile('/home/astro-util/projects/GBTog/configs/tp_config.py')
Catalog('/home/astro-util/projects/GBTog/cats/sources.cat')

# now we configure the GBT IF system for position switched observations
Configure(tp_config)

# define which sources to observe
srcA = 'Object4'
srcB = 'Object3'
srcC = 'Object1'
myoff=Offset('J2000','00:02:00',0.0) # Off position of 2min time in RA
h=Horizon(20.0) # specify a horizon of 20 degrees elevation

riseSrcB = h.GetRise(srcB) # now get rise and set times of srcB
setSrcB = h.GetSet(srcB)

#print the rise and set times of srcB
risesetstring='20 deg elev. rise = %s and set = %s'%(riseSrcB,setSrcB)
Comment(risesetstring)

# observe srcA until srcB has risen above 20 deg elevation
Slew(srcA)
Balance()
while Now() < riseSrcB and Now() != None:
    OnOff(srcA,myoff,120.)

# now observe srcB until it sets
Slew(srcB)
Balance()
while Now() < setSrcB and Now() != None:
    OnOff(srcB,myoff,120.)

# now observe srcC five times
numobs=5
Slew(srcC)
Balance()
for i in range(numobs):
    OnOff(srcC,myoff,120.)
