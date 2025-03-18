;+
; List all of the idstring values in the flag file of the current
; spectral line data source or the keep (output) data source.
;
; <p>Continuum flagging is not supported.
;
; @keyword keep {in}{optional}{type=boolean} List the idstring values
; in the keep (output) file?
;
; @version $Id$
;-
pro listids, keep=keep
    compile_opt idl2

    if not !g.line then begin
        message,'Flagging is not available for continuum data',/info
        return
    endif

    thisio = keyword_set(keep) ? !g.lineoutio : !g.lineio

    if not thisio->is_data_loaded() then begin
        if keyword_set(keep) then begin
            message, 'No keep (output) data is attached yet, use fileout.', /info
        endif else begin
            message, 'No line data is attached yet, use filein or dirin.', /info
        endelse
        return
    endif

    thisio->list_flag_ids

end
