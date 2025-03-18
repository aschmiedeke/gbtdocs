;+
; Gets the data associated with a given index number in the 
; input data set.
;
; <p>This is shorthand for get,index=index with optional use of
; useflag or skipflag.  See the documentation for
; <a href="get.html">get</a> for more information.
;
; @param index {in}{required}{type=integer} The index number of the 
; record to be retrieved
; @keyword useflag {in}{optional}{type=boolean or string}{default=true}
; Apply all or just some of the flag rules?
; @keyword skipflag {in}{optional}{type=boolean or string} Do not apply
; any or do not apply a few of the flag rules?
;
; @examples
; <pre>
;  getrec,1
;  show
;  getrec,1,/skipflag  ; ignore all flags
;  show
; </pre>
;
; @version $Id$
;-
pro getrec, index, useflag=useflag, skipflag=skipflag
   compile_opt idl2

   get,index=index, useflag=useflag, skipflag=skipflag
end

