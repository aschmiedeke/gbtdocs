;+
; FLAGS is the class which handles all flags used by an io_sdfits object.  It
; is composed of an array of FLAG_FILE objects for managing separate
; flag files.  It is also responsible for converting record number between
; their values for a particular sdfits file, and that for a single index file
; used with multiple sdfits files.  See <a href="../../../IDL_IO_classes.jpg">UML</a> fro all IO Classes.
;
; @field files pointer to an array of
; @field flie_index_bases pointer to an array of
; @field flag_files pointer to an array of flag file objects
; @field file_path path to where all flag files can be found
; @field version string indicating the flagging format
; @field flags_section_class string indicating the class to use for the flagging format
; @field param_types pointer to 2-D array of parameter names/types
; @field debug integer flag for printing debug info
;
;-
PRO flags__define

    flgs = { FLAGS, $
        files:ptr_new(), $
        file_index_bases:ptr_new(), $
        flag_files:ptr_new(), $
        file_path:string(replicate(32B,256)), $
        version:string(replicate(32B,3)), $
        flags_section_class:string(replicate(32B,256)), $
        param_types:ptr_new(), $
        flag_ids:ptr_new(), $
        debug:0L $
    }

END

;+
; Class constructor where pointers are initialized and flag parameter types
; are defined.
;-
FUNCTION FLAGS::init, file_path=file_path, debug=debug
    compile_opt idl2, hidden

    self.files = ptr_new(/allocate_heap)
    self.file_index_bases = ptr_new(/allocate_heap)
    self.flag_files = ptr_new(/allocate_heap)
    self.param_types = ptr_new(/allocate_heap)
    self.flag_ids = ptr_new(/allocate_heap)

    self.version = ""
    self.flags_section_class = ""

    if keyword_set(file_path) then self->set_file_path, file_path

    if keyword_set(debug) then self.debug=debug else self.debug = 0

    ; get the parameter types - must create a flag file obj.
    flag_file = obj_new("flag_file")
    *self.param_types = flag_file->get_param_types()
    if obj_valid(flag_file) then obj_destroy, flag_file

    return, 1
END

;+
; Class destructor where pointers and objects are freed.
;-
PRO FLAGS::cleanup
    compile_opt idl2, hidden

    if ptr_valid(self.files) then ptr_free, self.files
    if ptr_valid(self.file_index_bases) then ptr_free, self.file_index_bases
    if n_elements(*self.flag_files) ne 0 then begin
        for i=0,n_elements(*self.flag_files)-1 do begin
            ;print, (*self.flag_files)[i]->get_file_name()
            if obj_valid((*self.flag_files)[i]) then obj_destroy,(*self.flag_files)[i]
        endfor
        ptr_free, self.flag_files
    endif else begin
        ptr_free, self.flag_files
    endelse
    if ptr_valid(self.param_types) then ptr_free, self.param_types
    if ptr_valid(self.flag_ids) then ptr_free, self.flag_ids

END

;+
; One of two main methods for setting flags.
; This sets a flag rule according to observational parameters, such as 
; scan number, integration number, feed, polarization, and IF numbers.
; The channels to flag can also be set, along with an idstring for
; identification.  The fits filename parameter is used to retrieve the
; flag file object responsible for this file, which does the flagging.
; Flag IDs are reset after this operation.
; @param fits_filename {in}{required}{type=string} the full path name to the fits file that contains the scan to be flagged
; @param scan {in}{required}{type=long} scan number 
; @keyword _EXTRA {in}{optional}{type=keywords} includes keywords <b>intnum</b>, <b>fdnum</b>, <b>plnum</b>, <b>ifnum</b>, <b>bchan</b>, <b>echan</b>, <b>idstring</b>. 
;-
PRO FLAGS::set_flag, fits_filename, scan, _EXTRA=ex 
    compile_opt idl2, hidden

    flag_filename = self->fits_filename_to_flag_filename(fits_filename)
    ff = self->get_flag_file_obj(flag_filename)
    ff->set_flag, scan, _EXTRA=ex
    ff->append_index_value_recnums, "*"
    self->set_flag_ids

END

;+
; One of two main methods for setting flags.
; This sets a flag rule according to index parameters, specifically the  
; record number.
; The channels to flag can also be set, along with an idstring for
; identification.  The fits filename parameter is used to retrieve the
; flag file object responsible for this file, which does the flagging.
; Flag IDs are reset after this operation.
; @param fits_filename {in}{required}{type=string} the full path name to the fits file that contains the scan to be flagged
; @param index_recnum {in}{required}{type=long} record number to flag 
; @keyword _EXTRA {in}{optional}{type=keywords} includes keywords <b>bchan</b>, <b>echan</b>, <b>idstring</b>. 
;-
PRO FLAGS::set_flag_rec, fits_filename, index_recnum, _EXTRA=ex 
    compile_opt idl2, hidden
    
    flag_filename = self->fits_filename_to_flag_filename(fits_filename)
    flag_recnum = self->index_recnum_to_flag_recnum(index_recnum,flag_filename)
    ff = self->get_flag_file_obj(flag_filename)
    ff->set_flag_rec, flag_recnum, _EXTRA=ex
    ff->append_index_value_recnums, self->int_array_to_string_list(index_recnum)
    self->set_flag_ids
    
END

;+
; Converts an array of integers to a comma spearated string
; @param int_array {in}{required}{type=long} integer array
; @returns string containing comma separated elements of array
;-
FUNCTION FLAGS::int_array_to_string_list, int_array
    compile_opt idl2, hidden

    string_list = ""
    for i=0,n_elements(int_array)-1 do begin
        if i ne 0 then string_list += ","
        string_list += strtrim(string(int_array[i]),2)
    endfor
    return, string_list

END

;+
; Removes a line in a flag file via either its dynamic ID or its IDSTRING.
; @param id {in}{required}{type=long,string} id can be an integer ID
; or string IDSTRING
; @param status {out}{optional}{type=long} 0 - failure, 1 - success
; @keyword all {in}{optional}{type=boolean} When set, all IDs are
; unflagged and any id argument is ignored.
; @keyword quiet {in}{optional}{type=boolean} When set, suppress the
; warning messages when a specific id is used but not found.
;-
PRO FLAGS::unflag, id, status, all=all, quiet=quiet
    compile_opt idl2, hidden

    if keyword_set(all) then begin
        allIDs = self->get_all_ids(count)
        if count gt 0 then begin
            for i=(count-1),0,-1 do begin
                self->unflag_id, allIDs[i], status
                if status ne 1 then break
            endfor
        endif
    endif else begin
 
        idtype = size(id,/type)
        if idtype eq 7 then begin
            self->unflag_idstring, id, status, quiet=quiet
        endif else begin
            self->unflag_id, id, status, quiet=quiet
        endelse
    endelse
   
END


;+
; Removes a line in a flag file given the flags integer ID.
; Flag IDs are reassigned at the end of this operation.
; @param id {in}{required}{type=long} ID of line to remove
; @param status {out}{optional}{type=long} 0 - failure, 1 - success
; unflagged.
; @keyword quiet {in}{optional}{type=boolean} When set, suppress the
; warning message when id was not found.
;-
PRO FLAGS::unflag_id, id, status, quiet=quiet
    compile_opt idl2, hidden

    ; get flag filename and line number for this id
    location = self->get_flag_location(id,status)

    if status eq 0 then begin
       if not keyword_set(quiet) then begin
          message, "ID could not be found to unflag: "+string(id), /info
       endif
       return
    endif

    ; get the object for this filename
    ff = (*self.flag_files)[location[0]]

    ; comment out this line in the flag file
    ff->unflag, long(location[1])

    ; reassign the flag ids
    self->set_flag_ids

    ; recalculate the index value recnums for this flag file
    self->calculate_index_value_recnums,ff->get_file_name()

END

