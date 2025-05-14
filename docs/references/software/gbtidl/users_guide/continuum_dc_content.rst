########################################
Contents of the Continuum Data Container
########################################

The following table describes the contents of the continuum data container. It is closely
modeled on SDFITS files.

Unlike the spectral line DC, the continuum DC contains several pointers to arrays (date, 
utc, mjd, longitude axis, latitude axis, lst, azimuth, elevation and subref state) in
addition to the data array. The length of each of these arrays is the same as the data
array. Each element in these arrays corresponds to one integration for that sampler and 
switching state. The frequency at the center of the bandpass is given by the observed
frequency field and is always a topocentric frequency.


In this table, the *Index* column shows the name that each field is known by in the index
file. These are the names returned by the :idl:pro:`listcols` command. If the Index entry 
is blank, that field is not represented in the index file and is not available for selection.

.. list-table:: Content of the Continuum Data Container
    :widths: 10 15 15 10 20
    :header-rows: 1

    * - Name
      - Type 
      - Default 
      - Index 
      - Description
    * - data_ptr 
      - pointer to float array 
      - 0 
      - 
      - The data array. Must be de-referenced to get data values.
    * - units 
      - string 
      - counts 
      - 
      - The units of the data.
    * - source 
      - string 
      - 
      - source 
      - Source name
    * - observer 
      - string 
      -  
      - 
      - Observer’s name
    * - projid 
      - string 
      - 
      - project 
      - Project id
    * - scan_number 
      - long integer 
      - 0 
      - scan 
      - The scan number
    * - procseqn 
      - long integer 
      - 0 
      - procseqn 
      - The procedure sequence number
    * - procedure 
      - string 
      - 
      - procedure 
      - The name of the observing procedure
    * - procsize 
      - long integer 
      - 1 
      - 
      - Total number of subscans expected for this scan (procedure)
    * - switch_state 
      - string 
      - 
      - 
      - The type of switching used during this procedure.
    * - switch_sig 
      - string 
      - 
      - 
      - The switching signal scheme used during this procedure.
    * - sig_state 
      - long integer 
      - 1 
      - sig 
      - If true (1) this is the signal state, otherwise the reference state
    * - cal_state 
      - long integer 
      - 0 
      - cal 
      - If true (1) the cal was on, otherwise it was off
    * - caltype 
      - string 
      - 
      - 
      - The type of cal. Currently either HIGH or LOW.
    * - integration 
      - long integer 
      - 0 
      - 
      - The integration number (starting from 0)
    * - if_number 
      - long integer 
      - 0 
      - ifnum 
      - The IF number. Counts from 0 for each scan. For GBT data, the same IF NUMBER will correspond to the same IF in other data containers so long as the setup was identical.
    * - obsid 
      - string 
      - 
      - obsid 
      - GBT manager scanId, from the GBT GO FITS file, currently unused
    * - backend 
      - string 
      - 
      - 
      - Backend name
    * - frontend 
      - string 
      - 
      - 
      - Frontend (receiver) name
    * - exposure 
      - double 
      - 0.0 
      - 
      - Effective integration time in seconds
    * - duration 
      - double 
      - 0.0 
      - 
      - The clock time spent collecting this data, including blanking time, in seconds
    * - tambient 
      - float 
      - 0.0 
      - 
      - The ambient temperature in K
    * - pressure 
      - float 
      - 0.0 
      - 
      - The pressure in Pa
    * - humidity 
      - float 
      - 0.0 
      - 
      - The humidity fraction 0.1
    * - tsys 
      - float 
      - 1.0 
      - 
      - System temperature in K
    * - mean_tcal 
      - double 
      - 1.0 
      - 
      - The mean Tcal value across the entire bandpass in K
    * - tsysref 
      - float 
      - 1.0 
      - 
      - System temperature of reference data used b56y this data in K
    * - telescope 
      - string 
      - NRAO_GBT 
      - 
      - Name of the telescope
    * - site_location
      - 3 doubles 
      - Location of the GBT 
      -  
      - (East longitude in degrees, latitude in degrees, elevation in meters)
    * - coordinate_mode 
      -  string 
      - RADEC 
      - 
      - The type of coordinate for the pointing direction (inferred from CTYPE2 and CTYPE3). Possible choices are RADEC, GALACTIC, HADEC, AZEL, and OTHER.
    * - polarization 
      - string 
      - 
      - polarization 
      - The polarization
    * - polarization_num 
      - long integer 
      - 0
      - 
      - The polarization number. Counts from 0 for each scan.
    * - feed 
      - long integer 
      - 0
      -  
      - The feed name as known at the telescope.
    * - srfeed 
      - long integer 
      - 0 
      - 
      - The switching feed name as known at the telescope.
    * - feed_num 
      - long integer 
      - 0 
      - 
      - The number of this feed. Counts from 0 for each scan.
    * -  feedxoff 
      - double 
      - 0.0 
      -  
      - Beam offset for the cross-elevation axis, in degrees
    * - feedeoff 
      - double 
      - 0.0
      - 
      - Beam offset for the elevation axis, in degrees
    * - sampler_name 
      - string 
      - 
      - 
      - The name of the sampler (a GBT-specific term)
    * - bandwidth 
      - double 
      - 0.0 
      - 
      - Total bandwidth in Hz
    * - observed_frequency 
      - double 
      - 0.0 
      -
      - The observed (sky) frequency in Hz at the center of the bandpass.
    * - sideband
      - string 
      - 
      - 
      - The sideband (U or L)
    * - equinox 
      - double 
      - 2000.0 
      - 
      - The equinox, in years, of the longitude and latitude axis values, when appropriate.
    * - radesys 
      - string 
      - FK5 
      - 
      - The equitorial coordinate system when appropriate, e.g. FK5, FK4, GAPPT.
    * - target_longitude 
      - double 
      - 0.0
      - trgtlong 
      - The target (source) longitude pointing direction in degrees in the same coordinate system as longitude axis. From the GO FITS file.
    * - target_latitude 
      - double 
      - 0.0
      - trgtlat 
      - The target (source) latitude pointing direction in degrees in the same coordinate system as latitude axis. From the GO FITS file.
    * - timestamp 
      - string 
      - default 
      - timestamp 
      - The timestamp given to the scan when it was taken. YYYY MM DD HH:MM:SS. This can be used in data selection when there are repeated scan numbers.
    * - date
      - pointer to string array 
      - current date Date 
      - 
      - (YYYY-MM-DD) (along with utc) corresponding to mjd at each integration
    * - utc 
      - pointer to double array 
      - current time 
      - 
      - UTC seconds since start of date. Corresponds to UTC of mjd array
    * - mjd 
      - pointer to double array 
      - from current date and time 
      - 
      - Modified Julian Date at mid-point of integration in days
    * - longitude_axis 
      - pointer to double array 
      - 0.0 
      - 
      - The longitude pointing direction at each integration, in degrees in coordinate mode at equinox
    * - latitude_axis 
      - pointer to double array 
      - 0.0 
      - 
      - The latitude pointing direction at each integration, in degrees in coordinate mode at equinox
    * - lst 
      - pointer to double array 
      - from current time 
      - 
      - LST seconds corresponding to mjd array and site location.
    * - azimuth 
      - pointer to double array 
      - 0.0 
      - 
      - The azimuth for each integration in degrees.
    * - elevation 
      - pointer to double array 
      - 0.0 
      - 
      - The elevation for each integration in degrees.
    * - subref_state 
      - pointer to integer array 
      - 1 
      - 
      - Subreflector state when subreflector nodding; 0=moving, 1=first position, -1=second position

