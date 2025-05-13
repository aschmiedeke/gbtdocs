##############################
Data Retrieval and Calibration
##############################

Calibrating Data
----------------

If the sdfits program was run with -mode=raw as recommended, the data in the SDFITS file are
uncalibrated. The observer can calibrate the data in GBTIDL. If the data were taken in one of the
GBT standard observing modes supported by GBTIDL, then there is a GBTIDL command that can be
used to retrieve and calibrate the data. GBT calibration can be complex. These procedures typically
give results accurate to 10% - 20%. If you require higher precision, refer to the document Calibration of
Spectral Line Data in GBTIDL.

.. todo:: 

   Retrieve the document "Calibration of Spectral Line Data in GBTIDL and add it to GBTdocs.


For spectral line data, the following calibration procedures are available:

.. list-table:: Calibration procedures
    :widths: 10 20
    :header-rows: 0

    * - Frequency Switched 
      - :idl:pro:`getfs`
    * - Total Power Position Switched
      - :idl:pro:`getps` or :idl:pro:`getsigref`
    * - Total Power Nod
      - :idl:pro:`getnod`
    * - Beam Switched
      - :idl:pro:`getbs`

Each of the calibration procedures except :idl:pro:`getsigref` takes one required parameter: the 
``M&C scan number``. In the case of :idl:pro:`getfs`, the calibration and retrieval pertains to a 
single scan. For :idl:pro:`getps` and :idl:pro:`getnod`, the data comes in scan pairs and the scan
parameter can be either scan in the observing procedure. For example, if an
:func:`OffOn() <astrid_commands.OnOff>` observation comprises scans 9 and 10, then the following 
commands give the same result:

.. code-block:: IDL

    getps,9

and

.. code-block:: IDL

    getps,10

The procedure :idl:pro:`getsigref` takes two required parameters: the scan used for the “signal” 
and the scan used for the “reference”. So :idl:pro:`getsigref` offers some flexibility to use
mismatched sig/ref pairs or data from non-standard procedures.

.. code-block:: IDL

    getsigref, 14, 21    ; Get and calibrate data with signal scan 14 and reference scan 21

Each of the calibration procedures takes optional parameters. A few of the data selection keywords are
listed below:

.. list-table:: Keywords related to data selection
    :widths: 10 30 20 
    :header-rows: 1

    * - Keyword
      - Description
      - Default Value
    * - ``ifnum`` 
      - spectral window index
      - 0
    * - ``intnum`` 
      - integration number 
      - all integrations averaged
    * - ``plnum`` 
      - polarization index; 0=LL or XX, 1 = RR or YY
      - 0
    * - ``fdnum`` 
      - feed number
      - 0
    * - ``sampler`` 
      - sampler name; alternative to ``ifnum``, ``plnum``, ``fdnum``
      - unused unless given explicitly

So, for example, to retrieve the polarization LL data from the second IF, third integration in scans 12-13,
which make up a total power NOD observation, one could use:

.. code-block:: IDL

    getnod, 12, ifnum=1, plnum=0, intnum=2

Unlike some data processing packages, GBTIDL does not automatically average the two polarizations
associated with a scan. So, you must be sure to average polarizations by hand where appropriate.

.. list-table:: Keywords to control details of the calibration
    :widths: 10 30 20
    :header-rows: 1

    * - Keyword
      - Description 
      - Default Value
    * - ``smthoff``
      - smooth the off spectrum by smthoff channels 
      - no reference smoothing
    * - ``tsys``
      - system temperature 
      - Tsys derived from the data
    * - ``tcal``
      - cal temperature
      - taken from the data header
    * - ``eqweight``
      - apply equal weighting to integrations when averaging 
      - 0 (false) - weight by Tsys
    * - ``tau``
      - zenith opacity 
      - get_tau(freq)
    * - ``ap_eff``
      - aperture efficiency 
      - get_ap_eff(freq)
    * - ``units``
      - units of 'Ta', 'Ta*', or 'Jy'
      - 'Ta'

.. list-table:: Other keywords
    :widths: 10 30 20
    :header-rows: 1

    * - Keyword
      - Description
      - Default Value
    * - ``quiet``
      - suppress messages printed to the screen 
      - False (0)
    * - ``keepints``
      - save the individual integration results to the keep file 
      - False (0)
    * - ``useflag``
      - use all or some of the flag rules by id string (see flagging) 
      - use all flag rules
    * - ``skipflag``
      - skip all or some of the flag rules by id string (see flagging) 
      - do not skip any rules
    * - ``instance``
      - for multiple occurances of the same scan, choose this instance 
      - 0 (the first instance)
    * - ``file``
      - for multiple occurances of the same scan, find it in this file (relevant with :idl:pro:`dirin` only) 
      - first file
    * - ``timestamp``
      - for multiple occurances of the same scan, find the one with this timestamp
      - 


Retrieving Individual Records
-----------------------------

For most users, the data retrieval and calibration procedures discussed in the previous section will be
sufficient. Others may need to access data in its raw, uncalibrated form. There are two commands
for accessing uncalibrated data, :idl:pro:`get` and :idl:pro:`getrec`. The :idl:pro:`getrec` command is
also useful for retrieving calibrated data from a keep file (a file which contains data already calibrated
in GBTIDL and stored using the :idl:pro:`keep` command).

