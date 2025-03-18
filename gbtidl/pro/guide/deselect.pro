;+
; This procedure is used to remove previously selected index numbers
; from the stack.  
;
; <p>Data can be de-selected by using selection criteria in the same
; way as in <a href="select.html">select</a>.
;
; <p>Data can be de-selected based on entries in the index file, such
; as source  name, polarization type, IF number, etc.  For a complete
; list of eligible parameters use the procedure <a href="listcols.html">listcols</a>.
;
; <p>See the discussion on "Select" in the <a href="http://wwwlocal.gb.nrao.edu/GBT/DA/gbtidl/users_guide/node50.html" TARGET="_top">User's Guide</a> 
; for a summary of selection syntax.
;
; <p>The selection criteria are ultimately passed to the io class's
; search_index via the _EXTRA parameter. 
;
; @keyword keep {in}{optional}{type=boolean} If set, the selection comes from
; the keep file.  If not set, the selection comes from the input file.
; @keyword _EXTRA {in}{optional}{type=extra keywords} These are
; the selection parameters.
;
; @examples
; <pre>
;    select, source="ORION"    ; select all ORION data
;    deselect, scan=15         ; remove scan 15, perhaps it's bad
;    deselect, ifnum=1         ; remove the IFNUM=1 data
; </pre>
;
; @uses <a href="../toolbox/select_data.html">select_data</a>
; @uses <a href="delete.html">delete</a>
;
; @version $Id$
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
