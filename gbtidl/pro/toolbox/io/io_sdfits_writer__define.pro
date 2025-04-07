;+
; IO_SDFITS_WRITER is intended for use by users who wish to write spectral line data to sdfits. 
; See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just the line and continuum sdfits classes.
;
; @field sdfits_def sdfits object used just for getting the definition of an sdfits row
; @field output_file the name of the file to be written to.
;
; @inherits io_sdfits_line
; 
; @file_comments
; IO_SDFITS_WRITER is intended for use by users who wish to write spectral line data to sdfits. 
; See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just the line and continuum sdfits classes.
;
;-
PRO io_sdfits_writer__define
   compile_opt idl2, hidden

    io4 = { io_sdfits_writer, inherits io_sdfits_line, $
        sdfits_def:obj_new(), $
        output_file:string(replicate(32B,256)) $
    }
END    



;+
; Sets the name of the output file, and if the file exists, creates an
; sdfits object for it
; @param file_name {in}{type=string} full path name to the file to write to
; @uses IO::file_exists
; @uses IO_SDFITS::add_fits_obj
;-
PRO IO_SDFITS_WRITER::set_output_file, file_name
    compile_opt idl2
    self.output_file = file_name
    if self->file_exists(file_name) then begin
        if self.debug then print, "output file exists, creating fits object"
        if ptr_valid(self.fits_files) then obj_destroy, *self.fits_files
        self->add_fits_obj, file_name
    endif 
END

;+
; Sets the file which this object will exclusively be writing to and reading from.
; Acts much like IO_SDFITS::set_file in the way it forces creation of a new index file
; @param file_name {in}{type=string} file name (full path or not) of file to use exclusively
; @keyword file_path {in}{optinal}{type=string} file path where file_name is found
; @keyword index_name {in}{optinal}{type=string} name to use for the index file
; @uses IO_SDFITS::set_file_path
; @uses IO_SDFITS_LINE::set_file
; @uses IO_SDFITS::set_index_file_name
; @uses IO_SDFITS::free_fits_objs
;-
PRO IO_SDFITS_WRITER::set_file, file_name, file_path=file_path, index_name=index_name
    compile_opt idl2
    
    if (self.one_file ne 0) then message, "this object is commited to using only one file"

    if keyword_set(file_path) then file_path_set=1 else file_path_set=0 
    if keyword_set(index_name) then index_name_set=1 else index_name_set=0 
    
    ; see if file path is inlcuded seperately
    if file_path_set then begin
        self->set_file_path, file_path
        file_base=file_name
    endif else begin
        ; see if file path is inlcuded in file name or not
        if (strpos(file_name,'/') ne -1) then begin
            self->set_file_path, file_dirname(file_name)
            file_base = file_basename(file_name)
        endif else begin
            file_base = file_name
        endelse
    endelse

    ; now that self.file_path and file_base have been established
    ; check if this file exists
    if (self->file_exists(self->get_full_file_name(file_base)) eq 1) then begin
        ; in this case, we can use the superclass's method
        if (file_path_set eq 0) then file_path = 0
        if (index_name_set eq 0) then index_name = 0
        self->IO_SDFITS_LINE::set_file, file_name, file_path=file_path, index_name=index_name
        self.output_file = file_name
    endif else begin
        ; we can't use the superclass's method, we need a special implementation
        ; index file name == to file, or keyword?
        if index_name_set then begin 
            index_file=index_name 
        endif else begin
            parts=strsplit(file_base,'.',/extract)
            index_file = strjoin(parts[0:n_elements(parts)-2],'.')+'.index'
        endelse
        self->set_index_file_name, index_file
        ; discard all other fits objects
        self->free_fits_objs
        ; record the file to be written to
        self->set_output_file, file_name
        ; mark this io object as dedicated to one file
        self.one_file = 1
    endelse

END

;+
; Writes a single spectrum to the sdfits file, saving an NSAVE number
; in the index file corresponding to this spectrum
;
; @param spectrum {in}{required}{type=struct} the spectral line data container to be written
; @param nsave {in}{required}{type=long} the integer identifier to associate with this spectrum
; @param status {in}{optional}{type=long} set to 0 or 1 for failure or success
;
; @uses get_nsave_index
; @uses write_spectra
; @uses overwrite_spectra
;
;-
PRO IO_SDFITS_WRITER::nsave_spectrum, spectrum, nsave, status
    compile_opt idl2, hidden

    ; are we creating a new nsave number, or is it already in the index?
    ; what is the nsave numbers location in the index file
    nsave_index = self.index->get_nsave_index(nsave)
    
    if nsave_index eq -1 then begin
        ; this must be a new nsave number
        spectrum.nsave = nsave
        ; append the spectrum to the output file and update the index file
        self->write_spectra, spectrum
        status = 1 
    endif else begin
        ; are we allowed to overwrite previously nsaved spectra?
        if self.index->get_sprotect() eq 0 then begin
            spectrum.nsave = nsave
            ; overwrite the pre-existing specturm with this new one
            self->overwrite_spectrum, nsave_index, spectrum, status=status
        endif else begin
            ; this message is written from the standpoint of the GUIDE user
	    ; users who are knowingly using these classes directly should
            ; use set_sprotect_on, but they typically won't need this
            ; message the way a typically GUIDE user might and in that
            ; case this message might be confusing unless worded this way.
            message, "Cannot nsave spectrum: index file's nsave protection set. Use sprotect_on", /info
            if n_elements(status) ne 0 then status = 0 
        endelse    
    endelse 
    
END

