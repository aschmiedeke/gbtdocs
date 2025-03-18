;+
;  This Class provides an interface for reading/writing sdfits files that contain continuum data
; @file_comments
;  This Class provides an interface for reading/writing sdfits files that contain continuum data
; @inherits sdfits
; @private_file
;-
PRO cntm_sdfits__define
    compile_opt idl2, hidden

    f2 = { cntm_sdfits, inherits sdfits }    
END

;+
; Class Constructor - if file name passed and file exists, file's validity checked
; @param file_name {in}{optional}{type=string} full path name to sdfits file
; @keyword new {in}{optional}{type=boolean} is this a new file?
; @uses CNTM_SDFITS::check_file_validity
;-
FUNCTION CNTM_SDFITS::init, file_name, new=new, _EXTRA=ex
    compile_opt idl2, hidden

    ; file name passed?
    if (n_params() eq 1) then begin
        r = self->FITS::init( file_name, _EXTRA=ex ) 
        ; check file properties if we're not creating a new file
        if (r eq 1) and (keyword_set(new) eq 0) then begin
            r = self->check_file_validity(/verbose)
            if (r eq 0) then begin 
                print, 'error initing cntm_sdfits object'
                return, 0
            endif    
        endif    
    endif else begin
        r = self->FITS::init(_EXTRA=ex)
    endelse

    return, r
    
END

;+
; Checks file for basic validity, and also that it contains continuum data
; @uses SDFITS::check_sdfits_properites
; @returns 0,1
;-
FUNCTION CNTM_SDFITS::check_file_validity, _EXTRA=ex
    compile_opt idl2
    
    ; see if we need to print out problems
    if keyword_set(verbose) then loud=1 else loud=0

    ; check that basic sdfits properties are correct
    if (self->check_sdfits_properties( _EXTRA=ex ) eq 0) then return, 0
    
    ; is it for the right backend?
    backend = self->get_extension_header_value("BACKEND")

    ; valid values for this keyword must be strings
    if (size(backend,/TYPE) eq 7) then begin
        if (backend ne "DCR") then begin
            ;if loud then print, "sdfits file is for wrong backend: "+backend
            print, "sdfits file is for wrong backend: "+backend
            return, 0
        endif
    endif

    ; passes all tests
    return, 1
    
END

;+
; For a given extension, returns the row numbers that represent the start of a scan
; @param extension {in}{type=long} extension number (1-based)
; @uses fxbopen
; @uses fxbread
; @uses fxbclose
; @returns row numbers that are at the start of a scan
;-
FUNCTION CNTM_SDFITS::get_scan_starts, extension

    ; fxbopen uses /GET_LUN to get a new LUN on open
    fxbopen,lun,self.file_name,extension,hdr, access='R'
    fxbread,lun,scan_numbers,'scan'

    num_rows = n_elements(scan_numbers)

    ; make a copy
    scans = scan_numbers
    ; get unique scan numbers
    scans = scans[sort(scans)]
    unique_scans = scans[uniq(scans)]
    ; create an array to hold row #'s for where each scan starts
    scan_starts = make_array(n_elements(unique_scans),/LONG)
    ; get the indicies that new scans start
    for i=0,n_elements(unique_scans)-1 do begin
        r = where(scan_numbers eq unique_scans[i])
        scan_starts[i]=r[0]
    endfor

    ; this is a 0-based index 
    ;scan_starts = scan_starts+1
    
    ; fxbclose free's this lun
    fxbclose, lun

    return, scan_starts

END

;+
; Determine the significant properites of the continuum scan starting at the row given.
; Continuum data is interwoven and spread across rows; using mrdfits here would be inefficient;
; thus we read only the first row, and then certain columns.
; @param ext {in}{type=long} extension
; @param start_row {in}{type=long} the row the scan starts at
; @param end_row {in}{type=long} the row the scan ends at
; @param project {out}{type=string} project id
; @param samplers {out}{type=array} the unique samplers for this scan
; @param sigs {out}{type=array} the unique signals in this scan (1 or 2)
; @param cals {out}{type=array} the unique cal states in this scan (1 or 2)
; @param sampler_pols {out}{type=array} for each sampler, this is the polarization
; @uses SDFITS::get_and eval_rows
; @uses CNTM_SDFITS::get_column
; @uses fxbopen
; @uses fxbclose
; @returns the first row of the scan
;-
FUNCTION CNTM_SDFITS::get_cntm_scan_properties, ext, start_row, end_row, project, samplers, sigs, cals, sampler_pols

    ; get the first row
    row = self->get_and_eval_rows( missing, virtuals, start_row, ext=ext)
    ; watch for bad rows
    if size(row,/type) ne 8 then return, -1

    ; get the project id
    if (where('PROJID' eq tag_names(row)) ne -1) then begin
        project = row.projid
    endif else begin
        if (where('PROJID' eq tag_names(virtuals)) ne -1) then begin
            project = virtuals.projid
        endif else begin    
            project = 'project'
        endelse
    endelse    
    ; open the extension
    ; fxbopen uses /GET_LUN to get this lun
    fxbopen, lun, self.file_name, ext, access='R'
    ; get the unique values for samplers, sigs, and cals
    all_samplers = self->get_column(lun,'SAMPLER',missing,start_row,end_row,'UK')
    all_pols = self->get_column(lun,'CRVAL4',missing,start_row,end_row,0)
    all_sigs = self->get_column(lun,'SIG',missing,start_row,end_row,84)
    all_cals = self->get_column(lun,'CAL',missing,start_row,end_row,84)
    samplers = all_samplers[uniq(all_samplers,sort(all_samplers))]
    sigs = all_sigs[uniq(all_sigs,sort(all_sigs))]
    cals = all_cals[uniq(all_cals,sort(all_cals))]
    ; match polarizations with samplers
    sampler_pols = intarr(n_elements(samplers))
    for i=0,n_elements(samplers)-1 do begin
        whereSamp = where(all_samplers eq samplers[i])
        sampler_pols[i] = all_pols[whereSamp[0]]
    endfor
    ; cleanup
    ; fxbclose frees this lun
    fxbclose, lun
    return, row
    
