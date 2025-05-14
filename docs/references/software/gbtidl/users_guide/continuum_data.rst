#######################
Reducing Continuum Data
#######################

Limited processing of continuum data is available in GBTIDL. The :idl:pro:`cont` procedure is
used to switch to continuum mode. Continuum data comes from a separate file (also opened with
:idl:pro:`filein`) and there is a completely separate set of data containers in !g for holding
continuum data (``!g.c``) . Continuum data can only be displayed with the x-axis as sample 
number (you do not need to do anything other than :idl:pro:`show` to make that happen). There 
is currently no ability to save continuum data containers to disk, so the continuum functionality
is rather limited. Many routines simply refuse to work with continuum data (e.g. :idl:pro:`getfs`).
However, the data is available in GBTIDL and so some work can be done with continuum
data. 

Use the :idl:pro:`line` procedure to switch back to spectral-line mode.
