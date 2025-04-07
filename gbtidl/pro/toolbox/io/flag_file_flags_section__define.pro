;+
; FLAG_FILE_FLAGS_SECTION is an abstract class responsible for managing the 
; flags section of a flagging file.  It is a child of the index_file_section
; class, though it is not an index file (this should be changed). The 
; responsiblities include some of the translation of flagging info to and 
; from the string format found in the file and structures.
; 
; @field rows pointer to an array of structures representing each line in the flag section
; @field index_value_rows pointer to an array of strings, each representing the record number relative to the current index - managed by parent classes
; @field frmt pointer to a string array giving the full format of the flag section
; @field param_types pointer to a string array giving the type for each flagging parameter - which are, more or less, the columns in the flag section
; @field header_list a string used as the header when listing flags in summary format
; @field header_verbose the header string when flags are listed in verbose format
; @field values_list_format the string used along with the format keyword when listing the flag values
; @field deliminator this is a character used to deliminate columns in the flag section
; @field not_applicable_symbol a character used to symolize that a column in the flag section is not utilized.
; @field more_format boolean flag for wether listing uses more format  or not
;-
PRO flag_file_flags_section__define

    ris = { FLAG_FILE_FLAGS_SECTION, $ 
        inherits index_file_section, $
        rows:ptr_new(), $
        index_value_rows:ptr_new(), $
        frmt:ptr_new(), $
        param_types:ptr_new(), $
        header_list:string(replicate(32B,256)), $
        header_verbose:string(replicate(32B,256)), $
        values_list_format:string(replicate(32B,256)), $
        deliminator:string(32B), $
        not_applicable_symbol:string(32B), $
        more_format:0 $
    }

END



;+
; Takes the format array and creates the variables needed for listing
;-
PRO FLAG_FILE_FLAGS_SECTION::create_formats
    compile_opt idl2, hidden

    frmt = *self.frmt
    
    ; how many keywords?
    sz = size(frmt)
    len = sz[2]
    frmt_len = 0
    for i=0,len-1 do begin
        if long(frmt[4,i]) then frmt_len += 1
    endfor    
    
    ; build the format strings used for listing flags, and the verbose header
    param_types = strarr(2,len)
    header_keywords = strarr(frmt_len)
    self.header_verbose = ""
    values_format='('
    header_format='('
    ; go through each column that appears in flag file
    for i=0,len-1 do begin
        in_file = long(frmt[4,i])
        name = frmt[0,i]
        param_types[0,i] = name
        param_types[1,i] = frmt[3,i]
        if in_file then begin
            if strmid(name,0,1) eq "#" then name=strmid(name,1,strlen(name)-1)
            if (i ne 0) then begin 
                self.header_verbose +=','
                values_format += ',1x,'
                header_format += ',1x,'
            endif    
            self.header_verbose += frmt[0,i]
            header_format += frmt[1,i]
            values_format += frmt[2,i]
            header_keywords[i] = frmt[0,i]
        endif    
    endfor    
    values_format+=')'
    header_format+=')'
    
    ; save off the header used with listing flags
    self.header_list = string(header_keywords,format=header_format)

    ; save off the format strings used for print/reading index file
    self.values_list_format = values_format
    ;self.header_format = header_format
    *self.param_types = param_types
    
END

;+
; Accessor for the param_types member variable
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_param_types
    compile_opt idl2, hidden
    return, *self.param_types
END

;+
; Accessor for the deliminator member variable
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_deliminator
    compile_opt idl2, hidden
    return, self.deliminator
END

;+
; Accessor for the not_applicable_symbol member variable
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_not_applicable_symbol
    compile_opt idl2, hidden
    return, self.not_applicable_symbol
END

;+
; Creates rows section, but writes no actual rows to it, just the section marker,
; and the format_header 
;-
PRO FLAG_FILE_FLAGS_SECTION::create
    compile_opt idl2, hidden

    self->INDEX_FILE_SECTION::create, lines=self.header_verbose, /append

    ; HACK HACK HACK
    ; the index file section obj counts the header string as a line,
    ; even though it is commented out.  Since we don't want to alter
    ; index file behaviour at this point, reread the file here for
    ; flags so that this commented line is NOT counted.
    r = self->read_file()

END

;+
; Convert the rows into lines and returns them
; @param count {out}{optional}{type=long} number of lines returned
; @returns array of lines in section, -1 if no lines
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_all_lines, count
    compile_opt idl2, hidden

    count = 0
    if ptr_valid(self.rows) then begin
        count = n_elements(*self.rows)
        if count eq 0 then begin
            return, -1
        endif else begin
            return, self->rows_to_lines(*self.rows)
        endelse
    endif
    return, -1
