# Frequency Switched Observations where we loop through a list of sources

# first we load the configuration file
execfile('/home/astro-util/projects/GBTog/configs/fs_config.py')

# now we load the catalog file
c = Catalog('/home/astro-util/projects/GBTog/cats/sources.cat')

# now we configure the GBT IF system for frequency switch HI observations
Configure(fs_config)

# get the list of sources
sourcenames = c.keys()

# now loop the sources
for src in sourcenames:
    Slew(src)            # Slew to each source
    Balance()            # Balance power levels
    Track(src,None,600.) # Observe each source for 10 minutes
