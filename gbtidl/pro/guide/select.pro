; docformat = 'rst'

;+
; This procedure is used to select data from the current data file for
; later processing. 
;
; Selection puts the index numbers that match the selection
; criteria onto the end of the stack using :idl:pro:`appendstack`. Once 
; the index numbers are there, the can be used in a call to :idl:pro:`get`
; or to :idl:pro:`kget` to retrieve them from the data source.
;
; Data can be selected based on entries in the index file, such as
; source name, polarization type, IF number, etc.  For a complete list
; of eligible parameters use the procedure :idl:pro:`listcols`.
;
; See the discussion on "Select" in the GBTIDL User's Guide :ref:`here <Select>`
; for a summary of selection syntax.
;
; The selection criteria are ultimately passed to the io class's
; search_index via the _EXTRA parameter. 
;
; :Params:
; 
;   count : out, optional, type=integer
;       The number of records selected and added to the stack.
;
; :Keywords:
; 
;   keep : in, optional, type=boolean
;       If set, the selection comes from the keep file.  If not set,
;       the selection comes from the input file.
; 
;   quiet : in, optional, type=boolean
;       Turn off informational messages.
; 
;   _EXTRA : in, optional, type=extra keywords
;       These are the selection parameters.
;
; :Examples:
; 
;   .. code-block:: IDL
;   
;       select,source='Orion*',/keep
;       for i=0,(!g.acount-1) do begin
;           get,index=astack(i)
;           ; do things here
;       endfor
;
; :Uses:
; 
;   :idl:pro:`select_data`
;   :idl:pro:`appendstack`
;
;-
PRO select, count, keep=keep, quiet=quiet, _EXTRA=ex
    compile_opt idl2
    count = 0
    if (keyword_set(keep)) then begin
        indx = select_data(!g.lineoutio,_EXTRA=ex)
    endif else begin
        indx = !g.line ? select_data(!g.lineio, _EXTRA=ex) : select_data(!g.contio, _EXTRA=ex)
    endelse
    
    if (indx[0] lt 0) then begin
        if not keyword_set(quiet) then message,'No matching indices were found',/info
    endif else begin
        count = n_elements(indx)
        appendstack, indx
        if not keyword_set(quiet) then print, 'Indices added to stack : ', strtrim(n_elements(indx),2)
    endelse
END
