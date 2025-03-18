;+
; This class tries to make working with key -value pairs easier
; @field key_value_strings pointer to string array of key-value pairs
; @field key_value_strct poinrter to structure based of key_value_strings
; @file_comments
; This class tries to make working with an array of key value pairs easier
; @private_file
;-
PRO key_value_parser__define
   compile_opt idl2, hidden


    kvp = { key_value_parser, $
    key_value_strings:ptr_new(), $
    key_value_strct:ptr_new() $
    }

END    

;+
;  Class Constructor
; @private
; -
FUNCTION KEY_VALUE_PARSER::init, key_value_strings

    self.key_value_strings = ptr_new(key_value_strings)

    self->create_key_value_strct

    return, 1

END

;+
; Class Destructor
; @private
; -
PRO KEY_VALUE_PARSER::cleanup

    if ptr_valid(self.key_value_strings) then ptr_free, self.key_value_strings
    if ptr_valid(self.key_value_strct) then ptr_free, self.key_value_strct

END

;+
; Creates key-value structure based off the key-value string array
;-
PRO KEY_VALUE_PARSER::create_key_value_strct

    if (ptr_valid(self.key_value_strings) eq 0) then return
    hdr_lines = *self.key_value_strings
    
    for i = 0,(n_elements(hdr_lines)-1) do begin
        ; break up the single string 'key = value /comment' into parts
        line = hdr_lines[i]
        parts = strsplit(line,"=",/extract)
        key = strtrim(parts[0],2)
        key = strcompress(key,/remove_all)
        if (n_elements(parts) gt 1) then begin
            value = strtrim(parts[1],2) 
        endif else begin
            value = ''
        endelse    
        if (i eq 0) then hdr = create_struct(key,value) else hdr = create_struct(hdr,key,value)
    endfor

    if ptr_valid(self.key_value_strct) then ptr_free,self.key_value_strct
    self.key_value_strct = ptr_new(hdr)

END

;+
; Prints the contents of the key-value structure
;-
PRO KEY_VALUE_PARSER::list

    if (ptr_valid(self.key_value_strct) eq 0) then return 

    help,/struct,*self.key_value_strct

END

;+
; Retrieves the keys in use
; @returns string array of keys
;-
FUNCTION KEY_VALUE_PARSER::get_keys

    if (ptr_valid(self.key_value_strct) eq 0) then return, -1 
    return, tag_names(*self.key_value_strct)
    
END

;+
; Given the key, returns the value
; @returns string value, -1 if key not found
;-
FUNCTION KEY_VALUE_PARSER::get_key_value, keyword

    if (ptr_valid(self.key_value_strct) eq 0) then return, -1
    
    keyword = strupcase(keyword)

    header = *self.key_value_strct
    tags = tag_names(header)
    i = 0
    tag_found = 0
    while (tag_found eq 0) and (i lt (n_elements(tags))) do begin
        if (tags[i] eq keyword) then tag_found = 1 else i = i + 1
    endwhile
    if (tag_found eq 1) then value = header.(i) else value = -1

    return, value

END

;+
; Given the key, sets the value
; @returns 0 if key not found, 1 value set
;-
FUNCTION KEY_VALUE_PARSER::set_key_value, keyword, value

    if (ptr_valid(self.key_value_strct) eq 0) then return, -1
    
    keyword = strupcase(keyword)

    tags = tag_names(*self.key_value_strct)
    i = 0
    tag_found = 0
    while (tag_found eq 0) and (i lt (n_elements(tags))) do begin
        if (tags[i] eq keyword) then tag_found = 1 else i = i + 1
    endwhile
    if (tag_found eq 1) then (*self.key_value_strct).(i) = value

    return, tag_found

END

