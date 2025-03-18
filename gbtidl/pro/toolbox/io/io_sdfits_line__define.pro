;+
; IO_SDFITS_LINE is intended for end users wishing to work with spectral line data.  It's the child class of IO_SDFITS used for reading, writing, 
; navigating sdfits spectrual line files, and for
; translating their info to spectrum data containers.  See 
; <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or 
; <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just 
; the line and continuum sdfits classes.
;
;
; @file_comments
; IO_SDFITS_LINE is intended for end users wishing to work with spectral line data. It's the child class of IO_SDFITS used for reading, writing, 
; navigating sdfits spectrual line files, and for
; translating their info to spectrum data containers.  See 
; <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or 
; <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just 
; the line and continuum sdfits classes.
;
; @uses <a href="line_index__define.html">LINE_INDEX</a>
; @uses <a href="sdfits__define.html">SDFITS</a>
;
; @inherits io_sdfits 
;
; @version $Id$
;-

;+
; defines class structure
; @private
;-
PRO io_sdfits_line__define
    compile_opt idl2, hidden

    @online_status_info
    io = { io_sdfits_line, inherits io_sdfits, $
           index_class_name:'', $
           index_section_class_name:'', $
           sdfits_class_name:'', $
           default_index_name:'', $
           online_dir:string(replicate(32B,256)), $
           online_info:{online_status_info_strct} $
;           online_lock_dir:string(replicate(32B,256)) $
         }
    
END

;+
; Called upon instantiation of this class.
; @uses IO_SDFITS::init
; @private
;-
FUNCTION IO_SDFITS_LINE::init,index_file=index_file  
    compile_opt idl2, hidden

    self.index_class_name = 'line_index'
    self.index_section_class_name = 'line_index_section'
    self.sdfits_class_name = 'line_sdfits'
    self.default_index_name = 'io_sdfits_line_index'
    r = self->shared_init(index_file=index_file)
    return, r
END
   
;+
; Shared initialization of this class and derived classes
; @private
;-
FUNCTION IO_SDFITS_LINE::shared_init, index_file=index_file, version=version
    compile_opt idl2, hidden
 
    r = self->IO_SDFITS::init()
    ; optionally override the default version
    if n_elements(version) eq 1 then self.version = version
    if r eq 1 then begin
        if keyword_set(index_file) then begin 
            self.index = obj_new(self.index_class_name,file_name=index_file,version=self.version)
        endif else begin    
            self.index = obj_new(self.index_class_name,file_name=self.default_index_name,version=self.version)
        endelse    
        self.debug = 0
        self.online_dir = getConfigValue("SDFITS_DATA",defaultValue="/home/sdfits")
        ; self.online_lock_dir = "/home/sdfits-locks"
    endif
    return, r
    
END

;+
; Class destructor
;-
PRO IO_SDFITS_LINE::cleanup  
    compile_opt idl2, hidden

    self->IO_SDFITS::cleanup
    obj_destroy,self.online_status
    
END    

;+
; Reads in all the rows from every extension in the fits file represented by the
; passed in sdfits object, and passes this on to the index object so that the index
; file can be updated.
; Also, if an index file already exists for this fits file, this index is used
; to update the current index.  If an index file doesn't already exist for this 
; fits file, it is created first, and then used.
; @param fits_obj {in}{type=object} sdfits object representing an sdfits file.
; @uses SDFITS::get_and_eval_rows
; @uses SDFITS::get_number_extensions
; @uses SDFITS::get_file_name
; @uses SDFITS::get_extension_header_value
; @uses LINE_INDEX::update_file
; @private
;-
PRO IO_SDFITS_LINE::update_index_with_fits_file, fits_obj
    compile_opt idl2
    
    ; if a fits file is called 'name.fits', its index is 'name.index'
    index_name = self->get_expected_full_index_name(fits_obj)
    
    ; if we are trying to create 'name.index' from 'name.fits',
    ; (using self->set_file for examle), then read this fits file
    ; and create the index
    if index_name eq self.index->get_full_file_name() then begin
    
        ; must build index directly just by reading fits file
        self->update_index_obj_with_fits_obj, self.index, fits_obj

        ; update the flag files
        self->update_flags_with_fits_file, fits_obj
        
    endif else begin
    
        ; do we need to create a new index to help build our current index file?
        if not self->file_exists(index_name) then begin
            ; there does not exist an index file for this fits file yet
            self->create_index_for_fits_obj, index_name, fits_obj, status
        endif 
    
        ; if this fits file already has an index file, use it!
        if self->file_exists(index_name) then begin
            if self->update_index_with_other_index(index_name) then begin
                if self.debug then print, "used fits index to update index: "+index_name
                ; update the flag files
                self->update_flags_with_fits_file, fits_obj
                return
            endif else begin
                if self.debug then print, "failed attempt to use fits index to update index: "+index_name
                ;message, "failed attempt to use fits index to update index: "+index_name
                file_delete, index_name
                self->create_index_for_fits_obj, index_name, fits_obj, status
                if self->update_index_with_other_index(index_name) then begin
                    ; update the flag files
                    self->update_flags_with_fits_file, fits_obj
                endif else begin
                    message, "failed attempt to use fits index to update index: "+index_name
                endelse
            endelse    
        endif
        
    endelse ; using self->set_file mode?
    
    self.index->read_file

    self.index_synced = 1

END