end

;+
; Prints contents of flag section. For testing purposes only.
;-
PRO FLAG_FILE_FLAGS_SECTION::list, idstring=idstring, summary=summary
    compile_opt idl2, hidden

    if not self->has_valid_rows() then return
    if not self->has_valid_lines() then return

    if n_elements(idstring) then begin
        list_lines = self->search_flags(idstring=idstring)
    endif else begin
        list_lines = lindgen(n_elements(*self.rows))
    endelse
    
    if n_elements(summary) eq 0 then begin
        print, self.header_verbose
        for i=0,n_elements(list_lines)-1 do begin
            print, self->rows_to_lines((*self.rows)[list_lines[i]])
        endfor
    endif else begin
        print, self.header_list
        rows = *self.rows
        for i=0,n_elements(list_lines)-1 do begin
            print, rows[list_lines[i]], format=self.values_list_format
        endfor
    endelse
    
END

;+
; Returns the requested lines from the flag file AND their locations in the file
; @param status {out}{optional}{type=bool} 0 - failure, 1 - success
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_lines_and_line_nums, status, idstring=idstring
    compile_opt idl2, hidden

    ; get all the lines in this file section
    lines = self->get_all_lines(count)
    if count eq 0 then begin
        status = 0
        return, -1
    endif    
   
    ; get the locations of the lines
    line_nums = self->get_line_nums(count)
    if count eq 0 then begin
        status = 0
        return, -1
    endif    
    line_nums = string(line_nums)

    if n_elements(idstring) eq 0 then begin
        status = 1
        all = strarr(2, count)
        all[0,0:count-1] = lines
        all[1,0:count-1] = line_nums
        return, all 
    endif else begin
        list_lines = self->search_flags(idstring=idstring,ok)
        status = ok 
        if ok eq 0 then begin
            return, -1
        endif else begin
            count = n_elements(list_lines)
            all = strarr(2,count)
            all[0,0:count-1] = lines[list_lines]
            all[1,0:count-1] = line_nums[list_lines]
            return, all
        endelse
    endelse

END

;+
; Retrieves lines that match idstring from the flags section.  Returns all
; lines if idstring is not used.
; @param status {out}{optional}{type=bool} 0 - bad, 1 - good
; @keyword idstring {in}{optional}{type=string} return only lines that match this idstring
; @returns lines that match given idstring; all flag lines if idstring not used
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_lines, status, idstring=idstring
    compile_opt idl2, hidden

    lines = self->get_all_lines(count)

    if count eq 0 then begin
        status = 0
        return, -1
    endif    
   
    if n_elements(idstring) eq 0 then begin
        status = 1
        return, lines
    endif else begin
        list_lines = self->search_flags(idstring=idstring,ok)
        status = ok 
        if ok eq 0 then begin
            return, -1
        endif else begin
            return, lines[list_lines]
        endelse
    endelse
   
END

;+
; Returns status of pointer to flag structures
; @returns 0 - no valid flag structrues, 1 - has valid flag structres
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::has_valid_rows
    compile_opt idl2, hidden

    if not ptr_valid(self.rows) then begin
        return, 0
    endif else begin
        if n_elements(*self.rows) eq 0 then begin
            return, 0
        endif else begin
            return, 1
        endelse
    endelse    

end

;+
; Returns status of pointer to index value record numbers
; @returns 0 - not valid ,  1 - valid
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::has_valid_index_value_rows
    compile_opt idl2, hidden

    if not ptr_valid(self.index_value_rows) then begin
        return, 0
    endif else begin
        if n_elements(*self.index_value_rows) eq 0 then begin
            return, 0
        endif else begin
            return, 1
        endelse
    endelse    

end

;+
; Returns the flag structures that match the given idstring; returns all
; if idstring not used.
; @param indicies {out}{optional}{type=long} the indicies to the flags returned
; @param status {out}{optional}{type=bool} 0 - bad, 1 - good
; @keyword idstring {in}{optional}{type=string} return only lines that match this idstring
; @returns flag structures that match idstring
;- 
FUNCTION FLAG_FILE_FLAGS_SECTION::get_rows, status, indicies, idstring=idstring 
    compile_opt idl2, hidden

    status = 0
    if n_elements(idstring) then begin
        indicies = self->search_flags(idstring=idstring,ok)
        status = ok
        if ok eq 0 then begin
            return, -1
        endif else begin    
            return, (*self.rows)[indicies]
        endelse    
    endif else begin
        if n_elements(*self.rows) ne 0 then begin
            indicies = indgen(n_elements(*self.rows))
            status = 1
            return, *self.rows
        endif else begin
            status = 0
            return, -1
        endelse
    endelse
    
