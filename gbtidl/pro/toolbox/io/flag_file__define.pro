; docformat = 'rst'

;+
; FLAG_FILE is the class for managing a single flag file.  Its main components
; are objects for managing the files header and flags sections.
; See image below for all IO Classes.
; 
; .. image:: ../../material/IDL_IO_classes.jpg
;       :width: 400
;       :alt: IDL IO classes
;
; :Fields:
;   file_name 
;       basename of the flag file
;   file_loaded 
;       boolean flag for determining if the file has been read
;   file_path 
;       the full path to this files location
;   header 
;       object responsible for reading/writing to the header section
;   rows 
;       object responsible for managing the flags section of the file
;   flags_section_class 
;       name of class that rows is an instantiation of
;   version 
;       version of format used by the flag file
;   old_versions 
;       previous format versions - used for conversions.
;   num_old_versions
;       number of string referred to by the old_versions pointer
;-
PRO flag_file__define

    b1 = { FLAG_FILE,  $
        file_name:string(replicate(32B,256)),  $
        file_loaded:0L, $
        file_path:string(replicate(32B,256)),      $
        header:obj_new(), $
        rows:obj_new(), $
        flags_section_class:string(replicate(32B,256)), $
        version:string(replicate(32B,3)), $
        old_versions:ptr_new(), $
        num_old_versions:0L, $
        info:{file_info}, $
        debug:0L $
    }

END

;+
; Class Constructor - flags and constants set here.
; @keyword file_name {in}{optional}{type=string} file name of index file
; @keyword file_path {in}{optional}{type=string} directory where file is located
; @keyword debug {in}{optional}{type=bool} object is verbose or quiet
;-
FUNCTION FLAG_FILE::init, file_name=file_name, file_path=file_path, debug=debug
    compile_opt idl2, hidden
    
    if keyword_set(file_name) then self.file_name = file_basename(file_name)
    if keyword_set(file_path) then self.file_path = file_path
    if keyword_set(debug) then self.debug = debug

    self.file_loaded = 0
    self.version = '1.0'
    self.flags_section_class = "flags_section_one_zero"

    self.old_versions = ptr_new([['0.0','flags_section_zero_zero']])
    self.num_old_versions = 1
        
    if keyword_set(file_name) then begin
        self.header = obj_new("header_index_section", self->get_full_file_name())
    endif else begin
        self.header = obj_new("header_index_section")
    endelse
    
    return, 1

END

;+
; Retrieves the array that specifies the types allowable for each column of 
; the flag file
; @returns a string array of column names and types
;-
FUNCTION FLAG_FILE::get_param_types
    compile_opt idl2, hidden

    rows = obj_new(self.flags_section_class)
    param_types = rows->get_param_types()
    obj_destroy, rows
    return, param_types

END


;+
; Sets file name of index file
; @param file_name {in}{type=string} name of index file
;-
PRO FLAG_FILE::set_file_name, file_name
    compile_opt idl2
    self.file_name = file_basename(file_name)
    self.header->set_file_name, self->get_full_file_name()
    if obj_valid(self.rows) then self.rows->set_file_name, self->get_full_file_name()
END

;+
; Sets up object to read/create new index file
;-
PRO FLAG_FILE::reset
    compile_opt idl2

    if obj_valid(self.header) then obj_destroy, self.header
    if obj_valid(self.rows) then obj_destroy, self.rows
    
    if self.file_name ne "" then begin
        self.header = obj_new("header_index_section", self.file_name)
        self.rows = obj_new(self.flags_section_class, self.file_name)
    endif else begin
        self.header = obj_new("header_index_section")
        self.rows = obj_new(self.flags_section_class)
    endelse
    
    self.file_loaded = 0
    self.debug = 0
    
    if ptr_valid(self.row_lines) then ptr_free, self.row_lines
    self.row_lines = ptr_new(/allocate_heap)
    
END

;+
; Sets path to index file
; @param file_path {in}{type=string} path to index file
;-
PRO FLAG_FILE::set_file_path, file_path
    compile_opt idl2

    self.file_path = file_path
    self.header->set_file_name, self->get_full_file_name()
    if obj_valid(self.rows) then self.rows->set_file_name, self->get_full_file_name()
    
END

;+
; Retrieves file name of index file
; @returns file name of index file
;-
FUNCTION FLAG_FILE::get_file_name
    compile_opt idl2
    
    return, self.file_name

END

