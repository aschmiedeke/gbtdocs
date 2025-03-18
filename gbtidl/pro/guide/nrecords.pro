;+
; Retrieve the number of records associated with an i/o object.
;
; If the keyword keep is set, the data comes from !g.lineoutio
;
; If the value of !g.line is true, then the data comes from !g.lineio
; otherwise the data comes from !g.contio
;
; @keyword keep {in}{optional}{type=bool} the data comes from
; !g.lineoutio
; @returns The number of records.
;
; @version $Id$
;-
function nrecords, keep=keep
    compile_opt idl2

   if keyword_set(keep) then begin
       if (!g.lineoutio->is_data_loaded()) then begin
          return, !g.lineoutio->get_num_index_rows()
       endif else begin
           message, 'No output data is attached yet, use keep.',/info
           return, 0
       endelse
   endif else begin    
       if (!g.line) then begin
           if (!g.lineio->is_data_loaded()) then begin
               return, !g.lineio->get_num_index_rows() 
           endif else begin
               message, 'No line data is attached yet, use filein or dirin.',/info
               return, 0
           endelse
       endif else begin
           if (!g.contio->is_data_loaded()) then begin
               return, !g.contio->get_num_index_rows() 
           endif else begin
               message, 'No continuum data is attached yet, use filein or dirin.',/info
               return, 0
           endelse
       endelse ; line?
   endelse ; keep?    
    
end