END

;+
; Appends a new line to the flag section.  Also ensures that this line is converted
; to a flag structure that is also appended.
; @param lines {in}{required}{type=string} line(s) to append to flag section
;-
PRO FLAG_FILE_FLAGS_SECTION::append_lines, lines
    compile_opt idl2, hidden

    self->INDEX_FILE_SECTION::append_lines, lines
    rows = self->convert_lines_to_strcts(lines)
    self->append_rows, rows
    
END

;+
; Returns the last line number of the file, using system file_lines command.
; @returns file_lines() - 1
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_current_file_length
    compile_opt idl2, hidden
    
    return, file_lines(self.filename)-1

END
    
;+
; Appends flagging structures to the array of structures in memory.
; @param rows {in}{required}{type=flag structures} flags to add
;-
PRO FLAG_FILE_FLAGS_SECTION::append_rows, rows
    compile_opt idl2, hidden
    
    if self->has_valid_rows() then begin
        *self.rows = [*self.rows, rows]
    endif else begin
        self->set_rows, rows
    endelse

END

;+
; Appends index value record number(s) to the array kept in memory
; @param rows {in}{required}{type=string} index value record numbers to add
;-
PRO FLAG_FILE_FLAGS_SECTION::append_index_value_rows, rows
    compile_opt idl2, hidden
    
    if self->has_valid_index_value_rows() then begin
        *self.index_value_rows = [*self.index_value_rows, rows]
    endif else begin
        self->set_index_value_rows, rows
    endelse

END

;+
; Reset the array of flag structures kept in memory
; @param rows {in}{required}{type=flag structures} flags to reset
;-
PRO FLAG_FILE_FLAGS_SECTION::set_rows, rows
    compile_opt idl2, hidden

    if ptr_valid(self.rows) then begin
        *self.rows = rows
    endif else begin
        self.rows = ptr_new(rows)
    endelse

END

;+
; Reset the array of index value record number kept in memory
; @param rows {in}{required}{type=string} index value record numbers to reset
;-
PRO FLAG_FILE_FLAGS_SECTION::set_index_value_rows, rows
    compile_opt idl2, hidden

    if ptr_valid(self.index_value_rows) then begin
        *self.index_value_rows = rows
    endif else begin
        self.index_value_rows = ptr_new(rows)
    endelse

END

;+
; Free the memory allocated for the index value rec nums, and reallocate.
;-
PRO FLAG_FILE_FLAGS_SECTION::reset_index_value_rows
    compile_opt idl2, hidden

    if ptr_valid(self.index_value_rows) then begin
        ptr_free, self.index_value_rows
        self.index_value_rows = ptr_new(/allocate_heap)
    endif

END

;+
; Retrieve the index value record numbers kept in memory
; @param status {out}{optional}{type=bool} 0 - no rec nums, 1 - success
; @returns string array of index value record numbers
FUNCTION FLAG_FILE_FLAGS_SECTION::get_index_value_rows, status

    if not self->has_valid_index_value_rows() then begin
        status = 0
        return, -1
    endif else begin
        status = 1
        return, *self.index_value_rows
    endelse    

END

;+
; Free the memory allocated for the flag structures, and reallocate.
;-
PRO FLAG_FILE_FLAGS_SECTION::reset_rows
    compile_opt idl2, hidden

    if ptr_valid(self.rows) then ptr_free, self.rows
    self.rows = ptr_new(/allocate_heap)

END



;+
; Procedure to process each line.  Invoked by
; index_file_section::read_file
; @param line {in}{required}{type=string} The line to handle.
; @param index {in}{required}{type=integer} The index number for this line
;-
PRO FLAG_FILE_FLAGS_SECTION::process_line, line, index
    compile_opt idl2, hidden

    ; convert it and save it
    (*self.rows)[index] = self->convert_lines_to_strcts(line)
END

;+
; Loads the flag section of the flag file into memory.  After reading the lines
; in the file, these lines are then converted to flag structures
; @returns 0 - failure, 1 - success
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::read_file
    compile_opt idl2, hidden

    nlines = self->count_section_lines()
    if nlines le 0 then begin
        self->reset_rows
    endif else begin
        self->set_rows, replicate(self->get_row_info_strct(),nlines)
    endelse
            
    result = self->INDEX_FILE_SECTION::read_file()
    
    return, result