;+
; Given an object that manages a fits file, and an object for the index
; file, use the fits object to update the index object.  Avoids making
; the costly effort of reading the DATA column from the fits file.
; @param index_obj {in}{required}{type=object} object representing an index file
; @param fits_obj {in}{required}{type=object} object representing a fits file
;-
PRO IO_SDFITS::update_index_obj_with_fits_obj, index_obj, fits_obj
        
    num_exts = fits_obj->get_number_extensions()
    for ext = 1, (num_exts) do begin
        ; for updating an index, we don't need the data column
        rows = fits_obj->get_and_eval_rows(missing, virtuals, ext=ext, /no_data)
        ; watch for bad return result from get_and_eval_rows (empty extension)
        if size(rows,/type) ne 8 then continue

        project = fits_obj->get_extension_header_value('PROJID')
        file_name = fits_obj->get_file_name()
        index_obj->update_file, rows, project, file_name, ext, missing, virtuals
    endfor

END        

;+
; Groups a collection of rows from the index file by file and extension.
; This method is needed since we will want to access each files extension only once
; to read the pertinent rows (for efficiancy reasons).
; @param row_info {in}{type=array} array of structs, where each struct represents a row of the index file
; @returns array of group_row_info structures: rows that share a file and extension 
; @private
;-
FUNCTION IO_SDFITS_LINE::group_row_info, row_info
    compile_opt idl2 
   
    ; get all files
    files = row_info.file
    sortedFiles = files[sort(files)]
    unique_files = sortedFiles[uniq(sortedFiles)]

    group = {line_sdfits_row_group}

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
            group.integrations = ptr_new(file_ext_locals.integration)
            group.if_numbers = ptr_new(file_ext_locals.if_number)
            group.feed_nums = ptr_new(file_ext_locals.feed_number)
            group.pol_nums = ptr_new(file_ext_locals.pol_number)
            group.nsaves = ptr_new(file_ext_locals.nsave)
            if (i eq 0) and (j eq 0) then groups = [group] else groups = [groups,group]
        endfor
    endfor
    
    return, groups

END

;+
;  Function to convert rows into data containers.
;  This is used internally in get_spectra.
;  @private
;-
FUNCTION IO_SDFITS_LINE::rows_to_dc, rows, group, missing, virtuals, apply_offsets
    compile_opt idl2, hidden

    return, self->rows_to_spectra(rows, *group.integrations, $
                                  *group.if_numbers, *group.feed_nums, $
                                  *group.pol_nums, *group.nsaves, $
                                  missing, virtuals, apply_offsets)
END

;+
; This function searches the index file using the keyword parameters passed
; into it, reads the appropriate parts of the sdfits files, and tranlates this
; data into spectrum structures, which are returned.
; 
; @keyword _EXTRA {in}{optional} see <a href="line_index__define.html">search_for_row_info</a> for more info 
; @param count {out}{optional}{type=long} number of spectra returned
; @param indicies {out}{optional}{type=long} index numbers
; corresponding to each returned spectrum.  Can be used in flagging,
; future data retrieval, etc.
; @keyword srow {in}{optional}{type=int} starting row number to use in
; search.  Used after scan_info has been used.  Must be used with nrow.
; @keyword nrow {in}{optional}{type=int} Number of rows to use in
; search.  Used after scan_info has been used.  Must be used with srow.
;
; @returns Array of spectrum structures 
;
; @examples
; <pre>
; </pre>
;
; @uses LINE_INDEX::search_for_row_info
; @uses SDFITS::get_and_eval_rows
; @uses IO_SDFITS_LINE::rows_to_spectra
;
;-
FUNCTION IO_SDFITS_LINE::get_spectra, _EXTRA=ex, srow=srow, nrow=nrow, useflag=useflag, skipflag=skipflag, count, indicies
    compile_opt idl2 

    if self.index->validate_search_keywords(ex) eq 0 then begin
        count = 0
        return, -1
    endif    
  
    if self->check_search_param_syntax(_EXTRA=ex) eq 0 then begin
        count = 0
        return, -1
    endif
        
    ; if we're online, read in the latest index rows into memory
    if self.online then self->update

                                ; find the files,extensions, and rows
                                ; that match the specified criteria
    ; add srow and nrow to search keywords if necessary
    if n_elements(srow) eq 1 and n_elements(nrow) eq 1 then begin
       ex = create_struct(ex,'srow',srow,'nrow',nrow)
    endif
    row_info = self.index->search_for_row_info(indicies, _EXTRA=ex)
    
    ; get the flags
    flags = self.flags->get_flag_strcts(useflag=useflag, skipflag=skipflag, flag_count, index_value_recnums)

    if (size(row_info,/dimension) eq 0) then begin
        if row_info eq -1 then begin
            count = 0
            return, -1
        endif
     endif

    ; set this here, the spectra may not be returned in the order in which
    ; there were discovered via row_info, use that one to know
    ; what was last, indicies then is reset to reflect the returned order
    self.last_record = indicies[n_elements(indicies)-1]
     
    ; group rows found in index file by filename and extension
    groups = self->group_row_info(row_info)
    
    ; must read each extension seperately becasue they may contain varying data sizes
    for i = 0, n_elements(groups)-1 do begin
        sdfits_rows = self->get_and_eval_rows(groups[i], missing, virtuals,apply_offsets)
        ; watch for bad return value - empty extension
        if size(sdfits_rows,/type) ne 8 then continue

        ; convert this group of rows to data containers
        spectra = self->rows_to_dc(sdfits_rows, groups[i], missing, virtuals,apply_offsets)
        ; flag via recnum , if there ARE flags
        if flag_count ne 0 then begin
            for j=0,n_elements(flags)-1 do begin
                ind = self->find_flagged_index_data( *groups[i].index, index_value_recnums[j], count)
                if count ne 0 then self->flag_data,spectra[ind],flags[j]
            endfor
        endif    
        if (i eq 0) then begin
           all_spectra = [spectra] 
           ; save off the indicies for later use
           indicies = [*groups[i].index]
       endif else begin
           all_spectra = [temporary(all_spectra),spectra]
           indicies = [temporary(indicies),*groups[i].index]
        endelse
    endfor    

    self->free_group_row_info, groups
    
    count = n_elements(all_spectra)

    ; now, apply flagging via spectral characteristics, if there ARE flags
    if flag_count ne 0 then begin
       for i=0,n_elements(flags)-1 do begin
          flag = flags[i]
          flagged_data = self->find_flagged_data(all_spectra, flag, fcount)
          if fcount ne 0 then self->flag_data, all_spectra[flagged_data],flag
       endfor
    endif    

    return, all_spectra

