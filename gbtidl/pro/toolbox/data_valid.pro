; docformat = 'rst'

;+
; Check to see if the argument is a recognized data structure.
;
; A data structure is invalid if its name is not 'SPECTRUM_STRUCT'
; or 'CONTINUUM_STRUCT'. 
;
; :Params:
;   data_struct : in, required, type=data structure
;       The structure check.
;
; :Keywords:
;   name : out, optional, type=string
;       Holds the structure name when used in the call. This will 
;       be either 'CONTINUUM_STRUCT' or 'SPECTRUM_STRUCT'.  
;
; :Returns:
;   n_elements(*data_ptr) if valid and -1 if invalid. (hence if the
;   return value is = 0 it's undefined).
;
;-
FUNCTION DATA_VALID, data_struct, name=name
    compile_opt idl2

    result = -1
    name=''
    ; check on match in data_struct's type
    if (size(data_struct,/type) eq 8) then begin
        name = tag_names(data_struct[0],/structure_name)
	if (name eq 'CONTINUUM_STRUCT' or name eq 'SPECTRUM_STRUCT') then begin
            result = ptr_valid(data_struct[0].data_ptr) ? n_elements(*(data_struct[0].data_ptr)) : 0
        endif
    endif

    return, result
end