END

;+
; Returns the value to use for the input from a flagging command that is only
; allowed one value to the value it is stored as in the flag file, that is a string,
; or the 'not applicable' symbol if it is not set.
; @param input {in}{required} value to be converted
; @returns string to be stored in flag file
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::convert_set_flag_input_scalar, input
    compile_opt idl2, hidden

    if n_elements(input) ne 0 then begin
        return, strtrim(string(input),2)
    endif else begin
        return, self.not_applicable_symbol
    endelse
    
END    


;+
; Returns the value to use for the input from a flagging command that is 
; allowed to be an array to the value it is stored as in the flag file, 
; that is a string,
; or the 'not applicable' symbol if it is not set.
; @param input {in}{required} value to be converted
; @returns string to be stored in flag file
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::convert_set_flag_input_array, input
    compile_opt idl2, hidden

    if n_elements(input) ne 0 then begin
        return, compress_ints(input)
    endif else begin
        return, self.not_applicable_symbol
    endelse
    
END    

;+
; Converts an integer into a string, and trims all whitespace.
; @param int {in}{required}{type=long} integer to convert
; @returns string representation of integer
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::int2str, int
    compile_opt idl2, hidden

    return, strtrim(string(int),2)

END

;+
; Returns the indicies where flags can be found that match the passed in idstring
; @param status {out}{optional}{type=bool} 0 - match not found, 1 - match(es) found
; @keyword idstring {in}{optional}{type=string} return indicies of flags that match this idstring
; @returns indicies where flags match idstring; all indicies of flags when idstring not used
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::search_flags, idstring=idstring, status
    compile_opt idl2, hidden

    if not self->has_valid_rows() then begin
        status = 0
        return, -1
    endif

    if n_elements(idstring) eq 0 then begin
        result = lindgen(n_elements(*self.rows))
        status = 0
        return, result
    endif

    ids = (*self.rows).idstring

    result = where(ids eq idstring, cnt)

    if cnt eq 0 then status = 0 else status = 1

    return, result

END

;+
; Returns a list of all idstrings used in flags section
; @param count {out}{optional}{type=long} number of unique ids returns
; @returns list of all unique idstrings
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_unique_ids, count
    compile_opt idl2, hidden

    status = 0
    rows = self->get_rows(status)
    if status eq 0 then begin
        count = 0
        return, -1
    endif else begin    
        ids = (rows).idstring
        uniq_ids = ids[uniq(ids,sort(ids))]
        count = n_elements(uniq_ids)
        return, uniq_ids
    endelse    
END

;+
; Prints out unique ids found in file section.
; For testing purposes only.
;-
PRO FLAG_FILE_FLAGS_SECTION::list_ids
    compile_opt idl2, hidden

    uniq_ids = self->get_unique_ids()

    print, "UNIQUE FLAG IDS:"
    for i=0,n_elements(uniq_ids)-1 do begin
        print, uniq_ids[i]
    endfor
    
END

;+
; Comments out the given line number in the flag section.
; Flag file lines begin with a blank space that can be replaced
; with a # to comment them out without changing the lenght of the line,
; therefore the size of the file
; @param line_location {in}{required}{type=long} line number to comment out.  This is relative to the entire length of the file, not the flags section alone.
;-
PRO FLAG_FILE_FLAGS_SECTION::unflag_line, line_location
    compile_opt idl2, hidden

    ; check that there are valid rows to unflag
    if n_elements(*self.rows) eq 0 then message, "no valid flags to unflag."
   
    ; get the text currently at this location
    ind = self->get_index_by_location(line_location)
    old_line = self->rows_to_lines((*self.rows)[ind])
    if size(old_line,/type) ne 7 then begin
        message, "Could not find line number in file section: "+string(line_location), /info
    endif
    
    ; unflag ONLY this line
    unflagged_line = "#"+strmid(old_line,1,strlen(old_line))
    self->set_line, line_location, unflagged_line

    ; reset the info in memory
    result = self->read_file()

END