END

;+
; Handles the translation of several sdfits rows to spectrum data containers.
; Utilizes additional info from the index file, as well as info on keywords in the extension roads are found in, and what ever expected columns were not found in the sdfits file.
;
; @param sdfits_rows {in}{type=array} an array of structures mirroring rows from an sdfits file extension containing spectral line data
; @param integrations {in}{type=array} the integration numbers for these spectra; from index file
; @param if_numbers {in}{type=array} the if numbers for these spectra; from index file
; @param nsaves {in}{type=array} the nsave numbers for these spectra; from index file
; @param missing {in}{type=array} array of column names that were expected in sdfits file extension, but not found.
; @param virtuals {in}{optional}{type=struct} structure containing keywords found in the extension header.
;
; @uses io_sdfits_line::sdfits_row_to_spectrum
; @private
;-
FUNCTION IO_SDFITS_LINE::rows_to_spectra, sdfits_rows, integrations, if_numbers, feed_nums, pol_nums, nsaves, missing, virtuals, apply_offsets
    compile_opt idl2
    
    @spectrum_struct
    num_rows = n_elements(sdfits_rows)
    spectra = make_array(num_rows,value={spectrum_struct})
    for i = 0, (num_rows-1) do begin
        spectrum = self->sdfits_row_to_spectrum( sdfits_rows[i], integrations[i], if_numbers[i], feed_nums[i], pol_nums[i], nsaves[i], missing, virtuals, apply_offsets )
        if self.debug then print, "getting spectrum: "+string(i)+" of: "+string(num_rows)
        spectra[i] = spectrum
    endfor
    return, spectra

END

