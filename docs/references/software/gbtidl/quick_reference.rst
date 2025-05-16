###############################
Quick Reference for GBTIDL v2.8
###############################


For help with a routine from the gbtidl command line, use the :idl:pro:`usage` command, for example:

.. code-block:: IDL

    usage, "show"
    
or for more information: 

.. code-block:: IDL

    usage, "show", /verbose

or to view the IDL source: 

.. code-block:: IDL

    usage, "show", /source

GUIDE starts in spectral line mode. To switch to continuum mode, type :code:`cont` at the GBTIDL prompt.
To switch to line mode, type :code:`line` at the GBTIDL prompt.

* PDF version of this page: https://www.gb.nrao.edu/GBT/DA/gbtidl/QRG_release.pdf
* Product website: http://gbtidl.sourceforge.net/

.. note::

    In the following tables, optional arguments are in [brackets]. 
    
..     IDL parameters are in normal font, keywords are in boldface. 
..     The parameters argument refers to the selection parameters listed in the “Parameters for Data Retrieval and Selection” table below.

Data Operations
===============

Retrieving and Saving Data
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table:: Retrieving and Saving Data
    :widths: 20 20
    :header-rows: 0

    * - :idl:pro:`dirin`, [dir_name, /new_index]
      - Input from the given directory
    * - :idl:pro:`filein`, [file_name, /new_index]
      - Input from the given SDFITS file
    * - :idl:pro:`fileout`, file_name [/new]
      - Open an SDFITS file for writing
    * - :idl:pro:`files`, [/full] 
      - Lists the input and output files currently in use
    * - :idl:pro:`flag`, [scan, intnum, plnum, ifnum, fdnum, sampler, bchan, echan, chans, chanwidth, idstring, scanrange, /keep] 
      - Add a flag rule to the line data file
    * - :idl:pro:`flagrec`, record,[bchan,echan,chans, chanwidth, idstring, /keep] 
      - Add a record-based flag rule to the line data file
    * - :idl:pro:`get`, [useflag, skipflag, parameters] 
      - Retrieve a record from the input file
    * - :idl:pro:`getchunk` ([count,useflag, skipflag, indicies, /keep, parameters]) 
      - Retrieve multiple data containers at a time
    * - :idl:pro:`getdata` ([buffer,elements,count]) 
      - Returns the data into an IDL array
    * - :idl:pro:`getrec`, index [useflag, skipflag] 
      - Retrieve a record at the given index
    * - :idl:pro:`getscan`, scan [useflag, skipflag] 
      - Retrieve the first record with the given scan number
    * - :idl:pro:`keep`, [dc)
      - Save a spectrum to the output SDFITS file
    * - :idl:pro:`kget`, [useflag, skipflag, parameters] 
      - Retrieve a record from the output file
    * - :idl:pro:`kgetrec`, index, [useflag, skipflag] 
      - Retrieve a record at the given index from the output file
    * - :idl:pro:`kgetscan`, scan, [useflag, skipflag] 
      - Retrieve the first record with the given scan number from the output file
    * - :idl:pro:`nget`, nsave, [buffer,/infile, useflag, skipflag, ok] 
      - Retrieve a record with a given nsave identifier
    * - :idl:pro:`nsave` , nsave, [buffer, dc, ok] 
      - Save to the output file, with an nsave identifier
    * - :idl:pro:`offline`, project, [/acs, /sp] 
      - A shortcut for filein, used only in Green Bank
    * - :idl:pro:`online`, [/acs, /sp] 
      - Connect to the online data file, used only in Green Bank
    * - :idl:pro:`putchunk`, chunk 
      - Save multiple data containers to the output file
    * - :idl:pro:`setdata`, value, [elements, buffer] 
      - Replaces the data in a DC with the values in an IDL array
    * - :idl:pro:`set_data_container`, data, [buffer, /ignore_line, /noshow] 
      - Copy a data container into a global buffer
    * - :idl:pro:`sprotect_off`
      - Turns off write protection for nsave entries
    * - :idl:pro:`sprotect_on` 
      - Turns on write protection for nsave entries
    * - :idl:pro:`unflag`, id, [/keep, /all] 
      - Remove all flag rules with the same idstring or id number



