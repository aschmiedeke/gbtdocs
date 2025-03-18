;+
; Provides basic interface for reading and writing fits files 
; @field file_name full path name to the fits file
; @field num_extensions number of extensions for this file
; @field extension_names pointer to list of names for each extension
; @field extension_types pointer to list of types for each extension
; @field axis pointer to 2-D array with info on each extension
; @field primary_header fits_header_parser object for primary header
; @field ext_header fits_header_parsert object for last extension header
; @field properties_known flag signaling if above fields are valid798
; @field debug flag for determining if debug printouts occur
; @field version string denoting what version of the io modules 
; @file_comments
; Provides basic interface for reading and writing fits files 
; @private_file
;-
PRO fits__define
    compile_opt idl2, hidden

    f1 = { fits, $
        file_name:string(replicate(32B,256)), $
        num_extensions:0L, $
        extension_names:ptr_new(), $
        extension_types:ptr_new(), $
        axis:ptr_new(), $
        primary_header:obj_new(), $
        ext_header:obj_new(), $
        properties_known:0L, $
        debug:0, $
        version:string(replicate(32B,3)) $
    }    
END

;+ 
; Class Constructor - if file name is passed and it exists, the properties of this
; file are determined and stored
; @param file_name {in}{optional}{type=string} full path name to fits file
;-
FUNCTION FITS::init, file_name, version=version
    compile_opt idl2, hidden
    
    ; use undefined pointers here so that we never have to check 
    ; their validity before setting them
    ; This probably isn't necessary, but it doesn't hurt
    if ptr_valid(self.extension_names) then ptr_free, self.extension_names
    if ptr_valid(self.extension_types) then ptr_free, self.extension_types
    if ptr_valid(self.axis) then ptr_free, self.axis
    self.extension_names = ptr_new(/allocate_heap)
    self.extension_types = ptr_new(/allocate_heap)
    self.axis = ptr_new(/allocate_heap)

    if (n_params() eq 1) then begin
    
        self->set_file_name, file_name
 
        if (self->file_exists()) then begin
            self->update_properties
        endif

    endif
    
    if n_elements(version) ne 0 then self.version = version

    return, 1

END

;+
; Class Destructor
; @private
;-
PRO FITS::cleanup
    compile_opt idl2, hidden

    if ptr_valid(self.extension_names) then ptr_free, self.extension_names
    if ptr_valid(self.extension_types) then ptr_free, self.extension_types
    if ptr_valid(self.axis) then ptr_free, self.axis
    if obj_valid(self.ext_header) then obj_destroy, self.ext_header
    if obj_valid(self.primary_header) then obj_destroy, self.primary_header

END

;+
; Retrieves this objects version number
; @returns version number
;-
FUNCTION FITS::get_version
    compile_opt idl2

    return, self.version

END    

;+
; Sets the version number of this object
;-
PRO FITS::set_version, ver
    compile_opt idl2

    self.version = ver

END

;+
; Makes object verbose
;-
PRO FITS::set_debug_on
    compile_opt idl2

    self.debug = 1

END

;+
; Makes object quiet
;-
PRO FITS::set_debug_off
    compile_opt idl2

    self.debug = 0

END

;+
; Determins properties of file and last extension, and sotres them
; @uses FITS::update_file_properties
; @uses FITS::update_last_extension_properties
;-
PRO FITS::update_properties
    compile_opt idl2

    self->update_file_properties
    self->update_last_extension_properties

END

;+
; Determines and stores the fits files number of extenions, names & types of each
; extension, and more info on each extension, plus read in primry header keywords
; @uses FITS_OPEN
; @uses FITS_CLOSE
;-
PRO FITS::update_file_properties
    compile_opt idl2

    FITS_OPEN,self.file_name,fcb,/no_abort,message=msg
    if strlen(msg) ne 0 then begin
        print,'FITS_OPEN failed in FITS::update_file_properties'
        print,msg
        print,'problem file : ', self.file_name
        fileDir = file_dirname(self.file_name)
        if file_test(fileDir,/directory,/write) then begin
            badDir = fileDir + '/badfits'
            if not file_test(badDir,/write) then begin
                file_mkdir,badDir
            endif
            if file_test(badDir,/directory,/write) then begin
                thisfileBase = file_basename(self.file_name)
                copyFile = badDir + '/' + thisfileBase
                if file_test(copyFile) then begin
                    copyFile = copyFile + strtrim(string(round(systime(/sec)-1.129e9)),2)
                endif
                if not file_test(copyFile) then begin
                    file_copy,self.file_name,copyFile,/overwrite
                    print,'Copied to ',copyFile
                endif else begin
                    print,'Could not copy file, file already exists'
                endelse
            endif else begin
                print,'Could not copy file, no write permission in ',badDir
            endelse
        endif   
        retall
    endif
    
    ; this lun is via get_lun in FITS_OPEN
    lun = fcb.unit
    
    self.num_extensions = fcb.nextend

    *self.extension_names = fcb.extname
    *self.extension_types = fcb.xtension
    *self.axis = fcb.axis  ;[1,ext_num]

    ; read in the primary header
    FITS_READ,fcb,data,header,exten_no=0,/HEADER_ONLY
    self->create_primary_header_struct, header

    self.properties_known = 1

    FITS_CLOSE, fcb