;+
; Handles the translation of an sdfits row to a spectrum data container.
; Utilizes additional info from the index file, as well as info on
; keywords in the extension roads are 
; found in, and what ever expected columns were not found in the sdfits file.
;
; @param row {in}{type=struct} a structure mirroring a row from an sdfits file extension containing spectral line data
; @param integration {in}{type=long} the integration number of this spectrum; from index file
; @param if_number {in}{type=long} the if number of this spectrum; from index file
; @param nsave {in}{type=long} the nsave number of this spectrum; from index file
; @param missing {in}{type=array} array of column names that were expected in sdfits file extension, but not found.
; @param virtuals {in}{optional}{type=struct} structure containing keywords found in the extension header.
;
; @uses io_sdfits::get_row_value
; @uses io_sdfits::format_sdfits_freq_type
; @uses io_sdfits::coord_mode_from_types
; @uses io_sdfits::translate_sig
; @uses io_sdfits::translate_cal
; @uses io_sdfits::parse_sdfits_obsmode
; @uses fitsdateparse
; @uses juldate
; @private
;-
FUNCTION IO_SDFITS_LINE::sdfits_row_to_spectrum, row, integration, if_number, feed_num, pol_num, nsave, missing, virtuals, apply_offsets
    compile_opt idl2

    spec = {spectrum_struct} ;data_new()
    spec.data_ptr = ptr_new(/allocate_heap)
    
    ; check for NO virtual columns
    if (size(virtuals,/TYPE) eq 3) then virtual_names=-1 else virtual_names=tag_names(virtuals)
    
    names = {row:ptr_new(tag_names(row)),missing:ptr_new(missing),virtuals:ptr_new(virtual_names)}
 
    ; default values to use for missing cols in sdfits row
    di = -1L
    df = 0.0
    dd = 0.0D
    ds = 'default'
    nan = !values.f_nan
    
    spec.source = self->get_row_value(row,'OBJECT',virtuals,names,ds)
    spec.projid = self->get_row_value(row,'PROJID',virtuals,names,ds)
    spec.backend = self->get_row_value(row,'BACKEND',virtuals,names,ds) 
    spec.observer = self->get_row_value(row,'OBSERVER',virtuals,names,ds) 
    spec.telescope = self->get_row_value(row,'TELESCOP',virtuals,names,ds) 
    spec.bandwidth = self->get_row_value(row,'BANDWID',virtuals,names,dd)
    
    date_obs = self->get_row_value(row,'DATE_OBS',virtuals,names,ds)
    fd = fitsdateparse(date_obs)
    spec.date = strmid(date_obs,0,10)
    spec.utc = (fd[3]*60.0+fd[4])*60.0 + fd[5]

    juldate,fd,mjd
    ; juldate returnes Reduced Julian Date (RJD): MJD = RJD - 0.5
    spec.mjd=mjd - 0.5
    spec.timestamp = strtrim(self->get_row_value(row,'TIMESTAMP',virtuals,names,ds),2)
    spec.exposure = self->get_row_value(row,'EXPOSURE',virtuals,names,dd)
    spec.duration = self->get_row_value(row,'DURATION',virtuals,names,dd)
    spec.tambient = self->get_row_value(row,'TAMBIENT',virtuals,names,!values.f_nan)
    spec.pressure = self->get_row_value(row,'PRESSURE',virtuals,names,!values.f_nan) * 133.322368d ; mm Hg -> Pa
    spec.humidity = self->get_row_value(row,'HUMIDITY',virtuals,names,!values.f_nan)
    spec.tsys = self->get_row_value(row,'TSYS',virtuals,names,dd)
    spec.tsysref = self->get_row_value(row,'TSYSREF',virtuals,names,dd)
    sitelong = self->get_row_value(row,'SITELONG',virtuals,names,dd)
    sitelat = self->get_row_value(row,'SITELAT',virtuals,names,dd)
    siteelev = self->get_row_value(row,'SITEELEV',virtuals,names,dd)
    ; if this is the GBT, and it's got a positive longitude, its sdfits ver 1.1;
    ; turn it negative (bug in SDFITS 1.1); this is fixed in ver 1.2
    if (spec.telescope eq "NRAO_GBT") and (sitelong gt 0.0) then sitelong = -sitelong
    spec.site_location = [sitelong, sitelat, siteelev]
    
    ; assume row has a data tag name!
    *spec.data_ptr = row.data

    spec.units = self->get_row_value(row,'TUNIT7',virtuals,names,"")
    spec.frequency_type = self->format_sdfits_freq_type(self->get_row_value(row,'CTYPE1',virtuals,names,ds))
    spec.reference_frequency = self->get_row_value(row,'CRVAL1',virtuals,names,dd)
    ; ref channel 1-based in sdfits, 0-based in idl
    spec.reference_channel = self->get_row_value(row,'CRPIX1',virtuals,names,1.0) - 1.0
    spec.frequency_interval = self->get_row_value(row,'CDELT1',virtuals,names,dd)
    ; frequency_resolution should always be positive
    spec.frequency_resolution = abs(self->get_row_value(row,'FREQRES',virtuals,names,spec.frequency_interval))
    ctype2 = self->get_row_value(row,'CTYPE2',virtuals,names,ds)
    ctype3 = self->get_row_value(row,'CTYPE3',virtuals,names,ds) 
    spec.coordinate_mode = self->coord_mode_from_types(ctype2,ctype3)
    spec.equinox = self->get_row_value(row,'EQUINOX',virtuals,names,2000.0d)
    spec.longitude_axis = self->get_row_value(row,'CRVAL2',virtuals,names,dd)
    spec.latitude_axis = self->get_row_value(row,'CRVAL3',virtuals,names,dd)
    spec.equinox = self->get_row_value(row,'EQUINOX',virtuals,names,2000.0d)
    spec.radesys = self->get_row_value(row,'RADESYS',virtuals,names,'')
    if (spec.radesys eq '' and spec.coordinate_mode eq 'RADEC') then begin
        if (spec.equinox eq 2000.0) then begin
            spec.radesys = 'FK5'
        endif else begin
            if (spec.equinox eq 1950.0) then begin
                spec.radesys = 'FK4'
            endif else begin
                spec.radesys = 'GAPPT'
            endelse
        endelse
    endif
    spec.target_longitude = self->get_row_value(row,'TRGTLONG',virtuals,names,0.0D)
    spec.target_latitude = self->get_row_value(row,'TRGTLAT',virtuals,names,0.0D)
    crval4 = self->get_row_value(row,'CRVAL4',virtuals,names,0)
    spec.polarization = self->format_sdfits_polarization(crval4[0])
    spec.scan_number = self->get_row_value(row,'SCAN',virtuals,names,di)
    obsmode = self->get_row_value(row,'OBSMODE',virtuals,names,ds)
    self->parse_sdfits_obsmode,obsmode,proc,swstate,swtchsig
    spec.procedure = proc
    spec.switch_state = swstate
    spec.switch_sig = swtchsig
    spec.obsid = self->get_row_value(row,'OBSID',virtuals,names,ds)
    spec.procscan = self->get_row_value(row,'PROCSCAN',virtuals,names,"Unknown")
    spec.proctype = self->get_row_value(row,'PROCTYPE',virtuals,names,"Unknown")
    spec.frontend = self->get_row_value(row,'FRONTEND',virtuals,names,ds)
    ; FEEDXOFF/FEEDEFF vs older BEAMXOFF/BEAMEOFF
    ;   current - use default of nan to watch for missing case
    spec.feedxoff = self->get_row_value(row,'FEEDXOFF',virtuals,names,nan)
    if not finite(spec.feedxoff) then begin
       ; not found, try older version, standard defaults
       spec.feedxoff = self->get_row_value(row,'BEAMXOFF',virtuals,names,dd)
       spec.feedeoff = self->get_row_value(row,'BEAMEOFF',virtuals,names,dd)
    endif else begin
       ; feedeoff should be there, standard defaults
       spec.feedeoff = self->get_row_value(row,'FEEDEOFF',virtuals,names,dd)
    endelse
    spec.mean_tcal = self->get_row_value(row,'TCAL',virtuals,names,dd)
    spec.velocity_definition = self->get_row_value(row,'VELDEF',virtuals,names,ds)
    spec.frame_velocity = self->get_row_value(row,'VFRAME',virtuals,names,dd)
    spec.observed_frequency = self->get_row_value(row,'OBSFREQ',virtuals,names,dd)
    spec.lst = self->get_row_value(row,'LST',virtuals,names,dd) 
    spec.azimuth = self->get_row_value(row,'AZIMUTH',virtuals,names,dd)
    spec.elevation = self->get_row_value(row,'ELEVATIO',virtuals,names,dd)
    spec.subref_state = self->get_row_value(row,'SUBREF_STATE',virtuals,names,1)
    spec.qd_xel = self->get_row_value(row,'QD_XEL',virtuals,names,nan)
    spec.qd_el = self->get_row_value(row,'QD_EL',virtuals,names,nan)
    spec.qd_bad = self->get_row_value(row,'QD_BAD',virtuals,names,-1)
    spec.qd_method = self->get_row_value(row,'QD_METHOD',virtuals,names,'')
    spec.line_rest_frequency = self->get_row_value(row,'RESTFREQ',virtuals,names,dd)
    spec.doppler_frequency = self->get_row_value(row,'DOPFREQ',virtuals,names,dd)
    spec.center_frequency = self.index->get_center_frequency(spec.reference_frequency,spec.reference_channel,spec.frequency_interval,n_elements(row.data))
    spec.sampler_name = self->get_row_value(row,'SAMPLER',virtuals,names,ds)
    spec.feed = self->get_row_value(row,'FEED',virtuals,names,di)
    spec.srfeed = self->get_row_value(row,'SRFEED',virtuals,names,di)
    spec.sideband = self->get_row_value(row,'SIDEBAND',virtuals,names,ds)
    spec.procseqn =  self->get_row_value(row,'PROCSEQN',virtuals,names,0)
    spec.procsize = self->get_row_value(row,'PROCSIZE',virtuals,names,di)
    spec.source_velocity = self->get_row_value(row,'VELOCITY',virtuals,names,dd)
    spec.zero_channel = self->get_row_value(row,'ZEROCHAN',virtuals,names,nan)
    spec.adcsampf = self->get_row_value(row,'ADCSAMPF',virtuals,names,nan)
    spec.vspdelt = self->get_row_value(row,'VSPDELT',virtuals,names,nan)
    spec.vsprval = self->get_row_value(row,'VSPRVAL',virtuals,names,nan)
    ; make vsprpix 0-relative for use in IDL
    spec.vsprpix = self->get_row_value(row,'VSPRPIX',virtuals,names,nan) - 1
    spec.freq_switch_offset = self->get_row_value(row,'FOFFREF1',virtuals,names,dd)
    spec.sig_state = self->translate_sig(self->get_row_value(row,'SIG',virtuals,names,'T'))
    spec.cal_state = self->translate_cal(self->get_row_value(row,'CAL',virtuals,names,'T'))
    spec.caltype = self->get_row_value(row,'CALTYPE',virtuals,names,'')
    spec.twarm = self->get_row_value(row,'TWARM',virtuals,names,nan)
    spec.tcold = self->get_row_value(row,'TCOLD',virtuals,names,nan)
    spec.calposition = self->get_row_value(row,'CALPOSITION',virtuals,names,'Unknown')

    ; apply feed offsets for old data when non-zero
    if apply_offsets then begin
       dcdofeedoffsets,spec
    endif
    
    ; additional stuff - all from index file unless available in sdfits file
    spec.integration = self->get_row_value(row,'INT',virtuals,names,integration)
    spec.if_number = self->get_row_value(row,'IFNUM',virtuals,names,if_number)
    spec.feed_num = self->get_row_value(row,'FDNUM',virtuals,names,feed_num)
    spec.polarization_num = self->get_row_value(row,'PLNUM',virtuals,names,pol_num)
    spec.nsave = self->get_row_value(row,'NSAVE',virtuals,names,nsave)
    
    ptr_free,names.row
    ptr_free,names.missing
    ptr_free,names.virtuals

    return, spec
