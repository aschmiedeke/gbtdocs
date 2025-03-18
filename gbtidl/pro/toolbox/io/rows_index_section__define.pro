;+
; This virtual class extends the index_file_section class, but is extended by
; the line_index_section and cntm_index_section to manage the rows section of 
; spectral line index files and continuum index files, respectively.
;
; @file_comments
; This virtual class extends the index_file_section class, but is extended by
; the line_index_section and cntm_index_section to manage the rows section of 
; spectral line index files and continuum index files, respectively.
;
; @field rows pointer to array of structures mirroring index rows section
; @field param_types pointer to 2 by N array of param names and syntax types
; @field frmt pointer to 3xN array of formats for printing rows section
; @field frmt_quiet pointer to array of integers determining which columns are
; used for 'quiet' listing
; @field frmt_user pointer to array of integers determining which columns are
; used for 'user' listing
; @field float_format string representing how all floats are to be printed
; @field format_string string used for reading index lines into row structures.
; determined by frmt array
; @field format_header top row to be printed in listings
; @field index_header integer for accessing the format for the column header in the index file
; @field list_header integer for accessing the format for the column header for listings
; @field column_name integer for accessing the column name to be printed
; @field column_type integer for accessing the column syntax type
; @field index_value integer for accessing the format for the column value in the index file
; @field list_value integer for accessing the format for the column value in a listing
; @field more_format boolean: wether or not to use 'more' format listing style
;
; @inherits index_file_section
;
; @private_file
;-
PRO rows_index_section__define

    ris = { ROWS_INDEX_SECTION, $ 
        inherits index_file_section, $
        rows:ptr_new(), $
        frmt:ptr_new(), $
        frmt_quiet:ptr_new(), $
        frmt_user:ptr_new(), $
        param_types:ptr_new(), $
        float_format:string(replicate(32B,128)), $
        format_string:string(replicate(32B,1028)), $
        format_header:string(replicate(32B,1028)), $
        index_header:0, $
        list_header:0, $
        column_name:0, $
        index_value:0, $
        list_value:0, $
        column_type:0, $
        more_format:0, $
        tmp_row:ptr_new(), $
        tmp_lines:ptr_new(), $
        num_tmp_lines:0L,  $
        max_tmp_lines:0L $
    }

END

;+
; Class Constructor
; @private
;-
FUNCTION ROWS_INDEX_SECTION::init, filename


    if n_elements(filename) ne 0 then begin
        r = self->INDEX_FILE_SECTION::init("rows", filename)
    endif else begin    
        r = self->INDEX_FILE_SECTION::init("rows")
    endelse
  
    if r eq 1 then begin
        self.rows = ptr_new(/allocate_heap)
        self.frmt = ptr_new(/allocate_heap)
        self.frmt_quiet = ptr_new(/allocate_heap)
        self.frmt_user = ptr_new(/allocate_heap)
        self.param_types = ptr_new(/allocate_heap)
    endif

    ; specifies the meaning of the columns in the giant format array
    self.index_value  = 0
    self.list_value   = 1
    self.column_name  = 2
    self.index_header = 3
    self.list_header  = 4
    self.column_type  = 5
    
    ; rows section are the last sections in the file
    self.allow_append = 1

    ; set printing to be in the 'more' format
    self.more_format = 1

    self.max_tmp_lines = 1000L
    self.tmp_row = ptr_new(replicate(self->get_row_info_strct(),self.max_tmp_lines),/no_copy)
    self.tmp_lines = ptr_new(strarr(self.max_tmp_lines),/no_copy)
 
    return, r

END

;+
; Class Destructor
; @private
;-
PRO ROWS_INDEX_SECTION::cleanup
    compile_opt idl2, hidden
    
    self->INDEX_FILE_SECTION::cleanup

    if ptr_valid(self.rows) then ptr_free, self.rows
    if ptr_valid(self.frmt) then ptr_free, self.frmt
    if ptr_valid(self.param_types) then ptr_free, self.param_types
    if ptr_valid(self.frmt_quiet) then ptr_free, self.frmt_quiet
    if ptr_valid(self.frmt_user) then ptr_free, self.frmt_user
    if ptr_valid(self.tmp_row) then ptr_free, self.tmp_row
    if ptr_valid(self.tmp_lines) then ptr_free, self.tmp_lines
    
END    

;+
; Creates rows section, but writes no actual rows to it, just the section marker,
; and the format_header ("#INDEX  FILES  etc..").
;-
PRO ROWS_INDEX_SECTION::create
    compile_opt idl2, hidden

    self->INDEX_FILE_SECTION::create, lines=self.format_header, /append, /not_in_memory