Using the Stack
^^^^^^^^^^^^^^^

.. list-table:: Using the Stack
    :widths: 20 20 
    :header-rows: 0
    
    * - :idl:pro:`addstack`, first, [last, step] 
      - Add enumerated entries to the stack
    * - :idl:pro:`appendstack`, index 
      - Append array of entries to the stack
    * - :idl:pro:`astack` ([elem, count])
      - Returns the value of a given entry or all entries in the stack
    * - :idl:pro:`avgstack`, [/noclear, /keep, useflag, skipflag] 
      - Average spectra identified by entries in the stack
    * - :idl:pro:`clearfind`, [param] 
      - Clear selection parameters used by find
    * - :idl:pro:`delete`, index 
      - Remove individual entries from the stack
    * - :idl:pro:`deselect`, [/keep, parameters] 
      - Remove entries from the stack based on the given selection criteria
    * - :idl:pro:`emptystack`, [/reset, /shrink] 
      - Clear the stack
    * - :idl:pro:`find`, [/append,/keep] 
      - Put selections in the stack using previously set parameters (setfind)
    * - :idl:pro:`listfind`,[param] 
      - List selection parameters used by find
    * - :idl:pro:`liststack`, [start, finish, sortcol, columns, /user, /keep, parameters] 
      - List records from the input data file that correspond to entries in the stack
    * - :idl:pro:`select`, [count, /keep, /quiet, parameters] 
      - Add entries to the stack based on the given selection criteria
    * - :idl:pro:`setfind`, [param, val1, val2, /append] 
      - Set a selection parameter used by find
    * - :idl:pro:`tellstack` 
      - List the stack entries


Parameters for Data Retrieval and Selection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table:: Available search parameters for data retrieval and selection using listcols in **line** mode
    :widths: 10 10 10 10 10 
    :header-rows: 0

    * - azimuth
      - bandwidth 
      - cal 
      - centfreq
      - dateobs
    * - e2escan
      - elevation 
      - exposure 
      - extension 
      - fdnum 
    * - feed 
      - file 
      - freqint
      - freqres
      - ifnum
    * - index 
      - int 
      - latitude
      - longitude  
      - lst
    * - nsave 
      - numchn 
      - obsid
      - plnum 
      - polarization 
    * - procedure 
      - procseqn 
      - project 
      - restfreq
      - row 
    * - sampler
      - scan 
      - sig 
      - source 
      - subref
    * - timestamp 
      - trgtlat 
      - trgtlong 
      - tsys 
      - velocity

 



.. list-table:: Available search parameters for data retrieval and selection using listcols in **continuum** mode
    :widths: 10 10 10 10 10 
    :header-rows: 0

    * - cal
      - e2escan 
      - extension
      - file 
      - firstrow 
    * - ifnum       
      - index 
      - nsave
      - numrows 
      - obsid 
    * - polarization 
      - procedure 
      - procseqn 
      - project
      - scan 
    * - sig
      - source
      - stride 
      - trgtlat
      - trgtlong 
 
 




Using Data Containers
^^^^^^^^^^^^^^^^^^^^^

.. list-table:: Using Data Containers
    :widths: 20 20 
    :header-rows: 0

    * - :idl:pro:`add`, [in1, in2, out]
      - Adds DC's based on buffer numbers. out = in1+in2
    * - :idl:pro:`bias`, factor, [buffer] 
      - Add a bias to the spectrum in the buffer
    * - :idl:pro:`copy`, in, out 
      - Copies a data container to another buffer
    * - :idl:pro:`divide`, [in1, in2, out] 
      - out=in1/in2
    * - :idl:pro:`move`, in, out 
      - Moves a data container to another buffer
    * - :idl:pro:`multiply`, [in1, in2, out] 
      - out=in1*in2
    * - :idl:pro:`scale`, factor, [buffer] 
      - Scale the spectrum in the PDC
    * - :idl:pro:`subtract`, [in1, in2, out] 
      - out=in1-in2


