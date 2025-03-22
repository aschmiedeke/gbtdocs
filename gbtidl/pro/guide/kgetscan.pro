; docformat = 'rst' 

;+
; Gets the data associated with a given scan number in the 
; input data set from the output (keep) file. 
;
; This is shorthand for kget,scan=scan with optional use of
; useflag or skipflag.  See the documentation for
; :idl:pro:`kget` for more information. If there is more
; than one record that has the requested scan number, only the first
; is saved to the primary data container.  This is discussed in more
; detail in the documentation for kget.
;
; :Params:
;   scan : in, required, type=integer
;       The scan number of the record to be retrieved.
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
;       kgetscan,1
;       show
;       kgetscan,1,/skipflag ; ignore all flags
;       show
;
;-
pro kgetscan, scan, useflag=useflag, skipflag=skipflag
   compile_opt idl2

   kget,scan=scan, useflag=useflag, skipflag=skipflag
end