END

;+
; Determines and stores info on the last extension of the file
; @uses FXBOPEN
; @uses FXBCLOSE
; @uses FITS_HEADER_PARSER::create_extension_header_struct
;-
PRO FITS::update_last_extension_properties
    compile_opt idl2

    if (self.num_extensions gt 0) then begin
        ; fxbopen uses /GET_LUN to get this lun
        FXBOPEN, lun,self.file_name,self.num_extensions,header
        self->create_extension_header_struct, header ;self.num_extensions
        ; fxbclose frees this lun
        FXBCLOSE, lun
    endif
    
END

;+
; Sets the full path name of the fits file
; @param file_name {in}{type=string} full path name of fits file
;-
PRO FITS::set_file_name, file_name
    compile_opt idl2

    self.file_name = file_name

END

;+
; Retrieves the full path name of the fits file
; @returns full path name of fits file
;-
FUNCTION FITS::get_full_file_name
    compile_opt idl2

    return, self.file_name

END

;+
; Retrieves just the file name of the fits file (no path)
; @returns file name of fits file
;-
FUNCTION FITS::get_file_name
    compile_opt idl2

    return, file_basename(self.file_name)

END

;+
;  Checks if fits file represented by object (or keyword) exist on disk
; @keyword file_name {in}{optional}{type=string} full path name of file to check
; @uses file_info
; @returns 0,1
;-
FUNCTION FITS::file_exists, file_name=file_name
    compile_opt idl2

    if keyword_set(file_name) then begin
        file_info = file_info(file_name)
    endif else begin
        file_info = file_info(self.file_name)
    endelse    
    return, file_info.exists

END 

;+
; Returns the number of extensions of this fits file
; @returns number of extensions
;-
FUNCTION FITS::get_number_extensions
    compile_opt idl2

    return, self.num_extensions

END    

;+
; Returns the type of the given extension
; @param ext_num {in}{type=long} extension number in question
; @returns extension type
;-
FUNCTION FITS::get_extension_type, ext_num
    compile_opt idl2

    types = *self.extension_types
    return, types[ext_num]

END

;+
; Returns the name of the given extension
; @param ext_num {in}{type=long} extension number in question
; @returns extension name
;-
FUNCTION FITS::get_extension_name, ext_num
    compile_opt idl2

    names = *self.extension_names
    return, names[ext_num]

END    

;+
; REturns the number of rows for this extension
; @param ext_num {in}{type=long} extension number
; @returns number of rows
;-
FUNCTION FITS::get_ext_num_rows, ext_num
    compile_opt idl2

    ax = *self.axis
    return, ax[1,ext_num]

END

;+
; Returns the contents of the gvein extension and row numbers for this
; fits file. Also updates properties of this extension that was read.
; @keyword ext {in}{optional}{type=long} extension to read, default = 1
; @keyword row_nums {in}{optional}{type=array} array of row numbers to read (0-based), default=all
; @returns array of structures representing each row read
; @uses mrdfits
; @uses FITS::create_extension_header_struct
;-
FUNCTION FITS::get_rows, ext=ext, row_nums=row_nums
    compile_opt idl2

    if (keyword_set(ext) eq 0) then ext = 1
    
    if keyword_set(row_nums) then begin
        rows = mrdfits(self.file_name,ext,hdr,rows=row_nums,/silent)
    endif else begin
        rows = mrdfits(self.file_name,ext,hdr,/silent)
    endelse
    self->create_extension_header_struct, hdr
    
    return, rows
    
END  