Getting Information about Scans and Files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table:: Getting Information about Scans and Files
    :widths: 20 20
    :header-rows: 0

    * - :idl:pro:`get_scan_numbers` ([count, /keep, /unique, parameters]) 
      - Get a list of scan numbers from the input data file
    * - :idl:pro:`header`, [dc] 
      - Show the record header
    * - :idl:pro:`lastrec` ([/keep]) 
      - Record number of the most recently retrieved data container
    * - :idl:pro:`lastscan` ([/keep]) 
      - Scan number of the most recently retrieved data container.
    * - :idl:pro:`list`, [start, finish, sortcol, columns, file, /user, /keep, parameters] 
      - List records from the input file
    * - :idl:pro:`listflags`,[idstring, /summary, /keep] 
      - List the flag rules
    * - :idl:pro:`listids`,[/keep] 
      - List the unique idstrings in the current set of flag rules
    * - :idl:pro:`ls`, [pattern, options] 
      - List FITS files (default) or any other files in the directory
    * - :idl:pro:`nrecords` ([/keep]) 
      - Returns the number of records in the input or output file
    * - :idl:pro:`scan_info` (scan,[file, /keep, /quiet, count]) 
      - Returns some info such as num IFs, num integrations, etc.
    * - :idl:pro:`summary`, [file] 
      - Gives a summary of scans in the input file
    * - :idl:pro:`table`, [buffer, brange, erange] 
      - List data in tabular form


Plotter Operations
==================

.. list-table:: Plotter Operations
    :widths: 20 20 
    :header-rows: 0

    * - :idl:pro:`annotate`, x, y, text, [color, charsize, /normal, /noshow] 
      - Add text annotation to a plot
    * - :idl:pro:`bdrop`, nchan 
      - Drop initial channels from spectrum display
    * - :idl:pro:`chan` 
      - Set X-axis units to channels
    * - :idl:pro:`chantox` (chans, [type, dc]) 
      - Returns X-values for given list of channels
    * - :idl:pro:`clear` 
      - Erase the plotter
    * - :idl:pro:`clearannotations`, [/noshow] 
      - Clear annotations
    * - :idl:pro:`clearmarks`, [/noshow] 
      - Clear marks (the "+" markers)
    * - :idl:pro:`clearoplots`, [index, idstring] 
      - Clear overplots
    * - :idl:pro:`clearoshows` 
      - Clear oshows
    * - :idl:pro:`clearovers` 
      - Clear oshows and oplots
    * - :idl:pro:`clearvlines`, [/noshow,idstring] 
      - Clear vlines
    * - :idl:pro:`click` ([frame, veldef, /nocrosshair, /noshow, label])
      - Returns position of a mouse click
    * - :idl:pro:`crosshair`, [/on, /off] 
      - Toggle crosshair cursor
    * - :idl:pro:`edrop`, nchan 
      - Drop end channels from spectrum display
    * - :idl:pro:`freex` 
      - Sets the X-axis range to autoscale
    * - :idl:pro:`freexy` 
      - Sets X- and Y-axis to autoscale (equivalent to unzoom)
    * - :idl:pro:`freey` 
      - Sets the Y-axis range to autoscale
    * - :idl:pro:`freeze` 
      - Freeze the plotter, i.e. set auto update off
    * - :idl:pro:`freq` 
      - Set the X-axis units to frequency
    * - :idl:pro:`gbtoplot`, [x], y, [color, /chan, index, idstring] 
      - Overplot a set of X, Y points
    * - :idl:pro:`getplotterdc` ([/copy]) 
      - Get the currently displayed data container
    * - :idl:pro:`getxarray` ([count]) 
      - Get the xarray values for the currently displayed data
    * - :idl:pro:`getxframe` () 
      - Get the current reference frame (LSR, TOPO, etc)
    * - :idl:pro:`getxoffset` () 
      - Get the current X-offset (0.0 unless relative X-axis has been toggled)
    * - :idl:pro:`getxrange` ([empty]) 
      - Get the current X-range
    * - :idl:pro:`getxunits` () 
      - Get the current X-axis unts (counts, km/s, GHz, etc)
    * - :idl:pro:`getxveldef` () 
      - Get the current velocity definition (RADIO, OPTICAL, TRUE)
    * - :idl:pro:`getxvoffset` () 
      - Get the current velocity offset in m/s
    * - :idl:pro:`getyarray` ([count]) 
      - Get the data values for the currently displayed data
    * - :idl:pro:`getyrange` ([empty]) 
      - Get the current Y-range
    * - :idl:pro:`histogram`, [/on, /off] 
      - Toggles between histogram-style and connected-points style plots
    * - :idl:pro:`oshow`, [dc, color] 
      - Overlay spectrum on the displayed plot
    * - :idl:pro:`print_ps`, [filename, device, /portrait]
      - Send the plot to the printer 
    * - :idl:pro:`reshow` 
      - Re-draw everything known to the plotter
    * - :idl:pro:`setabsrel`, absrel 
      - Sets X-axis in Absolute (absrel='Abs') or Relative (absrel='Rel') units
    * - :idl:pro:`setframe`, frame 
      - Sets reference frame for X-axis
    * - :idl:pro:`setmarker`, x, y, [text] 
      - Places a marker on the plot at the desired location
    * - :idl:pro:`setveldef`, veldef 
      - Sets velocity definition for X-axis
    * - :idl:pro:`setvoffset`, voffset, [veldef] 
      - Sets the offset velocity
    * - :idl:pro:`setx`, [x1, x2] 
      - Sets the range on the X-axis
    * - :idl:pro:`setxunit`, unit [/noreshow] 
      - Sets the units for the X-axis
    * - :idl:pro:`setxy`, [xmin, xmax, ymin, ymax] 
      - Sets the range on the X- and Y-axes
    * - :idl:pro:`sety`, [y1, y2] 
      - Sets the range on the Y-axis
    * - :idl:pro:`show`, [dc, color, /defaultx, /smallheader, /noheader] 
      - Displays a data container on the plotter
    * - :idl:pro:`showregion`, [/off] 
      - Turn on and off the display of baseline region boxes
    * - :idl:pro:`toggleovers`, [/on, /off] 
      - Toggles overlays
    * - :idl:pro:`unfreeze` 
      - Unfreeze the plotter, i.e. set auto update on
    * - :idl:pro:`unzoom`, [/onestep] 
      - Unzoom the plot
    * - :idl:pro:`velo`
      - Set the x-axis units to velocity
    * - :idl:pro:`vline`, x, [ylabel, label, /noshow, /ynorm, idstring] 
      - Draw a vertical line on the plot
    * - :idl:pro:`write_ascii`, [filename, /prompt, brange, erange]
      - Writes the data in PDC to an ASCII file
    * - :idl:pro:`write_ps`, [filename, /portrait, /prompt]
      - Writes the displayed plot to a postscript file
    * - :idl:pro:`xtochan` (xvalues, [dc])
      - Returns channel number that corresponds to the given x-values
    * - :idl:pro:`zline`, [/on, /off] 
      - Toggles the zero line


