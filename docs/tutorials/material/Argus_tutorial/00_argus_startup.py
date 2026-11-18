# Argus Startup
# GBTdocs, 2026;  n2hp fsw tutorial

ResetConfig()


# Start up the instrument by calling the 'presets'  command
# this will turn on LNA/CIF if necessary
SetValues("RcvrArray75_115" , {"presets": "on"})

print "CIF Power: ", GetValue("RcvrArray75_115", "cif_power")
print "LNA Power: ", GetValue("RcvrArray75_115", "lna_power")