;+
; Creates a new header struct using the string array from the extension header
; @param hdr_lines {in}{type=array} string array of extension header returned by mrdfits
; @private
;-
PRO FITS::create_extension_header_struct, hdr_lines
    compile_opt idl2

    if obj_valid(self.ext_header) then obj_destroy,self.ext_header
    self.ext_header = obj_new('fits_header_parser',hdr_lines)

END

;+
; Creates a new header struct using the string array from the primary header
; @param hdr_lines {in}{type=array} string array of primary header returned by FITS_READ
; @private
;-
PRO FITS::create_primary_header_struct, hdr_lines
    compile_opt idl2

    if obj_valid(self.primary_header) then obj_destroy,self.primary_header
    self.primary_header = obj_new('fits_header_parser',hdr_lines)

END

;+
; Prints the contents of the header of the last read extension
; @uses FITS_HEADER_PARSER::list
;-
PRO FITS::list_extension_header
    compile_opt idl2

    if (obj_valid(self.ext_header) eq 0) then return 
    self.ext_header->list

END

;+
; Retrieves the value of a keyword in the last read extension
; @param keyword {in}{type=string} extension header keyword
; @returns value of keyword
; @uses FITS_HEADER_PARSER::get_key_value
;-
FUNCTION FITS::get_extension_header_value, keyword
    compile_opt idl2

    if (obj_valid(self.ext_header) eq 0) then return, -1
    return, self.ext_header->get_key_value(keyword)

END


;+ 
; Appends a new extension to fits file and adds rows to it. Additional keywords are added
; to the extesnion header, and fits files properties are updated.
; @param rows {in}{required}{type=array} array of structures that mirror rows to be writtein
; @param virtuals {in}{optional}{type=struct} keywords to be written to new extension (other then column specs)
; @uses FITS::make_header_array
; @uses mwrfits
;-
PRO FITS::write_rows_new_extension, rows, virtuals
    compile_opt idl2

    num_rows = n_elements(rows)
    
    if n_elements(virtuals) ne 0 then begin
        ; convert this structure to a special string array
        additional_header_keywords = self->make_header_array(virtuals)
        ; writes rows to new extension, adding additional keywords
        mwrfits, rows, self.file_name, additional_header_keywords, alias=['DATE_OBS','DATE-OBS'], /silent
    endif else begin    
        ; writes rows to new extension, adding additional keywords
        mwrfits, rows, self.file_name, alias=['DATE_OBS','DATE-OBS'], /silent
    endelse    

    ; update file properties without opening file again
    ; = self->update_file_properties
    self.num_extensions = self.num_extensions + 1
    *self.extension_names = [*self.extension_names,'SINGLE DISH']
    *self.extension_types = [*self.extension_types,'BINTABLE']
    new_axis = intarr(20)
    new_axis[0] = 8
    new_axis[1] = num_rows
    *self.axis = [[*self.axis],[new_axis]]

    ; update extension header
    ; fxbopen uses /GET_LUN to get this lun
    fxbopen, lun, self.file_name,self.num_extensions,header
    self->create_extension_header_struct, header ;self.num_extensions
    ; fxbclose frees this lun
    fxbclose, lun

    
END
;+
; Appends rows to last extension in fits file
; @param rows {in}{type=array} array of structs mirroring rows to be appended
; @uses FXBOPEN
; @uses FXBGROW
; @uses FXBFIND
; @uses FXBWRITE
; @uses FXBFINISH
; @uses FITS::get_logical_columsn
;-
PRO FITS::append_rows_to_extension, rows
    compile_opt idl2

    extension = self.num_extensions
      
    ; fxbopen uses /GET_LUN to get this lun
    FXBOPEN, lun,self.file_name,extension,header,access='RW'

    ; append
    appending_num_rows = n_elements(rows)
    current_num_rows = FXPAR(header,"NAXIS2")
    final_num_rows = current_num_rows + appending_num_rows
    
    FXBGROW,lun,header,final_num_rows

    ; find what columns are of type '1L' (logical): these need specail handling
    FXBFIND, lun, 'TFORM', cols, values, n_found
    logic_cols = self->get_logical_columns(values, n_logic_cols)
    
    ; go through each row, then each column and write value
    for i = 0, (n_elements(rows)-1) do begin
        row = rows[i]
        for j = 0, (N_TAGS(row)-1) do begin
            ; we can't write to '1L' (logical) column types
            if (n_logic_cols ne 0) then begin
                if (where(j+1 eq logic_cols) ne -1) then begin 
                    FXBWRITE, lun, byte(row.(j)), j+1, current_num_rows+1+i
                endif else begin    
                    FXBWRITE, lun, row.(j), j+1, current_num_rows+1+i
                endelse
            endif else begin
                FXBWRITE, lun, row.(j), j+1, current_num_rows+1+i
            endelse     
        endfor  ; for each column
    endfor  ; for each row  

    ; update properties
    axis_array = *self.axis
    axis_array[1,extension] = final_num_rows
    *self.axis = axis_array

    ; fxbfinish frees this lun
    FXBFINISH, lun

    self->create_extension_header_struct, header ; , extension