Analysis Procedures
===================

Averaging
^^^^^^^^^

.. list-table:: Averaging
    :widths: 20 20
    :header-rows: 0

    * - :idl:pro:`accum`, [accumnum, weight, dc] 
      - Add a spectrum to the accumulator
    * - :idl:pro:`ave`, [accumnum, wtarray, count, /noclear,/quiet] 
      - Average data in the accumulator
    * - :idl:pro:`avgstack`, [/noclear, /keep, useflag, skipflag] 
      - Average entries in the stack
    * - :idl:pro:`fshift` ([accumnum, buffer, frame]) 
      - Determine a shift to align in frequency
    * - :idl:pro:`gshift`, offset, [buffer, /wrap, ftol, /nowelsh, /nopad, /linear, /quadratic, /lsquadratic, /spline, /cubic, ok] 
      - Apply a shift to align spectra
    * - :idl:pro:`sclear`, [accumnum] 
      - Clear the accumulator buffer
    * - :idl:pro:`vshift` ([accumnum, buffer, frame, veldef, voffset]) 
      - Determine a shift to align in velocity
    * - :idl:pro:`xshift` ([accumnum, buffer])
      - Determine a shift to align in current X-axis units


Baselines
^^^^^^^^^

.. list-table:: Baselines
    :widths: 20 20 
    :header-rows: 0

    * - :idl:pro:`baseline`, [nfit, modelbuffer, ok]  
      - Fits and subtracts a baseline from the PDC spectrum
    * - :idl:pro:`bmodel`, [modelbuffer, nfit, ok] 
      - Writes a baseline model into a DC using coeffs from a previous fit
    * - :idl:pro:`bshape`, [nfit, /noshow, modelbuffer, ok, color] 
      - Fit and display a baseline as an overplot without subtracting it
    * - :idl:pro:`bshow`, [nfit, ok, color] 
      - Overplot the most recently fit baseline
    * - :idl:pro:`bsubtract`, [nfit, ok] 
      - Subtracts a baseline determined from the stored coeffs
    * - :idl:pro:`clearregion`
      - Clear all baseline regions
    * - :idl:pro:`getbasemodel` ([ nfit, ok])
      - Return a baseline polynomial evaluated at all channels in the PDC
    * - :idl:pro:`nfit`, order 
      - Sets the order of the (orthogonal) polynomial to be fit
    * - :idl:pro:`nregion`, regions 
      - Defines the regions to be used for a baseline fit
    * - :idl:pro:`setregion`
      - Interactive use of the cursor to define the baseline region


