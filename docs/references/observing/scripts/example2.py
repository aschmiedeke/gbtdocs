# Position Switched Observations to repeatedly observe the same source

# load the configuration file
execfile('/home/astro-util/projects/GBTog/configs/tp_config.py')

# load the catalog file
Catalog('/home/astro-util/projects/GBTog/cats/sources.cat')

# configure the GBT IF system for position switch HI observations
Configure(tp_config)

# specify which source we wish to observe
src = 'Object1'

# specify how far away from the source the off position should be
# offset two minutes of time in Right Ascension
myoff=Offset("J2000","00:02:00",0.0)

#Slew to the source and then balance the power levels
Slew(src)
Balance()
# now we use a Break() so that we can check the IF system
Break('Check the Balance of the IF system')

# specify how many times to observe the source
numobs = 20

# observe 'on' source for 2 minutes and 'off' source for 2 minutes
# and then repeat
for i in range(numobs):
    OnOff(src,myoff,120.)