END


;+
; Retrieves the TFROM# value for an extension column specified either by number or name
; @param extension {in}{required}{type=long} extension number in which column is to be found
; @param column_number {in}{optional}{type=long} column number to be queried
; @keyword column_name {in}{optional}{type=string} column name to be queried; overrides column number
; @returns string specifiying fits type ('1A','1024E').
;-
FUNCTION FITS::get_column_type, extension, column_number, column_name=column_name
    compile_opt idl2
    
    ; get the definitions of this extensions columns
    ; fxbopen uses /GET_LUN to get this LUN
    FXBOPEN, lun,self.file_name,extension,header,access='RW'
    FXBFIND, lun, 'TTYPE', cols, col_names, n_names_found
    FXBFIND, lun, 'TFORM', cols, col_types, n_types_found
    ; fxbfinish frees this lun
    FXBFINISH, lun

    if keyword_set(column_name) then begin
        for i = 0, n_elements(col_names)-1 do begin
            if strtrim(strupcase(col_names[i]),2) eq strtrim(strupcase(column_name),2) then column_number = i
        endfor
    endif

    if n_elements(column_number) eq 0 then message, "column_number needed."
    if column_number gt n_elements(col_types)-1 then message, "column #: "+string(column_number)+" greater then number of columns: "+string(n_elements(col_types))

    return, col_types[column_number]

END

;+
; Called before an extension is appended to with new rows.  Checks to see if a representative
; of these rows has properties that match the existing columns of the extension.  For each tag
; in the row structure, its name and type is compared to the column, in increasing order.
; @param row {in}{required}{type=struct} structure representing first row to be appended to extension
; @param extension {in}{required}{type=long} the extension number to be appended to
; @returns 0 - row not compatible to extension, 1 - row compatible to extension
;-
FUNCTION FITS::row_compatible_with_extension, row, extension
    compile_opt idl2
    
    ; get the definitions of this extensions columns
    ; fxbopen uses /GET_LUN to get this lun
    FXBOPEN, lun,self.file_name,extension,header,access='RW'
    FXBFIND, lun, 'TTYPE', cols, col_names, n_names_found
    FXBFIND, lun, 'TFORM', cols, col_types, n_types_found
    ; fxbfinish frees this lun
    FXBFINISH, lun
    
    row_tags = tag_names(row)
    
    ; simplest check: does the row to be appended and the extension have the 
    ; same number of columns?
    if (n_elements(row_tags) ne n_names_found) then begin
       if self.debug then begin
          message, 'row does not have same number of tags as extension has columns',/info
       endif
       return, 0
    endif    
    
    ; check each column's name and type
    for i=0,n_elements(row_tags)-1 do begin
        ; get the row properties
        row_tag_name = strtrim(row_tags[i],2)
        row_tag_type = size(row.(i),/TYPE)
        ; get the extension properties:
        ; convert type string into the idl integer type
        col_type = self->fits_type_to_idl_type(col_types[i],col_size)
        ; get rid of dashes in column names
        col_name = col_names[i]
        parts = strsplit(col_name,"-",/extract)
        if (n_elements(parts) eq 2) then begin
            col_name = parts[0] + "_" + parts[1]
        endif else begin
            col_name = parts[0]
        endelse    
        col_name = strtrim(col_name,2)
        ; compare row and extension properties:
        if (row_tag_name  ne col_name) then begin
            if self.debug then print, 'for column: '+string(i)+' row name *'+row_tag_name+'* differs from *'+col_name+'*.'
            return, 0
        endif    
        if (row_tag_type  ne col_type) then begin
            if self.debug then print, 'for column: '+string(i)+' row type *'+string(row_tag_type)+'* differs from *'+string(col_type)+'*.'
            return, 0
        endif    
    endfor
    
    return, 1

END

