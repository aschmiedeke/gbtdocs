;+
; Gets the data associated with a given scan number.  In general this
; procedure is used on data that have already been calibrated and
; written o a new data file.
;
; To retrieve scans from a raw data file, as produced by the 'sdfits'
; program on the GBT, use getfs, gettp, getnod, or one of the other
; procedures that does both retrieval and calibration.
;
; <p>This is shorthand for get,scan=scan with optional use of
; useflag or skipflag.  See the documentation for <a href="get.html">get</a> for more 
; information.  If there is more than one record that has the
; requested scan number, only the first is saved to the primary data
; container.  This is discussed in more detail in the documentation
; for get. 
;
; @param scan {in}{required}{type=integer} The scan number of the 
; record to be retrieved
; @keyword useflag {in}{optional}{type=boolean or string}{default=true}
; Apply all or just some of the flag rules?
; @keyword skipflag {in}{optional}{type=boolean or string} Do not apply
; any or do not apply a few of the flag rules?;
;
; @examples
; <pre>
;  filein,'my_processed_data.fits'
;  getscan,101
;  copy, 0, 10
;  getscan,102
;  oshow, 10
;  getscan,103,/skipflag ; ignore all flags
; </pre>
;
; @version $Id$
;-
pro getscan, scan, useflag=useflag, skipflag=skipflag
   compile_opt idl2

   get,scan=scan,useflag=useflag,skipflag=skipflag
end

