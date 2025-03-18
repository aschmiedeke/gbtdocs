
;+
; Gets the data associated with a given index number in the 
; input data set from the output (keep) file.  
;
; <p>This is shorthand for kget,index=index with optional use of
; useflag or skipflag.  See the documentation for
; <a href="kget.html">kget</a> for more information.
;
; @param index {in}{required}{type=integer} The index number of the 
; record to be retrieved.
; @keyword useflag {in}{optional}{type=boolean or string}{default=true}
; Apply all or just some of the flag rules?
; @keyword skipflag {in}{optional}{type=boolean or string} Do not apply
; any or do not apply a few of the flag rules?
;
; @examples
; <pre>
;  kgetrec,1
;  show
;  kgetrec,1,/skipflag ; ignore all flags
;  show
; </pre>
;
; @version $Id$
;-
pro kgetrec, index, useflag=useflag, skipflag=skipflag
   compile_opt idl2

   kget,index=index, useflag=useflag, skipflag=skipflag
end