;+
; Comments out all the lines in the flag section that contain the given idstring.
; @param idstring {in}{required}{type=string} used to find what lines to comment out
;-
PRO FLAG_FILE_FLAGS_SECTION::unflag, idstring
    compile_opt idl2, hidden

    ; check that there are valid rows to unflag
    rows = self->get_rows(status)
    if status eq 0 then message, "no valid flags to unflag with id: "+idstring
    
    ; find the flag to unflag
    id_lines = self->search_flags(idstring=idstring, status)
    if status eq 0 then message, "idstring could not be found to unflag: "+idstring

    for i=0,n_elements(id_lines)-1 do begin
        id_line = id_lines[i]
        old_line = self->rows_to_lines((*self.rows)[id_line])
        unflagged_line = "#"+strmid(old_line,1,strlen(old_line))
        line_number = (*self.line_nums)[id_line]
        self->set_line, line_number, unflagged_line, id_line
    endfor

    ; reset the info in memory
    result = self->read_file()

    return
END    

;+
; Accessor method to member variable.
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_formatted_header
    compile_opt idl2, hidden
    
    return, self.header_list

END

;+
; Accessor method to member variable.
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_verbose_header
    compile_opt idl2, hidden

    return, self.header_verbose

END    

;+
; Accessor method to member variable.
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::get_values_list_format
    compile_opt idl2, hidden

    return, self.values_list_format

END    

;+
; Used for converting old flag file to the current format.
; @param old_rows {in}{required}{type=flag structure} an array of the old flagging structures to convert
; @param status {out}{optional}{type=long} 0 - failure, 1 - success
; @returns flag structures containing the same content passed in
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::convert_rows, old_rows, status
    compile_opt idl2, hidden

    status = 0

    old_tags = tag_names(old_rows[0])
    num_old_tags = n_tags(old_rows[0])
    
    new_rows = replicate(self->get_row_info_strct(),n_elements(old_rows))
    new_tags = tag_names(new_rows[0])
    num_new_tags = n_tags(new_rows[0])
    ; init each new structure
    for i=0,n_elements(new_rows)-1 do begin 
        for j=0,num_new_tags-1 do begin
            new_rows[i].(j) = '*'
        endfor
    endfor

    ; convert each row structure
    for i=0,n_elements(old_rows)-1 do begin
        ; for each tag name in the old rows, see if that exists in the new rows
        for j=0,num_old_tags-1 do begin
            ind = where(old_tags[j] eq new_tags, count)
            if count ne 0 then begin
                ; transfer this value from the old row to the new
                new_rows[i].(ind[0]) = old_rows[i].(j)
            endif 
        endfor    
    endfor

    status = 1
    return, new_rows

END


;+
; Appends new flag structures to the flag seciton of flag file.
; Structures are first converted to strings, and then written to file.
; @param rows {in}{required}{type=flag structures} representing new flag lines
; @param status {out}{optional}{type=long} 0 - failure, 1 - success
;-
PRO FLAG_FILE_FLAGS_SECTION::write_new_rows, rows, status
    compile_opt idl2, hidden

    lines = self->rows_to_lines(rows)
    self->append_lines, lines

END    
   
;+
; Converts flagging structures to strings, using the deliminator character.
; @param rows {in}{required}{type=flag structures} flags to convert to strings
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::rows_to_lines, rows
    compile_opt idl2, hidden

    tags = tag_names(rows[0])
    num_tags = n_tags(rows[0])
    lines = replicate(string(replicate(32B,256)),n_elements(rows))
    dlm = self.deliminator
    
    for i=0,n_elements(rows)-1 do begin
        ; append tags back to back using deliminator
        line = ""
        for j=0,num_tags-1 do begin
            field = strtrim(rows[i].(j),2) 
            if j eq 0 then line = ' '+field else line += dlm + field
        endfor
        lines[i] = line
    endfor
    
    return, lines

END    

