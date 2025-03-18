;+
; IO_SDFITS_Z is intended for end users wishing to work with
; zpectrometer data.  It's the child class of IO_SDFITS_LINE used for
; reading, writing, navigating sdfits spectral line files, and for
; translating their info to spectrum data containers.  See 
; <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or 
; <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just 
; the line and continuum sdfits classes.
;
;
; @file_comments
; IO_SDFITS_Z is intended for end users wishing to work with
; zpectrometer data.  It's the child class of IO_SDFITS_LINE used for
; reading, writing, navigating sdfits spectrual line files, and for
; translating their info to spectrum data containers.  See 
; <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or 
; <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just 
; the line and continuum sdfits classes.
;
; @uses <a href="line_index__define.html">LINE_INDEX</a>
; @uses <a href="sdfits__define.html">SDFITS</a>
;
; @inherits io_sdfits_line
;
; @version $Id$
;-

;+
; Called upon instantiation of this class.
; @uses IO_SDFITS::init
; @private
;-
FUNCTION IO_SDFITS_Z::init,index_file=index_file  
    compile_opt idl2, hidden
    
    self.index_class_name = 'z_index'
    self.index_section_class_name = 'z_index_section'
    self.sdfits_class_name = 'z_sdfits'
    self.default_index_name = 'io_sdfits_z_index'
    ; The version passed here is the Zpectrometer INDEX version
    ; It may differ from the standard SDFITS INDEX version number.
    r = self->shared_init(index_file=index_file,version='1.6')
    return, r

END

;+
; Class destructor
;-
PRO IO_SDFITS_Z::cleanup  
    compile_opt idl2, hidden

    self->IO_SDFITS_LINE::cleanup
    
END    

;+
; Groups a collection of rows from the index file by file and extension.
; This method is needed since we will want to access each files extension only once
; to read the pertinent rows (for efficiany reasons).
; @param row_info {in}{type=array} array of structs, where each struct represents a row of the index file
; @returns array of group_row_info structures: rows that share a file and extension 
; @private
;-
FUNCTION IO_SDFITS_Z::group_row_info, row_info
    compile_opt idl2 
   
    ; get all files
    files = row_info.file
    unique_files = files[uniq(files[sort(files)])]
    
    group = {z_sdfits_row_group}

    for i = 0, (n_elements(unique_files)-1) do begin
        file_locals = row_info[ where(row_info.file eq unique_files[i]) ]
        exts = file_locals.extension
        unique_exts = exts[uniq(exts[sort(exts)])]
        for j = 0, (n_elements(unique_exts)-1) do begin
            file_ext_locals = file_locals[ where(file_locals.extension eq unique_exts[j]) ]
            ; collapse the array into one struct
            group.file = file_ext_locals[0].file
            group.extension = file_ext_locals[0].extension
            group.rows = ptr_new(file_ext_locals.row_num)
            group.index = ptr_new(file_ext_locals.index)
            if (i eq 0) and (j eq 0) then groups = [group] else groups = [groups,group]
        endfor
    endfor
    
    return, groups

END


;+
; Temporary function to use as interface until we can think of a better name
; then get_spectra
;-
FUNCTION IO_SDFITS_Z::get_rows, _EXTRA=ex
    compile_opt idl2 

    return, self->get_spectra( _EXTRA=ex )
    
END

;+
;  Function to convert rows into data containers.
;  This is used internally in get_spectra.
;  group, missing, apply_offsets are not used here but are needed by the signature
;  of this function.
;  @private
;-
FUNCTION IO_SDFITS_Z::rows_to_dc, rows, group, missing, virtuals, apply_offsets
    compile_opt idl2, hidden

    ; append the virtuals 
    result = self->append_virtuals(rows, virtuals)

    ; strip off the white space from all string fields in rows
    for i=0, (n_tags(result)-1) do begin
        if size(result.(i),/type) eq 7 then begin
            result.(i) = strtrim(result.(i))
        endif 
    endfor

    return, result

END

;+
; Given an array of data containers and a structure representing virtual 
; columns in an extension table (keywords), appends these virtuals to each
; data container and returns the new array
;
; @param spectra {in}{type=array} array of data containers
; @param virtuals {in}{type=structure} structure representing virtual columns in an extension table (keywords)
; @returns the original array of data containers, but with each element containing the virtuals
;-
FUNCTION IO_SDFITS_Z::append_virtuals, spectra, virtuals
    compile_opt idl2
    
    ; this also copies the values from virtuals
    new_spectrum = create_struct(spectra[0],virtuals)
    ; the virtuals are replicate here
    new_spectra = replicate(new_spectrum, n_elements(spectra))
    ; no need to assign the first spectra, already done
    if n_elements(spectra) gt 1 then begin
        for i = 1 , n_elements(spectra)-1 do begin
            ; relaxed assignment here, only fields in new_spectra are copied from spectra
            dest = new_spectra[i]
            struct_assign, spectra[i], dest, /nozero
            new_spectra[i] = dest
        endfor
    endif
    return, new_spectra

END

;+
; defines class structure
; @private
;-
PRO io_sdfits_z__define
    compile_opt idl2, hidden

    io = { io_sdfits_z, inherits io_sdfits_line}
    
END
