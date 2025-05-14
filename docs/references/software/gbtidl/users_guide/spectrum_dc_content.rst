#######################################
Contents of the Spectrum Data Container
#######################################

The following table describes the contents of the spectrum data container. It is closely modeled on the contents of SDFITS files.


The column in this table labeled *Index* shows the name that each field is known by in the index file. 
These are the names returned by the :idl:pro:`listcols` command. If the Index entry is blank, that 
field is not represented in the index file and is not available for selection. Note that the 
:idl:pro:`dateobs` index name corresponds to the full DATE-OBS value from the SDFITS file, which
combines the information in the date and utc fields from the data container.

The ``zero_channel`` value is only relevant for data from the spectrometer (ACS). When the N lags are
transformed from lags to frequency space, there are N+1 unique frequencies. The data values are taken
from channels 1 through N and the 0 value is stored in the ZEROCHAN column of the SDFITS file. The value
is not used by any core GBTIDL procedures but is included here for experienced users who wish to make 
use of it.


.. list-table:: Content of the Spectrum Data Container
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
      - The data array. Must be dereferenced to get data values.
    * - zero_channel 
      - double 
      - NaN 
      - 
      - The zerochan value from the SDFITS file. Will be a finite value only for ACS data.
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
      - Project ID
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
    * - nsave 
      - long integer 
      - -1 
      - nsave 
      - The nsave location this has been saved to. Will only be = 0 if NSAVE was used to save this to the output file.
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
      - int
      - The integration number (starting from 0)
    * - if_number 
      - long integer 
      - 0 
      - ifnum 
      - The IF number. For GBT data, the IF NUMBER will correspond to the same IF in other data containers if the setup was identical.
    * - obsid 
      - string 
      - 
      - obsid 
      - GBT manager scanId, from the GBT GO FITS file.
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
      - exposure 
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
      - tsys 
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
      - System temperature of reference data used by this data in K
    * - telescope 
      - string 
      - NRAO_GBT  
      - 
      - Name of the telescope
    * - site_location 
      - 3 doubles 
      - 
      - 
      - Location of the GBT (East longitude in degrees, latitude in degrees, elevation in meters)
    * - coordinate_mode 
      - string 
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
      - plnum 
      - The polarization number. Counts from 0 for each scan.
    * - feed 
      - long integer 
      - 0 
      - feed 
      - The feed name as known at the telescope.
    * - srfeed 
      - long integer 
      - 0
      -  
      - The switching feed name as known at the telescope.
    * - feed_num
      - long integer 
      - 0 
      - fdnum 
      - The number of this feed. Counts from 0 for each scan.
    * - feedxoff 
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
      - sampler 
      - The name of the sampler (a GBT-specific term)
    * - bandwidth 
      - double 
      - 0.0
      - bandwidth 
      - Total bandwidth in Hz
    * - observed_frequency 
      - double 
      - 0.0 
      -
      - The observed (sky) frequency in Hz at the reference channel
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
    * - date
      - string 
      - current date 
      - [dateobs] 
      - Date (YYYY-MM-DD), along with utc, corresponding to mjd
    * - utc 
      - double 
      - current time 
      - [dateobs] 
      - UTC seconds since start of date. Corresponds to mjd
    * - mjd 
      - double 
      - from current date and time 
      - 
      - Modified Julian Date at mid-point of integration in days
    * - timestamp 
      - string 
      - default 
      - timestamp 
      - The timestamp given to the scan when it was taken. YYYY MM DD HH:MM:SS. This can be used in data selection when there are repeated scan numbers.
    * - frequency_type 
      - string 
      - TOPO 
      - 
      - Description of the frequency axis. From CTYPE1 Recognized values are TOPO, LSR, LSD, GEO, HEL, BAR, and GAL.
    * - reference_frequency 
      - double 
      - reference channel 
      - 
      - Frequency, in Hz, at the reference channel
    * - reference_channel 
      - double 
      - n elements(data ptr)/2 + 1 
      - 
      - The reference channel
    * - frequency_interval 
      - double 
      - 1.0 
      - freqint 
      - Spacing in Hz between adjacent channels: f(i+1)-f(i)
    * - frequency_resolution 
      - double 
      - 1.0 
      - freqres 
      - The spectral resolution of one channel, in Hz. 
    * - center_frequency 
      - double 
      - 0.0 
      - centfreq 
      - The frequency in Hz at the center channel, which may not be reference frequency. This is used in the index file and is available for selection.
    * - longitude_axis 
      - double 
      - 0.0 
      - longitude 
      - The longitude pointing direction in degrees in coordinate mode at equinox
    * - latitude_axis
      - double 
      - 0.0 
      - latitude 
      - The latitude pointing direction in degrees in coordinate mode at equinox
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
    * - velocity_definition
      - string 
      - RADI-OBS
      - 
      - SDFITS VELDEF keyword
    * - frame_velocity 
      - double 
      - 0.0 
      - 
      - True (relativistic) velocity of the doppler tracked frame with respect to the telescope in m/s
    * - lst
      - double 
      - from current time 
      - lst 
      - The LST in seconds corresponding to UTC on date given the site location
    * - azimuth 
      - double 
      - 0.0
      - azimuth 
      - Azimuth in degrees
    * - elevation
      - double
      - 0.0
      - elevation
      - Elvation in degrees
    * - subref_state
      - integer
      - -1
      - subref
      - Subreflector state when subreflector nodding; 0=moving, 1=first position, -1=second position
    * - line_rest_frequency
      - double
      - 0.0
      - restfreq
      - Rest frequency of line of interest in Hz
    * - source_velocity
      - double
      - 0.0
      - velocity
      - Velocity of the source in m/s in the reference frame and definition given by velocity definition
    * - freq_switch_offset
      - double
      - 0.0
      -   
      - The offset of the reference switching state to the signal state in Hz for calibrated data