;+
; Converts a structure containing keyword-values and returns a string
; array suitable for using to add to extension header
; @param virtuals {in}{type=struct} structure cointing keyword-values for header
; @returns string array suitable for using to add to extension header.
;- 
FUNCTION FITS::make_header_array, virtuals
    compile_opt idl2

    tags = tag_names(virtuals)
    lines = strarr(n_elements(tags)+1)
    for i=0,n_elements(tags)-1 do begin
        key = tags[i]
        ; make sure key is exactly 8 spaces long
        key_len = strlen(key)
        for j=0,(7-key_len) do key = key + ' '
        ; float or string type?
        if (size(virtuals.(i),/type) eq 7) then begin
            sval = strtrim(string(virtuals.(i)),2)
            ; string values should be at least 8 chars long, pad with spaces
            sval_len = strlen(sval)
            for j=0,(7-sval_len) do sval = sval + ' '
            ; place additional quotes around strings
            value = "'" + sval + "'"
        endif else begin
            ; format floats
            value = string(virtuals.(i),format='(E20.7)')
        endelse    
        line = key + "= " + value
        lines[i] = line
    endfor
    ; BUG: we must add one extra line for some reason
    lines[i] = "COMMENT virtual columns added"
    return, lines

END

;+
; Given the TFORMs found in extension header, finds which ones are of type '1L'
; @param forms {in}{type=array} string array of all TFORM#s foudn in extension header
; @param n_logic_cols {out}{type=long} number of logic columns found
; @returns indicis where forms [i] is of type '1L'
; @private
;-
FUNCTION FITS::get_logical_columns, forms, n_logic_cols
    compile_opt idl2

    n_logic_cols = 0
    for i=0,n_elements(forms)-1 do begin
        thisForm = strtrim(forms[i],2)
        if (thisForm eq '1L') or (thisForm eq 'L') then begin
            if (n_logic_cols eq 0) then logic_cols = [i+1] else logic_cols=[logic_cols,(i+1)]
            n_logic_cols = n_logic_cols + 1
            
        endif
    endfor
    if (n_logic_cols eq 0) then return, -1 else return, logic_cols

END

;+
; Converts fits TFORM# keyword value to it's IDL integer type
; @param fits_type {in}{required}{type=string} the value of the TFORM# keyword in the ext. header
; @param idl_size {out}{optional}{type=long} the size of this type (ex: string length)
; @returns integer idl data type code
; @private
;-
FUNCTION FITS::fits_type_to_idl_type, fits_type, idl_size

    ; find the type from the last letter in the fits_type
    fits_type = strtrim(fits_type,2)
    type_char = strmid(fits_type,(strlen(fits_type)-1))
    type_size = strmid(fits_type,0,(strlen(fits_type)-1))
    type_size = long(type_size)
    
    case type_char of
        'A': begin
            ; string
            idl_type = 7
        end
        'D': begin
            ; double     
            idl_type = 5
        end
        'E': begin
            ; float     
            idl_type = 4
        end
        'I': begin
            ; short integer     
            idl_type = 2
        end
        'J': begin
            ; long integer
            idl_type = 3
        end
        'L': begin
            ; logical: no corresponding type in IDL     
            idl_type = 7
        end
    endcase

    if (n_params() eq 2) then idl_size = type_size

    return, idl_type

END

;+
; Overwrites a value in a fits file, identified by extension number, row number, and column number. 
; @param extension {in}{required}{type=long} extension number to modify
; @param row_num {in}{required}{type=long} row number to modify in extension
; @param col_num {in}{required}{type=long} column number to modify in extension
; @param value {in}{required}{type=varies} value that will overwrite the row+column specified 
; @uses FXBOPEN
; @uses FXBFIND
; @uses FXBWRITE
; @uses FXBFINISH
; @uses FITS::get_logical_columsn
;-
PRO FITS::modify_row_column, extension, row_num, col_num, value
    compile_opt idl2

    ; fxbopen uses /GET_LUN to get this lun
    FXBOPEN, lun,self.file_name,extension,header,access='RW'

    current_num_rows = FXPAR(header,"NAXIS2")

    if row_num gt current_num_rows then begin
        ; fxbfinish frees this lun
        FXBFINISH, lun
        message, "cannot modify row number: "+string(row_num)+" ; exceeds # of rows: "+string(current_num_rows)
    endif

    ; find what columns are of type '1L' (logical): these need specail handling
    logic_value = 0
    FXBFIND, lun, 'TFORM', cols, values, n_found
    logic_cols = self->get_logical_columns(values, n_logic_cols)
    if (n_logic_cols ne 0) then begin
        if where(col_num eq logic_cols) ne -1 then logic_value = 1
    endif    
    
    ; write value
    ; we can't write to '1L' (logical) column types
    if (logic_value ne 0) then begin
        FXBWRITE, lun, byte(value), col_num, row_num
    endif else begin    
        FXBWRITE, lun, value, col_num, row_num
    endelse

    ; fxbfinish frees this lun
    FXBFINISH, lun