END

;+
; Retrieves the pointer to the array of structures that mirror the
; lines in the row section.  Be sure to NOT delete this pointer.
; @returns pointer to array of structures that mirror the lines in the
; row section.
;-
FUNCTION ROWS_INDEX_SECTION::get_rows_ptr
    if self.section_read eq 0 then message, "cannot get_rows_ptr, must read section first"
    return, self.rows
END

;+ 
; Retrieves the number of rows in the rows section, not counting the marker
; and the format header
; @returns  number of rows in the rows section
;-
FUNCTION ROWS_INDEX_SECTION::get_num_rows

    ; there is the section marker and the header to take into account
    ;return, self.num_lines - 2
    if ptr_valid(self.rows) then begin
        return, n_elements(*self.rows)
    endif else begin
        return, 0
    endelse
    
END

;+
; Procedure to process each line.  Invoked by
; index_file_section::read_file. 
; @param line {in}{required}{type=string} The line to handle.
; @param index {in}{required}{type=integer} The index number for this
; line - ignored here because of underlying assumptions.
;-
PRO ROWS_INDEX_SECTION::process_line, line, index
    compile_opt idl2, hidden

    (*self.tmp_lines)[self.num_tmp_lines] = line
    self.num_tmp_lines += 1
    if (self.num_tmp_lines ge self.max_tmp_lines) then begin
        fmt = self.format_string

        ; buffer is full, process it
        reads, *self.tmp_lines, *self.tmp_row, format=fmt
        ; trust in index
        offset = index / self.max_tmp_lines
        first = offset * self.max_tmp_lines
        last = first+self.max_tmp_lines-1
        (*self.rows)[first:last] = *self.tmp_row
        self.num_tmp_lines = 0L
    endif
END

;+
; Reads the rows section into memory, then converts all lines (array of strings)
; into row structures
; @uses INDEX_FILE_SECTION::read_file()
; @keyword max_nrows {in}{optional}{type=long} Maximum number of rows to
; read.
;-
FUNCTION ROWS_INDEX_SECTION::read_file, max_nrows = max_nrows
    compile_opt idl2, hidden

    if ptr_valid(self.rows) then ptr_free, self.rows
    if keyword_set(max_nrows) then useMaxNrows = max_nrows else useMaxNrows = long(2LL^31-1)
    nlines = min([self->count_section_lines(),useMaxNrows])

    if nlines gt 0 then begin
        self.rows = ptr_new(replicate((*self.tmp_row)[0],nlines),/no_copy)
    endif else begin
        self.rows = ptr_new(/allocate_heap)
    endelse

    result = self->INDEX_FILE_SECTION::read_file(max_nrows=useMaxNrows)

    if (self.num_tmp_lines ne 0) then begin
        fmt = self.format_string
        ; more to convert
        *self.tmp_lines = (*self.tmp_lines)[0:(self.num_tmp_lines-1)]
        *self.tmp_row =(*self.tmp_row)[0:(self.num_tmp_lines-1)]
        reads, *self.tmp_lines, *self.tmp_row, format=fmt
        ; trust in nlines
        offset = (nlines-1) / self.max_tmp_lines
        first = offset * self.max_tmp_lines
        last = first+self.num_tmp_lines-1
        (*self.rows)[first:last] = *self.tmp_row
        self.num_tmp_lines = 0L

        *self.tmp_lines = strarr(self.max_tmp_lines)
        *self.tmp_row = replicate((*self.tmp_row)[0],self.max_tmp_lines)
    endif

    ; get rid of annoying white space
    if result ne -1 then begin
        ; truncate if necessary, shouldn't be
        if (n_elements(*self.rows) ne self.num_lines) then begin
            *self.rows = (*self.rows)[0:(self.num_lines-1)]
        endif
        self->trim_row_whitespace, *self.rows
    endif else begin
        ; bad result, possibly no lines to read, free pointer and reset to simple from the heap
        ptr_free, self.rows
        self.rows = ptr_new(/allocate_heap)
    endelse

    return, result

END

