; docformat = 'rst'

;+
; This procedure is used to remove previously selected index numbers
; from the stack.  
;
; Data can be de-selected by using selection criteria in the same
; way as in :idl:pro:`select`.
;
; Data can be de-selected based on entries in the index file, such
; as source  name, polarization type, IF number, etc.  For a complete
; list of eligible parameters use the procedure :idl:pro:`listcols`.
;
; See the discussion on "Select" in the `GBTIDL manual <https://www.gb.nrao.edu/GBT/DA/gbtidl/users_guide.pdf#page=29>`_ 
; for a summary of selection syntax.
;
; The selection criteria are ultimately passed to the io class's
; search_index via the ``_EXTRA`` parameter. 
;
; :Keywords:
; 
;   keep : in, optional, type=boolean
;       If set, the selection comes from the keep file.  If not set, 
;       the selection comes from the input file.
; 
;   _EXTRA : in, optional, type=extra keywords
;       These are the selection parameters.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       select, source="ORION"    ; select all ORION data
;       deselect, scan=15         ; remove scan 15, perhaps it's bad
;       deselect, ifnum=1         ; remove the IFNUM=1 data
;
; :Uses:
; 
;   :idl:pro:`select_data`
;   :idl:pro:`delete`
;
;-
PRO deselect, keep=keep, _EXTRA=ex
    compile_opt idl2
    if (keyword_set(keep)) then begin
        indx = select_data(!g.lineoutio,_EXTRA=ex)
    endif else begin
        indx = !g.line ? select_data(!g.lineio, _EXTRA=ex) : select_data(!g.contio, _EXTRA=ex)
    endelse
    
    if (indx[0] lt 0) then begin
        print,'No matching indices were found'
    endif else begin
        acount = !g.acount
        delete,indx
        print, 'Indices removed from stack :', acount - !g.acount
    endelse
END