END

;+
; Overwrites entire rows in fits extension
; @param extension {in}{required}{type=long} extension number to modify
; @param row_nums {in}{required}{type=long array} row numbers to modify in extension
; @param rows {in}{required}{type=array} array of structs that will overwrite the rows specified 
; @uses FXBOPEN
; @uses FXBFIND
; @uses FXBWRITE
; @uses FXBFINISH
; @uses FITS::get_logical_columsn
;-
PRO FITS::modify_rows, extension, row_nums, rows
    compile_opt idl2

    if n_elements(row_nums) ne n_elements(rows) then message, "modify_rows must have row numbers specified for each row passed"

    ; fxbopen uses /GET_LUN to get this lun
    FXBOPEN, lun,self.file_name,extension,header,access='RW'

    current_num_rows = FXPAR(header,"NAXIS2")

    if max(row_nums) gt current_num_rows then begin
        ; fxbfinish frees this lun
        FXBFINISH, lun
        message, "cannot modify row number: "+string(max(row_nums))+" ; exceeds # of rows: "+string(current_num_rows)
    endif

    ; find what columns are of type '1L' (logical): these need specail handling
    FXBFIND, lun, 'TFORM', cols, values, n_found
    logic_cols = self->get_logical_columns(values, n_logic_cols)
    
    ; go through each row, then each column and write value
    for i = 0, (n_elements(row_nums)-1) do begin
        row_num = row_nums[i]
        row = rows[i]
        for j = 0, (N_TAGS(row)-1) do begin
            ; we can't write to '1L' (logical) column types
            if (n_logic_cols ne 0) then begin
                if (where(j+1 eq logic_cols) ne -1) then begin 
                    FXBWRITE, lun, byte(row.(j)), j+1, row_num
                endif else begin    
                    FXBWRITE, lun, row.(j), j+1, row_num
                endelse
            endif else begin
                FXBWRITE, lun, row.(j), j+1, row_num
            endelse     
        endfor  ; for each column
    endfor  ; for each row  

    ; fxbfinish frees this lun
    FXBFINISH, lun

END

;+
; Retrieves the column number for a given column name and extension.
; Note that column name refers to name in the header line:
; TTYPEn = 'name'
; @param extension {in}{required}{type=long} extension to retrieve column number from
; @param col_name {in}{required}{type=string} column name whose number is retrieved
; @uses FXBOPEN
; @uses FXBFIND
; @uses FXBFINISH
; @returns integer representing the column number of the name passed in.
; @private
;-
FUNCTION FITS::get_column_num, extension, col_name
    compile_opt idl2, hidden
    
    if strlen(col_name) gt 8 then message, "column names must be 8 chars or less: "+col_name

    ; get the definitions of this extensions columns
    ; fxbopen uses /GET_LUN to get this lun
    FXBOPEN, lun,self.file_name,extension,header,access='RW'
    FXBFIND, lun, 'TTYPE', cols, col_names, n_names_found
    ;FXBFIND, lun, 'TFORM', cols, col_types, n_types_found
    ; fxbfinish frees this lun
    FXBFINISH, lun

    ; modify column name for search
    dif = 8-strlen(col_name)
    col_name = col_name + string(replicate(32B,dif))
    col_name = strupcase(col_name)
    
    col_index = [where(col_names eq col_name)]
    if col_index eq -1 then begin
        return, -1
    endif else begin
        return, cols[col_index]
    endelse    
    
END

;+
; Modifies a 'cell' in a fits file, by specifiying the extension, row number,
; column name, and the value to replace 'cell' with.
; @param extension {in}{required}{type=long} extension number to modify
; @param row_num {in}{required}{type=long} row number to modify in extension
; @param column_name {in}{required}{type=string} column name to modify in extension
; @param value {in}{required}{type=varies} value that will overwrite the row+column specified 
; @uses modify_row_col
; @uses get_column_num
;-
PRO FITS::modify_row_col_name, extension, row_num, column_name, value
    compile_opt idl2, hidden

    ; first find the column number associated with this name
    col_num = self->get_column_num(extension, column_name)
    if col_num eq -1 then message, "Could not find column in fits file: "+column_name

    ; now we can modify it
    self->modify_row_column, extension, row_num, col_num, value

END 