;+
; Removes line(s) in a flag file given the flags IDSTRING.
; Flag IDs are reassigned at the end of this operation.
; @param idstring {in}{required}{type=string} IDSTRING of line(s) to remove
; @param status {out}{optional}{type=long} 0 - failure, 1 - success
; @keyword quiet {in}{optional}{type=boolean} When set, suppress the
; warning message when id was not found.
;-
PRO FLAGS::unflag_idstring, idstring, status, quiet=quiet
    compile_opt idl2, hidden

    id_found = 0
    for i=0,n_elements(*self.flag_files)-1 do begin
        ff = (*self.flag_files)[i]
        status = 0
        inds = ff->search_flags(status,idstring=idstring)
        if status ne 0 then begin
            ff->unflag, idstring
            id_found = 1
            ; recalculate the index value recnums for this flag file
            self->calculate_index_value_recnums,ff->get_file_name()
        endif
    endfor
    if not id_found and not keyword_set(quiet) then message, "IDSTRING could not be found to unflag: "+idstring, /info

    ; reassign the flag ids
    self->set_flag_ids

END

;+
; To be called after flags are added or removed.
; Assigns unique integer IDs to each line in all flag files.
; These IDs are dynamic and only stored in memory.
;-
PRO FLAGS::set_flag_ids
    compile_opt idl2, hidden

    ; how many ids in total are there?
    num_ids = 0
    for i=0,n_elements(*self.flag_files)-1 do begin
        ff = (*self.flag_files)[i]
        num_lines = ff->get_num_lines()
        num_ids += num_lines
    endfor
    
    ; create the 3xN array for mapping IDs to locations
    if num_ids gt 0 then flag_ids = make_array(3,num_ids,/long)

    id = 0
    
    ; go through each file and line sequentially
    for i=0,n_elements(*self.flag_files)-1 do begin
        ff = (*self.flag_files)[i]
        ;filename = ff->get_file_name()
        line_nums = ff->get_line_nums(num_lines)
        if num_lines gt 0 then begin
            ; create separate arrays for IDs, filenames, and line numbers 
            for j=0,num_lines-1 do begin
                flag_ids[0,id] = id
                flag_ids[1,id] = i
                flag_ids[2,id] = line_nums[j]
                id += 1
            endfor
        endif
    endfor

    if n_elements(flag_ids) ne 0 then begin
        *self.flag_ids = flag_ids
    endif else begin
        if ptr_valid(self.flag_ids) then ptr_free, self.flag_ids
        self.flag_ids = ptr_new(/allocate_heap)
    endelse

END

;+
; Checks to make sure that the flag ids pointer is valid.
; Use this before trying to use this pointer.
; @returns 1 - valid flag ids, 0 - no valid flag ids
;-
FUNCTION FLAGS::has_valid_flag_ids
    compile_opt idl2, hidden

    if ptr_valid(self.flag_ids) then begin
        if n_elements(*self.flag_ids) gt 0 then return, 1 else return, 0
    endif else begin
        return, 0
    endelse
END

;+
; Given a flag filename and a line number in this flag file, returns
; the current uniqe ID for this line.  
; This method accesses the
; flag id pointer, which points to an array that maps unique IDs 
; to there locations in flag files.
; @param flag_filename {in}{required}{type=string} full path name to a flag file
; @param linenum {in}{required}{type=long} line number in the flag file
; @returns the unique integer ID for this line in the flag file.
;-
FUNCTION FLAGS::get_flag_id, flag_filename, linenum
    compile_opt idl2, hidden
    if not self->has_valid_flag_ids() then return, -1
    flag_ids = *self.flag_ids
    id = -1
    num_ids = self->get_number_of_flag_ids()
    if num_ids eq 1 then begin
        ff = (*self.flag_files)[flag_ids[1]]
        flag_id_filename = strtrim(ff->get_file_name(),2)
        if flag_id_filename eq flag_filename and long(flag_ids[2]) eq long(linenum) then id=long(flag_ids[0])
    endif else begin
        for i=0,num_ids-1 do begin
            flag_id = flag_ids[0:2,i]
            ff = (*self.flag_files)[flag_id[1]]
            flag_id_filename = strtrim(ff->get_file_name(),2)
            if flag_id_filename eq flag_filename and long(flag_id[2]) eq long(linenum) then id=long(flag_id[0])
            num_ids = self->get_number_of_flag_ids()
         endfor
    endelse     
    return, id
END

;+
; Given a unique integer flag ID, returns this ID's location -
; a location being the flag file and the line number in said file.
; This method accesses the
; flag id pointer, which points to an array that maps unique IDs 
; to their locations in flag files.
; @param flag_id {in}{required}{type=long} unique integer flag ID
; @param status {out}{optional}{type=long} 1 - success, 0 - failure
; @returns 2 element string array containing file name and line number
;-
FUNCTION FLAGS::get_flag_location, flag_id, status
    compile_opt idl2, hidden
    status = 1
    if not self->has_valid_flag_ids() then begin
        status = 0
        return, -1
    endif    
    flag_ids = *self.flag_ids
    location = -1
    num_flag_ids = self->get_number_of_flag_ids()
    for i=0,num_flag_ids-1 do begin
        id_line = flag_ids[0:2,i]
        if id_line[0] eq flag_id then begin
            location = id_line[1:2]
            break
        endif
    endfor
    if size(location,/n_dim) eq 0 then status = 0
    return, location
END

;+
; Get a vector of all of the ID integers currently known.
; Returns, -1 and sets count to 0 if there is nothing flagged.
; @param count {out}{optional}{type=long} The total count, returns 0
; if there are none.
; @returns array of all ID integers known, -1 if none known.
;-
FUNCTION FLAGS::get_all_ids, count
    compile_opt idl2, hidden
    count = 0
    result = -1
    if not self->has_valid_flag_ids() then begin
        return, result
    endif
    flag_ids = *self.flag_ids
    count = self->get_number_of_flag_ids()
    if count gt 0 then begin
        result = lonarr(count)
        if count eq 1 then begin
            result = flag_ids[0]
        endif else begin
            result = flag_ids[0,0:(count-1)]
        endelse
    endif
    sortResult = result[sort(result)]
    return, sortResult
end

;+
; Sets the file path for this object and all managed flag files.
; @param file_path {in}{required}{type=string} path used for all flag files.
;-
PRO FLAGS::set_file_path, file_path
    compile_opt idl2, hidden

    self.file_path = file_path

    if ptr_valid(self.flag_files) then begin
        for i=0,n_elements(*self.flag_files)-1 do begin
            (*self.flag_files)[i]->set_file_path, file_path
        endfor
    endif

END    

;+
; Returns the types of each parameter for the flag file columns.
; Another words, the scan column takes an integer value, idstring
; takes a string value, etc.
; @returns string array
;-
FUNCTION FLAGS::get_param_types
    compile_opt idl2, hidden
    return, *self.param_types
END

;+
; Simple function for returning a filename without its extension
; @param filename {in}{required}{type=string} filename with extension
; @returns filename without extension
;-
FUNCTION FLAGS::get_filename_minus_ext, filename
    compile_opt idl2, hidden

    parts = strsplit(filename,".",/extract)
    if n_elements(parts) eq 1 then begin
        basename = filename
    endif else begin
        basename = strjoin(parts[0:n_elements(parts)-2],".")
    endelse

    return, basename

END

;+
; Converts a *.fits filename to a *.index filename.
; In this case, just the extension is changed.
; @param fits_filename {in}{required}{type=string} fits filename
; @returns index filename
;-
FUNCTION FLAGS::fits_filename_to_index_filename, fits_filename
    compile_opt idl2, hidden
    return, self->get_filename_minus_ext(fits_filename)+".index"
END

;+
; Converts a *.fits filename to a *.flag filename.
; In this case, just the extension is changed.
; @param fits_filename {in}{required}{type=string} fits filename
; @returns flag filename
;-
FUNCTION FLAGS::fits_filename_to_flag_filename, fits_filename
    compile_opt idl2, hidden
    return, self->get_filename_minus_ext(fits_filename)+".flag"
END

;+
; Converts a *.index filename to a *.flag filename.
; In this case, just the extension is changed.
; @param index_filename {in}{required}{type=string} index filename
; @returns flag filename
;-
FUNCTION FLAGS::index_filename_to_flag_filename, index_filename
    compile_opt idl2, hidden
    return, self->get_filename_minus_ext(index_filename)+".flag"
END