;+
; Uses format array to create format strings for printing/reading index file.
; Results get stored in object fields: format_string, format_header 
; For the named idField, return the start of that field in the format
; string and the length of that field in idStart and idLen.
; @private
;-
PRO ROWS_INDEX_SECTION::create_formats, idField, idStart, idLen
    compile_opt idl2

    frmt = *self.frmt
    frmt_quiet = *self.frmt_quiet
    
    ; how many keywords?
    sz = size(frmt)
    frmt_len = sz[2]
    
    ; build the format strings used for reading/writing index file
    param_types = strarr(2,frmt_len)
    header_keywords = strarr(frmt_len)
    data_format='('
    header_format='('
    idStart = 0
    idLen = -1
    for i=0,frmt_len-1 do begin
        thisFrmt= frmt[*,i]
        name = frmt[self.column_name,i]
        if strmid(name,0,1) eq "#" then name=strmid(name,1,strlen(name)-1)
        if (i ne 0) then begin 
            data_format += ',1x,'
            header_format += ',1x,'
            if idLen lt 0 then idStart += 1
        endif 
        data_format += frmt[self.index_value,i]
        if idLen lt 0 then begin
           frmtLen = long(strmid(frmt[self.index_value,i],1))
           if name eq idField then begin
              idLen = frmtLen
           endif else begin
              idStart += frmtLen
           endelse
        endif
        header_format += frmt[self.index_header,i]
        header_keywords[i] = frmt[self.column_name,i]
        param_types[0,i] = name
        param_types[1,i] = frmt[self.column_type,i] 
    endfor    

    data_format+=')'
    header_format+=')'
    
    header = string(header_keywords,format=header_format)

    ; save off the format strings used for print/reading index file
    self.format_string = data_format
    self.format_header = header
    *self.param_types = param_types

END

;+
; Returns the 2-N array of parameter names and their syntax types
; @private
;-
FUNCTION ROWS_INDEX_SECTION::get_param_types
    return, *self.param_types
END

;+
; Prints the rows section of the index file for those rows specified.
; Columns keyword overrieds, verobse, and user.  User keyword overrides verbose.
; If no keywords are set, the default mode is 'quiet', where just a handfull of columns
; are listed.
; The column names used with the columns keywords must be exact matches.  Use list_available_columns 
; to see what the choices are.
; To use the user keyword, first set the user colums using set_user_columns.
;
; @keyword rows {in}{optional}{type=array} the row numbers which are to be printed
; @keyword verbose {in}{optional}{type=boolean} set to true and ALL info on each row is printed
; @keyword columns {in}{optional}{type=array} array of column names to print (must contain exact matches)
; @keyword user {in}{optional}{type=boolean} set to true and only the
; columns selected by user are listed
; @keyword file {in}{optional}{type=string}{default=/dev/tty} The file
; to write to.  Defaults to the current screen, using "more" to page
; the output.
;-
PRO ROWS_INDEX_SECTION::list, rows=rows, verbose=verbose, columns=columns, user=user, file=file
    compile_opt idl2
    
    if self.debug then begin
        print, "list mode: "
        if keyword_set(verbose) then print, "verbose" else print, "not verbose"
        if keyword_set(user) then print, "user" else print, "not user"
        if n_elements(columns) ne 0 then print, "columns" else print, "no columns"
    endif

    if (self.section_read) eq 0 then begin
        message, 'cannot list rows until index file is loaded.  Use read_file method'
        return
    endif
    
    if (n_elements(rows) eq 0) then rows=lindgen(n_elements(*self.rows)) 

    ; columns keyword overides everything
    if n_elements(columns) ne 0 then begin
        self->list_columns_by_name, rows=rows, columns, file=file
    endif else begin
        ; user keyword overrides the rest
        if keyword_set(user) then begin
            self->list_columns_by_user, rows=rows, file=file
        endif else begin
            ; either verbosity is on, or no keywords used
            if keyword_set(verbose) then begin
                self->list_all_columns, rows=rows, file=file
            endif else begin
                ; default: quiet listing
                self->list_quiet, rows=rows, file=file
            endelse
        endelse
    endelse
    
    
END

;+
; Lists only those rows and column names passed to it.
;
; @keyword rows {in}{optional}{type=array} the row numbers which are to be printed
; @param column_names {in}{required}{type=array} array of column
; names to print (must contain exact matches)
; @keyword file {in}{optional}{type=string}{default=/dev/tty} The file
; to write to.  Defaults to the current screen, using "more" to page
; the output.
;-
PRO ROWS_INDEX_SECTION::list_columns_by_name, rows=rows, column_names, file=file
    compile_opt idl2
    
    if (self.section_read) eq 0 then begin
        message, 'cannot list rows until index file is loaded.  Use read_file method'
        return
    endif

    if (n_elements(column_names) eq 0) then $
        message, "must specify columns to print on listing"
        
    if (n_elements(rows) eq 0) then rows=lindgen(n_elements(*self.rows)) 

    ; get the indicies for each column named
    col_indicies = lonarr(n_elements(column_names))
    for i=0,n_elements(column_names)-1 do begin
        col_indicies[i] = self->get_format_index(strupcase(column_names[i]))
        if col_indicies[i] eq -1 then $
            message, "column was not found, cannot list: "+column_names[i]
    endfor
    
    self->list_columns_by_index, rows=rows, col_indicies, file=file

