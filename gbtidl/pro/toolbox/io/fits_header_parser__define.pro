;+
; Child of key_value_parser, removes comments that are part of the
; string array returned from fits headers
; @file_comments
; Child of key_value_parser, removes comments that are part of the
; string array returned from fits headers
; @inherits key_value_parser
; @private_file
;-
PRO fits_header_parser__define
   compile_opt idl2, hidden

    fkv = { fits_header_parser, $
        inherits key_value_parser $
    }

END

;+
; Class Constructor
; @param key_value_strings {in}{type=array} string array returned from fits header
;-
FUNCTION FITS_HEADER_PARSER::init, key_value_strings
    compile_opt idl2

    if ptr_valid(self.key_value_strings) then ptr_free, self.key_value_strings
    self.key_value_strings = ptr_new(key_value_strings)

    self->FITS_HEADER_PARSER::create_key_value_strct

    return, 1

END

;+
; Converts the string array from fits header into a structure,
; removing comments and white space.
;-
PRO FITS_HEADER_PARSER::create_key_value_strct
    compile_opt idl2

    if (ptr_valid(self.key_value_strings) eq 0) then return
    hdr_lines = *self.key_value_strings
    
    for i = 0,(n_elements(hdr_lines)-1) do begin
        ; break up the single string 'key = value /comment' into parts
        line = hdr_lines[i]
        parts = strsplit(line,"=",/extract)
        ; ignore everything that doesn't have at least one = in it
        ; and all COMMENT and HISTORY lines
        if n_elements(parts) le 1 then continue
        if strpos(line[0],"COMMENT") eq 0 then continue
        if strpos(line[0],"HISTORY") eq 0 then continue

        key = strtrim(parts[0],2)
        ; dont allow dashes in names, replace with underscores
        key_parts = strsplit(key,"-",/extract)
        if (n_elements(key_parts) gt 1) then begin
            key = strjoin(key_parts,"_")
        endif
        key = strcompress(key,/remove_all)
        value = strtrim(parts[1],2) 
        ; get rid of the comments in the value
        parts = strsplit(value,"/",/extract)
        value = strtrim(parts[0],2)
        ; get rid of leading and trailing quotes
        value = strsplit(value,"'",/extract)
        value = strtrim(value,2)
        if (i eq 0) then hdr = create_struct(key,value) else hdr = create_struct(hdr,key,value)
    endfor

    if ptr_valid(self.key_value_strct) then ptr_free,self.key_value_strct
    self.key_value_strct = ptr_new(hdr)

END