;+
; Finds if object contains index file's contents in memory
; Also checks to make sure that the file info on disk matches
; that in memory.  If that does not match, this function returns
; 0 (not loaded).
; @returns 0,1
;-
FUNCTION FLAG_FILE::is_file_loaded
    compile_opt idl2

    if self.file_loaded then begin
       ; also check against info
       thisInfo = file_info(self->get_full_file_name())
       self.file_loaded = thisInfo.size eq self.info.size
    endif

    return, self.file_loaded

END

;+
; Sets version number of I/O modules
; @param version {in}{type=string} version number
;-
PRO FLAG_FILE::set_version, version
    compile_opt idl2

    self.version = version

END

;+ 
; Retrieves the version number of the I/O module using this object
; @returns version number (string)
;-
FUNCTION FLAG_FILE::get_version
    compile_opt idl2

    return, self.version

END

;+
; Creates a new flag file.  Only writes the header section, flags section marker
; and header.
; @keyword file_name {in}{optional}{type=string} base file name of new flag file
;-
PRO FLAG_FILE::new_file, file_name=file_name
    compile_opt idl2

    if keyword_set(file_name) then self->set_file_name, file_name

    ; writes over any pre-existing files
    openw, lun, self->get_full_file_name(), /get_lun
    free_lun, lun
    
    ; write the header section
    header_strings = self->create_header()
    self.header->set_file_name, self->get_full_file_name()
    self.header->create, header_strings

    if not obj_valid(self.rows) then begin
        self.rows = obj_new(self.flags_section_class, self->get_full_file_name(self.file_name))
    endif

    self.rows->create

    self.info = file_info(self->get_full_file_name())
    
    self.file_loaded = 1
    
END

;+
; Returns a string array, where each element will be a line in the flag
; file header.  The most important line here is the version key/value pair.
; @returns a string array representing the flag file header
;-
FUNCTION FLAG_FILE::create_header
    compile_opt idl2, hidden

    creation_date = systime(/UTC) 
    header = ['created = '+creation_date]
    header = [header,'version = '+self.version]
    header = [header,'created_by = gbtidl']
    return, header
    
END


;+
; Along with set_flag_rec, sets a line in the flag file representing a flagging
; rule.  The input here is a scan number, and optional arguments that are 
; determined by the current flagging format being used.
; If the flag file does not yet exist, it is created here.  The input arguments
; are used to construct a string, and this string is appended to the flag file.
; @param scan {in}{required}{type=long} scan nubmer to flag
;-
PRO FLAG_FILE::set_flag, scan, _EXTRA=ex 
    compile_opt idl2, hidden

    if not n_elements(scan) gt 0 then begin
        print, "scan a required argument"
        return
    endif
    if not self.file_loaded then begin
        self->new_file
    endif

    flag_string = self.rows->create_flag_scan_string(scan, _EXTRA=ex)
    self.rows->append_lines, flag_string
    
END

;+
; Along with set_flag, sets a line in the flag file representing a flagging
; rule.  The input here is a single or array of record number, and optional
; arguments that are 
; determined by the current flagging format being used.
; If the flag file does not yet exist, it is created here.  The input arguments
; are used to construct a string, and this string is appended to the flag file.
; @param recnum {in}{required}{type=long} record nubmer to flag
;-
PRO FLAG_FILE::set_flag_rec, recnum, _EXTRA=ex 
    compile_opt idl2, hidden

    if not n_elements(recnum) gt 0 then begin
        print, "record number a required argument"
        return
    endif
    if not self.file_loaded then begin
        self->new_file
    endif
    if not obj_valid(self.rows) then begin
        self.rows = obj_new(self.flags_section_class, self->get_full_file_name(self.file_name))
    endif
    flag_string = self.rows->create_flag_rec_string(recnum, _EXTRA=ex)
    self.rows->append_lines, flag_string
    
END

