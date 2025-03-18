;+
; This is the base class for managing a section in an index file.  Sections are
; started with a line: '[section_name]'.  This class manages all basic i/o functions
; for a section.
; See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes
;
; @file_comments
; This is the base class for managing a section in an index file.  Sections are
; started with a line: '[section_name]'.  This class manages all basic i/o functions
; for a section.
; See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes
;
; @field lines_incr number of lines that buffers grow by
; internally as necessary.  Placed here for consistency only.
; @field max_line_width maximum number of chars allowed on each line
; @field num_lines the current number of lines in this section
; @field filename full pathname to the file where this section resides
; @field section_marker name of section
; @field line_nums pointer to an array of indicies locating each line in file (line #s zero based)
; @field all_lines pointer to an array holding all lines in this
;        section - not normally used except during testing.  Derived classes
;        should NOT rely on this.
; @field section_read boolean flag for wether section is in memory or not
; @field allow_append boolean flag for wether this section allows appends
; @field pad_width boolean flag determines wether lines are padded to max width
; @field debug boolean flag for wether this class is verbose or not
;
; @private_file
;-
PRO index_file_section__define

    ifs = { INDEX_FILE_SECTION,  $
        lines_incr:0L, $
        max_line_width:0L, $
        num_lines:0L, $  ; does not include section marker
        filename: string(replicate(32B,256)), $
        section_marker: string(replicate(32B,6)), $  ; [section_marker]
        line_nums:ptr_new(), $ ; line numbers zero-based
        all_lines:ptr_new(), $ ; only used during test
        section_read:0L, $
        allow_append:0L, $
        pad_width:0L, $
        debug:0L $
    }

END

;+
; Class Constructor
; @private
;-
FUNCTION INDEX_FILE_SECTION::init,  section, filename
    compile_opt idl2, hidden
    
    self.section_marker = section
    if n_elements(filename) ne 0 then self.filename = filename

    self.lines_incr = 100000L
    self.max_line_width = 256L
    
    self.line_nums = ptr_new(/allocate_heap)

    self.debug = 0
    return, 1

END

;+
; Class Destructor
; @private
;-
PRO INDEX_FILE_SECTION::cleanup
    compile_opt idl2, hidden

    if ptr_valid(self.line_nums) then ptr_free,self.line_nums
    if ptr_valid(self.all_lines) then ptr_free,self.all_lines
    
END

;+
; Sets file name of file to be written to
; @param file_name {in}{type=string} name of index file
;-
PRO INDEX_FILE_SECTION::set_file_name, file_name
    compile_opt idl2, hidden
    self.filename = file_name
END

;+
; Sets object to pad lines written with spaces to their max width
;-
PRO INDEX_FILE_SECTION::pad_width_on
    compile_opt idl2, hidden
    self.pad_width = 1
END    

;+
; Sets object to NOT pad lines written with spaces to their max width
;-
PRO INDEX_FILE_SECTION::pad_width_off
    compile_opt idl2, hidden
    self.pad_width = 0
END    
;+
; Creates the section in the file.
; 
; @param start_line_number {in}{optional}{type=long} what line to start section on in file
; @keyword lines {in}{optional}{type=string array} array of lines to be written in section upon creation (does not include section marker).
; @keyword append {in}{optional}{type=bool} exclusive with start_line_number: if set, lines get written at end of section
;
;-
PRO INDEX_FILE_SECTION::create, start_line_number, lines=lines, append=append, not_in_memory=not_in_memory
    compile_opt idl2, hidden

    if keyword_set(append) then begin
        ; we need to know how many lines currently in the file,
        ; HACK HACK HACK: for now determin this
        ;openu, lun, self.filename, /append
        openu,lun, self.filename, /get_lun
        tmp = ''
        num_lines=0
        while eof(lun) eq 0 do begin
            readf, lun, tmp
            num_lines = num_lines+1
        endwhile
        start_line_number = num_lines
    endif else begin    
        ; open file and position pointer for writing
        openu, lun, self.filename, /get_lun
        self->go_to_line, start_line_number, lun
    endelse

    inMemory = 1
    if keyword_set(not_in_memory) then inMemory=0
    
    printf, lun, '['+self.section_marker+']'

    if keyword_set(lines) then begin
        ; print them to the file
        for i=0,n_elements(lines)-1 do begin
            line = lines[i]
            if self.pad_width then line = self->pad_line(line)
            printf, lun, line
        endfor
        if inMemory then begin
                                ; get memory in sync with lines written
           self.num_lines = n_elements(lines)
                                ; take into account the section marker written above when 
                                ; calculating the line numbers for each line
           if n_elements(start_line_number) ne 0 then begin
              *self.line_nums = lindgen(self.num_lines)+start_line_number+1
           endif else begin    
              *self.line_nums = lindgen(self.num_lines)+1
           endelse
        endif

    endif

    ; this will also close this lun
    free_lun, lun

    self.section_read = 1

END

;+
; Adds extra blank characthers to end of given line, if this line is less
; then the max line width.
;
; @param line {in}{required}{type=string} line to pad
; @returns string with added blank chars to make it the max line width
;-
FUNCTION INDEX_FILE_SECTION::pad_line, line
    compile_opt idl2, hidden

    if strlen(line) lt self.max_line_width then begin
        dif = self.max_line_width - strlen(line)
        line = line + string(replicate(32B,dif))
    endif

    return, line
    
END

;+
; Tests the validity of the pointer to array of lines in section
; @returns 0 - not valid, 1 -valid
;-
FUNCTION INDEX_FILE_SECTION::has_valid_lines
    compile_opt idl2, hidden

    if not ptr_valid(self.line_nums) then begin
        return, 0
    endif else begin
        if n_elements(*self.line_nums) eq 0 then begin
            return, 0
        endif else begin
            return, 1
        endelse
    endelse    

end

;+
; Tests the validity of the pointer to array of line numbers in section
; @returns 0 - not valid, 1 -valid
;-
FUNCTION INDEX_FILE_SECTION::has_valid_line_numbers
    compile_opt idl2, hidden

    if not ptr_valid(self.line_nums) then begin
        return, 0
    endif else begin
        if n_elements(*self.line_nums) eq 0 then begin
            return, 0
        endif else begin
            return, 1
        endelse
    endelse    

end

;+
; Retrieves the location of each section line in the file
; @param {count}{optional}{type=long} number of line_nums
; @returns integer array which is location of each section line in file
;-
FUNCTION INDEX_FILE_SECTION::get_line_nums, count
    compile_opt idl2, hidden
    
    if ptr_valid(self.line_nums) then begin
        count = n_elements(*self.line_nums)
        if count gt 0 then begin
            return, *self.line_nums
        endif else begin
            return, -1
        endelse
    endif else begin
        count = 0
        return, -1
    endelse

    return, *self.line_nums

END

;+
; Retrieves the number of lines in this section
; @returns long integer - number of lines in the section
;-
FUNCTION INDEX_FILE_SECTION::get_num_lines
    compile_opt idl2

    return, self.num_lines

END

;+
; Increments the number of lines this class believes are in the section.
; @private
;-
PRO INDEX_FILE_SECTION::increment_num_lines
    compile_opt idl2, hidden

    self.num_lines = self.num_lines + 1L

END

;+
; Counts lines in the section, not including the section line itself
; @returns -1 on failure
;-
FUNCTION INDEX_FILE_SECTION::count_section_lines
    compile_opt idl2, hidden

    count = -1L

    openr, lun, self.filename, /get_lun

    done = 0
    reading_section = 0

    line = ""
    
    while (eof(lun) ne 1) and (done eq 0) do begin
        readf,lun,line
        first_char = strmid(line,0,1)
        if (first_char eq '#') or (strlen(line) eq 0) then begin
            ; ignore comments and blank lines
        endif else begin
            if (first_char eq '[') then begin
                ; section marker
                if reading_section then begin
                    ; must be done reading this section
                    done = 1
                endif else begin
                    current_section = strmid(line,1,(strlen(line)-2))
                    if current_section eq self.section_marker then begin
                        reading_section = 1
                        count = 0L
                    endif
                endelse
            endif else begin
                if reading_section then begin
                    count = count + 1L
                    if count lt 0 then begin
                        message,'Number of rows in section exceeds maximum long integer, can not continue'
                    endif
                endif
            endelse
        endelse
    endwhile

    ; free_lun also closes it
    free_lun, lun
    return, count
END

;+
; Retrieves array of lines in section; commented out lines are not
; included.  This only works for testing and it should be replaced by
; the suitable version for any derived class as necessary.
; @param count {out}{optional}{type=long} number of lines returned
; @returns array of lines in section, -1 if no lines
;-
FUNCTION INDEX_FILE_SECTION::get_lines, count
    compile_opt idl2, hidden

    if ptr_valid(self.all_lines) then begin
        count = n_elements(*self.all_lines)
        if count eq 0 then begin
            return, -1
        endif else begin    
            return, *self.all_lines
        endelse    
    endif else begin
        count = 0
        return, -1
    endelse    

END

;+
; Procedure to process each line.  Invoked by
; index_file_section::read_file.  This is a dummy version that must be
; replaced by any derived class wanting to make use of read_file.
; @param line {in}{required}{type=string} The line to handle.
; @param index {in}{required}{type=integer} The index number for this line
;-
PRO INDEX_FILE_SECTION::process_line, line, index
    compile_opt idl2, hidden

    if ptr_valid(self.all_lines) eq 0 then begin
        nlines = self->count_section_lines()
        self.all_lines = ptr_new(strarr(nlines))
    endif

    (*self.all_lines)[index] = line
END


;+
; Reads the file, locates the section, and loads all lines and metainfo
; into objects memory
; @keyword max_nrows {in}{optional}{type=long} Maximum number of rows
; to read.
; @returns 0 - failure, 1 - success
;-
FUNCTION INDEX_FILE_SECTION::read_file, max_nrows = max_nrows
    compile_opt idl2, hidden

    result = 0
    self.section_read = 0

    ; reset pointers
    if ptr_valid(self.line_nums) then ptr_free, self.line_nums
    self.line_nums = ptr_new(/allocate_heap)
    self.num_lines = 0 
    
    maxToRead = -1
    if keyword_set(max_nrows) then maxToRead = max_nrows

    openr, lun, self.filename, /get_lun

    num_lines_read = 0L
    line_nums = lonarr(self.lines_incr) 
    line_num = 0L
    current_section = 'None'
    line = ''
    done = 0
    reading_section = 0
    
    while (eof(lun) ne 1) and (done eq 0) do begin
        readf, lun, line
        if self.debug then print, "read line from file: ", line
        first_char = strmid(line,0,1)
        if (first_char eq '#') or (strlen(line) eq 0) then begin
           ; nothing to do with comments or blank lines
        endif else begin
            if (first_char eq '[') then begin
                ; begining new section
                if reading_section then begin
                    ; if we've been reading a section, then the start of a new
                    ; one means that there's nothing more for us to read
                    done = 1
                endif else begin 
                    current_section = strmid(line,1,(strlen(line)-2))
                    if current_section eq self.section_marker then reading_section = 1
                 endelse    
            endif else begin
                ; we're in a section, is it the right one? 
                if reading_section then begin
                    ; store this line and it's location in the file
                    if self.pad_width then line = strtrim(line, 2)
                    if num_lines_read ge n_elements(line_nums) then begin
                        ; add in another increment
                        line_nums = [line_nums,lonarr(self.lines_incr)]
                    endif
                    self->process_line, line, num_lines_read
                    line_nums[num_lines_read]=line_num
                    num_lines_read = num_lines_read + 1L
                    if maxToRead gt 0 and num_lines_read ge maxToRead then break
                    if (num_lines_read lt 0) then begin
                        ; must be too large for long integer if this happens
                        message,'number of rows in section exceeds maximum long integer, can not continue'
                    endif
                endif           ; if we're in our section    
            endelse             ; if we're starting new section
        endelse                 ; if anything but a comment line
        line_num = line_num + 1L
    endwhile
   
    ; free_lun also closes it
    free_lun, lun

    ; free unused portions of arrays
    if (num_lines_read gt 0) then begin
        line_nums = line_nums[0:(num_lines_read-1)]
    endif    
    
    if (num_lines_read eq 0) then begin
    ;    message, 'no lines found in section'
        return, 0
    endif

    *self.line_nums = line_nums
    self.num_lines = n_elements(*self.line_nums)

    self.section_read = 1

    return, 1

END

;+
; Advances file pointer to right before the line number parameter.  To be used
; to write to a specific line in file.  File must be opened beforehand and closed
; after call.  This is something that idl should provide.
; 
; @param line_number {in}{required}{type=long} line number to go to
; (0-based)
; @param lun {in}{required}{type=integer} Already opened file unit number
;
; @private
;-

PRO INDEX_FILE_SECTION::go_to_line, line_number, lun
    compile_opt idl2, hidden

    line=''
    next_line = 0L

    while (next_line lt line_number) do begin
        if (EOF(lun) ne 1) then begin
            next_line = next_line+1L
            readf, lun, line
        endif else begin
            ; we hit the end of file before we got to our line_number
            message, 'line number exceeds number of rows in file: '+string(line_number)
        endelse    
    endwhile    

END

;+
; Retrurns the index associated with the given location in 
; the file, the line number.
; 
; @param location {in}{required}{type=long} the file line number
;
; @returns the index number associated with that location
;-
FUNCTION INDEX_FILE_SECTION::get_index_by_location, location
    compile_opt idl2, hidden

    ind = where(*self.line_nums eq location, count)
    if count ne 1 then return, -1
    return, ind

END

;+
; Replaces a line already in the index with a new string.
; 
; @param line_number {in}{required}{type=long} the file line number (first line, 
; second line, etc. ) to replace.
; @param line {in}{required}{type=string} new line to place in section
; @param line_index {out}{optional}{type=long} index in array of lines for this section
; specified by line_number
;
;-
PRO INDEX_FILE_SECTION::set_line, line_number, line, line_index
    compile_opt idl2, hidden

    if not self->has_valid_line_numbers() then return
    if not self->has_valid_lines() then return

    if n_elements(line_index) eq 0 then begin
        line_index = where(line_number[0] eq *self.line_nums, cnt)
        if cnt ne 1 then message, "line number is not uniquely found in section: "+string(line_number)
    endif
    
    openu, lun, self.filename, /get_lun
    
    self->go_to_line, line_number, lun
    
    if self.pad_width then line = self->pad_line(line)
    printf, lun, line
    
    ; free_lun also closes it
    free_lun, lun

END    

;+
; Uses the line numbers in memory to return what the last
; line number is for the file
; @returns the last line number in memory for this file
;-
FUNCTION INDEX_FILE_SECTION::get_current_file_length
    compile_opt idl2, hidden

    if not self->has_valid_line_numbers() then return, -1
    return, (*self.line_nums)[self.num_lines-1]

END

    
;+
; Appends lines to end of section (if allowed).  Keeps objects memory in sync with
; section
;
; @param lines {in}{required}{type=string array} lines to append to section
;
;-
PRO INDEX_FILE_SECTION::append_lines, lines
    compile_opt idl2, hidden

    if self.allow_append eq 0 then message, "this section does not allow appending lines" 

    if self.num_lines eq 0 then begin
        ; read the whole file to the number of lines
        openr, lun, self.filename, /get_lun
        num_lines = 0
        line = ""
        while (eof(lun) ne 1) do begin
            readf, lun, line
            num_lines += 1
        endwhile
        ; free_lun also closes it
        free_lun, lun

        starting_line_num = num_lines
    endif else begin
        if not self->has_valid_lines() then message, "no valid lines in file to append to."
        starting_line_num = self->get_current_file_length() + 1
    endelse

    openu, lun, self.filename, /append, /get_lun

    final_num_lines = self.num_lines+n_elements(lines)

    if final_num_lines lt 0 then begin
        message,'Number of rows in index file section exceeds largest long integer, can not continue'
    endif

    new_line_nums = lonarr(final_num_lines)
    len = self.num_lines-1
    if len ge 0 then begin
        new_line_nums[0:len] = *self.line_nums
    endif 
    
    ; if sufficiently large, use a progress bar
    if n_elements(lines) gt 1000 then progress_bar=1 else progress_bar=0
    if progress_bar then begin
        total_bar = '__________'
        step_size = long(n_elements(lines)/10)
        step = 0
        print, "Writing rows to index file:"
        print, total_bar
    endif 
    
    for i=0,n_elements(lines)-1 do begin
        ; write new lines to file
        if self.pad_width then file_line=self->pad_line(lines[i]) else file_line=lines[i]
        printf, lun, file_line 
        ; keep this object in sync with the file
        new_line_nums[self.num_lines+i] = starting_line_num+i
        ; update the progress bar
        if progress_bar then begin
            if step eq step_size then begin
                step = 0
                print, format='("X",$)'
            endif else begin
                step += 1
            endelse    
        endif
    endfor

    ; terminate progress bar
    if progress_bar then print, format='(/)'
    
    *self.line_nums = new_line_nums
    self.num_lines = n_elements(*self.line_nums)

    ; free_lun also closes the file
    free_lun, lun

END

;+
; Makes object verbose
;-
PRO INDEX_FILE_SECTION::set_debug_on
    compile_opt idl2

    self.debug = 1

END

;+
; Makes object quiet
;-
PRO INDEX_FILE_SECTION::set_debug_off
    compile_opt idl2

    self.debug = 0

END

;+
; Has the section been read?
; @returns 0 - no, 1 - yes
;-
FUNCTION INDEX_FILE_SECTION::is_section_read
    compile_opt idl2

    return, self.section_read

END    

;+
; Set this if the section can be appended to
;-
PRO INDEX_FILE_SECTION::set_allow_append_on
    compile_opt idl2

    self.allow_append = 1

END

;+
; Print out useful debugging information
;-
PRO INDEX_FILE_SECTION::show_state
    compile_opt idl2

    print,"INDEX_FILE_SECTION state"
    print,"   filename : ", self.filename
    print,"   num_lines : ", self.num_lines
    if self->has_valid_lines() then begin
       print,"   line_nums ; ", (*self.line_nums)
    endif else begin
       print,"   no valid line_nums"
    endelse
    print,"END INDEX_FILE_SECTION state"

END