get: The get procedure can be used to retrieve individual data records from the input data file based
on the scan number, feed, IF, integration, polarization, cal state, and sig/ref state of the data. If these
parameters are not sufficient to uniquely identify a single row in the SDFITS file, only the first matching
row is returned and a warning message is printed. The :idl:pro:`get` procedure might be used as follows to
calculate a system temperature from an uncalibrated data file:

.. code-block:: IDL

    get, scan=10, pol=’LL’, ifnum=1, fdnum=1, int=1, sig=’T’, cal=’T’
    calon = getdata()
    get, scan=10, pol=’LL’, ifnum=1, fdnum=1, int=1, sig=’T’, cal=’F’
    caloff = getdata()
    tcal = !g.s[0].mean_tcal
    tsys = caloff/(calon-caloff)*tcal
    print,’Mean Tsys = ’,mean(tsys)


.. list-table:: Complete list of parameters for the :idl:pro:`get` procedure
    :widths: 10 20
    :header-rows: 1

    * - Parameter 
      - Description
    * - ``index`` 
      - record number
    * - ``project``
      - project ID
    * - ``file``
      - SDFITS file names (only relevant if the input data set is specified with dirin rather than filein)
    * - ``timestamp``
      - scan timestamp as YYYY MM DD HH:MM SS
    * - ``extension``
      - SDFITS extension number
    * - ``row``
      - SDFITS row number
    * - ``source``
      - source name
    * - ``procedure``
      - procedure name
    * - ``procseqn``
      - procedure sequence number
    * - ``scan``
      - M&C scan number
    * - ``polarization``
      - polarization, e.g. ‘LL’, ‘RR’, ‘XX’ or ‘YY’
    * - ``plnum``
      - polarization index, zero-based
    * - ``ifnum``
      - IF (i.e. spectral window) index number, zero-based
    * - ``feed``
      - feed name (e.g. B1)
    * - ``fdnum``
      - feed index number, zero-based
    * - ``int``
      - Integration number
    * - ``numchn``
      - number of channels in the spectrum
    * - ``sig``
      - ‘T’ or ‘F’ to identify SIG state
    * - ``cal``
      - ‘T’ or ‘F’ to identify cal-on or cal-off
    * - ``sampler``
      - backend sampler name
    * - ``azimuth``
      - antenna azimuth
    * - ``elevation``
      - antenna elevation
    * - ``longitude``
      - longitude-like axis, e.g. RA
    * - ``latitude``
      - latitude-like axis, e.g. DEC
    * - ``lst``
      - LST
    * - ``centfreq``
      - center frequency in Hz
    * - ``restfreq``
      - rest frequency in Hz
    * - ``velocity``
      - source velocity in km/s
    * - ``freqres``
      - frequency resolution in Hz
    * - ``freqint``
      - frequency interval (channel spacing) in Hz
    * - ``dateobs``
      - date-time value
    * - ``bandwidth``
      - bandwidth in Hz
    * - ``exposure``
      - exposure time
    * - ``tsys``
      - system temperature
    * - ``nsave``
      - nsave index
    * - ``trgtlat``
      - latitude coordinate of source
    * - ``trgtlon``
      - longitude coordinate of source
    * - ``obsid``
      - observation ID
    * - ``subref``
      - subreflector state (subref state); 0=moving, 1=first position, -1=second position

  
**getrec** To retrieve an individual record, use the :idl:pro:`getrec` procedure. 
This procedure takes one parameter, the record number. The record number is equivalent to the 
row number in the SDFITS file. Like all indices in IDL, the record number is a zero-based index.
So, for example, the fifth record can be retrieved and displayed as follows:

.. code-block:: IDL

    getrec,4

    
Getting Scan Header Information
-------------------------------

After data have been loaded into the PDC using one of the GBTIDL calibration procedures, :idl:pro:`get`, or
:idl:pro:`getrec`, the :idl:pro:`header` command can be used to show header information for that scan. For example:

.. code-block:: IDL
   
    GBTIDL -> header

returns

.. code-block:: text

    --------------------------------------------------------------------------------
    Proj: TREG_050627 Src : W3OH Obs : Jim Braatz
    Scan: 79 RADec : 02 27 04.1 +61 52 22 Fsky: 1.667696 GHz
    Int : 0 Eqnx : 2000.0 Frst: 1.667359 GHz
    Pol : YY V : -44.0 OPTI-LSR BW : 50.000 MHz
    IF : 0 AzEl : 379.232 16.105 delF: 3.052 kHz
    Feed: 1 Gal : 133.948 1.064 Exp : 26.2 s
    13
    Proc: Track UT : +04 10 20.0 2005-06-28 Tcal: 1.45 K
    Sub : 0 LST/HA: +17 16 29.4 -9.18 Tsys: 28.38 K
    --------------------------------------------------------------------------------

The :idl:pro:`header` command shows information for the PDC by default, but headers for other data containers
can be displayed by specifying the desired buffer index, or by specifying the IDL variable name explicitly.
The following two commands are equivalent, and show the header for the data stored in buffer 2.

.. code-block:: IDL

    GBTIDL -> header, 2
    GBTIDL -> header, !g.s[2]