END

;+
; Frees the memory referenced by pointers in the passed in structure
; @param row_info {in}{type=struct} contains pointers to row number lists, integration and if number lists
; @private
;-
PRO IO_SDFITS_LINE::free_group_row_info, row_info
    compile_opt idl2

    for i=0, (n_elements(row_info)-1) do begin
        if ptr_valid(row_info[i].rows) then ptr_free, row_info[i].rows
        if ptr_valid(row_info[i].integrations) then ptr_free, row_info[i].integrations
        if ptr_valid(row_info[i].if_numbers) then ptr_free, row_info[i].if_numbers
        if ptr_valid(row_info[i].feed_nums) then ptr_free, row_info[i].feed_nums
        if ptr_valid(row_info[i].pol_nums) then ptr_free, row_info[i].pol_nums
        if ptr_valid(row_info[i].nsaves) then ptr_free, row_info[i].nsaves
        if ptr_valid(row_info[i].index) then ptr_free, row_info[i].index
    endfor

END

;+
; Creates and returns a line_sdfits object
; @param file_name {in}{type=string} full path file name for sdfits file of with spectral line data
; @private
;-
FUNCTION IO_SDFITS_LINE::get_new_fits_obj, file_name, _EXTRA=ex
    compile_opt idl2

    return, obj_new(self.sdfits_class_name,file_name,version=self.version,_EXTRA=ex)

END 

;+
;
; Determines if any files have grown, and appends new rows to the index file
;
; @uses get_new_row_locations
; @uses group_row_locations
;
; @examples
; >io->set_file, 'filename'
; >io->list
; ; here you see contents of 'filename'
; >io->update ; even though 'filename' hasnt changed
; >'No sdfits file(s) in index need updating'
; ; now new rows are appended to 'filename' (by the online filler perhaps)
; >io->update
; >'Index file updated with 5 rows'
; >io->list
; ; here you see the original contents of 'filname'
; ; plus the extra 5 new rows.
; ; NOTE: the index file was NOT re-created from scatch
;
;-
PRO IO_SDFITS_LINE::load_new_sdfits_rows

    if self.index->is_file_loaded() eq 0 then message, "Cannot update until an index file has been created/loaded"
   
    ; for every file in sdfits file, check that its 'nsync
    files = self.index->get_column_values('file',/unique)
    for i=0,n_elements(files)-1 do begin
        status = 0
        locations = self->get_new_row_locations(files[i],status) 
        if status then begin
            ; group the locations by filename-extension to save file I/O time
            location_groups = self->group_locations(locations)
            ; use a fits object for accessing the fits file that has our missing rows
            fits = self->get_fits(files[i])
            for j=0,n_elements(location_groups)-1 do begin
                group = location_groups[j]
                new_rows = fits->get_and_eval_rows(missing, virtuals, (*group.rows), ext=group.ext)
                ; watch for bad return value - empty extension
                if size(new_rows,/type) ne 8 then continue

                project = fits->get_extension_header_value('PROJID')
                file_name = fits->get_file_name()
                startrow = (*group.rows)[0]
                self.index->update_file, new_rows, project, file_name, group.ext, missing, virtuals, startrow
                ; free memory
                ptr_free, group.rows
            endfor ; for each extension
        endif 
    endfor ; for each file
    
    ; get the new additions into memory
    self.index->read_file
    self.index_synced = 1