END    

;+
; Lists only those columns previously set by user, using set_user_columns. 
;
; @keyword rows {in}{optional}{type=array} the row numbers which are to be printed
; @keyword file {in}{optional}{type=string}{default=/dev/tty} The file
; to write to.  Defaults to the current screen, using "more" to page
; the output.
;-
PRO ROWS_INDEX_SECTION::list_columns_by_user, rows=rows, file=file
    compile_opt idl2
    
    if (self.section_read) eq 0 then begin
        message, 'cannot list rows until index file is loaded.  Use read_file method'
        return
    endif

    if ptr_valid(self.frmt_user) eq 0 then begin
        message, "user must specify columns for listing first", /info
        return
    endif    

    if n_elements(*self.frmt_user) eq 0 then begin
        message, "user must specify columns for listing first", /info
        return
    endif
    
    if (n_elements(rows) eq 0) then rows=lindgen(n_elements(*self.rows)) 

    self->list_columns_by_index, *self.frmt_user, rows=rows, file=file
    
END    

;+
; Lists ALL the columns. 
;
; @keyword rows {in}{optional}{type=array} the row numbers which are to be printed
; @keyword file {in}{optional}{type=string}{default=/dev/tty} The file
; to write to.  Defaults to the current screen, using "more" to page
; the output.
;-
PRO ROWS_INDEX_SECTION::list_all_columns, rows=rows, file=file
    compile_opt idl2
    
    if (self.section_read) eq 0 then begin
        message, 'cannot list rows until index file is loaded.  Use read_file method'
        return
    endif

    if (n_elements(rows) eq 0) then rows=lindgen(n_elements(*self.rows)) 

    ; get the number of columns
    sz = size(*self.frmt)
    ncols = sz[2]
    all_indicies = lindgen(ncols)

    self->list_columns_by_index, all_indicies, rows=rows, file=file
    
END

;+
; Lists only a handfull of statically determined columns. 
;
; @keyword rows {in}{optional}{type=array} the row numbers which are to be printed
; @keyword file {in}{optional}{type=string}{default=/dev/tty} The file
; to write to.  Defaults to the current screen, using "more" to page
; the output.
;-
PRO ROWS_INDEX_SECTION::list_quiet, rows=rows, file=file
    compile_opt idl2
    
    if (self.section_read) eq 0 then begin
        message, 'cannot list rows until index file is loaded.  Use read_file method'
        return
    endif

    if ptr_valid(self.frmt_quiet) eq 0 then begin
        message, "user must specify columns for listing first", /info
        return
    endif    
    
    if (n_elements(rows) eq 0) then rows=lindgen(n_elements(*self.rows)) 

    self->list_columns_by_index, *self.frmt_quiet, rows=rows, file=file
    
END    

;+
; Returns index of format specification according to header name
; @param frmt_header {in}{required}{type=string} header keyword: must match exactly with what list prints.
; @private
;-
FUNCTION ROWS_INDEX_SECTION::get_frmt_index, frmt_header
    compile_opt idl2

    ind = -1
    frmt = *self.frmt
    sz = size(frmt)
    for i=0,sz[2]-1 do begin
        if (strtrim(frmt[self.column_name,i],2) eq strtrim(frmt_header,2)) then ind = i
    endfor
    return, ind

END

;+
; Uses the objects format array to build a string for one formated header word
; @param frmt_header {in}{required}{type=string} header keyword: must match exactly with what list prints.
; @private
;-
FUNCTION ROWS_INDEX_SECTION::get_frmt_header_keyword, frmt_header
    compile_opt idl2
    
    i = self->get_frmt_index(frmt_header)
    if (i eq -1) then message, "Cannot find format for header: "+frmt_header
    return, string((*self.frmt)[self.column_name,i],format='('+(*self.frmt)[self.index_header,i]+')')
    
END

