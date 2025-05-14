################
The !g Structure
################

The following table describes the contents of the global structure ``!g`` used by many GBTIDL routines. Using this structure improves the interface of many GBTIDL routines by not requiring that all parameters be specified each time a procedure is run. To view the structure of ``!g``, type in GBTIDL:

.. code-block:: IDL

    GBTIDL -> help, !g, /struct


.. list-table:: Content of the global structure ``!g``
    :widths: 10 15 10 20
    :header-rows: 1

    * - Name 
      - Type 
      - Default 
      - Description
    * - version
      - string
      - ‘2.8’
      - A version identifier for this version of gbtidl
    * - s 
      - spectrum data container array
      - empty spectrum
      - 16 spectrum data structures
    * - c 
      - continuum data container array 
      - empty continuum 
      - 16 continuum data structures
    * - lineio 
      - io_sdfits_line_object 
      - not connected 
      - An io sdfits line object
    * - contio 
      - io_sdfits_cntm_object 
      - not connected 
      - An io sdfits cntm object
    * - lineoutio 
      - io_sdfits_writer_object 
      - GBTIDL_KEEP.fits 
      - An io sdfits writer object
    * - line_filein_name 
      - string 
      -  
      - The last argument to filein, Sdirin, or online in “line” mode
    * - cont_filein_name 
      - string 
      - 
      - The last argument to filin or dirin in “cont” mode
    * - line_fileout_name 
      - string 
      - GBTIDL_KEEP.fits
      - The last argument to fileout
    * - frozen 
      - long integer 
      - 0 
      - When true, the plotter is not updated (frozen) after !g.s[0] or !g.c[0] is changed.
    * - sprotect 
      - long integer 
      - 1 
      - When true, you can not overwrite an NSAVE in fileout. “s” refers to “save”.
    * - line 
      - long integer 
      - 1 
      - When true, !g.s and !g.lineio are used, else =!g.c and !g.contio.
    * - plotter_axis_type 
      - long integer 
      - 1 
      - 0=Channels, 1=Frequency, 2=Velocity
    * - has_display 
      - long integer 
      - 1 
      - Used to distinguish sessions that cannot use a plotter
    * - interactive 
      - long integer 
      - 1 
      - Will be 0 for non-interactive sessions (e.g. cron jobs)
    * - background 
      - long integer 
      - !black 
      - Default plotter background color
    * - foreground 
      - long integer 
      - !white 
      - Default plotter foreground color
    * - showcolor 
      - long integer 
      - !red 
      - Default color for “show”
    * - oshowcolor 
      - long integer 
      - !white 
      - Default color for “oshow”
    * - crosshaircolor 
      - long integer 
      - !green 
      - Default crosshair color
    * - zlinecolor 
      - long integer 
      - !green 
      - Default zero-line color
    * - markercolor 
      - long integer 
      - !green 
      - Default marker color
    * - annotatecolor 
      - long integer 
      - !green 
      - Default color for annotate
    * - oplotcolor 
      - long integer 
      - !white 
      - Default color for oplot
    * - vlinecolor 
      - long integer 
      - !green 
      - Default vline color
    * - zoomcolor 
      - long integer 
      - !cyan 
      - Default color for zoom box
    * - gshowcolor 
      - long integer 
      - !white 
      - Default color for gshow
    * - gausstextcolor 
      - long integer 
      - !white 
      - Default color for gshow text
    * - highlightcolor 
      - long integer 
      - !cyan 
      - Default color for highlighted data (fitgauss, gmeasure)
    * - colorpostscript
      - long integer 
      - 1 
      - If not true, generated postscript will be black and white, ignoring any colors.
    * - astack 
      - pointer 
      - 0 
      - The stack contents, as an array of long integers. Initially 5120 elements but this is extended as needed.
    * - acount 
      - long integer 
      - 0 
      - Number of values of astack actually used.
    * - accumbuf 
      - Array of 4 accum struct structures 
      - empty accum_struct 
      - An array of 4 accum buffers used by accum, ave, et al. 
    * - regions 
      - long integer array 
      - All -1 
      - 2D with shape [2,100] array holding regions to use in fitting. Actual regions in use are given by nregion.
    * - nregion 
      - long integer 
      - 0 
      - Total number of regions in regions that are in use currently. [\*,0:(nregion-1)]
    * - regionboxes 
      - long integer 
      - 0 
      - When true, the region boxes on the plotter are persistent as new plots are shown
    * - nfit 
      - long integer
      - -1 
      - Most recent polynomial order for a baseline fit (bshape and baseline).
    * - polyfit 
      -  double array 
      - 0 
      - 2D array holding the parameters of the most recent baseline fit. The shape is [4,51] and [\*,0:nfit] are in use at any time.
    * - polfitrms 
      - double array 
      - 0 
      - 1D array holding RMS for each of the (nfit+1) polynomials in the most recent baseline fit. Shape is [51] and [0:nfit] are in use at any time.
    * - Gauss 
      - Gauss structure 
      - Gauss defaults 
      - The structure used by the Gaussian fitting routines
    * - printer 
      - string 
      - PRINTER environment variable from the unix shell 
      - Identifies the printer to use. 
    * - tau0 
      - float 
      - 0.0 
      - Zenith tau
    * - ap_eff 
      - float 
      - 0.7 
      - Aperture efficiency
    * - nsave 
      - long integer 
      - -1 
      - Most recent NSAVE used.
    * - user_list_cols
      - string
      - 
      - Comma-separated list of index column names. Used by list and liststack when /user is set.
    * - find 
      - find_struct structure 
      - ‘’ 
      - The find structure. Fore use with find, setfind, and clearfind.
    * - molecules 
      - Array of 4000 molecule_struct structures
      - empty 
      - A structure used by molecule.
    * - nmol 
      - long integer 
      - 0  
      - Number of elements of molecules in use.