END

;+
; Like other group functions in I/O, groups an array of structures by their filename,
; and extension tags.  This is used so that rows in the same file-extension can be 
; accessed all at once.
; @param locations {in}{required}{type=array} array of structures containing filenames, ext, and row #
; @returns array of structures, each structure giving a filename, extension, and array of row nubmers
; @private
;-
FUNCTION IO_SDFITS_LINE::group_locations, locations
    compile_opt idl2 

    group = {location_group,filename:string(replicate(32B,256)),ext:0L,rows:ptr_new()}
   
    ; get all files
    files = locations.filename
    unique_files = files[uniq(files,sort(files))]
    
    for i = 0, (n_elements(unique_files)-1) do begin
        file_locals = locations[ where(locations.filename eq unique_files[i]) ]
        exts = file_locals.ext
        unique_exts = exts[uniq(exts,sort(exts))]
        for j = 0, (n_elements(unique_exts)-1) do begin
            group = {location_group}
            group.rows = ptr_new(/allocate_heap)
            file_ext_locals = file_locals[ where(file_locals.ext eq unique_exts[j]) ]
            ; collapse the array into one struct
            group.filename = file_ext_locals[0].filename
            group.ext = file_ext_locals[0].ext
            *group.rows = file_ext_locals.row
            if (i eq 0) and (j eq 0) then groups = [group] else groups = [groups,group]
        endfor
    endfor

    return, groups
    
END

;+
; Compares index file with sdfits files listed in it, and looks for new rows in the sdfits file.
; @returns array of structures, each giving location of file, extension, and row # of new sdfits row
; @private
;-
FUNCTION IO_SDFITS_LINE::get_new_row_locations, filename, status
    compile_opt idl2, hidden

    loc = {row_location, filename:string(replicate(32B,256)), ext:0L, row:0L}
    
    ; get the fits object for this file
    fits = self->get_fits(filename)
    fits->update_properties

    ; retrieve the extensions in the file
    file_num_exts = fits->get_number_extensions()
    file_exts = lindgen(file_num_exts)+1

    ; collect all index rows for this file
    index_rows = self.index->search_for_row_info(file=filename)

    ; collect all the extensions in the index file
    index_exts = index_rows.extension
    index_exts = index_exts[uniq(index_exts,sort(index_exts))]

    ; what extensions does the index not have?
    for i=0,n_elements(file_exts)-1 do begin
        ; dont just compare the number of extesions, be more thourogh
        count = 0
        ind = where(file_exts[i] eq index_exts, count)
        if count eq 0 then begin
            if n_elements(missing_ext) eq 0 then missing_ext = [file_exts[i]] else missing_ext = [missing_ext, file_exts[i]]
        endif
    endfor ; for each extension in file

    ; recored the locations of all rows in the missing extensions
    if n_elements(missing_ext) ne 0 then begin
        for i=0,n_elements(missing_ext)-1 do begin
            ; get number of rows in this fits file - row numbers are 0-based
            num_rows = fits->get_ext_num_rows(missing_ext[i])
            for j=0,num_rows-1 do begin
                loc = {row_location}
                loc.filename = filename
                loc.ext = missing_ext[i]
                loc.row = j
                if n_elements(locs) eq 0 then locs=[loc] else locs=[locs,loc]
            endfor ; for each missing row number
        endfor ; for each missing extension
    endif

    ; missing rows in index extensions?
    for i=0,n_elements(index_exts)-1 do begin
        ; for each extension, compare row's. get the index's ext's rows
        index_rows = self.index->search_for_row_info(file=filename,ext=index_exts[i])
        index_row_nums = index_rows.row_num
        ; get the fits files rows for this extension
        file_ext_num_rows = fits->get_ext_num_rows(index_exts[i])
        ; although there aren't 'row numbers' in the sdfits files, treat them
        ; like they are, and don't just compare number of rows
        missing_rows = [-1]
        for j=0,file_ext_num_rows-1 do begin
            count = 0
            ind = where(j eq index_row_nums,count) 
            if count eq 0 then begin
                ; build the list of missing rows for this ext    
                missing_rows = [missing_rows, j]
            endif
        endfor ; for each file row number for this extension

        ; if rows are missing, record their location in the sdfits file
        if n_elements(missing_rows) gt 1 then begin
            missing_rows = missing_rows[1:n_elements(missing_rows)-1]
            for j=0,n_elements(missing_rows)-1 do begin
                loc = {row_location}
                loc.filename = filename
                loc.ext = index_exts[i]
                loc.row = missing_rows[j]
                if n_elements(locs) eq 0 then locs=[loc] else locs=[locs,loc]
            endfor
        endif ; if rows missing
    endfor ; for each ext in index

    if n_elements(locs) eq 0 then begin
        status = 0
        return, -1
    endif else begin
        status = 1
        return, locs
    endelse

END

