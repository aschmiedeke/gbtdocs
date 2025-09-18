#first load the catalog with the flux calibrators
cata=Catalog('/home/astro-util/projects/GBTog/cats/sources.cat')

#now load the catalog with the pointing source list
catb=Catalog('/home/astro-util/projects/GBTog/cats/pointing.cat')

#Objects defined in loaded catalogs may now be used in scan functions
#Object1 is in source.cat and 0006-0004 is in pointing.cat
Track('Object1',None, 60)
Slew('0006-0004')