END

;+
; Retrieves the data for this scan.  Unlike spectral line data, continuum data is dispersed across more then
; one row, and interwoven for one scan.  Thus what is accomplished with spectral line by reading just one
; row is more complicated here.
; @param extension {in}{type=long} extension number
; @param start {in}{type=long} row to start reading from
; @param num_rows {in}{type=long} how many rows to read in from the start
; @param stride {in}{type=long} the spacing between each row that we read in
; @param data {out}{type=struct} structure with pointers to all the data for this scan (data, az, el, ...)
; @param missing {out}{type=array} string array of expected sdfits columns that were not found
; @param virtuals {out}{type=struct} keywords from the extension header that do not describe columns
; @returns first row of continuum data
; @uses SDFITS::get_and_eval_rows
; @uses CNTM_SDFITS::get_float_column
; @uses CNTM_SDFITS::get_string_column
; @uses fxbopen
; @uses fxbclose
;-
FUNCTION CNTM_SDFITS::get_cntm_data, extension, start, num_rows, stride, data, missing, virtuals 
    compile_opt idl2
    
    ; create the index mask from the first row #, # of rows, and step size
    index = lindgen(num_rows)
    index = index * stride

    ; the fxbread methods used below are 1-based
    start = start+1
    
    ; how much data do we HAVE to read?
    end_row = start + (num_rows*stride) - stride

    ; Check for obvious errors
    if end_row lt start then end_row = start
    if end_row eq 0 then end_row = 1

    ; get the first row, and find out what keywords are present, and what is missing
    ; this uses MRDFITS, which is 0-based
    row = self->get_and_eval_rows( missing, virtuals, start-1, ext=extension)
    if size(row,/type) ne 8 then return, -1
    
    ; get the columns that vary for a continnum sdfits file
    ; fxbopen uses /GET_LUN
    fxbopen, lun, self.file_name, extension, access='R'
    *data.data = self->get_float_column(lun,'DATA',missing,start,end_row,index)
    *data.azimuth = self->get_double_column(lun,'AZIMUTH',missing,start,end_row,index)
    *data.elevation = self->get_double_column(lun,'ELEVATIO',missing,start,end_row,index)
    *data.longitude = self->get_double_column(lun,'CRVAL2',missing,start,end_row,index)
    *data.latitude = self->get_double_column(lun,'CRVAL3',missing,start,end_row,index)
    *data.lst= self->get_double_column(lun,'LST',missing,start,end_row,index)
    *data.date_obs= self->get_string_column(lun,'DATE-OBS',missing,start,end_row,'2000-01-01T00:00:00.00',index)
    *data.subref_state = self->get_short_int_column(lun,'SUBREF_STATE',missing,start,end_row,1,index)
    *data.qd_el = self->get_double_column(lun,'QD_EL',missing,start,end_row,index,/nanmissing)
    *data.qd_xel = self->get_double_column(lun,'QD_XEL',missing,start,end_row,index,/nanmissing)
    *data.qd_bad = self->get_short_int_column(lun,'QD_BAD',missing,start,end_row,-1,index)
    ; fxbclose frees this lun
    fxbclose, lun

    return, row
    
END