;+
; Finds the latest files in the online directory (reads status file
; produced by online sdfits).
; @param newest_acs {out}{optional}{type=string} the newest
; spectrometer fits file in the online directory  
; @param newest_dcr {out}{optional}{type=string} the newest dcr fits
; file in the online directory 
; @param newest_sp {out}{optional}{type=string} the newest spectral
; processor fits file in the online directory
; @param newest_zpec {out}{optional}{type=string} the newest
; zpectrometer fits file in the online directory
; @param newest_vegas {out}{optional}{type=string} the newest vegas
; fits directory in the online directory
; @param status {out}{optional}{type=boolean} 0 - error, 1 - success
; @returns the newest spectral line fits file (ignoring any dcr and
; zpec fits files) in the online directory 
;-
FUNCTION IO_SDFITS_LINE::get_online_files, newest_acs, newest_dcr, newest_sp, newest_zpec, newest_vegas, status
    compile_opt idl2

    status = 0
    
    if obj_valid(self.online_status) eq 0 then begin
        ; check if /home/sdfits is visible
        if file_test(self.online_dir) eq 0 then begin
            message, "Cannot find online files: "+self.online_dir+" not visible", /info
            return, -1
        endif
        self.online_status = obj_new('online_status_file',self.online_dir)
    endif
    if self.online_status->get_status() eq 0 then return, -1

    newest = self.online_status->get_filenames(newest_acs, newest_dcr, newest_sp, newest_zpec, newest_vegas, status)
    
    ; warning message if absolutely nothing found
    if strlen(newest_acs+newest_dcr+newest_sp+newest_zpec+newest_vegas) eq 0 then begin
        message, "No fits files shown in online sdfits status file in : "+self.online_dir, /info
        return, -1
    endif

    return, newest
    
END

;+
; Finds the latest online info structs for all of the lines in the
; current online sdfits info file. 
; @param newest_acs {out}{optional}{type=online_status_info_strct} the current
; spectrometer fits file info structure in the online directory  
; @param newest_dcr {out}{optional}{type=online_status_info_strct} the current
; dcr fits file info structure in the online directory 
; @param newest_sp {out}{optional}{type=online_status_info_strct} the current
; spectral processor fits file info structure in the online directory
; @param newest_zpec {out}{optional}{type=online_status_info_strct} the current
; zpectrometer fits file info structure in the online directory
; @param newest_vegas {out}{optional}{type=online_status_info_strct}
; the current vegas fits directory info struture in the online directory
; @param status {out}{optional}{type=boolean} 0 - error, 1 - success
; @returns the newest spectral line fits file info structure (ignoring any dcr and
; zpec fits files) in the online directory 
;-
FUNCTION IO_SDFITS_LINE::get_online_infos, newest_acs, newest_dcr, newest_sp, newest_zpec,  newest_vegas, status
    compile_opt idl2

    status = 0
    
    if obj_valid(self.online_status) eq 0 then begin
        ; check if /home/sdfits is visible
        if file_test(self.online_dir) eq 0 then begin
            message, "Cannot find online files: "+self.online_dir+" not visible", /info
            return, -1
        endif
        self.online_status = obj_new('online_status_file',self.online_dir)
    endif
    if self.online_status->get_status() eq 0 then return, -1

    newest = self.online_status->get_all_infos(newest_acs, newest_dcr, newest_sp, newest_zpec, newest_vegas, status)
    
    ; warning message if absolutely nothing found
    if strlen(newest_acs.file+newest_dcr.file+newest_sp.file+newest_zpec.file+newest_vegas.file) eq 0 then begin
        message, "No fits files shown in online sdfits status file in : "+self.online_dir, /info
        return, -1
    endif

    return, newest
    
END

;+
; Connects to a file in the online directory, and sets up object so that
; every time a query of the index file is done, the update method is called.
; This depends on another process(es) that should be updating the sdfits and
; index files for the current project.
;
; @param file_name {in}{required}{type=string} base or full filename
; to connect to (may be a directory)
; @keyword test {in}{optional}{type=bool} if true, this is a test, and the online directory does not need to be visible
;
;-
PRO IO_SDFITS_LINE::set_online, file_name, test=test
    compile_opt idl2

    ; just in case we were thrown out of update with one in progress,
    ; this allows for that status to be reset
    self.update_in_progress = 0

    ; find this in the online_status 
    if obj_valid(self.online_status) eq 0 then begin
        ; check if /home/sdfits is visible
        if file_test(self.online_dir) eq 0 and keyword_set(test) eq 0 then begin
            message, "Cannot find online files: "+self.online_dir+" not visible", /info
            return
        endif
        self.online_status = obj_new('online_status_file',self.online_dir)
    endif
    if self.online_status->get_status() eq 0 then begin
        message,"There was a problem reading the online status file.  No online files are available.",/info
        return
    endif

    ; this must be either ACS, SP, VEGAS, or ZPEC
    self.online_info = self.online_status->get_status_info('acs')
    if self.online_info.file ne file_name then begin
        self.online_info = self.online_status->get_status_info('vegas')
        if self.online_info.file ne file_name then begin
            self.online_info = self.online_status->get_status_info('sp')
            if self.online_info.file ne file_name then begin
                self.online_info = self.online_status->get_status_info('zpec')
                if self.online_info.file ne file_name then begin
                    message,"The requested file is not currently an online file.",/info
                    message,"Use 'offline' to connect to this file:" + file_name,/info
                    return
                endif
            endif
        endif
    endif

    ; is the file_path a directory
    isDirectory = file_test(file_name,/directory)

    ; check if path is included or not
    file_path = file_dirname(file_name)
    file_name = file_basename(file_name)
    if file_path eq "." then file_path = self.online_dir
    ; if keyword_set(test) then self.online_lock_dir = file_path

    ; construct the name of the index we should load
    if isDirectory then begin
        ; directory index is directory name + .index
        index_file = file_name + '.index'
        ; file path should be that directory
        file_path = file_path + "/" + file_name
    endif else begin
        ; last part is "fits", extract the rest and add on '.index'
        parts=strsplit(file_name,'.',/extract)
        index_file = strjoin(parts[0:n_elements(parts)-2],'.')+'.index'
    endelse
    
    ; for online mode, the daemons really should create it;
    ; therefore, if this index doesn't exist, raise an error

    if file_test(file_path+'/'+index_file) eq 0 then begin
        message, "Cannot use online mode: index file not created yet.  Wait until first scan is finished or seek help.", /info
        return
    endif
    
    ; discard all other fits objects
    self->free_fits_objs

    ; set the names of the index file, and where it's located
    self->set_file_path, file_path
    self->set_index_file_name, index_file

    ; mark the state as online
    self.online = 1

    ; add this file, the index should get loaded
    if isDirectory then begin
        ; read the index file as far as the status indicates we should
        self.index->read_file, ver_status, max_nrows=self.online_info.index+1
        if ver_status eq 0 then begin
            ; bad version number, oops
            message, 'Cannot read online index, version number is out of date.  Report this problem.', /info
            return
        endif
        self->conform_fits_objs_to_index
        self.index_synced = 1
        ; no need to look for additional files not already in the index
        self->load_index_flag_info
        self.one_file = 0
    endif else begin
        self->add_file, file_name, max_nrows=self.online_info.index+1
    
        ; mark this io object as dedicated to one file
        self.one_file = 1
    endelse
 