;+
; Given the full path name to a flag file, returns a flag file object
; responsible for managing this file.
; If the flag file object has already been created, this object will be
; returned, or it will be created and returned.
; @param flag_filename {in}{required}{type=string} full path to flag file
; @returns flag file object
;-
FUNCTION FLAGS::get_flag_file_obj, flag_filename
    compile_opt idl2, hidden

    flag_filename = file_basename(flag_filename)

    ; if there are no flag file objects, create this one
    if n_elements(*self.flag_files) eq 0 then begin
        if self.debug then print, "creating first flag obj for: ", flag_filename
        *self.flag_files = obj_new("flag_file", file_name=flag_filename,file_path=self.file_path,debug=self.debug)
        ; has the format been set for this object?
        if self.version ne "" and self.flags_section_class ne "" then begin
            (*self.flag_files)->set_flag_file_version, self.version, self.flags_section_class
        endif
        return, *self.flag_files
    endif else begin
        ; try and find the object for the file requested
        obj_index = -1
        for i=0,n_elements(*self.flag_files)-1 do begin
            if (*self.flag_files)[i]->get_file_name() eq flag_filename then obj_index = i
        endfor
        ; if found, return it, if not, create it
        if obj_index ne -1 then begin
            if self.debug then print, "getting flag obj for: ", flag_filename
            return, (*self.flag_files)[obj_index]
        endif else begin
            if self.debug then print, "creating flag obj for: ", flag_filename
            ff = obj_new("flag_file",file_name=flag_filename,file_path=self.file_path,debug=self.debug)
            ; has the format been set for this object?
            if self.version ne "" and self.flags_section_class ne "" then begin
                ff->set_flag_file_version, self.version, self.flags_section_class
            endif
            *self.flag_files = [*self.flag_files,ff]
            return, ff
        endelse
    endelse

END

;+
; Reads in a flag file into memory.
; This consists of using/creating a flag file object for the file,
; using this object to read the file, and then assigning unique IDs
; to all the flags managed by this class.
; @param flag_filename {in}{required}{type=string} full path to flag file
;-
PRO FLAGS::load_flag_file, flag_filename
    compile_opt idl2, hidden

    if self.debug then print, "reading in flag file: ", flag_filename

    ff = self->get_flag_file_obj(flag_filename)
    ff->read_file
    self->calculate_index_value_recnums,flag_filename
    self->set_flag_ids

END

;+
; For a given fits filename, make sure that if there is a flag file for it,
; it has been read by a flag file object, and all IDs are up to date.
; @param fits_filename {in}{required}{type=string} full path to flag file
;-
PRO FLAGS::check_flag_file_for_fits_file, fits_filename
    compile_opt idl2, hidden

    if self.debug then print, "checking for flag file for fits file: ", fits_filename

    flag_filename =  self->fits_filename_to_flag_filename(fits_filename)
    full_flag_filename = self->get_full_file_name(flag_filename)
    ff = self->get_flag_file_obj(flag_filename)
    is_loaded = ff->is_file_loaded()
    
    if file_test(full_flag_filename) and is_loaded ne 0 then begin
        ff->read_file
        self->calculate_index_value_recnums,flag_filename
        self->set_flag_ids
    endif    

END

;+
; To be called whenever a flag file is loaded, or all flags are reset, due to
; an unflag command.  Takes the record numbers in the flag file, and converts
; them to their new values relative to the current index (remember
; that this is a no-op if there is only one sdfits file).  
; These values are stored in each respective flag file object.
; @param flag_filename {in}{required}{type=string} name of the flag file
;-
PRO FLAGS::calculate_index_value_recnums, flag_filename
    compile_opt idl2, hidden
    
    ff = self->get_flag_file_obj(flag_filename)
    rows = ff->get_row_strcts(status)
    if status eq 0 or n_elements(rows) eq 0 then begin
        ff->reset_index_value_recnums
    endif else begin
        all_recnums = strarr(n_elements(rows))
        for i=0,n_elements(rows)-1 do begin
            flag_recnum_string = rows[i].recnum
            if flag_recnum_string ne "*" then begin
                index_recnum_string = $
                self->flag_recnum_string_to_index_recnum_string(flag_recnum_string,flag_filename)
            endif else begin
                index_recnum_string = "*"
            endelse
            all_recnums[i] = index_recnum_string
        endfor    
        ff->set_index_value_recnums, all_recnums
    endelse

END

;+
; Add a flag filename to the list of flag files currently begin managed.
; @param flag_filename {in}{required}{type=string} full path to flag file
;-
PRO FLAGS::add_flag_filename, flag_filename
    compile_opt idl2, hidden

    if n_elements(*self.files) eq 0 then begin
        *self.files = flag_filename
    endif else begin
        *self.files = [*self.files,flag_filename]
    endelse   

END

;+
; Adds a file index base to the list of these values.
; The file index base values are used for converting a spectrum's index, or 
; record number for in a single index file (an index file for one sdfits file),
; to its record number in an index file that manages several fits file.
; This is used in converting record numbers from their values recorded in the flag file to
; their corresponding values for the current index file, which may differ if the index file
; manages multiple fits files.
; @param file_index_base {in}{required}{type=long} value of record number for first spectrum in a multi-sdfits file index file.
;-
PRO FLAGS::add_file_index_base, file_index_base
    compile_opt idl2, hidden

    if n_elements(*self.file_index_bases) eq 0 then begin
        *self.file_index_bases = file_index_base
    endif else begin
        *self.file_index_bases = [*self.file_index_bases,file_index_base]
    endelse    

END

;+
; Adds the flag file name and index base to this class's list of these variables.
; The index filename is converted to the flag filename simply by changing the extension.
; This is used in converting record numbers from their values recorded in the flag file to
; their corresponding values for the current index file, which may differ if the index file
; manages multiple fits files.
; @param index_filename {in}{required}{type=string} full path to index file
; @param index_base {in}{required}{type=long} value of record number for first spectrum in a multi-sdfits file index file.
;-
PRO FLAGS::add_index_file_info, index_filename, index_base
    compile_opt idl2, hidden

    if self.debug then print, "adding index file info: ", index_filename, index_base

    self->add_flag_filename, self->index_filename_to_flag_filename(index_filename)
    self->add_file_index_base, index_base

END

;+
; Searches the files member variable for a match with given flag filename, and uses this index
; to return the  value of record number for first spectrum in a multi-sdfits file index file.
; This is used in converting record numbers from their values recorded in the flag file to
; their corresponding values for the current index file, which may differ if the index file
; manages multiple fits files.
; The returned index base will be zero for the special case of one sdfits file per index file,
; or for the first fits file in a multiple fits file index file.
; @param flag_filename {in}{required}{type=string} full path to flag file
; @returns  value of record number for first spectrum in a multi-sdfits file index file.
;-
FUNCTION FLAGS::get_file_index_base, flag_filename
    compile_opt idl2, hidden

    if not self->has_valid_files() then return, -1
    
    file_index = -1
    for i=0,n_elements(*self.files)-1 do begin
        if (*self.files)[i] eq flag_filename then file_index = i
    endfor
    if file_index eq -1 then begin
        file_index_base = -1
    endif else begin
        file_index_base = (*self.file_index_bases)[file_index]
    endelse

    return, file_index_base

END

;+
; Retrieves the value of record number for first spectrum in a multi-sdfits file index file,
; and subtracts this from the given index number.
; This is used in converting record numbers from their values recorded in the flag file to
; their corresponding values for the current index file, which may differ if the index file
; manages multiple fits files.
; @param index_recnum {in}{required}{type=long} the record number found in the current index file.
; @param flag_filename {in}{required}{type=string} full path to flag file
; @returns the record number found in the fits files index file corresponding to the same spectrum referenced by index_recnum
;-
FUNCTION FLAGS::index_recnum_to_flag_recnum, index_recnum, flag_filename
    compile_opt idl2, hidden

    file_index_base = self->get_file_index_base(flag_filename)
    return, index_recnum - file_index_base

END

;+
; Retrieves the value of record number for first spectrum in a multi-sdfits file index file,
; and adds this to the given record number from the given flag file.
; This is used in converting record numbers from their values recorded in the flag file to
; their corresponding values for the current index file, which may differ if the index file
; manages multiple fits files.
; @param flag_recnum {in}{required}{type=long} the record number found in the flag file.
; @param flag_filename {in}{required}{type=string} full path to flag file
; @returns the record number found in the current index file
;-
FUNCTION FLAGS::flag_recnum_to_index_recnum, flag_recnum, flag_filename
    compile_opt idl2, hidden

    file_index_base = self->get_file_index_base(flag_filename)
    return, flag_recnum + file_index_base

