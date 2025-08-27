# Frequency Switched Observations where we perform on-the-fly (OTF) mapping

# Load the configuration file
execfile('/home/astro-util/projects/GBTog/configs/fs_config.py')

# Load the catalog file
Catalog('/home/astro-util/projects/GBTog/cats/sources.cat')

# now we configure the GBT IF system for freq switched HI observations
Configure(fs_config)

# now we set the parameters for the map
src       = 'Object2'                   # location of the map center
majorSize = Offset('Galactic',5.0,0.0)  # 5 degrees in galactic longitude
minorSize = Offset('Galactic',0.0,5.0)  # 5 degrees in galactic latitude
rowStep   = Offset('Galactic',0.0,0.05) # 3 arcminutes between map rows

# the time to scan each row
# time = majorSize / rowStep * integration time per pixel
scanTime = 5.0/0.05*2. # 2 seconds per pixel

# Balance power levels
Slew(src)
Balance()
Break('Check power levels')

# only do part of the map here
rowStart = 10
rowStop  = 20

# now observe for the map
RALongMap(src,majorSize,minorSize,rowStep,scanTime,
          start=rowStart,stop=rowStop)