END

;+
; Reads the new lines in an index file into memory, if the size of the
; index file has changed.  Uses a lock file since other processes might
; be reading/writing the index file.
; @uses INDEX_FILE::read_new_rows
;-
PRO IO_SDFITS_LINE::update
    compile_opt idl2

    if self.update_in_progress then begin
        return
    endif

    if self.online then begin
        ; monitor online status info
        curr_info = self.online_status->get_status_info(self.online_info.backend)

        if curr_info.file ne self.online_info.file then begin
            ; no longer the current online file
            ; turn off online mode
            self.online=0
            ; recursively invoke update to get the standard update
            ; to make sure the copy in memory here is fully up to date
            self->update
            ; and now tell the user about all of this
            message,'This data file is no longer the current online file for this backend.',/info
            message,'Automatic updates on this file are now turned off in GBTIDL.',/info
            message,'Use "online" to switch to the current online file.',/info
        endif else begin
            if curr_info.index ne self.online_info.index then begin
                ; need to update, index has changed
                self.update_in_progress = 1
                self.index->read_new_rows, num_new_lines, max_nrows=(curr_info.index+1)

                if self.one_file eq 0 then begin
                    self->conform_fits_objs_to_index
                    self->load_index_flag_info
                endif
                self.online_info = curr_info
                self.update_in_progress = 0
           endif
        endelse
    endif else begin
        ; otherwise need to look at the index file size to watch for changes
        current_fi = file_info(self.index->get_full_file_name())
        old_fi = self.index->get_info()
        if old_fi.size ne current_fi.size then begin
            ; the size has changed
            self.update_in_progress = 1
            self.index->set_info, current_fi
            ; check the status of the lock file
	    ; The lock file check was commented out by JB, as discussed with gbtidl team.
	    ; It's only purpose is to print a warning message on the screen.
            ; self->check_lock_file
            self.index->read_new_rows, num_new_lines
            if self.one_file eq 0 then begin
                self->conform_fits_objs_to_index
                self->load_index_flag_info
            endif
            self.update_in_progress = 0
        endif 
     endelse
END  

FUNCTION IO_SDFITS_LINE::get_index_class_name
    compile_opt idl2

    return, self.index_class_name
END

FUNCTION IO_SDFITS_LINE::get_index_section_class_name
    compile_opt idl2

    return, self.index_section_class_name
END

;+
; Removes any VEGAS_SPUR flags from the flag file and resets those
; flags from the associated FITS files.
;
; The FITS files should be raw FITS files.  The checks on that are
; the presence of the SDFITSVER keyword (any value) and the INSTRUME
; keyword must be present and have a value of "VEGAS"
;
; @keyword flagcenteradc {in}{optional}{type=boolean} When set, the
; center ADC spur is also flagged.  Normally that spur is left
; unflagged because sdfits usually replaces the value at that location
; with an average of the two adjacent channels and so that spur does
; not need to be flagged since it's been interpolated.
;-
PRO IO_SDFITS_LINE::reflag_vegas_spurs, flagcenteradc=flagcenteradc
  compile_opt idl2

  ; don't do anything unless there's something there
  ; don't warn if nothing found, just return
  fitsFiles = self->get_fits_file_names()
  if size(fitsFiles,/type) ne 7 then return

  ; unflag any existing VEGAS_SPUR flags
  self->unflag,'VEGAS_SPUR',/quiet

  totalSpurFlagCount = 0
  thisFlags = self->get_flags_obj()

  for i=0,n_elements(fitsFiles)-1 do begin
     thisFits = self->get_fits(fitsFiles[i])
     thisFlagFilename = thisFlags->fits_filename_to_flag_filename(fitsFiles[i])
     thisFlag = thisFlags->get_flag_file_obj(thisFlagFilename)
     thisCount = thisFits->flagVegasSpurs(thisFlag,flagcenteradc=flagcenteradc)
     if thisCount lt 0 then begin
                                ; at least one of the files lacks
                                ; VEGAS spur information, give up
                                ; error message already printed 
        break
     endif
     totalSpurFlagCount = totalSpurFlagCount + thisCount
  endfor

  if totalSpurFlagCount gt 0 then begin
     thisFlags->set_flag_ids
  endif
END
