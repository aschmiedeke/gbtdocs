;+
; Select data from the given io object and return the array of
; matching indices.
;
; <p>Data can be selected based on entries in the index file, such as source
; name, polarization type, IF number, etc.  For a complete list of eligible
; parameters use the procedure <a href="listcols.html">listcols</a>
;
; <p>See the discussion on "Select" in the <a href="http://wwwlocal.gb.nrao.edu/GBT/DA/gbtidl/users_guide/node50.html" TARGET="_top">User's Guide</a> 
; for a summary of selection syntax.
;
; <p>The selection criteria are ultimately passed to the io
; class's search_index via the _EXTRA parameter.
;
; @param io_object {in}{required}{type=sdfits io object} The io object
; on which the selection is performed
; @keyword count {out}{optional}{type=integer} The number of matches found.
; @keyword _EXTRA {in}{optional}{type=extra keywords} These are
; the selection parameters.
;
; @returns an array of indicies.  Returns a value of -1 if no match
; was found.
;
; @version $Id$
;-
FUNCTION select_data, io_object, count=count, _EXTRA=ex
    compile_opt idl2

    result = -1
    count = 0

    if (io_object->is_data_loaded()) then begin
        result = io_object->get_index(_EXTRA=ex)
        if result[0] ne -1 then count = n_elements(result)
    endif else begin
        message, 'There is no data to select from', /info
    endelse

    return, result
END