;+
; Uses the objects format array to build a formated string of a value from the index file
; @param frmt_header {in}{required}{type=string} header keyword: must match exactly with what list prints.
; @param row {in}{required}{type=struct} structure reflecting one row from the index file 
; @private
;-
FUNCTION ROWS_INDEX_SECTION::get_frmt_row_value, frmt_header, row
    compile_opt idl2
    
    i = self->get_frmt_index(frmt_header)
    if (i eq -1) then message, "Cannot find format for header: "+frmt_header
    return, string(row.(i),format='('+(*self.frmt)[self.index_value,i]+')')
    
END

;+
; Writes the information in rows_structs to the index file using the
; current self.format_string.
; @param row_strcts {in}{required}{type=struct array} the index values to
; write, in the same order as expected by the format string, one
; row_strcts element for each line to be written.
; @private
;-
PRO ROWS_INDEX_SECTION::write_rows, row_strcts
    compile_opt idl2, hidden

    lines = strarr(n_elements(row_strcts))
    
    ; translate the structs to string lines
    for i=0,n_elements(lines)-1 do begin
        fmt = self.format_string
        lines[i] = string(row_strcts[i],format=fmt) 
    endfor

    ; write the string lines to file
    self->append_lines, lines

    ; update the structures in memory
    if (n_elements(*self.rows) eq 0) then begin
        *self.rows = row_strcts
    endif else begin
        *self.rows = [*self.rows,row_strcts]
    endelse
END    

;+
; Retrieves the line number in the file of a row with the given index number
;
; @param index_num {in}{required}{type=long} index number of row for which the line number is returned
; @param row_index {out}{optional}{type=long} the index into the array of lines this index number is found
; @returns the line number (zero based) in the file where this index number is located
;-
FUNCTION ROWS_INDEX_SECTION::get_line_number, index_num, row_index
    compile_opt idl2, hidden

    indicies = (*self.rows).index

    cnt = 0
    row_index = where(indicies eq index_num, cnt)

    if cnt gt 1 then message, "index numbers must be unique: "+string(index_num)

    ; return the file line number of the index found
    if cnt eq 0 then begin
        return, -1
    endif else begin    
        return, (*self.line_nums)[row_index] 
    endelse
    
END    

;+
; Overwrites a row in the index with a new one
; 
; @param index_num {in}{required}{type=long} index number of row which is to be overwritten
; @param row {in}{required}{type=struct} new row to write in index file at index_num
;
; @uses get_line_number
;-
PRO ROWS_INDEX_SECTION::overwrite_row, index_num, row
    compile_opt idl2, hidden

    line_number = self->get_line_number(index_num,row_index)

    if line_number eq -1 then message, "cannot overwrite row, index not found: "+string(index_num)

    fmt = self.format_string
    new_line = string(row,format=fmt)

    ; write the new line to file and keep memory in sync
    self->set_line, line_number, new_line
    (*self.rows)[row_index] = row
    
END

;+
; Overwirtes a specific value in a row within the index file
; 
; @param index_num  {in}{required}{type=long} index number of row which is to be overwritten
; @param column_name {in}{required}{type=string} column in row which is to be overwritten
; @param value {in}{required}{type=varies} value to place in row.
;
; @uses overwrite_row
;-
PRO ROWS_INDEX_SECTION::overwrite_row_column, index_num, column_name, value
    compile_opt idl2, hidden
    
    ; get the row index of the given file index number
    indicies = (*self.rows).index
    cnt = 0
    row_index = where(indicies eq index_num, cnt)
    if cnt eq 0 then message, "index number not in index file: "+string(index_num)
    if cnt gt 1 then message, "index numbers in index file must be unique: "+string(index_num)
    
    ; get a copy of the row we are going to write to, and the index of it's tag
    row = (*self.rows)[row_index]
    column_name = strtrim(strupcase(column_name),2)
    tag_index = where(column_name eq tag_names(row))
    if tag_index eq -1 then message, "row does not contain tag: "+column_name

    ; set the value in the column of the row
    row.(tag_index) = value
    ; now overwrite the old colum with this new one
    self->overwrite_row, row.index, row
    
END    

;+
;   Sets the object to print rows using the interactive 'more' format 
;-
PRO ROWS_INDEX_SECTION::set_more_format_on
    compile_opt idl2, hidden

    self.more_format = 1

END    

;+
;   Sets the object NOT to print rows using the interactive 'more' format 
;-
PRO ROWS_INDEX_SECTION::set_more_format_off
    compile_opt idl2, hidden

    self.more_format = 0

END

