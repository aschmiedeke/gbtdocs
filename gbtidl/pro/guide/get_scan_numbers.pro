; docformat = 'rst'

;+
; Function to return scan numbers for the input file.
;
; This returns the different scan numbers in the order they appear
; in the input file.  Use the keep flag to get the scan numbers from
; the output file.  For example, if list shows these scan numbers: 99,
; 99, 99, 100, 99, 99, 100, 100, 101, 101, then ``get_scan_numbers`` will
; return this array [99, 100, 99, 100, 101].  If unique is set it will
; return this array [99, 100, 101].   
;
; The default behavior (without the unique flag set) is a useful
; check to see if a scan number repeats itself in a raw data file.
; That may cause processing problems since the standard calibration
; routines rely on scan numbers not appearing again later in the same
; data file.  If you want to simply see which scan numbers appear in a
; data file where repeating scan numbers is expected or not otherwise
; a problem (e.g. an output file containing processed data), use the
; unique flag. 
;
; Selection fields can be used here in the same way that they can
; be used in other data selection procedures and functions. For a
; complete list of eligible parameters use the procedure 
; :idl:pro:`listcols`
;
; See the discussion on "Select" in the `GBTIDL manual <https://www.gb.nrao.edu/GBT/DA/gbtidl/users_guide.pdf#page=29>`_ 
; for a summary of selection syntax.
;
; The selection criteria are ultimately passed to the io class's
; search_index via the _EXTRA parameter. 
;
; :Params:
;   count : out, optional, type=integer
;       The number of scan numbers returned.  This is 0 when no scan
;       numbers are in the file (the returned value from this function 
;       will also be -1 in that case).
;
; :Keywords:
;   keep : in, optional, type=boolean
;       If set, the scan numbers come from the output file.
;
;   unique : in, optional, type=boolean
;       If set, the unique scan numbers are returned.  This is a sorted 
;       list and it is impossible to tell if there are any duplicate
;       scan numbers.
;   _EXTRA : in, optional, type=extra keywords
;       These are the selection parameters.
;
; :Returns:
;   an array of scan numbers.  Returns -1 (an illegal scan number) if the 
;   file is empty, or nothing matches the selection criteria. 
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       a = get_scan_numbers()
;       print,a
;       a = get_scan_numbers(source='3C*',/unique)
;       print,a
;
;-
function get_scan_numbers, count, keep=keep, unique=unique, _EXTRA=ex
   compile_opt idl2

   result = -1
   count = 0
   if ((keyword_set(keep) and not !g.lineoutio->is_data_loaded()) or $
       (!g.line and not !g.lineio->is_data_loaded()) or $
       (not !g.line and not !g.contio->is_data_loaded())) then begin
       message, 'There is no data to get scan numbers from.',/info
       return, result
   endif

   if (not keyword_set(unique)) then begin
       if (keyword_set(keep)) then begin
           result = !g.lineoutio->get_index_values("scan",_EXTRA=ex)
       endif else begin
           if !g.line then begin
               result = !g.lineio->get_index_values("scan",_EXTRA=ex)
           endif else begin
               result = !g.contio->get_index_values("scan",_EXTRA=ex)
           endelse
       endelse
       oldscan = -1
       count = 0
       for i=0,n_elements(result)-1 do begin
           if result[i] ne oldscan then begin
               result[count] = result[i]
               count += 1
               oldscan = result[i]
           endif
       endfor
       if count gt 0 then begin
           result = result[0:(count-1)]
       endif else begin
           result = -1
       endelse
   endif else begin
       if (keyword_set(keep)) then begin
           result = !g.lineoutio->get_index_scans(_EXTRA=ex)
       endif else begin
           if !g.line then begin
               result = !g.lineio->get_index_scans(_EXTRA=ex)
           endif else begin
               result = !g.contio->get_index_scans(_EXTRA=ex)
           endelse
       endelse
   endelse
   if result[0] gt 0 then count = n_elements(result)
   return, result
end
