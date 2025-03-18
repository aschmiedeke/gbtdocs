;+
; Class provides an interface for reading/writing sdfits files that contain zpectrometer data.
; @inherits sdfits
; @file_comments
; Class provides an interface for reading/writing sdfits files that contain spectral line data.
; @private_file
;-

;+
; Class constructor - object is constructed and file may be checked for validity
; @param file_name {in}{optional}{type=string} full path name to sdfits file
; @keyword new {in}{optinal}{type=boolean} is this a new file?
;_
FUNCTION Z_SDFITS::init, file_name, new=new, _EXTRA=ex
    compile_opt idl2, hidden

    ; file name passed?
    if (n_params() eq 1) then begin
        r = self->FITS::init( file_name, _EXTRA=ex )
        ; if this is not a new fits file, check its properties
        if (r eq 1) and (keyword_set(new) eq 0) then begin
            r = self->check_file_validity(/verbose)
            if (r eq 0) then begin 
                print, 'error initing line_sdfits object'
                return, 0
            endif    
        endif    
    endif else begin
        r = self->FITS::init(_EXTRA=ex)
    endelse

    return, r
    
END

;+
; Checks sdfits file for basic validity, and also that it contains spectral line data
; @returns 0,1
; @uses SDFITS::check_sdfits_properties
;-
FUNCTION Z_SDFITS::check_file_validity, _EXTRA=ex
    compile_opt idl2
    
    ; see if we need to print out problems
    if keyword_set(verbose) then loud=1 else loud=0

    ; check that basic sdfits properties are correct
    if (self->check_sdfits_properties( _EXTRA=ex ) eq 0) then return, 0
    
    ; is it for the right backend?
    backend = self->get_extension_header_value("BACKEND")

    ; valid header values for this must be strings
    if (size(backend,/TYPE) eq 7) then begin
        if (backend ne "ZPECTROMETER") then begin
            ;if loud then print, "sdfits file is for wrong backend: "+backend
            print, "sdfits file is for wrong backend: "+backend
            return, 0
        endif
    endif

    ; passes all tests
    return, 1
    
END

;+
; Defines class structure
; @private
;-
PRO z_sdfits__define
    compile_opt idl2, hidden

    ls = { z_sdfits, inherits zfits }    

END