;+
;  Prints a line either to stdout, or using the interactive 'more' format
;  The choice to use more or not is now handled elsewhere.  If lun is
;  not supplied, -1 is used (stdout).
;-
PRO ROWS_INDEX_SECTION::print_line, line, lun, _EXTRA=ex
    compile_opt idl2, hidden

    thislun = -1
    if n_elements(lun) ne 0 then thislun = lun
    printf, thislun, line, _EXTRA=ex

END

;+
;  Prints the available columns for list; these are also the valid search keywords
;-
PRO ROWS_INDEX_SECTION::list_available_columns
    compile_opt idl2, hidden

    ; how many keywords?
    sz = size(*self.frmt)
    frmt_len = sz[2]
    
    if self.more_format then begin
       openw, out, '/dev/tty', /get_lun, /more
    endif
    
    ; print each keyword, in more format, if set
    for i=0,frmt_len-1 do begin
        column_name = (*self.frmt)[self.column_name,i]
        ; don't print the comment marker at the begining of INDEX
        if strmid(column_name,0,1) eq '#' then begin
            column_name = strmid(column_name,1,strlen(column_name)-1)
        endif
        ; or the one that might be at the end of INDEX
        if strmid(column_name,0,1,/reverse_offset) eq '#' then begin
            column_name = strmid(column_name,0,strlen(column_name)-1)
        endif
        self->print_line, column_name, out
    endfor

    if self.more_format then begin
       free_lun, out
     endif


END

;+
;  Prints the columns currently selected for the user specified listing
;-
PRO ROWS_INDEX_SECTION::list_user_columns
    compile_opt idl2, hidden
    
    if ptr_valid(self.frmt_user) eq 0 then begin
        message, "user must specify columns for listing first", /info
        return
    endif    

    if n_elements(*self.frmt_user) eq 0 then begin
        message, "user must specify columns for listing first", /info
        return
    endif

    frmt_user = *self.frmt_user
    
    format_header_user = ""
    for i=0,n_elements(frmt_user)-1 do begin
        if i ne 0 then format_header_user += " "
        format_header_user += (*self.frmt)[self.column_name,frmt_user[i]]
    endfor
    print, format_header_user

END    

;+
;  Extracts just the keywords from the format array
;  @returns keywords from the format array
;-
FUNCTION  ROWS_INDEX_SECTION::get_format_keywords
    compile_opt idl2, hidden

    ; how many keywords in format?
    sz = size(*self.frmt)
    nkeys = sz[2]

    return, (*self.frmt)[self.column_name,0:(nkeys-1)]

END

;+
;  Find the index for a keyword in the format array
;  @ returns the index for the given keyword; -1 if not found
;-
FUNCTION ROWS_INDEX_SECTION::get_format_index, keyword
    compile_opt idl2, hidden

    cnt = 0
    index = where(keyword eq self->get_format_keywords(), cnt)

    ; special case: #INDEX
    if keyword eq "INDEX" then index = 0

    return, index
    
END

;+
;  Adds a column to the list of user columns
;-
PRO ROWS_INDEX_SECTION::add_user_column, column
    compile_opt idl2, hidden

    index = self->get_format_index(column) 
    
    if index eq -1 then $
        message, "keyword: "+column+" does not exist, cannot be added"

    if ptr_valid(self.frmt_user) then begin
        if n_elements(*self.frmt_user) ne 0 then begin
            *self.frmt_user = [*self.frmt_user, index]
        endif else begin
            *self.frmt_user = [index]
        endelse
    endif else begin    
        *self.frmt_user = [index]
    endelse

END

;+
;  Sets what columns should be used for user listing
;  @param columns {in}{required}{type=string array} array of columns to print on list command
;-
PRO ROWS_INDEX_SECTION::set_user_columns, columns
    compile_opt idl2, hidden

    ; we are resetting this, so clear it
    if ptr_valid(self.frmt_user) then ptr_free, self.frmt_user
    self.frmt_user = ptr_new(/allocate_heap)
    
    for i=0,n_elements(columns)-1 do begin
        self->add_user_column, columns[i]
    endfor

END
;+
;  Returns the available columns for list; these are also the valid search keywords
;-
FUNCTION ROWS_INDEX_SECTION::get_available_columns
    compile_opt idl2, hidden

    ; how many keywords?
    sz = size(*self.frmt)
    frmt_len = sz[2]
    
    cols = strarr(frmt_len)
    
    ; print each keyword, in more format, if set
    for i=0,frmt_len-1 do begin
        column_name = (*self.frmt)[self.column_name,i]
        ; don't print the comment marker at the begining of INDEX
        if strmid(column_name,0,1) eq '#' then begin
            column_name = strmid(column_name,1,strlen(column_name)-1)
        endif
        ; or the # that might be at the end of INDEX
        if strmid(column_name,0,1,/reverse_offset) eq '#' then begin
            column_name = strmid(column_name,0,strlen(column_name)-1)
        endif
        cols[i] = column_name
    endfor
    
    return, cols