END

;+
; Prints out flag lines in all flag files, either nearly as the appear in the flag file, or
; in a special format.
; @keyword idstring {in}{optional}{type=string} list only flag lines that match this idstring
; @keyword summary {in}{optional}{type=boolean} if set, print in summary format, if not, print in verbose mode.
;-
PRO FLAGS::list, idstring=idstring, summary=summary 
    compile_opt idl2, hidden

    if not self->has_valid_files() then return

    if n_elements(summary) eq 0 then begin
        self->list_verbose, idstring=idstring
    endif else begin
        self->list_formatted, idstring=idstring
    endelse

END

;+
; Prints the contents of all flag files, nearly in the format they appear in the flag files.
; The Unique IDs are prepended to each line, and the delminators are converted to white space.
; @keyword idstring {in}{optional}{type=string} list only flag lines that match this idstring
;-
PRO FLAGS::list_verbose, idstring=idstring 
    compile_opt idl2, hidden

    if not self->has_valid_files() then begin
        print,'No flags for the current dataset.'
        return
    endif

    ; get the header - same for all flag files
    ; place the ID column at the beggining
    status = 0
    header = self->get_verbose_header(status)
    
    cnt = 0
    index_lines = self->get_index_value_lines_with_id(cnt,idstring=idstring)

    ; replace all the separator chars with blank spaces
    index_lines = self->replace_deliminators_in_lines(index_lines, " ")
    
    if cnt ne 0 then begin
        ; only print the header if there are flag lines to print
        if status eq 1 then print, header
        for j=0,n_elements(index_lines)-1 do print, index_lines[j]
    endif else begin
	print,'No flags for the current dataset.'
    endelse  

END

;+
; Replaces all delminators that appear in the given strings with the given replacement character.
; @param lines {in}{required}{type=string array} lines to adjust
; @param replacement {in}{required}{type=string array} character used to replace deliminators
; @returns the given lines with the deliminators replaced by replacement param.
;-
FUNCTION FLAGS::replace_deliminators_in_lines, lines, replacement
    compile_opt idl2, hidden

    deliminator = self->get_deliminator(status)

    if status eq 0 then return, lines
        
    for i=0,n_elements(lines)-1 do begin
        line = lines[i]
        while (((j = strpos(line, deliminator))) ne -1) do $
            strput, line, replacement, j     
        lines[i] = line    
    endfor
 
    return, lines

END

;+
; Returns lines from flag flag files, with record numbers corresponding to
; their values in the current index file, along with their unique ID numbers
; prepended to the begining of each line.
; This is used for listing in verbose mode.
; @param count {out}{optional}{type=long} the number of lines returned
; @keyword idstring {in}{optional}{type=string} get only flag lines that match this idstring
; @returns string array ready for use in listing in verbose mode
;- 
FUNCTION FLAGS::get_index_value_lines_with_id, count, idstring=idstring
    compile_opt idl2, hidden
    
    ; retrieve lines from flag flag files, with record numbers corresponding to
    ; their values in the current index file
    lines = self->get_index_value_lines(count,idstring=idstring)

    if count eq 0 then return, -1
    
    ; get lines from each file at a time
    for i=0,n_elements(*self.flag_files)-1 do begin
        ; get the raw lines, that start off with the flag recnum
        status = 0
        lines_and_nums = (*self.flag_files)[i]->get_lines_and_line_nums(idstring=idstring,status)
        if status ne 0 then begin
            num_dim = size(lines_and_nums,/n_dim)
            if num_dim eq 1 then begin 
                num_lines=1 
            endif else begin
                sz=size(lines_and_nums,/dim)
                num_lines = sz[1]
            endelse    
            line_nums = lines_and_nums[1,0:num_lines-1]
            dlm = (*self.flag_files)[i]->get_deliminator()
            flag_filename = (*self.flag_files)[i]->get_file_name()
            ; get the flag id for each line
            for j=0,n_elements(line_nums)-1 do begin
                id = self->get_flag_id(flag_filename, line_nums[j])
                if n_elements(ids) eq 0 then ids=[id] else ids=[ids,id]
            endfor
        endif
    endfor    

    ; add the line ids to the flag lines
    id_lines = strarr(n_elements(lines))
    for i=0,n_elements(lines)-1 do begin
        id_lines[i] =  strtrim(string(ids[i]),2)+lines[i]
    endfor    

    return, id_lines    
    
END
;+
; Retrieve lines from flag flag files, with record numbers corresponding to
; their values in the current index file
; This is used for listing in verbose mode.
; @param count {out}{optional}{type=long} the number of lines returned
; @keyword idstring {in}{optional}{type=string} get only flag lines that match this idstring
; @returns string array corresponding to lines in flag files, with record number adjusted.
;- 
FUNCTION FLAGS::get_index_value_lines, count, idstring=idstring
    compile_opt idl2, hidden
    
    count = 0

    ; get lines from each file at a time
    for i=0,n_elements(*self.flag_files)-1 do begin
        ; get the raw lines, that start off with the flag recnum
        status = 0
        lines = (*self.flag_files)[i]->get_lines(idstring=idstring,status)
        if status ne 0 then begin
            count += n_elements(lines)
            ; convert this flag recnum to an index recnum
            dlm = (*self.flag_files)[i]->get_deliminator()
            flag_filename = (*self.flag_files)[i]->get_file_name()
            index_lines = self->convert_flag_lines_to_index_lines(lines,dlm,flag_filename)
            if n_elements(all_index_lines) eq 0 then begin
                all_index_lines = index_lines
            endif else begin
                all_index_lines = [all_index_lines,index_lines]
            endelse    
        endif    
    endfor
    if count ne 0 then return, all_index_lines else return, -1
END

;+
; Given lines from a flag file, returns the same lines, but with the
; record numbers adjusted to reflect the same spectra in the current index file.
; Remember that if the current index file manages multiple sdfits files, the 
; record numbers in the flag files must be adjusted.
; @param lines {in}{required}{type=string array} lines from a flag file
; @param deliminator {in}{required}{type=string} character used to deliminate values in a flag file
; @param flag_filename {in}{required}{type=string} full path to flag file
; @returns the same lines passed in, but with their record number adjusted.
;-
FUNCTION FLAGS::convert_flag_lines_to_index_lines, lines, deliminator, flag_filename
    compile_opt idl2, hidden

    for i=0,n_elements(lines)-1 do begin
        line = lines[i]
        ; get the flag recnum
        line_cols = strsplit(line,deliminator,/extract)
        flag_recnum_string = strtrim(line_cols[0],2)
        if flag_recnum_string ne "*" then begin
            ; convert the line
            index_recnum_string = self->flag_recnum_string_to_index_recnum_string(flag_recnum_string,flag_filename)
            index_line = ' '+index_recnum_string + deliminator + $
                strjoin(line_cols[1:n_elements(line_cols)-1],deliminator)
        endif else begin
            ; nothing to convert
            index_line = line
        endelse    
        if i eq 0 then index_lines=[index_line] else index_lines=[index_lines,index_line]
    endfor    

    return, index_lines

END

;+
; Checks status of flag file pointer
; @returns 1 - valid files, 0 - no valid flag files
;-
FUNCTION FLAGS::has_valid_files
    compile_opt idl2, hidden

    if ptr_valid(self.flag_files) then begin
        if n_elements(*self.flag_files) eq 0 then begin
            return, 0
        endif else begin
            return, 1 ;n_elements(*self.flag_files)
        endelse    
    endif else begin
        return, 0
    endelse

END

;+
; The format for listing flag file contents in summary mode is stored in
; a flag file object.  This method  finds and flag file object, and 
; retrieves that format.
; @param status {out}{optional}{type=long} 0 - failure, 1 - success
; @returns The format for listing flag file contents in summary mode
;-
FUNCTION FLAGS::get_values_list_format, status
    compile_opt idl2, hidden

    i = self->find_file_with_flags()
    if i eq -1 then begin
        str = ""
        status = 0
    endif else begin
        str = (*self.flag_files)[i]->get_values_list_format()
        status = 1
    endelse
    return, str

