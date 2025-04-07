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
; Temporary function to use as interface until we can think of a better name
; then get_spectra
;-
FUNCTION IO_SDFITS_Z::get_rows, _EXTRA=ex
    compile_opt idl2 

    return, self->get_spectra( _EXTRA=ex )
    
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