END

;+
;  For reading into memory the new rows that may have been written to the 
;  index file ( by hand, or by an online process ).  
;  Jumps to previous last line, and reads new rows.
;  @param num_new_lines {out}{optional}{type=long} number of new lines
;  found in file
;  @keyword max_nrows {in}{optional}{type=long} maximum number of
;  total lines when finished. 
;-
PRO ROWS_INDEX_SECTION::read_new_rows, num_new_lines, max_nrows=max_nrows
    compile_opt idl2, hidden

    num_new_lines = 0

    ; see if we should just read it
    if self.section_read eq 0 then begin
        self->read_file
        return
    endif

    max_new_lines = -1
    if keyword_set(max_nrows) then begin
        max_new_lines = max_nrows - self.num_lines
    endif
    if max_new_lines eq 0 then return
    
    ; read file untill we get to the 'rows' section
    openr, lun, self.filename, /get_lun
    
    line_num = 0L
    line = ''
    section = "[" + self.section_marker + "]"
    while strtrim(line) ne section and eof(lun) ne 1 do begin
        readf, lun, line
        line_num += 1L
    endwhile
    
    if strtrim(line) ne section then begin
        message, "file does not contain rows section marker: "+self.filename
        return
    endif
    
    if self.debug then print, "num lines up to [rows]: ", line_num

    ; read in the previous number of rows, + the header 
    line = ''
    num_lines_read = 0L
    while num_lines_read lt n_elements(*self.rows)+1 do begin
        if eof(lun) then begin
            message, "got to end of file before number of lines: "+string(self.num_lines)
        endif
        readf, lun, line
        line_num += 1L
        num_lines_read += 1L
    endwhile
    
    if self.debug then print, "num lines up to previous lines: ", line_num
    
    ; now read in these new lines
    line = ''
    num_lines_read = 0L
    lines = strarr(self.lines_incr)
    line_nums = lonarr(self.lines_incr)
    while eof(lun) ne 1 do begin
        readf, lun, line
        if num_lines_read ge n_elements(lines) then begin
            lines = [lines,strarr(self.lines_incr)]
            line_nums = [line_nums,lonarr(self.lines_incr)]
        endif
        lines[num_lines_read] = line
        line_nums[num_lines_read]=line_num
        line_num += 1L
        num_lines_read += 1L
        if max_new_lines gt 0 and num_lines_read ge max_new_lines then break
        if num_lines_read lt 0 then begin
            message,'Number of index file rows exceeds largest long integer, can not continue.'
        endif
    endwhile
    ; free unused portions of arrays
    if (num_lines_read gt 0) then begin
        lines = lines[0:(num_lines_read-1)]
        line_nums = line_nums[0:(num_lines_read-1)]
    endif    

    ; free_lun also closes it
    free_lun, lun
   
    if self.debug then print, "total lines read: ", line_num
    if self.debug then print, "new lines read: ", num_lines_read
    
    num_new_lines = num_lines_read 

    if num_new_lines lt 1 then return

    ; convert the new lines to new row structures
    rows = make_array(num_lines_read,value=self->get_row_info_strct())
    reads,lines, rows, format=self.format_string
    ; get rid of annoying white space from file
    self->trim_row_whitespace, rows
    
    ; update the objects memory
    *self.line_nums = [*self.line_nums,line_nums]
    self.num_lines += num_lines_read
    *self.rows = [*self.rows,rows]

END