END

;+
; The format for listing flag file headers in summary mode is stored in
; a flag file object.  This method  finds and flag file object, and 
; retrieves that format.
; @param status {out}{optional}{type=long} 0 - failure, 1 - success
; @returns The format for listing flag file headers in summary mode
;-
FUNCTION FLAGS::get_formatted_header, status
    compile_opt idl2, hidden

    if not self->has_valid_files() then begin
        status = 0
        return, ""
    endif

    i = self->find_file_with_flags()
    if i eq -1 then begin
        header = ""
        status = 0
    endif else begin
        ; prepend the ID column
        header = (*self.flag_files)[i]->get_formatted_header()
        header = "#ID  "+strmid(header,1,strlen(header)-1)
        status = 1
    endelse
    return, header

END

;+
; The header used when listing flag file headers in verbose mode is stored in
; a flag file object.  This method  finds and flag file object, and 
; retrieves that header.
; @param status {out}{optional}{type=long} 0 - failure, 1 - success
; @returns The header used when listing flag file headers in verbose mode 
;-
FUNCTION FLAGS::get_verbose_header, status
    compile_opt idl2, hidden

    i = self->find_file_with_flags()
    if i eq -1 then begin
        header = ""
        status = 0
    endif else begin
        ; prepend the ID column
        header = (*self.flag_files)[i]->get_verbose_header()
        header = "#ID,"+strmid(header,1,strlen(header)-1)
        status = 1
    endelse
    return, header

END

;+
; Returns the character used for separating values in flag files.
; Foramt info for flag files are stored in flag file objects.  One of these
; objects must be retrieved first to get format info.
; @param status {out}{optional}{type=long} 0 - failure, 1 - success
; @returns The character used for separating values in flag files.
;-
FUNCTION FLAGS::get_deliminator, status
    compile_opt idl2, hidden

    i = self->find_file_with_flags()
    if i eq -1 then begin
        deliminator = ""
        status = 0
    endif else begin
        deliminator = (*self.flag_files)[i]->get_deliminator()
        status = 1
    endelse
    return, deliminator

END

;+
; Looks for a flag file object that manages a valid flag file.
; @returns the index to the flag file object, or -1 if none found.
;-
FUNCTION FLAGS::find_file_with_flags
    compile_opt idl2, hidden

    f = -1
    for i=0, n_elements(*self.flag_files)-1 do begin
        if (*self.flag_files)[i]->has_valid_rows() then f = i 
    endfor
    return, f

END

;+
; Prints contents of flag files in a formatted version.
; Columns have fixed width, and if values are wider then this width
; a symbol is used to denote the truncation of these values.
; @keyword idstring {in}{optional}{type=string} prints only flag lines that match this idstring
;-
PRO FLAGS::list_formatted, idstring=idstring
    compile_opt idl2, hidden

    if not self->has_valid_files() then begin
        print,'No flags for the current dataset.'
        return
    endif

    ; get the header - same for all flag files
    hstatus = 0
    header = self->get_formatted_header(hstatus)
    
    rows_format = self->get_values_list_format(status)
    if status eq 0 then begin
        print,'No flags for the current dataset.'
        return
    endif

    index_value_rows = self->get_index_value_rows(cnt,ids,useflag=idstring)

    ; print each formatted line, prepending the ID
    if cnt ne 0 then begin
        if hstatus eq 1 then print, header
        for i=0,n_elements(index_value_rows)-1 do begin
            line = self->get_summary_line(index_value_rows[i],rows_format)
            id = string(strtrim(ids[i],2),format='(a3)')
            print, id+" "+line
        endfor    
    endif else begin
        print,'No flags for the current dataset.'
    endelse

END

;+
; Given a structure that represents a line form the flag file (with record number already adjusted),
; copy this structure to a line that is ready for printing in summary format.
; This involves going through each structure field and turncating its value to the length
; specified in the given format.
; @param line_strct {in}{required}{type=strct} represents a line form the flag file (with record number already adjusted)
; @param line_format {in}{required}{type=string} string that would print out this structure if used with format keyword
; @returns string ready to print as a line in summary format
;-
FUNCTION FLAGS::get_summary_line, line_strct, line_format 
    compile_opt idl2, hidden

    ; get the names of the columns
    columns = tag_names(line_strct)
    
    ; get the length for each column:
    ; first strip off the parenthases at each end
    stripped_format = strmid(line_format,1,strlen(line_format)-2)
    ; the format for each column and space is separated by a comma
    formats = strsplit(stripped_format,",",/extract)
    ; get only the formats for each column, ignore the space formats
    for i=0,n_elements(formats)-1 do begin
        if i MOD 2 eq 0 then begin
            f = long(strmid(formats[i],1,strlen(formats[i])-1))
            if n_elements(fs) eq 0 then fs=[f] else fs=[fs,f]
        endif
    endfor

    ; go through each column, and see if it's beyond the allocated space
    for i=0,n_elements(columns)-1 do begin
        if fs[i] lt strlen(strtrim(line_strct.(i),2)) then begin
            ; truncate it, using special symbol to show this
            ; dont just replace the last character, make sure that
            ; numbers aren't misreprented
            values = strsplit(line_strct.(i),",",/extract)
            if n_elements(values) eq 1 then begin
                line_strct.(i) = strmid(line_strct.(i),0,fs[i]-1)+'+'
            endif else begin
                len = 0
                line = ""
                num_values = 0
                while strlen(line) lt fs[i] do begin
                    oldline = line
                    line = strjoin(values[0:num_values],",")
                    num_values +=1
                endwhile
                line_strct.(i) = oldline+",+" 
            endelse
        endif
    endfor
    
    return, string(line_strct, format=line_format)
    
END

;+
; Returns structures representing desired lines from flag files.
; The desired lines are determined by the optional
; useflag and skipflag keywords.
; @param count {out}{optional}{type=long} number of structures returned
; @param index_recnums {out}{optional}{type=long} the value of the structures' returned record numbers when converted to be relative to the current index file.
; @keyword _EXTRA {in}{optional}{type=strct} useflag and skipflag kewords
; @returns structures representing desired lines from flag files
;-
FUNCTION FLAGS::get_flag_strcts, count, index_recnums, _EXTRA=ex 
    compile_opt idl2, hidden
    
    count = 0
    index_recnums = -1
    flags_used_count = 0

    ; if now flags are being used, the flag structures won't be needed
    if self->are_all_flags_off(_EXTRA=ex) then return, -1

    if self->are_all_flags_on(_EXTRA=ex) then begin
        ; retrieve all the flag structures, and index record numbers
        index_recnums = self->get_index_value_recnums()
        return, self->get_all_row_strcts(count)
    endif    

    ; use the useflag and skipflag keywords to determine what the idstrings
    ; of all flag lines to be used
    flags_used = self->get_flag_idstrings_used(_EXTRA=ex, flags_used_count)

    if flags_used_count eq 0 then return, -1

    ; get flag rows only for the flags used
    for i=0,n_elements(flags_used)-1 do begin
        for j=0,n_elements(*self.flag_files)-1 do begin
            status = 0
            ; get the flag structures from this flag file for a specific flag idstring
            rows = (*self.flag_files)[j]->get_row_strcts(idstring=flags_used[i],status,indicies)
            file_recnums = (*self.flag_files)[j]->get_index_value_recnums()
            if status ne 0 then begin
                count += n_elements(rows)
                ; keep track of only the index valued record numbers used
                recnums_used = file_recnums[indicies]
                if n_elements(all_rows) eq 0 then begin
                    all_rows = rows
                    index_recnums = [recnums_used]
                endif else begin
                    all_rows = [all_rows,rows]
                    index_recnums = [index_recnums,recnums_used]
                endelse    
            endif
        endfor
    endfor

    if count eq 0 then all_rows = -1

    return, all_rows
            
END

