;+
; This procedure is used to select data from the current data file for
; later processing. 
;
; <p>Selection puts the index numbers that match the selection
; criteria onto the end of the stack using <a href="appendstack.html">appendstack</a>. Once the index 
; numbers are there, the can be used in a call to <a href="get.html">get</a> or to <a href="kget.html">kget</a> to 
; retrieve them from the data source.
;
; <p>Data can be selected based on entries in the index file, such as
; source name, polarization type, IF number, etc.  For a complete list
; of eligible parameters use the procedure <a href="listcols.html">listcols</a>
;
; <p>See the discussion on "Select" in the <a href="http://wwwlocal.gb.nrao.edu/GBT/DA/gbtidl/users_guide/node50.html" TARGET="_top">User's Guide</a> 
; for a summary of selection syntax.
;
; <p>The selection criteria are ultimately passed to the io class's
; search_index via the _EXTRA parameter. 
;
; @param count {out}{optional}{type=integer} The number of records
; selected and added to the stack.
; @keyword keep {in}{optional}{type=boolean} If set, the selection comes from
; the keep file.  If not set, the selection comes from the input file.
; @keyword quiet {in}{optional}{type=boolean} Turn off informational messages.
; @keyword _EXTRA {in}{optional}{type=extra keywords} These are
; the selection parameters.
;
; @uses <a href="../toolbox/select_data.html">select_data</a>
; @uses <a href="appendstack.html">appendstack</a>
;
; @examples
; <pre>
; select,source='Orion*',/keep
; for i=0,(!g.acount-1) do begin
;    get,index=astack(i)
;    ; do things here
; endfor
; </pre>
;
; @version $Id$
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
