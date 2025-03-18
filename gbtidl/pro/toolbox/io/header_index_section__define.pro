;+
; This extends the index_file_section class to properly handle the header section
; of an index file.  The added basic functionality is to treat the header section
; like a dictionary, that is, a list of keyword-value pairs.
; See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes
;
; @field header a key_value_parser object for converting the lines in the section
; to a structure
; 
; @file_comments
; This extends the index_file_section class to properly handle the header section
; of an index file.  The added basic functionality is to treat the header section
; like a dictionary, that is, a list of keyword-value pairs.
; See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes
;
; @field header a key_value_parser object for converting the lines in the section
; to a structure
; 
; @inherits index_file_section
; @private_file
;
;-
PRO header_index_section__define

    his = { HEADER_INDEX_SECTION, $ 
        inherits index_file_section,  $
        header:obj_new(), $
        lines:ptr_new() $ ; does not include section marker
    }

END

;+
; Class Constructor
; @private
;-
FUNCTION HEADER_INDEX_SECTION::init, filename
    compile_opt idl2, hidden

    if n_elements(filename) ne 0 then begin
        r = self->INDEX_FILE_SECTION::init("header", filename)
    endif else begin    
        r = self->INDEX_FILE_SECTION::init("header")
    endelse

    self.lines = ptr_new(/allocate_heap)

    self.pad_width = 1
    return, r

END    

;+
; Class Destructor
; @private
;-
PRO HEADER_INDEX_SECTION::cleanup
    compile_opt idl2, hidden

    self->INDEX_FILE_SECTION::cleanup

    if obj_valid(self.header) then obj_destroy, self.header
    if ptr_valid(self.lines) then ptr_free, self.lines

END    

;+
; Creates the header section, given the strings to place there.
;
; @param hdr_lines {in}{required}{type=string array} lines to be placed in header 
; section; must be of form 'keyword = value' for each line.
; @param start_line_number {in}{optional}{type=long} line to start at, 
; defaults to zero
;
;-
PRO HEADER_INDEX_SECTION::create, hdr_lines, start_line_number
    compile_opt idl2, hidden

    if n_elements(start_line_number) eq 0 then start_line_number = 0

    self->INDEX_FILE_SECTION::create, start_line_number, lines=hdr_lines

    if obj_valid(self.header) then obj_destroy, self.header

    self.header = obj_new("key_value_parser", hdr_lines)
    
END


;+
; Procedure to process each line.  Invoked by
; index_file_section::read_file
; @param line {in}{required}{type=string} The line to handle.
; @param index {in}{required}{type=integer} The index number for this line
;-
PRO HEADER_INDEX_SECTION::process_line, line, index
    compile_opt idl2, hidden

    ; just keep a copy of it
    (*self.lines)[index] = line
END

;+
; Reads the header section of an index file.  After reading in the lines, creates a 
; key_value_parser object to manage them.
;-
FUNCTION HEADER_INDEX_SECTION::read_file
    compile_opt idl2, hidden

    nlines = self->count_section_lines()

    *self.lines = strarr(nlines)

    result = self->INDEX_FILE_SECTION::read_file()

    if result ne -1 then begin
        if obj_valid(self.header) then obj_destroy, self.header
        self.header = obj_new("key_value_parser",*self.lines)
    endif

    return, result
END

;+
; Retrieves array of lines in section; commented out lines are not included
; @param count {out}{optional}{type=long} number of lines returned
; @returns array of lines in section, -1 if no lines
;-
FUNCTION HEADER_INDEX_SECTION::get_lines, count
    compile_opt idl2, hidden

    if ptr_valid(self.lines) then begin
        count = n_elements(*self.lines)
        if count eq 0 then begin
            return, -1
        endif else begin    
            return, *self.lines
        endelse    
    endif else begin
        count = 0
        return, -1
    endelse    

END

;+
; Retrieves the value for a header keyword.
; @param keyword {in}{required}{type=string} keyword whose value is returned
; @returns string value of keyword passed in. -1 if keyword is not found.
;-
FUNCTION HEADER_INDEX_SECTION::get_value, keyword
    compile_opt idl2, hidden

    if self.section_read ne 1 then message, "section not read yet"

    return, self.header->get_key_value(keyword)

END

;+ 
; Retrieves the position in the file of the header keyword supplied
; @param keyword {in}{required}{type=string} keyword whose position is returned
; @returns position in the file of the header keyword supplied
; @private
;-
FUNCTION HEADER_INDEX_SECTION::get_line_number, keyword
    compile_opt idl2, hidden

    keys = self.header->get_keys()
    
    line_number = -1
    for i=0,n_elements(keys)-1 do begin
        if strtrim(strlowcase(keys[i]),2) eq strtrim(strlowcase(keyword),2) then begin
            line_number = (*self.line_nums)[i]
        endif
    endfor

    return, line_number

END

;+
; Sets the value for the keyword in the file header
; @param keyword {in}{required}{type=string} keyword whose value is set
; @param value {in}{required}{type=string} value to set for keyword
; @returns 0 - failure, 1 - success
; @uses get_line_number
; @uses header->set_key_value
;-
FUNCTION HEADER_INDEX_SECTION::set_value, keyword, value
    compile_opt idl2, hidden

    if self.section_read ne 1 then message, "section not read yet"
    
    line_number =  self->get_line_number(keyword)
    
    if line_number eq -1 then message, "keyword not found in header: "+keyword

    self->set_line, line_number, strtrim(strlowcase(keyword),2) + " = " + strtrim(value,2)
        
    return, self.header->set_key_value(keyword, value)
    
END

;+
; Prints out the contents of the header (in it's structure form)
; @uses header->list
;-
PRO HEADER_INDEX_SECTION::list
    compile_opt idl2, hidden

    if self.section_read ne 1 then message, "section not read yet"

    self.header->list

END