;+
; Now only used when printing in list summary format.  This should eventually
; be deprecated so that get_flag_strcts is used (its much faster).
; Returns structures representing desired lines from flag files, with record numbers adjusted
; to their values in the current index file.  The desired lines are determined by the optional
; useflag and skipflag keywords.
; @keyword _EXTRA {in}{optional}{type=strct} useflag and skipflag kewords
; @returns structures representing desired lines from flag files, with record numbers adjusted
;-
FUNCTION FLAGS::get_index_value_rows, count, ids, _EXTRA=ex 
    compile_opt idl2, hidden
    
    count = 0
    flags_used_count = 0

    if self->are_all_flags_off(_EXTRA=ex) then return, -1

    if self->are_all_flags_on(_EXTRA=ex) then begin
        ids = self->get_all_flag_ids()
        return, self->get_all_index_value_rows(count)
    endif    

    ; use the useflag and skipflag keywords to determine what the idstrings
    ; of all flag lines to be used
    flags_used = self->get_flag_idstrings_used(_EXTRA=ex, flags_used_count)

    if flags_used_count eq 0 then return, -1

    ; get ids only for the flags used
    ids = self->get_flag_ids_used(flags_used)
    
    ; get flag rows only for the flags used
    for i=0,n_elements(flags_used)-1 do begin
        for j=0,n_elements(*self.flag_files)-1 do begin
            status = 0
            rows = (*self.flag_files)[j]->get_row_strcts(idstring=flags_used[i],status)
            if status ne 0 then begin
                ; convert this flag recnum to an index recnum
                flag_filename = (*self.flag_files)[j]->get_file_name()
                index_rows = self->convert_flag_rows_to_index_rows(rows,flag_filename)
                count += n_elements(index_rows)
                if n_elements(all_index_rows) eq 0 then begin
                    all_index_rows = index_rows
                endif else begin
                    all_index_rows = [all_index_rows,index_rows]
                endelse    
            endif
        endfor
    endfor

    if count eq 0 then all_index_rows = -1

    return, all_index_rows
    
END    
    
;+
; Returns all the flag IDs, which should just be 0..N, N==number of flag lines.
; @param count {out}{optional}{type=long} number of IDs returned
; @returns array of integer IDs
;-
FUNCTION FLAGS::get_all_flag_ids, count
    compile_opt idl2, hidden

    count = 0
    if not self->has_valid_flag_ids() then return, -1

    flag_ids = *self.flag_ids
    count = self->get_number_of_flag_ids()
    if count eq 1 then begin
        return, flag_ids[0]
    endif else begin    
        return, flag_ids[0,0:count-1]
    endelse    

END

;+
; Simply returns the number of flag ID's. This should be equal to the number of 
; all flag lines.
; @returns number of flag IDs
;-
FUNCTION FLAGS::get_number_of_flag_ids
    compile_opt idl2, hidden
    if not self->has_valid_flag_ids() then return, 0
    num_dims = size(*self.flag_ids,/n_dim)
    if num_dims eq 1 then begin
        return, 1
    endif else begin
        sz = size(*self.flag_ids)
        return, sz[2]
    endelse
END

;+
; Returns the unique integer IDs that match flag lines that contain the given IDSTRINGs.
; @param idstrings {in}{required}{type=string array} array of IDSTRINGs.
; @param count {out}{optional}{type=long} number of IDs returned
; @returns the  unique integer IDs used by IDSTRINGs.
;-
FUNCTION FLAGS::get_flag_ids_used, idstrings, count
    compile_opt idl2, hidden

    count = 0

    ; get flag ids only for the idstrings given
    for i=0,n_elements(idstrings)-1 do begin
        for j=0,n_elements(*self.flag_files)-1 do begin
            status = 0
            flag_file_name  = (*self.flag_files)[j]->get_file_name()
            lines_and_nums = (*self.flag_files)[j]->get_lines_and_line_nums(idstring=idstrings[i],status)
            if status ne 0 then begin
                num_dim = size(lines_and_nums,/n_dim)
                if num_dim eq 1 then begin 
                    num_lines=1 
                endif else begin
                    sz=size(lines_and_nums,/dim)
                    num_lines = sz[1]
                endelse    
                count += num_lines 
                line_nums = lines_and_nums[1,0:num_lines-1]
                ; get the corresponding IDs for this flag file and the lines found for the idstring.
                for k=0,n_elements(line_nums)-1 do begin
                    id = self->get_flag_id(flag_file_name, long(line_nums[k]))
                    if n_elements(ids) eq 0 then ids=[id] else ids=[ids,id]
                endfor
            endif    
        endfor ; for each file        
    endfor ; for each idstring

    if n_elements(ids) eq 0 then return, -1 else return, ids

END

;+
; Returns structures representing all lines in all flag files, with the 
; record number field adjusted to reflect the correct value in the current index file.
; Remember that if the current index file manages multiple sdfits files, the 
; record numbers in the flag files must be adjusted.
; @param count {out}{optional}{type=long} number of structures returned
; @returns array of structures representing all lines in all flag files
;-
FUNCTION FLAGS::get_all_index_value_rows, count
    compile_opt idl2, hidden
    
    ; get the structures that represent each line for each flag file
    for i=0,n_elements(*self.flag_files)-1 do begin
        ; get the structures that represent each line in flag file
        status = 0
        rows = (*self.flag_files)[i]->get_row_strcts(status)
        if status ne 0 then begin
            ; convert this flag recnum to an index recnum
            flag_filename = (*self.flag_files)[i]->get_file_name()
            index_rows = self->convert_flag_rows_to_index_rows(rows,flag_filename)
            count += n_elements(index_rows)
            if n_elements(all_index_rows) eq 0 then begin
                all_index_rows = index_rows
            endif else begin
                all_index_rows = [all_index_rows,index_rows]
            endelse    
        endif
    endfor

    if count eq 0 then all_index_rows = -1

    return, all_index_rows
END

;+
; Adjusts the record number field in the given structures to match the record number value
; used in the current index file.
; Remember that if the current index file manages multiple sdfits files, the 
; record numbers in the flag files must be adjusted.
; @param rows {in}{required}{type=strct array} array of structures representing lines in flag files
; @param flag_filename {in}{required}{type=string} filename of the flag file where these rows came from
; @returns the given rows, with their record number field adjusted
;-
FUNCTION FLAGS::convert_flag_rows_to_index_rows, rows, flag_filename
    compile_opt idl2, hidden

    for i=0,n_elements(rows)-1 do begin
        flag_recnum_string = rows[i].recnum
        ; nothing to convert if using the NA symbol
        if flag_recnum_string ne "*" then begin
            rows[i].recnum = self->flag_recnum_string_to_index_recnum_string(flag_recnum_string,flag_filename)
        endif 
    endfor    

    return, rows

END

;+
; Converts the string found in flag file lines that represent flagged record numbers.  This string may
; represent a range of record numbers, compressed using a certain syntax.  After decompression, the integer
; values this string represents then must be adjusted to reflect the same spectra in the current index file.
; Remember that if the current index file manages multiple sdfits files, the 
; record numbers in the flag files must be adjusted.
; @param flag_filename {in}{required}{type=string} filename of the flag file where the given string came from
; @returns string identical to passed string, except the values have been adjusted for the current index file.
;-
FUNCTION FLAGS::flag_recnum_string_to_index_recnum_string, flag_recnum_string, flag_filename

    if not self->has_valid_files() then return, ""

    ; this could just be a scalar, or a compressed range
    ; we need to convert string to an integer array, convert it, then
    ; recreate the appropriate string
    decompressed_recnums = decompress_ints(flag_recnum_string)
    for j=0,n_elements(decompressed_recnums)-1 do begin
        flag_recnum = decompressed_recnums[j]
        ; convert actual integer values
        index_recnum = self->flag_recnum_to_index_recnum(flag_recnum,flag_filename)
        if j eq 0 then index_recnums=[index_recnum] else index_recnums=[index_recnums,index_recnum]
    endfor    
    return, compress_ints(index_recnums)


END

;+
; Should change this to get_unique_idstrings.
; Collects all idstrings from all flag files, and returns the sorted, unique idstrings.
; @param count {out}{optional}{type=long} number of structures returned
; @returns unique idstrings found in all flag files
;-
FUNCTION FLAGS::get_unique_ids, count
    compile_opt idl2, hidden

    for i=0,n_elements(*self.flag_files)-1 do begin
        uniq_ids = (*self.flag_files)[i]->get_unique_ids(cnt)
        if cnt ne 0 then begin
            if n_elements(all_ids) eq 0 then all_ids=[uniq_ids] else all_ids=[all_ids,uniq_ids]
        endif    
    endfor

    if n_elements(all_ids) eq 0 then begin
        count = 0
        return, -1
    endif else begin
        ; find the unique ids from the above collection
        unique_ids = all_ids[uniq(all_ids,sort(all_ids))]
        count = n_elements(unique_ids)
        return, unique_ids
    endelse