Calibration
^^^^^^^^^^^

.. list-table:: Calibration
    :widths: 20 20 
    :header-rows: 0

    * - :idl:pro:`fold`, [sig, ref, ftol] 
      - Fold a frequency-switched scan (also done in getfs)
    * - :idl:pro:`getbs`, scan, [ifnum, intnum, plnum, sampler, trackfdnum, bswitch, tsys, tau, ap_eff, smthoff, units, tcal, /eqweight, /quiet, /keepints, useflag, skipflag, instance, file, timestamp, status] 
      - Retrieves and calibrates a total power nod beamswitched scan pair
    * - :idl:pro:`getcal`, scan, [ifnum, intnum, plnum, fdnum, sampler, tcal, sig_state, /eqweight, /quiet, /keepints, useflag, skipflag, instance, file, timestamp, status] 
      - Retrieves the "cal" signal from a cal-switched scan.
    * - :idl:pro:`getfs`, scan, [ifnum, intnum, plnum, fdnum, sampler, tsys, tau, ap_eff, smthoff, units, tcal, /nofold, /eqweight, /quiet, /keepints, useflag, skipflag, instance, file, timestamp, status] 
      - Retrieves and calibrates a frequency switched scan
    * - :idl:pro:`getnod`, scan, [ifnum, intnum, plnum, sampler, trackfdnum, tsys, tau, ap_eff,smthoff,units, tcal, /eqweight, /quiet, /keepints, useflag, skipflag, instance, file,timestamp,status] 
      - Retrieves and calibrates a total power nod scan pair
    * - :idl:pro:`getps`, scan, [ifnum, intnum, plnum, fdnum, sampler, tsys, tau, ap_eff, smthoff, units, tcal, /eqweight, /quiet, /keepints, useflag, skipflag, instance, file, timestamp, status] 
      - Retrieves and calibrates a total power position switched scan pair
    * - :idl:pro:`getsigref`, sigscan, refscan, [ifnum, intnum, plnum, fdnum, sampler, tsys, tau, ap_eff, smthoff, units, tcal, /eqweight, /quiet, /avgref, /keepints, useflag, switched pair, skipflag, siginstance, sigfile, sigtimestamp, refinstance, reffile, reftimestamp, status] 
      - Retrieves and calibrates a total power position with the user identifying the sig scan and ref scan separately
    * - :idl:pro:`gettp`, scan, [ifnum, intnum, plnum, fdnum, sampler, tcal, sig_state, cal_state, /eqweight, /quiet, /keepints, useflag, skipflag, instance, file, timestamp, status] 
      - Retrieves and calibrates a single total power scan



Gaussians
^^^^^^^^^

