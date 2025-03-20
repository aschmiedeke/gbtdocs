; docformat = 'rst'

;+
; List flags associated with the current input spectral line data file 
; or with the keep (output) data file.  Use the idstring parameter to
; limit the listing to a specific idstring.
;
; Continuum flagging is not supported.
;
; :Params:
;   idstring : in, optional, type=string, default=all
;       The string to match.  All flags that match this string will be listed.
; 
; :Keywords:
;   summary : in, optional, type=boolean
;       Produces a somewhat more readable output at the cost of possibly
;       not showing all of the information. Truncated information is
;       indicated with "." in the truncated field. The default is to show
;       all of the information - which may have long lines and which will 
;       not necessarily be nicely aligned by column.
;   keep : in, optional, type=boolean
;       List the flags in the keep (output) file?
;
; :Examples:
; 
;   ..code-block::
;
;       ; list all flags, formatted nicely, possibly truncated
;       listflags, /summary
;       ; only list "RFI" tagged flags
;       listflags, "RFI"
;  
;-
pro listflags, idstring, summary=summary, keep=keep
    compile_opt idl2

    if not !g.line then begin
        message,'Flagging is not available for continuum data',/info
        return
    endif

    thisio = keyword_set(keep) ? !g.lineoutio : !g.lineio

    if not thisio->is_data_loaded() then begin
        if keyword_set(keep) then begin
            message,'No keep (output) data is attached yet, use fileout.', /info
        endif else begin
            message, 'No line data is attached yet, use filein or dirin.', /info
        endelse
        return
    endif

    thisio->list_flags,idstring=idstring,summary=summary

end