END

;+
; Should change this to list_unique_idstrings
; Takes the lines returned from get_unique_ids, and prints them
;-
PRO FLAGS::list_ids
    compile_opt idl2, hidden

    unique_ids = self->get_unique_ids(count)
    
    if count ne 0 then begin  
        print, "Unique Flag Ids: "
        for i=0,n_elements(unique_ids)-1 do begin
            print, unique_ids[i]
        endfor
    endif else begin
        print, "No flags for the current dataset."
    endelse

END
  
;+
; If a flag file already exists for the given fits file, this flag file is loaded.
; Also stores information so that record numbers between the index file and flag file
; can be adjusted.
; Remember that if the current index file manages multiple sdfits files, the 
; record numbers in the flag files must be adjusted.
; @param fits_name {in}{required}{type=string} filename of the fits file
; @param base_index {in}{required}{type=long} where in the current index file the first spectrum of this fits file appears
;-
PRO FLAGS::update_flags, fits_name, base_index
    compile_opt idl2, hidden

    if self.debug then print, "update_flags with: ", fits_name, base_index

    index_name = self->fits_filename_to_index_filename(fits_name)
    flag_file = self->fits_filename_to_flag_filename(fits_name)
    

    self->add_index_file_info, index_name, base_index
    
    ; if the file exists, and is not already loaded, load it
    flag_file = self->get_full_file_name(flag_file)
    file_exists = file_test(flag_file)
    flag_file_loaded = self->is_flag_file_loaded(flag_file) 
    if file_exists and flag_file_loaded eq 0 then begin
        self->load_flag_file, flag_file
    endif
    
END    
    

;+
; Is the given flag file name currently loaded in memory?
; @param file_name {in}{required}{type=string} filename of the flag file
; @returns 0 - not loaded; 1 - is loaded
;-
FUNCTION FLAGS::is_flag_file_loaded, file_name
    compile_opt idl2, hidden

    flag_file = self->get_flag_file_obj(file_name)
    return, flag_file->is_file_loaded()

END

;+
; Given a filename, return it full path name, taking into account all possible pertabations.
; @param file_name {in}{required}{type=string} filename
; @returns full path to the given filename
;-
FUNCTION FLAGS::get_full_file_name, file_name
    compile_opt idl2, hidden

    ; if the file_name already has a path attatched to it, don't add to it
    if strpos(file_name,'/') eq -1 then begin
        if self.file_path eq "" then begin
            ; no filepath to prepend, return filename as is
            full_name = file_name
        endif else begin
            ; look for / at end of file_path
            last_char = strmid(self.file_path,strlen(self.file_path)-1,1)
            if last_char eq '/' then begin
                ; get rid of this backslash at the end of the path
                file_path = strmid(self.file_path,0,strlen(self.file_path)-1)
            endif else begin
                file_path = self.file_path
            endelse    
            ; full path name is just the path plus the given name.
            full_name = file_path +'/'+ file_name
        endelse
    endif else begin
        ; the given file name already has a path 
        full_name = file_name
    endelse

    return, full_name

END

;+
; Certain values in flag files integer ranges stored as a string.  This string
; may use a special syntax for effectively compressing ranges of integers.
; This method takes the string value from part of a line in a flag file, and converts
; it into an integer array by decompressing the string.
; @param flag_string {in}{required}{type=string} string representing integer range using a special syntax
; @returns integer array
;-
FUNCTION FLAGS::get_int_array_from_flag_string, flag_string, count
    compile_opt idl2, hidden

    if not self->has_valid_files() then begin 
        count = 0
        return, -1
    endif    
    if flag_string ne "*" then begin
        int_array = decompress_ints(flag_string)
        count = n_elements(int_array)
    endif else begin
        int_array = -1
        count = 0
    endelse    
    return, int_array

END    

;+
; Makes object verbose
;-
PRO FLAGS::set_debug_on
    compile_opt idl2, hidden

    self.debug = 1
    self->set_flag_files_debug, 1

END    

;+
; Makes object quiet
;-
PRO FLAGS::set_debug_off
    compile_opt idl2, hidden

    self.debug = 0
    self->set_flag_files_debug, 0

END    

;+
; Sets debug flag for all flag file objects
; @param debug {in}{required}{type=long} 0 - set debug off, 1 - set debug on
;-
PRO FLAGS::set_flag_files_debug, debug

    for i=0,n_elements(*self.flag_files)-1 do begin
        if debug eq 1 then begin
            (*self.flag_files)[i]->set_debug_on
        endif else begin    
            (*self.flag_files)[i]->set_debug_off
        endelse    
    endfor

END

;+
; For testing purposes only.
; Sets the flag file format version and class that flag files are to use.
; @param version_num {in}{required}{type=string} format version for flag files
; @param version_class {in}{required}{type=string} class to be used to read in rows sections of flag files
;-
PRO FLAGS::set_flag_file_version, version_num, version_class

    self.version = version_num
    self.flags_section_class = version_class

    for i=0,n_elements(*self.flag_files)-1 do begin
        (*self.flag_files)[i]->set_flags_section_version, version_num, version_class
    endfor

END


;+
; Checks keywords to see if all flags are to be used.
; Useflag keyword takes precedence. If none are set, use all flags.
; @keyword useflag {in}{optional}{type=boolean, string array} if set to 1, then all flags are used; if set to
; a string array, then only those idstrings included are used.
; @keyword skipflag {in}{optional}{type=boolean, string array} if set to 1, then all flags are skipped; if set to
; a string array, then only those idstrings included are skipped.
; @returns 0 - not all flags are used, 1 - all flags are used.
;-
FUNCTION FLAGS::are_all_flags_on, useflag=useflag, skipflag=skipflag
    compile_opt idl2, hidden
    
    ; useflag keyword takes presidence
    if n_elements(useflag) ne 0 then begin
        if size(useflag,/type) eq 7 then begin
            ; certain flags are choosen
            return, 0
        endif else begin
            ; use all flags
            return, 1
        endelse
    endif

    ; if any flags are turned off, then not ALL are used
    if n_elements(skipflag) ne 0 then begin
        return, 0
    endif

    ; if no keyword set, then default to useflag=1
    return, 1

END

;+
; Checks keywords to see if all flags are to be skipped.
; Useflag keyword takes precedence. If none are set, use all flags.
; @keyword useflag {in}{optional}{type=boolean, string array} if set to 1, then all flags are used; if set to
; a string array, then only those idstrings included are used.
; @keyword skipflag {in}{optional}{type=boolean, string array} if set to 1, then all flags are skipped; if set to
; a string array, then only those idstrings included are skipped.
; @returns 0 - some flags are used, 1 - all flags are off.
;-
FUNCTION FLAGS::are_all_flags_off, useflag=useflag, skipflag=skipflag
    compile_opt idl2, hidden
    
    ; useflag keyword takes presidence - if ANY set, then false
    if n_elements(useflag) ne 0 then begin
            return, 0
    endif

    ; if any flags are turned off
    if n_elements(skipflag) ne 0 then begin
        if size(skipflag,/type) eq 7 then begin
            ; only certain flags are turned off, not all
            return, 0
        endif else begin
            return, 1
        endelse    
    endif

    ; if no keyword set, then default to useflag=1
    return, 0

END

