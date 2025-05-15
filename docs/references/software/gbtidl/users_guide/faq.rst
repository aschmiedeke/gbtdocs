######################
General Hints and Tips
######################


Calibrating Data
================

One strategy in using GBTIDL is to first calibrate your data using a procedure in 
the (:idl:pro:`getfs`, :idl:pro:`getnod`, :idl:pro:`getoffon`, ...) family, and 
then write the calibrated data to a new SDFITS file. Once the data are in the new 
file, the calibrated scans can be retrieved with the getrec procedure, and tools
such as the stack and select and find can be used to access data groupings.

Recovering from Errors
======================

In GBTIDL, when an error is encountered you are sometimes left at the “procedure level” and not the
“main level” of the command line interface. GBTIDL will not work at the procedure level. To return
to the main level, use the command “retall” and GBTIDL will resume. IDL users, in general, type
:code:`retall` often. This should only happen rarely in GBTIDL. If you find that it happening unexpectedly
or frequently, please let us know.

##########
GBTIDL FAQ
##########

Do I need to know IDL to run GBTIDL?
====================================

No, but it helps. The GBTIDL syntax is similar to UniPOPs and it is possible to reduce many types
of observations without much previous IDL knowledge. The GBTIDL User’s Guide shows you how.
However, if you’d like to go beyond the standard reduction facilities provided, some IDL knowledge is
required. If you are not familiar with IDL and would like to learn, you may find the IDL primer useful.
Links to a few primers can be found in section 1.6.


What is the latest version of GBTIDL?
=====================================

Version 2.8 was released on June 1, 2011. It is available as gbtidl for all users in Green Bank,
Charlottesville and Socorro. It can be downloaded from the GBTIDL home page.


What version of IDL is required to run GBTIDL?
==============================================

GBTIDL runs on version 6.1 (or later). It does not run on earlier or later versions of IDL.


Everything was working fine, then I encountered an error and now GBTIDL is not working. How do I recover?
=========================================================================================================

Try :code:`retall`. The error handling mechanism in IDL leaves you at the “procedure level” after an error
is encountered. GBTIDL runs at the “main level”. To return to the main level, use the IDL command
:code:`retall`.

The plotter is not responding, how do I recover?
================================================

Try code::`retall`. If you can’t change the x-axis units, or print, or otherwise interact with the plotter
graphically then the most likely explanation is that there was an error at the “procedure level” and IDL
is not at the “main level”. IDL only processes these GUI events when it is at the “main level” so when
an error occurs, the plotter appears unresponsive.


I have a collection of IDL procedures. Where should I put them so that I can use them in GBTIDL?
================================================================================================

The current directory is always searched first by IDL for files to compile. If you always run GBTIDL
from the same directory, it is simplest to put your .pro files there. If you run GBTIDL from different
directories and you want to collect your .pro files all in one place, place them in ``$HOME/gbtidlpro``.
GBTIDL includes ``$HOME/gbtidlpro`` at the head of the search path (after the current directory). So,
any files you put in ``$HOME/gbtidlpro`` and in any subdirectories under ``$HOME/gbtidlpro`` will be found -
even if a duplicate named file exists in the GBTIDL installation. ``$HOME/gbtidlpr``` could be a symbolic
link to any other location.

How do I change the Y-axis label?
=================================

There are a few ways:

1. When you get the scan, use the unit specifier. This will automatically 
   scale the spectra to the new units.
    
   .. code-block:: IDL

       getfs, 79, units=’Jy’
       show                        ; If auto update is off

2. Set the units field in the data container:

   .. code-block:: IDL

       !g.s[0].units = ’Flux Density (mJy)’
       show

3. Use the predefined units :

   .. code-block:: IDL

       If !g.s[0].units is ’Jy’    then label is   ’Flux Density (Jy)’
                           ’Ta*’                   ’Antenna Temperature (Ta*)’
                           ’Ta’                    ’Antenna Temperature (Ta)’
                           empty                   ’Intensity’
                           ’any other string’      ’any other string’

4. This technique is not recommended because the string is not saved with the
   data (it only affects the current contents of the plotter), but this will
   also change the y-axis label:

   .. code-block:: IDL

       show
       (getplotterdc()).units = ’Flux Density (mJy)’
       reshow


Can I use GBTIDL with data from telescopes other than the GBT?
==============================================================

If the data are in UniPOPS format you can use the uni2sdfits procedure (see details at the end of this
answer). Otherwise, GBTIDL provides no tools for converting data from other telescopes. However,
with a little work on your part, it should be possible to get spectral line data from any other telescope
into GBTIDL. There is even some chance that if your data follow the SDFITS convention that GBTIDL
will be able to read it directly.
The easiest way to import generic data into GBTIDL is to use standard IDL tools to get the data into
a data container, as described below. You can then use GBTIDL to operate on data in data containers,
and you can save the data containers to SDFITS format as well.
A data container is just an IDL data structure with a predefined format. See the ‘About Data Containers’
section for a discussion about data containers in GBTIDL.
You can get data into a data container as follows:

* Read your data values into an IDL array (e.g. use READU to read unformatted
  binary values or mrdfits to read FITS tables, or import the data from an 
  ASCII file using readf)
* Create a new data container to hold those values: dc = data new(myvalues)
* Set the associated header fields in dc, for example:

  .. code-block:: IDL

       dc.source = ’mysource’
       dc.scan = 24
       dc.coordinate_mode = ’J2000’
       ...

* Copy dc to the primary data container:

  .. code-block:: IDL

      set_data_container, dc

* Save it to an output file:

  .. code-block:: IDL

      fileout,’myfile.fits’
      keep

* Free the memory used by the data container:
    
  .. code-block:: IDL

      data_free, dc

* When you return to look at this data in a later session, you can load it into 
  GBTIDL directly from the SDFITS file as follows:

  .. code-block:: IDL

      ; start a new GBTIDL session first
      filein,’myfile.fits’
      getrec, 0

Pointers:

* When setting the header fields in dc, pay particular attention to those related
  to the frequency axis and its conversion to velocity.
* If you are going to be using set data container repeatedly, use freeze to speed
  up the operation.

Please contact us with any questions about the contents of the data container or other
aspects of GBTIDL necessary to do this translation. (However, please be advised that
we have limited resources, and will not be able to provide extensive development for 
reducing data from non-NRAO telescopes.)

As an example, the contributed procedure uni2sdfits uses an IDL class sdd to read in
the UniPOPS binary file and then the above steps are used to copy it to the primary
data container and keep it to the output file. The source code can be seen by clicking 
on the “source” links at the top of the page in each of the above two links.