;+
; Loads the contents of a flag file into memory
; Initializes the objects resposible for managing each section of the flag file.
; If an old format is encountered, then this flag is converted to the current
; format, with a backup of the original file saved off.
; @keyword file_name {in}{optional}{type=string} base file name of the flag file
;-
PRO FLAG_FILE::read_file, file_name=file_name, ver_status
    compile_opt idl2

    ; if filename is being set, we may need to recreate the section objects
    if keyword_set(file_name) then begin
        if self.debug then print, "Attempting to read: ", file_name
        self->set_file_name, file_name
        if obj_valid(self.header) then obj_destroy, self.header
        if obj_valid(self.rows) then obj_destroy, self.rows
        self.header = obj_new("header_index_section", self->get_full_file_name(self.file_name)) 
    endif else begin
        if self.debug then print, "attempting to read: ", self.file_name
    endelse

    ; read header section
    if self.header->read_file() eq -1 then message, 'error in header, cannot read.' 
    file_version = strtrim(self.header->get_value("VERSION"),2)

    ; check what version this flag file is
    if file_version eq self.version then begin
        ; this flag file is using the current version
        self.rows = obj_new(self.flags_section_class, self->get_full_file_name(self.file_name))
        if self.debug then self.rows->set_debug_on
        ; read rows section
        if self.rows->read_file() eq -1 then message, 'error in rows, cannot read.'
        self.file_loaded = 1
    endif else begin
        ; this flag file is NOT using the latest version format, so convert it
        ; make a backup of this old flag file before we overwrite it
        full_file_name = self->get_full_file_name(self.file_name)
        backup = full_file_name+'.v'+file_version
        file_copy, full_file_name, backup, /overwrite
        print, "Updating Flag File; Outdated flag file version backed up to: ", backup
        old_flags_class = self->get_old_flags_class(file_version,status)
        if status eq 0 then message, "This flags format not supported: "+file_version
        ; here we actually read in the old file, translate it, and overwrite it
        self->convert_old_flag_file, old_flags_class, status
        if status eq 1 then self.file_loaded = 1
     endelse

    if self.file_loaded then self.info = file_info(self->get_full_file_name())

END

;+
; Returns the name of the class to use for managing a flag format, given
; the formats version number
; @param file_version {in}{required}{type=string} the value found in the flag file's version tag
; @param status {out}{optional}{type=bool} 1 - class name found, 0 - not found
; @returns the name of the class to use to read this old flag format
;-
FUNCTION FLAG_FILE::get_old_flags_class, file_version, status
    compile_opt idl2, hidden

    status = 0
    class = ""
    old_versions = (*self.old_versions)[0,0:(self.num_old_versions-1)]
    for i=0,self.num_old_versions-1 do begin
        if file_version eq old_versions[i] then class = (*self.old_versions)[1,i]    
    endfor
    if class ne "" then status = 1
    return, class

END

;+
; Reads in the contents of the current flag file, given the name of the class
; to do this with, and then rewrites the flag file using the current format.
; @param old_flags_class {in}{required}{type=string} class to use to read original file
;-
PRO FLAG_FILE::convert_old_flag_file, old_flags_class, status
    compile_opt idl2, hidden
    
    ; first, get the flags using its present format
    self.rows = obj_new(old_flags_class,self->get_full_file_name(self.file_name))
    if self.debug then self.rows->set_debug_on
    if self.rows->read_file() eq -1 then message, 'error in rows, cannot read.'
    old_rows = self.rows->get_rows(num_old_rows)

    ; now, read in these old rows using the current version
    if obj_valid(self.rows) then obj_destroy, self.rows
    self.rows = obj_new(self.flags_section_class,self->get_full_file_name(self.file_name))
    if self.debug then self.rows->set_debug_on
    self->new_file
    if num_old_rows ne 0 then begin
        new_rows = self.rows->convert_rows(old_rows,status)
        self.rows->write_new_rows, new_rows
    endif    
    if self.rows->read_file() eq -1 then message, 'error in rows, cannot read.'

END

;+
; Prints out contents of flag file.  For testing purposes only.
;-
PRO FLAG_FILE::list, _EXTRA=ex
    compile_opt idl2, hidden
    if obj_valid(self.rows) then self.rows->list, _EXTRA=ex
END

;+
; Prints out unique idstrings of flag file.  For testing purposes only.
;-
PRO FLAG_FILE::list_ids
    compile_opt idl2, hidden
    if obj_valid(self.rows) then self.rows->list_ids
END

;+
; Comments out a line in the flagging file, given either the ID or IDSTRING
; of the flag to unflag.
; @param id {in}{required}{type=string,long} if string, this is the IDSTRING to unflag, if long, the ID
;-
PRO FLAG_FILE::unflag, id
    compile_opt idl2, hidden
    if obj_valid(self.rows) then begin
        if size(id,/type) eq 7 then begin
            self.rows->unflag, id
        endif else begin
            self.rows->unflag_line, id
        endelse
    endif    
END

;+
; Returns the lines and their locations in the flag file
; @param status {out}{optional}{type=long} 0 - failure, 1 - success
; @returns a 2-D string array of lines and their locations in the flag file
;-
FUNCTION FLAG_FILE::get_lines_and_line_nums, status,  _EXTRA=ex
    compile_opt idl2, hidden
    if obj_valid(self.rows) then begin 
        return, self.rows->get_lines_and_line_nums(status, _EXTRA=ex)
    endif else begin
        status = 0
        return, -1
    endelse    