;+
; Returns the idstrings of all flag lines that match the criteria of the given keywords.
; @keyword useflag {in}{optional}{type=boolean, string array} if set to 1, then all flags are used; if set to
; a string array, then only those idstrings included are used.
; @keyword skipflag {in}{optional}{type=boolean, string array} if set to 1, then all flags are skipped; if set to
; a string array, then only those idstrings included are skipped.
; @param count {out}{optional}{type=long} number of idstrings returned
;-
FUNCTION FLAGS::get_flag_idstrings_used, useflag=useflag, skipflag=skipflag, count
    compile_opt idl2, hidden

    all_flag_ids = self->get_unique_ids(cnt)

    if cnt eq 0 then begin   
        count = 0
        return, -1
    endif    

    ; useflag keyword takes precedence
    if n_elements(useflag) ne 0 then begin
        if size(useflag,/type) ne 7 then begin
            count = cnt
            return, all_flag_ids
        endif else begin
            ; check that the flags passed in exist before returning them
            count = 0
            for i=0,n_elements(useflag)-1 do begin
                ind = where(strtrim(useflag[i],2) eq all_flag_ids, flag_matches)
                if flag_matches ne 0 then begin
                    if count eq 0 then flag_ids_used=[all_flag_ids[ind]] else $
                        flag_ids_used=[flag_ids_used,all_flag_ids[ind]]
                    count += 1
                endif
            endfor
            if count eq 0 then return, -1 else return, flag_ids_used
        endelse    
    endif

    ; process skipflag keyword if useflag keyword was not used
    if n_elements(skipflag) ne 0 then begin
        if size(skipflag,/type) ne 7 then begin
            ; skipflag = 1
            count = 0 
            return, -1
        endif else begin
            ; check that the flags passed in exist 
            count = 0
            for i=0,n_elements(skipflag)-1 do begin
                ind = where(strtrim(skipflag[i],2) eq all_flag_ids, flag_matches)
                if flag_matches ne 0 then begin
                    if count eq 0 then flags_not_used=[all_flag_ids[ind]] else $
                        flags_not_used=[flags_not_used,all_flag_ids[ind]]
                    count += 1
                endif
            endfor
            if count eq 0 then begin
                ; none of the skipflags actually exist, so use all flags
                count = n_elements(all_flag_ids)
                return, all_flag_ids
            endif else begin
                count = 0
                ; remove the flags not used
                for i=0,n_elements(all_flag_ids)-1 do begin
                    ind = where(strtrim(all_flag_ids[i],2) eq flags_not_used, cnt)
                    if cnt eq 0 then begin
                        if count eq 0 then flag_ids_used=[all_flag_ids[i]] else $
                            flag_ids_used=[flag_ids_used,all_flag_ids[i]]
                        count += 1    
                    endif
                endfor
                if count eq 0 then return, -1 else return, flag_ids_used
            endelse    
        endelse    
    endif

    ; if no keywords set, then use all ids
    count = n_elements(all_flag_ids)
    return, all_flag_ids

END    
    
;+
; Returns an array for all the record numbers in all the flag files, with
; their values given with respect to the current index file.
; @param status {out}{optional}{type=bool} 0 - failure, 1 - success
;-
FUNCTION FLAGS::get_index_value_recnums, status

    status = 1
    index_value_recnums = -1
    num_flags = self->get_num_flags()


    if self->has_valid_files() eq 0 or num_flags eq 0 then begin
        status = 0
        return, -1
    endif    

    index_value_recnums = strarr(num_flags)

    ; optimize for performance if there is only one file
    if n_elements(*self.flag_files) eq 1 then begin
        return, (*self.flag_files)[0]->get_index_value_recnums(status)
    endif else begin
        allStatus = 0
        r = -1
        for i=0,n_elements(*self.flag_files)-1 do begin
            recnums = (*self.flag_files)[i]->get_index_value_recnums(status)
            if status then begin
                if allStatus then r=[r,recnums] else r=[recnums]
                allStatus = 1
            endif
        endfor
        return, r
    endelse

END    

;+
; Returns the sum of all the flags in all flag files
; @returns the sum of all the flags in all flag files
;-
FUNCTION FLAGS::get_num_flags
    compile_opt idl2, hidden

    if not self->has_valid_files() then begin
        return, 0 
    endif else begin
        cnt = 0
        for i=0,n_elements(*self.flag_files)-1 do begin
            cnt += (*self.flag_files)[i]->get_num_lines()
        endfor
        return, cnt
    endelse

END

    
;+
; Method for returning structures that represent all the flags in all the
; flag files. 
; @param count {out}{optional}{type=long}
; @returns structures that represent all the flags in all flag files, -1 if none
;-
FUNCTION FLAGS::get_all_row_strcts, count

    if not self->has_valid_files() then begin
        count = 0
        return, -1
    endif    

    ; to optimize performance, if there is just one file, just 
    ; return its rows...
    if n_elements(*self.flag_files) eq 1 then begin
        count = (*self.flag_files)[0]->get_num_lines() 
        return, (*self.flag_files)[0]->get_row_strcts()
    endif else begin
        for i=0,n_elements(*self.flag_files)-1 do begin
            rows = (*self.flag_files)[i]->get_row_strcts(status)
            if status ne 0 then begin
                if n_elements(all_rows) eq 0 then all_rows=[rows] else all_rows=[all_rows,rows]
            endif    
        endfor
        count = n_elements(all_rows)
        if count ne 0 then return, all_rows else return, -1
    endelse    

END

;+
; Uses keyword inheritance to intercept the channel keywords and test 
; them for valid usage.
; Relevant keywords are : bchan, echan, chans, chanwidth
; bchan and echan are exclusive to chans and chanwidth.
; If bchan or echan are greater then one, then they must have the
; same length.
; chanwidth will default to 1.
; @returns 0 - keywords not valid, 1 - keywords valid
;-
FUNCTION FLAGS::check_channels_range, _EXTRA=ex 
    compile_opt idl2, hidden

    ; convert tags of the extra structure to keywords
    if n_elements(ex) eq 0 then return,1 
    keywords = tag_names(ex)
    for i=0,n_elements(keywords)-1 do begin
        if keywords[i] eq "BCHAN" then bchan = ex.(i) 
        if keywords[i] eq "ECHAN" then echan = ex.(i) 
        if keywords[i] eq "CHANS" then chans = ex.(i) 
        if keywords[i] eq "CHANWIDTH" then chanwidth = ex.(i) 
    endfor
    
    ; either bchan or echan are set, then chan and widths should not
    if n_elements(bchan) ne 0 or n_elements(echan) then begin
        if n_elements(chans) ne 0 or n_elements(chanwidth) ne 0 then begin
            message, "bchan and echan keywords are exclusive to chans and chanwidth keywords", /info
            return, 0
        endif
    endif

    ; chanwidth cant be set without chans
    if n_elements(chanwidth) ne 0 and n_elements(chans) eq 0 then begin
        message, "chans must be specified with chanwidth keyword", /info
        return, 0
    endif

    ; if chans is set, use this to set bchan and echan
    if n_elements(chans) ne 0 then begin
        ; what is the width?
        if n_elements(chanwidth) eq 0 then begin 
            width=1 
        endif else begin
            ; width MUST be an odd number
            if chanwidth MOD 2 eq 0 then begin
                message, "chanwidth must be an odd number.", /info
                return, 0
            endif    
        endelse  
    endif else begin 
        ; just bchan and/or echan must be set
        ; if only one begin or end channel is specified, the other end
        ; will default to the max or min range.
        ; if there is only one begining channel, then there must
        ; one or less end channels
        if n_elements(bchan) eq 1 then begin
            if n_elements(echan) gt 1 then begin
                message, "bchan and echan must have equal lengths if more then one range is to be specified", /info
                return, 0
            endif
        endif
        ; if there is only one end channel, then there must
        ; one or less begining channels
        if n_elements(echan) eq 1 then begin
            if n_elements(bchan) gt 1 then begin
                message, "bchan and echan must have equal lengths if more then one range is to be specified", /info
                return, 0
            endif
        endif    
        
        ; when specifying more then one channel range, bchan and echan must 
        ; be of same length
        if n_elements(bchan) gt 1 or n_elements(echan) gt 1 then begin
            if n_elements(bchan) ne n_elements(echan) then begin
                message, "when specifying more then one range, bchan and echan must have equal lengths.", /info
                return, 0
            endif
        endif    
            
    endelse    
    
    ; nifty trick to inherit keywords
    if 0 then self->set_flag, 0, _EXTRA=ex
    return, 1

END    

PRO FLAGS::show_state
  compile_opt idl2

  if ptr_valid(self.flag_files) then begin
     for i=0,n_elements(*self.flag_files)-1 do begin
        (*self.flag_files)[i]->show_state
     endfor
  endif else begin
     print,"no valid flag files in flags"
  endelse
end
