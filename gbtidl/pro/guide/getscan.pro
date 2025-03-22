; docformat = 'rst' 

;+
; Gets the data associated with a given scan number.  In general this
; procedure is used on data that have already been calibrated and
; written o a new data file.
;
; To retrieve scans from a raw data file, as produced by the 'sdfits'
; program on the GBT, use getfs, gettp, getnod, or one of the other
; procedures that does both retrieval and calibration.
;
; This is shorthand for get,scan=scan with optional use of
; useflag or skipflag.  See the documentation for :idl:pro:`get` for more 
; information.  If there is more than one record that has the
; requested scan number, only the first is saved to the primary data
; container.  This is discussed in more detail in the documentation
; for get. 
;
; :Params:
;   scan : in, required, type=integer
;       The scan number of the record to be retrieved
; 
; :Keywords:
;   useflag : in, optional, type=boolean or string, default=true
;       Apply all or just some of the flag rules?
;   skipflag : in, optional, type=boolean or string
;       Do not apply any or do not apply a few of the flag rules?;
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       filein,'my_processed_data.fits'
;       getscan,101
;       copy, 0, 10
;       getscan,102
;       oshow, 10
;       getscan,103,/skipflag ; ignore all flags
;
;-
pro getscan, scan, useflag=useflag, skipflag=skipflag
   compile_opt idl2

   get,scan=scan,useflag=useflag,skipflag=skipflag
end