;+
; Wrapper to fxbread for doubles
; NOTE: fxbread uses 1-based row numbers
; NOTE: this lun was returned by a previous call to fxbopen
; @private
;-
FUNCTION CNTM_SDFITS::get_double_column, lun, col_name, missing, start, end_row, index, nanmissing=nanmissing
    compile_opt idl2
    
    if start ne end_row then begin
    
        ; does this column exist in the extensiom
        if (where(col_name eq missing) eq -1) then begin
            ; the column exists, get it
            fxbread, lun, col_values, col_name, [start, end_row]
        endif else begin
            ; the column doesn't exist, return 0.0's unless nanmissing is set
            if keyword_set(nanmissing) then begin
               col_values = make_array(end_row-start,value=!values.d_nan)
            endif else begin
               col_values = dblarr(end_row-start)
            endelse
        endelse
    
    endif else begin
    
        if (where(col_name eq missing) eq -1) then begin
            ; the column exists, get it
            fxbread, lun, col_values, col_name, start
        endif else begin
            ; the column doesn't exist, return 0.0's unless nanmissing is set
            if keyword_set(nanmissing) then begin
               col_values = make_array(1,value=!values.d_nan)
            endif else begin
               col_values = dblarr(1)
            endelse
        endelse

    endelse

    ; return the pertinent subset of data
    return, col_values[index]
    
END

;+
; Wrapper to fxbread for floats
; NOTE: fxbread uses 1-based row numbers
; NOTE: lun was returned by a previous call to fxbopen
; @private
;-
FUNCTION CNTM_SDFITS::get_float_column, lun, col_name, missing, start, end_row, index
    compile_opt idl2
    
    if start ne end_row then begin
    
        ; does this column exist in the extensiom
        if (where(col_name eq missing) eq -1) then begin
            ; the column exists, get it
            fxbread, lun, col_values, col_name, [start, end_row]
        endif else begin
            ; the column doesn't exist, return 0.0's
            col_values = fltarr(end_row-start)
        endelse

    endif else begin
    
        if (where(col_name eq missing) eq -1) then begin
            ; the column exists, get it
            fxbread, lun, col_values, col_name, start
        endif else begin
            ; the column doesn't exist, return 0.0's
            col_values = fltarr(1)
        endelse

    endelse    

    ; return the pertinent subset of data
    return, col_values[index]
    
END

;+
; Wrapper to fxbread
; NOTE: fxbread uses 1-based row numbers
; NOTE: lun was returned by a previous call to fxbopen
; @private
;-
FUNCTION CNTM_SDFITS::get_string_column, lun, col_name, missing, start, end_row, default, index
    compile_opt idl2
    

    if start ne end_row then begin
    
        ; does this column exist in the extensiom
        if (where(col_name eq missing) eq -1) then begin
            ; the column exists, get it
            fxbread, lun, col_values, col_name, [start, end_row]
        endif else begin
            ; the column doesn't exist, return default string
            col_values = make_array((end_row-start),value=default)
        endelse
    
    endif else begin
    
        if (where(col_name eq missing) eq -1) then begin
            ; the column exists, get it
            fxbread, lun, col_values, col_name, start
        endif else begin
            ; the column doesn't exist, return default
            col_values = default 
    
        endelse
        
    endelse 
    
    ; return the pertinent subset of values
    return, col_values[index]
    
END

;+
; Wrapper to fxbread for short ints
; NOTE: fxbread uses 1-based row numbers
; NOTE: this lun was returned by a previous call to fxbopen
; @private
;-
FUNCTION CNTM_SDFITS::get_short_int_column, lun, col_name, missing, start, end_row, default, index
    compile_opt idl2
    
    if start ne end_row then begin
    
        ; does this column exist in the extensiom
        if (where(col_name eq missing) eq -1) then begin
            ; the column exists, get it
            fxbread, lun, col_values, col_name, [start, end_row]
        endif else begin
            ; the column doesn't exist, return default
            col_values = make_array((end_row-start),value=fix(default))
        endelse
    
    endif else begin
    
        if (where(col_name eq missing) eq -1) then begin
            ; the column exists, get it
            fxbread, lun, col_values, col_name, start
        endif else begin
            ; the column doesn't exist, return default
            col_values = fix(default)
        endelse

    endelse

    ; return the pertinent subset of data
    return, col_values[index]
    
END

;+
; Wrapper to fxbread
; NOTE: fxbread uses 1-based row numbers
; NOTE: lun was returned by a previous call to fxbopen
; @private
;-
FUNCTION CNTM_SDFITS::get_column, lun, col_name, missing, start, end_row, default, index
    compile_opt idl2
    
    if (n_params() eq 7) then use_index = 1 else use_index = 0

    if start ne end_row then begin
    
        ; does this column exist in the extensiom
        if (where(col_name eq missing) eq -1) then begin
            ; the column exists, get it
            fxbread, lun, col_values, col_name, [start+1, end_row]
        endif else begin
            ; the column doesn't exist, return default string
            col_values = make_array((end_row-start),value=default)
        endelse

    endif else begin
    
        if (where(col_name eq missing) eq -1) then begin
            ; the column exists, get it
            fxbread, lun, col_values, col_name, start
        endif else begin
            ; the column doesn't exist, return 0.0's
            col_values = default 
        endelse

    endelse

    ; return the pertinent subset of values
    if use_index then begin
        return, col_values[index]
    endif else begin    
        return, col_values
    endelse    
    
END