;+
; Converts CHANS and CHANWIDTH keywords, if used, to their equivalent use with 
; BCHAN and ECHAN, and checks all values of BCHAN and ECHAN.  Then takes these
; integer arrays, and converts them to comma separated strings.
; BCHAN and ECHAN are mutually exclusive to CHANS and CHANWIDTH.
; These values should also have been checked higher up, closer to the initial
; flagging command.
; @param bchan {in}{optional}{type=long} channel(s) to start flagging
; @param echan {in}{optional}{type=long} channel(s) to stop flagging
; @param chans {in}{optional}{type=long} channel(s) to flag
; @param chanwidth {in}{optional}{type=long} buffer width for CHANS keyword (default=1)
; @param status {out}{optional}{type=bool}  0 - param values not valid, 1 - success
; @returns string array, where first element is bchan, second echan values for line in flag file
;-
FUNCTION FLAG_FILE_FLAGS_SECTION::check_channels, bchan, echan, chans, chanwidth, status
    compile_opt idl2, hidden

    ; either bchan or echan are set, then chan and widths should not
    if n_elements(bchan) ne 0 or n_elements(echan) then begin
        if n_elements(chans) ne 0 or n_elements(chanwidth) ne 0 then begin
            message, "bchan and echan keywords are exclusive to chans and chanwidth keywords"
        endif
    endif

    ; chanwidth cant be set without chans
    if n_elements(chanwidth) ne 0 and n_elements(chans) eq 0 then begin
        message, "chans must be specified with chanwidth keyword"
    endif

    ; if chans is set, use this to set bchan and echan
    if n_elements(chans) ne 0 then begin
        ; what is the width?
        if n_elements(chanwidth) eq 0 then begin 
            width=1 
        endif else begin
            ; width MUST be an odd number
            if chanwidth MOD 2 eq 0 then message, "chanwidth must be an odd number."
            width=chanwidth
        endelse    
        side = width / 2
        ; now, create ranges 
        for i=0,n_elements(chans)-1 do begin
            chan = chans[i]
            b = chan - side
            e = chan + side
            if i eq 0 then bchan=[b] else bchan=[bchan,b]
            if i eq 0 then echan=[e] else echan=[echan,e]
        endfor    
    endif else begin
        ; bchan/echan used
        ; validate them first
    
        ; check bchan and echan
        ; if only one begin or end channel is specified, the other end
        ; will default to the max or min range.
        ; if there is only one begining channel, then there must
        ; be no more than one end channel
        if n_elements(bchan) eq 1 then begin
            if n_elements(echan) gt 1 then begin
                message, "bchan and echan must have equal lengths if more then one range is to be specified"
            endif
        endif    
    
        ; if there is only one end channel, then there must
        ; be no more than one beginning channel
        if n_elements(echan) eq 1 then begin
            if n_elements(bchan) gt 1 then begin
                message, "bchan and echan must have equal lengths if more then one range is to be specified"
            endif
        endif    
    
        ; when specifying more then one channel range, bchan and echan must 
        ; be of same length
        if n_elements(bchan) gt 1 or n_elements(echan) gt 1 then begin
            if n_elements(bchan) ne n_elements(echan) then begin
                message, "when specifying more then one range, bchan and echan must have equal lengths."
            endif
        endif

        ; ensure that for each matched bchan and echan, bchan le echan
        if n_elements(bchan) ge 1 and n_elements(echan) ge 1 then begin
            for i=0,(n_elements(bchan)-1) do begin
                if echan[i] lt bchan[i] then begin
                    tmp = echan[i]
                    echan[i] = bchan[i]
                    bchan[i] = tmp
                endif
            endfor
        endif
    endelse

    ; now actually process bchan and echan

    if n_elements(bchan) gt 1 then begin
        ; echan must also be same length at this point
        ; expand bchan, echan into array of individual channel numbers
        for i=0,(n_elements(bchan)-1) do begin
            thisSeq = seq(bchan[i],echan[i])
            if i eq 0 then chans = thisSeq else chans = [chans,thisSeq]
        endfor
        ; compress the ints, chans always >= 0
        chanString = compress_ints(chans,llimit=0)
        ; extract range boundaries - eventually the flag file could be
        ; redesigned and use chanString directly, I think
        result = extract_edges(chanString)
    endif else begin
        ; this does the right thing for 0 and 1 element bchan and echan
        b = self->convert_set_flag_input_array(bchan)
        e = self->convert_set_flag_input_array(echan) 
        result = [b,e]
    endelse

    return, result

END


PRO FLAG_FILE_FLAGS_SECTION::show_state
    compile_opt idl2
    print,"FLAG_FILE_FLAGS SECTION state"
    self->INDEX_FILE_SECTION::show_state
    if ptr_valid(self.rows) then begin
       if n_elements(*self.rows) then begin
          print,'   rows ...'
          for i=0,(n_elements(*self.rows)-1) do begin
             print,(*self.rows)[i]
          endfor
       endif else begin
          print,"   0 rows"
       endelse
    endif else begin
       print,"    no valid rows"
    endelse
    if ptr_valid(self.index_value_rows) and n_elements(*self.index_value_rows) gt 0 then begin
       print,"  index_value_rows : ", *self.index_value_rows
    endif else begin
       print,"   no valid index value rows"
    endelse
    print,"END FLAG_FILE_FLAGS_SECTION state"
END