.. list-table:: Gaussians
    :widths: 20 20 
    :header-rows: 0
 
    * - :idl:pro:`fitgauss`, [fit, fitrms, modelbuffer, highlightcolor] 
      - Interactive procedure to fit Gaussians to the spectrum
    * - :idl:pro:`gauss`, [fit, fitrms, buffer, modelbuffer, ok, /quiet] 
      - Fits Gaussians to the spectrum, based on initial values set by procedures gregion, ngauss, gmaxiter, and gparamvalues
    * - :idl:pro:`gmaxiter`, maxiter 
      - Sets max number of iterations for Gauss fitter
    * - :idl:pro:`gparamvalues`, gauss_index, values 
      - Sets initial guesses for Gauss fitter
    * - :idl:pro:`gregion`, regions 
      - Sets the regions used for Gauss fitter
    * - :idl:pro:`gshow`, [modelbuffer, /parts, color] 
      - Displays the Gaussian fits on the plotter
    * - :idl:pro:`ngauss`, ng
      - Sets the number of Gaussians to be fit
    * - :idl:pro:`report_gauss`, [/fits, /params] 
      - Prints the results of a Gaussian fit on terminal


Other
^^^^^

.. list-table:: Other commands
    :widths: 20 20 
    :header-rows: 0

    * - :idl:pro:`boxcar`, width, [buffer, /decimate] 
      - Boxcar smoothing
    * - :idl:pro:`clip`, datamin, datamax, [buffer, /blank] 
      - Truncate spectrum to a min and max data value
    * - :idl:pro:`decimate`, [nchan, startat, buffer, ok] 
      - Decimate the spectrum by paring channels
    * - :idl:pro:`gconvol`, kernel, [scale_factor, buffer, ok, /normalize, /center, /edge_wrap, /edge_truncate, missing, /nan, /normalize] 
      - Convolve the spectrum in the PDC with an array
    * - :idl:pro:`gfft`, [real_buffer, imag_buffer, /inverse, bdrop, edrop] 
      - FFT or inverse FFT the spectrum
    * - :idl:pro:`ginterp`,[buffer, bchan, echan, /linear, /quadratic, /lsquadratic, /spline] 
      - Interpolate across blanked channels
    * - :idl:pro:`gmeasure`,mode,fract,[brange, erange, rms, /chan, lefthorn, righthorn, /quiet,ret] 
      - Find paramaters of a galaxy profile
    * - :idl:pro:`gmoment`,[bmoment, emoment, /chan, /full, /quiet, ret] 
      - Find moments of the data in the PDC
    * - :idl:pro:`gsmooth`, newres, [buffer, /decimate] 
      - Gaussian smooth the spectrum in the PDC to the newres resolution (channels)
    * - :idl:pro:`gstatus`, [/full] 
      - Summarize status of GBTIDL
    * - :idl:pro:`hanning`, [buffer, /decimate, ok] 
      - Hanning smooth the spectrum in the PDC
    * - :idl:pro:`invert`, [buffer] 
      - Flip the data end-to-end
    * - :idl:pro:`mediansub`, width, [buffer] 
      - Subtract the median filtered values of the given width from the data
    * - :idl:pro:`molecule`, [/doprint] 
      - Show molecular transition frequencies on the plotter
    * - :idl:pro:`powspec`, [buffer] 
      - Compute power spectrum of the specified DC
    * - :idl:pro:`recomball`, [/doprint] 
      - Plot the H alpha, beta, gamma; He :math:`\alpha`, beta and C alpha recombination lines
    * - :idl:pro:`recombc`, [dn, /doprint] 
      - Compute and plot frequencies of Carbon recombination lines
    * - :idl:pro:`recombhe`, [dn, /doprint] 
      - Compute and plot frequencies of Helium recombination lines
    * - :idl:pro:`recombh`, [dn, /doprint] 
      - Compute and plot frequencies of Hydrogen recombination lines
    * - :idl:pro:`recombn`, [dn, /doprint] 
      - Compute and plot frequencies of Nitrogen recombination lines
    * - :idl:pro:`recombo`, [dn, /doprint] 
      - Compute and plot frequencies of Oxygen recombination lines
    * - :idl:pro:`replace`, [bchan, echan, /zero, /blank] 
      - Replace bad data values with interpolated or zero values
    * - :idl:pro:`resample`, newinterval, [keychan, buffer, /nearest, /linear, /lsquadratic, /quadratic, /spline] 
      - Resample the spectrum in the PDC at the new interval (channels)
    * - :idl:pro:`stats`, [brange, erange, /full, /chan, /quiet, ret] 
      - Provide statistics
    * - :idl:pro:`usage`, proname, [/verbose, /source] 
      - Print out usage information on the named procedure or function
