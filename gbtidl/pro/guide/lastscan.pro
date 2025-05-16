; docformat = 'rst'

;+
; Returns the scan number of the most recently retrieved data
; container. 
;
; In line mode, this is the most recently retrieved scan number
; from the input line file.  In continuum mode, this is the most
; recently retrieved scan number from the input continuum file.  If
; the ``/keep`` keyword is used, this is the most recently retrieved
; scan number from the output line file (the keep file).
;
; This is -1 if nothing has been retrieved from that data source or
; if the data source is empty.
;
; If multiple data containers were retrieved in a single call
; (e.g. using one of the calibration routines such as getfs) then this
; will be the scan number of the last record actually retrieved from
; the data source.
;
; :Keyword:
; 
;   keep : in, optional, type=boolean
;       If set, returns the scan number of the data container most
;       recently retrieved from the output line file (the keep file).
;
; :Returns:
;   An integer giving the scan number of the last record fetched 
;   from the data source.  Returns -1 if nothing has been fetched
;   so far from that data source.
;
; :Examples:
;
;   .. code-block:: IDL
;
;       ; This could be used to get the next scan, assuming they were sequential
;       getfs, lastscan()+1
; 
;-
function lastscan, keep=keep
    compile_opt idl2

    result = lastrec(keep=keep)
    if result ge 0 then begin
        if keyword_set(keep) then begin
            thisIO = !g.lineoutio
        endif else begin
            thisIO = !g.line ? !g.lineio : !g.contio
        endelse
        result = thisIO->get_index_values('SCAN',index=result)
    endif

    return, result
end