END

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_line_nums, count
    compile_opt idl2, hidden
    if obj_valid(self.rows) then begin 
        return, self.rows->get_line_nums(count)
    endif else begin
        count = 0
        return, -1
    endelse    
END


;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_lines, status, _EXTRA=ex
    compile_opt idl2, hidden
    if obj_valid(self.rows) then begin 
        return, self.rows->get_lines(status, _EXTRA=ex)
    endif else begin
        status = 0
        return, -1
    endelse    
END

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_row_strcts, status, indicies, _EXTRA=ex
    compile_opt idl2, hidden
    if obj_valid(self.rows) then begin 
        rows = self.rows->get_rows(ok, indicies, _EXTRA=ex)
        status = ok
        return, rows
    endif else begin
        indicies = -1
        status = 0
        return, -1
    endelse    
END

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_unique_ids, count
    compile_opt idl2, hidden
    if obj_valid(self.rows) then begin 
        return, self.rows->get_unique_ids(count)
    endif else begin
        count = 0
        return, -1
    endelse
END

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_formatted_header
    compile_opt idl2, hidden
    if obj_valid(self.rows) then return, self.rows->get_formatted_header() else return, "" 
END

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_verbose_header
    compile_opt idl2, hidden
    if obj_valid(self.rows) then return, self.rows->get_verbose_header() else return, ""
END    

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_values_list_format
    compile_opt idl2, hidden
    if obj_valid(self.rows) then return, self.rows->get_values_list_format() else return, ""
END    

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_deliminator
    compile_opt idl2, hidden
    if obj_valid(self.rows) then return, self.rows->get_deliminator() else return, ""
END

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_not_applicable_symbol
    compile_opt idl2, hidden
    if obj_valid(self.rows) then return, self.rows->get_not_applicable_symbol() else return, ""
END

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::search_flags, status, _EXTRA=ex
    compile_opt idl2, hidden
    if obj_valid(self.rows) then begin 
        return, self.rows->search_flags(status, _EXTRA=ex)
    endif else begin
        status = 0
        return, -1
    endelse    
END    

;+
; Makes this object and child objects verbose
;-
PRO FLAG_FILE::set_debug_on
    compile_opt idl2, hidden

    self.debug = 1
    self.header->set_debug_on
    if obj_valid(self.rows) then self.rows->set_debug_on

END    

;+
; Makes this object and child objects quiet
;-
PRO FLAG_FILE::set_debug_off
    compile_opt idl2, hidden

    self.debug = 0
    self.header->set_debug_off
    if obj_valid(self.rows) then self.rows->set_debug_off

END    

;+
; Is the row object valid?
; @returns 0 - object not valid, 1 - object valid
;-
FUNCTION FLAG_FILE::has_valid_rows
    compile_opt idl2, hidden
    return, obj_valid(self.rows)
END

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_num_lines
    compile_opt idl2, hidden
    if not self->has_valid_rows() then return, 0
    return, self.rows->get_num_lines()
END

;+
; Call to the row object's method of the same name
;-
PRO FLAG_FILE::set_index_value_recnums, recnums
    compile_opt idl2, hidden
    if not self->has_valid_rows() then return
    self.rows->set_index_value_rows, recnums
END

;+
; Call to the row object's method of the same name
;-
PRO FLAG_FILE::reset_index_value_recnums
    compile_opt idl2, hidden
    if not self->has_valid_rows() then return
    self.rows->reset_index_value_rows
END

;+
; Call to the row object's method of the same name
;-
PRO FLAG_FILE::append_index_value_recnums, recnums
    compile_opt idl2, hidden
    if not self->has_valid_rows() then return
    self.rows->append_index_value_rows, recnums
END

;+
; Call to the row object's method of the same name
;-
FUNCTION FLAG_FILE::get_index_value_recnums, status
    compile_opt idl2, hidden
    if not self->has_valid_rows() then begin
       status = 0
       return, -1
    endif
    rows = self.rows->get_index_value_rows(status)
    if status then return, rows else return, -1
END    


PRO FLAG_FILE::show_state
  compile_opt idl2

  print,"FLAG_FILE state"
  print,"   file_name : ", self.file_name
  print,"   file_loaded : ", self.file_loaded
  print,"   file_path : ", self.file_path
  print,"   version : ", self.version

  self.rows->show_state
END
