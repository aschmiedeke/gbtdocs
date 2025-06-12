; docformat = 'rst' 

;+
; Select data from the given io object and return the array of
; matching indices.
;
; Data can be selected based on entries in the index file, such as source
; name, polarization type, IF number, etc.  For a complete list of eligible
; parameters use the procedure :idl:pro:`listcols`
;
; See the discussion on "Select" in the GBTIDL User's Guide :ref:`here <Select>`
; for a summary of selection syntax.
;
; The selection criteria are ultimately passed to the io
; class's search_index via the _EXTRA parameter.
;
; :Params:
;   io_object : in, required, type=sdfits io object
;       The io object on which the selection is performed
; 
; :Keywords:
;   count : out, optional, type=integer
;       The number of matches found.
;   _EXTRA : in, optional, type=extra keywords
;       These are the selection parameters.
;
; :Returns:
;   an array of indicies.  Returns a value of -1 if no match was found.
;
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