;+
; General method for listing columns based off the indicies passed to it.
; Responsible for formatting each column according to the default
; or special formatting used.
; @param col_indicies {in}{required}{type=array} indicies of the columns to list
; @keyword rows {in}{optional}{type=array} the row numbers which are to be printed
; @keyword file {in}{optional}{type=string}{default=/dev/tty} The file
; to write to.  Defaults to the current screen, using "more" to page
; the output.
;-
PRO ROWS_INDEX_SECTION::list_columns_by_index, col_indicies, rows=rows, file=file
    compile_opt idl2, hidden

    row_info = *self.rows
    
    ; if specific rows aren't specied, print them all
    if n_elements(rows) eq 0 then rows = lindgen(n_elements(row_info))

    ; build the format strings used for listing index 
    header_keywords = strarr(n_elements(col_indicies))
    header_format='('
    for i=0,n_elements(col_indicies)-1 do begin
        if (i ne 0) then begin 
            header_format += ',1x,'
        endif    
        header_format += (*self.frmt)[self.list_header,col_indicies[i]]
        header_keywords[i] = (*self.frmt)[self.column_name,col_indicies[i]]
        ; remove any trailing # - #INDEX#
        if strmid(header_keywords[i],0,1,/reverse_offset) eq "#" then begin
           header_keywords[i] = strmid(header_keywords[i],0,strlen(header_keywords[i])-1)
        endif
    endfor    
    header_format+=')'    
    
    header = string(header_keywords,format=header_format)

    ; print using 'more' format
    usemore = 0
    fileout=''
    if n_elements(file) eq 0 then begin
        if self.more_format then begin
            usemore = 1
            fileout='/dev/tty'
        endif
    endif else begin
        fileout=file
    endelse

    if strlen(fileout) gt 0 then begin
        openw, out, fileout, /get_lun, more=usemore
    endif else begin
        ; just write to stdout, without using more
        out = -1
    endelse

    ; print the header
    self->print_line, header, out
    for i = 0L, (n_elements(rows)-1) do begin
        ; get the next row
        r = row_info[rows[i]]
        ; append default values
        line = ''
        for j=0,n_elements(col_indicies)-1 do begin
            if (j ne 0) then line += ' '
            line += self->get_formatted_values(r.(col_indicies[j]),(*self.frmt)[self.list_value,col_indicies[j]])
        endfor
        ; print the row
        self->print_line, line, out
    endfor    
    if out ne -1 then begin
        free_lun, out
        if n_elements(file) gt 0 then begin
            if strlen(file) gt 0 then print, 'Listing written to : ', file
        endif
    endif
    
END

;+
;  Returns a string representation of the value passed in, using the passed in format
;  If the given format is not recognized as a special formatting function, then
;  it is assumed it is simply an IDL format string
;  
;  @param value {in}{required}{type=any} value to be returned as a formated string
;  @param frmt {in}{required}{type=string} format to be used on value -either a function name or an IDL format string
;
;  @returns string representing the formatted value
;-
FUNCTION ROWS_INDEX_SECTION::get_formatted_values, value, frmt
    compile_opt idl2, hidden

    ; switch off the type of formatting passed in
    case frmt of
        'sexigesimal': val = self->format_sexigesimal(value)
        'sexigesimal_ra': val = self->format_sexigesimal_ra(value)
        'sex_degrees': val = self->format_sexigesimal_degrees(value)
        'source_name': val = self->format_source_name(value) 
        'dateobs'    : val = self->format_dateobs(value)
        'file_name'  : val = self->format_file_name(value)
        else: val = string(value,format='('+frmt+')') 
    endcase    
    
    return, val
END

FUNCTION ROWS_INDEX_SECTION::format_source_name, source
    compile_opt idl2, hidden

    if strlen(source) gt 16 then source = strmid(source,0,15) + "*"
    source = string(source,format='(a16)')

    return, source
END  

FUNCTION ROWS_INDEX_SECTION::format_file_name, filename
    compile_opt idl2, hidden

    if strlen(filename) gt 32 then filename = strmid(filename,0,31) + "*"
    filename = string(filename,format='(a32)')

    return, filename
END  
FUNCTION  ROWS_INDEX_SECTION::format_sexigesimal, value
    compile_opt idl2, hidden

    value = adstring(value)
    value = string(value,format='(a12)')
    
    return, value
END

FUNCTION  ROWS_INDEX_SECTION::format_sexigesimal_ra, value
    compile_opt idl2, hidden

    value = adstring(value/15.0)
    value = string(value,format='(a12)')
    
    return, value
END

FUNCTION  ROWS_INDEX_SECTION::format_sexigesimal_degrees, value
    compile_opt idl2, hidden

    value = adstring(value/3600.0)
    value = string(value,format='(a12)')
    
    return, value
END

FUNCTION  ROWS_INDEX_SECTION::format_dateobs, value
    compile_opt idl2, hidden

    parts = strsplit(value, "T", /extract)
    if n_elements(parts) gt 1 then begin
        value = parts[1] + " " + parts[0] 
        return, string(value,format='(a23)')
    endif else begin
        return, value
    endelse

END    

FUNCTION ROWS_INDEX_SECTION::get_format_string
  compile_opt idl2, hidden

  return, self.format_string
END
