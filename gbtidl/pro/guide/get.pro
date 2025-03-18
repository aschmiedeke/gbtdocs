; docformat = 'rst'

;+
; Get data from the input data file and put that into the primary data 
; container (buffer 0).  
; 
; The data to be retrieved are specified by giving a number of selection
; parameters.  If more than one record satisfies the selection criteria given,
; only the first is returned.  If you need to retrieve one of the
; other records you must first refine the selection criteria.  A
; better approach might be to use :idl:pro:`select` to get the list of records that 
; satisfy that selection and then use :idl:pro:`getrec` to get the individual records.
;
; *Note:* All of the data satisfying the selection criteria (or lack of criteria
; if none are given) are extracted from the file before this routine copies the 
; first one found and puts it into buffer 0. There is no protection against running
; out of memory by grabbing too much data.
;
; Run the procedure :idl:pro:`listcols` to see a complete list of selection parameters.
;
; See the discussion on "Select" in the :ref:`https://www.gb.nrao.edu/GBT/DA/gbtidl/users_guide.pdf#page=29` 
; for a summary of selection syntax.
; 
; Flags (set via :idl:pro:`flag`) can be selectively applied or ignored using the 
; useflag and skipflag keywords.  Only one of those two keywords can
; be used at a time (it is an error to use both at the same time).
; Both can be either a boolean (/useflag or /skipflag) or an array of
; strings.  The default is /useflag, meaning that all flag rules that
; have been previously set are applied when the data is fetched from
; disk, blanking any data as described by each rule.  If /skipflag is
; set, then all of the flag rules associated with this data are
; ignored and no data will be blanked when fetched from disk (it may
; still contain blanked values if the actual values in the disk file
; have already been blanked by some other process).  If useflag is a
; string or array of strings, then only those flag rules having the 
; same idstring value are used to blank the data.  If skipflag is a
; string or array of strings, then all flag rules except those
; with the same idstring value are used to blank the data.
;
; :Keywords:
; 
;   useflag : in, optional, type=boolean or string, default=true
;       Apply all or just some of the flag rules?
; 
;   skipflag : in, optional, type=boolean or string
;       Do not apply any or do not apply a few of the flag rules?
; 
;   _EXTRA : in, optional, type=extra keywords
;       These are selection parameters that determine which data to retrieve.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       filein,'my_raw_data.fits'
;       listcols                  ; show the parameters that can be used
;       get,index=0               ; retrieves the first record
;       copy, 0, 10
;       get, scan=6, plnum=0, ifnum=1, int=2
;       oshow, 10
;       get, scan=6, plnum=0, ifnum=1, int=2, /skipflag ; ignore all flags
;       ; in this next example, only flags with idstring='wind' are ignored.
;       get, scan=6, plnum=0, ifnum=1, int=2, skipflag='wind'
; 
; :Uses:
;
;   :idl:pro:`set_data_container`
;
;-
pro get, useflag=useflag, skipflag=skipflag, _EXTRA=ex
   compile_opt idl2

    if n_elements(useflag) gt 0 and n_elements(skipflag) gt 0 then begin
        message,'Useflag and skipflag can not be used at the same time',/info
        return
    endif

   if (!g.line) then begin
       if (!g.lineio->is_data_loaded()) then begin
           dc = !g.lineio->get_spectra(count,useflag=useflag,skipflag=skipflag,_EXTRA=ex)
       endif else begin
           message, 'No line data is attached yet, use filein or dirin.',/info
           return
       endelse
   endif else begin
       if n_elements(useflag) gt 0 or n_elements(skipflag) gt 0 then $
         message,'Flagging is not yet available for continuum data, ignoring flag-related keywords',/info

       if (!g.contio->is_data_loaded()) then begin
           dc = !g.contio->get_continua(count,_EXTRA=ex)
       endif else begin
           message, 'No continuum data is attached yet, use filein or dirin.',/info
           return
       endelse
   endelse

   if (data_valid(dc) gt 0) then begin
       if (n_elements(dc) gt 1) then begin
           message,'More than one item fetched - ignoring all but the first',$
                   /info
       endif
       nblanks = count_blanks(dc[0],ntot)
       if nblanks eq ntot then begin
           message,'All the data in the item fetched is blanked.',/info
       endif
       set_data_container, dc[0]
       data_free, dc
   endif else begin
       if (count eq 0) then begin
           message, 'No matching entries',/info
       endif else begin
           message, 'There was a problem getting the data from the i/o object',/info
       endelse
   endelse

end