FUNCTION IO_SDFITS_WRITER::get_nsave_index, nsave

    ; get all nsave values
    nsaves = self.index->get_column_values("NSAVE",/unique)
    
    ; is the one we're looking for in there?
    cnt = 0
    nsave_index = where(nsaves eq nsave,cnt)
    
    ; multiple nsave numbers is a blatant error
    if cnt gt 1 then message, "nsave numbers in index file must be unique: "+string(nsave)

    return, nsave_index

END

PRO IO_SDFITS_WRITER::overwrite_spectrum, index, spectrum, status=status
    compile_opt idl2, hidden

    status=0
    
    ; get the location, and other info abou the spectrum to be overwritten
    row_info = self.index->search_for_row_info(index=index)
    
    ; will this spectrum fit in the current spot?
    ; first get the data size for the extension of this index
    spectrum_size = n_elements(*spectrum.data_ptr)

    ; then get the size of the extension that this row is located in
    full_file_name = self->get_full_file_name(row_info.file)
    fits = obj_new("sdfits",full_file_name,version=self.version)
    ext_data_size = fits->get_extension_data_size(row_info.extension)
    if obj_valid(fits) then obj_destroy,fits

    ; if they don't agree, print out warning message, status still 0
    if spectrum_size ne ext_data_size then begin
        message, "Cannot overwrite spectrum of size "+string(ext_data_size)+" with spectrum of size "+string(spectrum_size),/info
        return
    endif

    ; this spectrum can fit in this extension, overwrite the old one
    sdfits_row = self->spectra_to_rows(spectrum, virtuals)     
    
    ; check if we have a fits writer object for this file
    fw = self->get_fits(self.output_file)
  
    ; we are only allowed to write to sdfits files that were created by idl
    if fw->is_gbtidl_file() eq 0 then $
        message, "This file was not created by gbtidl, we cannot modify it: "+self.output_file

    ; types must be compatible
    if fw->row_compatible_with_extension(sdfits_row[0], row_info.extension) then begin
    
        ; finally, overwrite the row in the fits file AND the index
        fw->modify_rows, row_info.extension, row_info.row_num+1, sdfits_row
        self.index->replace_with_spectrum, index, spectrum, row_info.file, row_info.extension, row_info.row_num
        status = 1
    endif else begin
        message,"Some column types differ from current version, can not overwrite spectrum at that location",/info
        return
    endelse
    
END

;+
; Writes given spectra to an sdfits file.  The spectra are translated to their proper
; form for sdfits, and the rows are written to the output file in extensions based off
; the data size of each spectrum.
; @param spectra {in}{type=array} array of spectrum data containers to write to disk
; @keyword file_name {in}{optinal}{type=string} if passed in, this is the name of the output file
; @uses IO_SDFITS_WRITER::set_output_file
; @uses IO_SDFITS_WRITER::check_spectrum_size_uniformity
; @uses IO_SDFITS_WRITER::spectra_to_rows
; @uses IO_SDFITS_WRITER::write_rows_to_extension
; @uses IO_SDFITS_WRITER::update_index_with_spectra
;-
PRO IO_SDFITS_WRITER::write_spectra, spectra, file_name=file_name
    compile_opt idl2

    if keyword_set(file_name) then self->set_output_file, file_name

    uniformity = self->check_spectrum_size_uniformity(spectra)

    if (uniformity eq 1) then begin

        ; all the spectra have the same data size, we can write them at once
        sdfits_rows = self->spectra_to_rows(spectra, virtuals)
        self->write_rows_to_extension, sdfits_rows, virtuals, ext, start
        self->update_index_with_spectra, spectra, ext, start

    endif else begin    
       
        ; not all spectra have same data length, they need separate extensions
        ; group spectra by data size
        spectrum = spectra[0]
        data_size = n_elements(*spectrum.data_ptr)
        group_size = data_size
        spectrum_group = [spectrum]
    
        for i = 1, n_elements(spectra)-1 do begin
        
            spectrum = spectra[i]
            data_size = n_elements(*spectrum.data_ptr)
            if (group_size eq data_size) then begin
                spectrum_group = [spectrum_group,spectrum]
            endif else begin
                ; data size has changed
                ; write current group, and start a new one
                sdfits_rows = self->spectra_to_rows(spectrum_group, virtuals)
                self->write_rows_to_extension, sdfits_rows, virtuals, ext, start
                self->update_index_with_spectra, spectrum_group, ext, start

                ; start a new group
                start_ext = i
                group_size = data_size
                spectrum_group = [spectrum]
            endelse    
           
        endfor   

        ; write last spectrum group
        sdfits_rows = self->spectra_to_rows(spectrum_group, virtuals)
        self->write_rows_to_extension, sdfits_rows, virtuals, ext, start
        self->update_index_with_spectra, spectrum_group, ext, start
        
    endelse    
    
    
END


;+
; Sets index file so nsave numbers cannot be overwritten
;-
PRO IO_SDFITS_WRITER::set_sprotect_on
    compile_opt idl2, hidden
    
    self.index->set_sprotect_on

END    

;+
; Sets index file so nsave numbers can be overwritten
;-
PRO IO_SDFITS_WRITER::set_sprotect_off
    compile_opt idl2, hidden
    
    self.index->set_sprotect_off

END 

;+
; Retrieves the state of nsave protection 
; @returns 0 - nsave numbers cannot be overwritten; 1 - they cannot be overwritten
;-
FUNCTION IO_SDFITS_WRITER::get_sprotect
    compile_opt idl2, hidden

    return, self.index->get_sprotect()

END   

