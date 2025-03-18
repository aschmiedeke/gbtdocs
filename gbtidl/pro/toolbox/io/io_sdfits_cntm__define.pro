;+
; IO_SDFITS_CNTM is intended for end users wishing to work with continuum data. It's the child class of IO_SDFITS used for reading, writing, 
; navigating sdfits continuum files, and for
; translating their info to continuum data containers.  See 
; <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or 
; <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just 
; the line and continuum sdfits classes.
;
;
; @file_comments
; IO_SDFITS_LINE is intended for end users wishing to work with continuum data. It's the child class of IO_SDFITS used for reading, writing, 
; navigating sdfits continuum line files, and for
; translating their info to continuum data containers.  See 
; <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or 
; <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just 
; the line and continuum sdfits classes.
;
; @uses <a href="cntm_index__define.html">LINE_INDEX</a>
; @uses <a href="cntm_sdfits__define.html">SDFITS</a>
;
; @inherits io_sdfits 
;
; @version $Id$
;-

;+
; @private
;-
PRO io_sdfits_cntm__define
    compile_opt idl2, hidden

    ioc = { io_sdfits_cntm, inherits io_sdfits }

END    

;+
; Constructor
; @uses IO_SDFITS::init
; @private
;-
FUNCTION IO_SDFITS_CNTM::init  
    compile_opt idl2
    
    r = self->IO_SDFITS::init()
    if (r ne 1) then return, r
    self.index = obj_new('cntm_index',file_name='io_sdfits_cntm_index',version=self.version)
    self.debug = 0
    return, 1
    
END

;+
; This function searches the index file using the keyword parameters passed
; into it, reads the appropriate parts of the sdfits files, and tranlates this
; data into continuum structures, which are returned.
; 
; @keyword _EXTRA {in}{optional} see <a href="cntm_index__define.html">search_for_row_info</a> for more info 
; @param count {out}{optional}{type=long} number of continua returned
;
; @returns Array of spectrum structures 
;
; @examples
; <pre>
; </pre>
;
; @uses CNTM_INDEX::search_for_row_info
; @uses IO_SDFITS_CNTM::get_continua_from_group
;
; @version $Id$
;-
FUNCTION IO_SDFITS_CNTM::get_continua, _EXTRA=ex, count, indicies

    if self.index->validate_search_keywords(ex) eq 0 then begin
        count = 0
        return, -1
    endif   

    if self->check_search_param_syntax(_EXTRA=ex) eq 0 then begin
        count = 0
        return, -1
    endif

    row_info = self.index->search_for_row_info(_EXTRA=ex, indicies) ;pol='XX')

    if (size(row_info,/dimension) eq 0) then begin
        count = 0
        return, -1
    endif   

    ; set this here, the continua may not be returned in the order in which
    ; there were discovered via row_info, use that one to know
    ; what was last, indicies then is reset to reflect the returned order
    self.last_record = indicies[n_elements(indicies)-1]

    groups = self->group_row_info(row_info)

    for i=0,n_elements(groups)-1 do begin
       group = groups[i]
       continua = self->get_continua_from_group(group)
       if (i eq 0) then begin
          all_cntm=[continua] 
          indicies = [*groups[i].index]
       endif else begin
          all_cntm=[all_cntm,continua]
          indicies = [temporary(indicies),*groups[i].index]
       endelse
    endfor

    self->free_group_row_info, groups
    
    count = n_elements(continua)

    return, continua

END

;+
; Retrieves Continua data containers from a group of sdfits rows from the same extension.
;
; @param group {in}{type=struct} structure that contains all the info needed for extracting continua from sdfits.
; 
; @private
;-
FUNCTION IO_SDFITS_CNTM::get_continua_from_group, group

    @continuum_struct

    start_rows=*group.start_rows
    num_rows=*group.num_rows
    strides=*group.strides
    if_numbers=*group.if_numbers

    ; get the fits object for reading from 
    fits = self->get_fits(group.file)
    apply_offsets = fits->auto_apply_offsets()
    
    ; how many continnua will we be getting?
    continua = make_array(n_elements(start_rows),value={continuum_struct})

    for i=0,n_elements(start_rows)-1 do begin

        ; structure for passing data ptrs around
        data = { data:ptr_new(/allocate_heap), $
              azimuth:ptr_new(/allocate_heap), $
            elevation:ptr_new(/allocate_heap), $
            longitude:ptr_new(/allocate_heap), $
             latitude:ptr_new(/allocate_heap), $
                  lst:ptr_new(/allocate_heap), $
             date_obs:ptr_new(/allocate_heap), $
             subref_state:ptr_new(/allocate_heap), $
             qd_el:ptr_new(/allocate_heap), $
             qd_xel:ptr_new(/allocate_heap), $
             qd_bad:ptr_new(/allocate_heap) $
        }
        
        ; get the first row, and all the columns that vary
        row = fits->get_cntm_data( group.extension, start_rows[i], num_rows[i], strides[i], data, missing, virtuals )
        
        ; translate the data to a data container
        cnt = self->cntm_data_to_cntm_container(row, data, missing, virtuals, if_numbers[i])

        ; apply offsets when appropriate
        if apply_offsets then dcdofeedoffsets,cnt
        
        if self.debug then begin
            print, 'retrieved continuum:'
            print, cnt.scan_number, cnt.procedure, cnt.polarization, cnt.sig_state, cnt.cal_state, format='(i5,2x,16a,2x,2a,2x,i3,2x,i3)'
        endif
        
        ; append the new continuum to the array  
        continua[i]=cnt 
        
        ; don't clean up ALL the 'data' struct: it's pointers are used by the continnua
        if ptr_valid(data.date_obs) then ptr_free, data.date_obs
        ;if ptr_valid(data.lst) then ptr_free, data.lst
        
    endfor
    
    return, continua
END

;+
; Translates continuum data derived from an sdfits file and index file into a Continuum data container.
; @param row {in}{type=struct} struct mirroring the first row that this continuum starts at
; @param data {in}{type=struct} struct containing pointers to the continuum data: data, az, el, etc.
; @param missing {in}{type=array} array of column names expected in sdfits and not found
; @param virtuals {in}{type=struct} struct containg extension header keywords
; @param if_number {in}{type=long} if number from index file for this continuum
; 
; @uses IO_SDFITS::get_row_value
; @uses fitsdateparse
; @uses mjd
; @uses juldate
; @uses IO_SDFITS::coord_mode_from_types
; @uses IO_SDFITS::format_sdfits_polarization
; @uses IO_SDFITS::format_sdfits_procedure
; @uses IO_SDFITS::translate_sig
; @uses IO_SDFITS::translate_cal
;
; @private
;-
FUNCTION IO_SDFITS_CNTM::cntm_data_to_cntm_container, row, data, missing, virtuals, if_number
    compile_opt idl2
        
    cnt = {continuum_struct}
    
    names = {row:ptr_new(tag_names(row)),missing:ptr_new(missing),virtuals:ptr_new(tag_names(virtuals))}    
    
    ; pass over the data pointers of varying columns
    cnt.data_ptr = data.data 
    cnt.azimuth = data.azimuth 
    cnt.elevation = data.elevation 
    cnt.longitude_axis = data.longitude
    cnt.latitude_axis = data.latitude
    cnt.subref_state = data.subref_state
    cnt.qd_el = data.qd_el
    cnt.qd_xel = data.qd_xel
    cnt.qd_bad = data.qd_bad

    ; default values to use for most missing cols in sdfits row
    di = -1L
    df = 0.0
    dd = 0.0D
    ds = 'default'
    nan = !values.f_nan
    
    ; data units
    cnt.units = self->get_row_value(row,'TUNIT7',virtuals,names,"")
    
    ; date
    cnt.date = ptr_new(strmid(*data.date_obs,0,10))
    
    ; this is needed up here first
    cnt.telescope = self->get_row_value(row,'TELESCOP',virtuals,names,ds) 
    sitelong = self->get_row_value(row,'SITELONG',virtuals,names,dd)
    sitelat = self->get_row_value(row,'SITELAT',virtuals,names,dd)
    siteelev = self->get_row_value(row,'SITEELEV',virtuals,names,dd)
    ; if this is the GBT, and it's got a positive longitude, its sdfits ver 1.1
    ; turn it negative (bug in SDFITS 1.1); this is fixed in ver 1.2
    cnt.site_location = [sitelong, sitelat, siteelev]
    if (cnt.telescope eq "NRAO_GBT" and cnt.site_location[0] gt 0.0) then begin
        ; if its negative, the problem must have been fixed
        cnt.site_location[0] = -cnt.site_location[0]
    endif

    ; utc, mjd and ltc
    utc = dblarr(n_elements(*data.date_obs))
    mjd = dblarr(n_elements(*data.date_obs))
    lst = dblarr(n_elements(*data.date_obs))
    for i=0,n_elements(*data.date_obs)-1 do begin
        fd = fitsdateparse((*data.date_obs)[i])
        utc[i] = (fd[3]*60.0+fd[4])*60.0 + fd[5]
        juldate,fd,thismjd
        ; juldate sets Reduced Julian Date (RJD).  MJD = RJD - 0.5
        mjd[i] = thismjd - 0.5
        ;print, i, mjd[i], mjd[i]-mjd[0], thismjd, fd, (*data.date_obs)[i]
        ;ct2lst,lst[i],cnt.site_location[1],0,(mjd[i]+2400000.5)
        ;lst[i] = lst[i] * 3600.0
    endfor
    cnt.utc = ptr_new(utc)
    cnt.mjd = ptr_new(mjd)
    ;cnt.lst = ptr_new(lst)
    cnt.lst = data.lst

    ; pass on the rest of the const info
    cnt.source = self->get_row_value(row,'OBJECT',virtuals,names,ds)
    cnt.projid = self->get_row_value(row,'PROJID',virtuals,names,ds)
    cnt.backend = self->get_row_value(row,'BACKEND',virtuals,names,ds) 
    cnt.observer = self->get_row_value(row,'OBSERVER',virtuals,names,ds) 
    cnt.bandwidth = self->get_row_value(row,'BANDWID',virtuals,names,dd)
    cnt.exposure = self->get_row_value(row,'EXPOSURE',virtuals,names,dd)
    cnt.timestamp = strtrim(self->get_row_value(row,'TIMESTAMP',virtuals,names,ds),2)
    cnt.duration = self->get_row_value(row,'DURATION',virtuals,names,dd)
    cnt.tambient = self->get_row_value(row,'TAMBIENT',virtuals,names,!values.f_nan)
    cnt.pressure = self->get_row_value(row,'PRESSURE',virtuals,names,!values.f_nan) * 133.322368 ; mm Hg -> Pa
    cnt.humidity = self->get_row_value(row,'HUMIDITY',virtuals,names,!values.f_nan)
    cnt.tsys = self->get_row_value(row,'TSYS',virtuals,names,dd)
    cnt.tsysref = self->get_row_value(row, 'TSYSREF',virtuals,names,dd)
    
    ctype2 = self->get_row_value(row,'CTYPE2',virtuals,names,ds)
    ctype3 = self->get_row_value(row,'CTYPE3',virtuals,names,ds) 
    cnt.coordinate_mode = self->coord_mode_from_types(ctype2,ctype3)
    cnt.equinox = self->get_row_value(row,'EQUINOX',virtuals,names,2000.0d)
    cnt.radesys = self->get_row_value(row,'RADESYS',virtuals,names,'')
    if (cnt.radesys eq '' and cnt.coordinate_mode eq 'RADEC') then begin
        if (cnt.equinox eq 2000.0) then begin
            cnt.radesys = 'FK5'
        endif else begin
            if (cnt.equinox eq 1950.0) then begin
                cnt.radesys = 'FK4'
            endif else begin
                cnt.radesys = 'GAPPT'
            endelse
        endelse
    endif
    cnt.target_longitude = self->get_row_value(row,'TRGTLONG',virtuals,names,0.0D)
    cnt.target_latitude = self->get_row_value(row,'TRGTLAT',virtuals,names,0.0D)
    crval4 = self->get_row_value(row,'CRVAL4',virtuals,names,0)
    cnt.polarization = self->format_sdfits_polarization(crval4[0])
    cnt.scan_number = self->get_row_value(row,'SCAN',virtuals,names,di)
    obsmode = self->get_row_value(row,'OBSMODE',virtuals,names,ds)
    self->parse_sdfits_obsmode,obsmode,proc,swstate,swtchsig
    cnt.procedure = proc
    cnt.switch_state = swstate
    cnt.switch_sig = swtchsig
    cnt.obsid = self->get_row_value(row,'OBSID',virtuals,names,ds)
    cnt.proctype = self->get_row_value(row,'PROCTYPE',virtuals,names,ds)
    cnt.procscan = self->get_row_value(row,'PROCSCAN',virtuals,names,ds)
    cnt.frontend = self->get_row_value(row,'FRONTEND',virtuals,names,ds)
    ; FEEDXOFF/FEEDEFF vs older BEAMXOFF/BEAMEOFF
    ;   current - use default of nan to watch for missing case
    cnt.feedxoff = self->get_row_value(row,'FEEDXOFF',virtuals,names,!values.f_nan)
    if not finite(cnt.feedxoff) then begin
       ; not found, try older version, standard defaults
       cnt.feedxoff = self->get_row_value(row,'BEAMXOFF',virtuals,names,dd)
       cnt.feedeoff = self->get_row_value(row,'BEAMEOFF',virtuals,names,dd)
    endif else begin
       ; feedeoff should be there, standard defaults
       cnt.feedeoff = self->get_row_value(row,'FEEDEOFF',virtuals,names,dd)
    endelse
    cnt.mean_tcal = self->get_row_value(row,'TCAL',virtuals,names,dd)
    cnt.observed_frequency = self->get_row_value(row,'OBSFREQ',virtuals,names,dd)
    cnt.sampler_name = self->get_row_value(row,'SAMPLER',virtuals,names,ds)
    cnt.qd_method = self->get_row_value(row,'QD_METHOD',virtuals,names,'')
    cnt.feed = self->get_row_value(row,'FEED',virtuals,names,di)
    cnt.srfeed = self->get_row_value(row,'SRFEED',virtuals,names,di)
    cnt.sideband = self->get_row_value(row,'SIDEBAND',virtuals,names,ds)
    cnt.procseqn =  self->get_row_value(row,'PROCSEQN',virtuals,names,di)
    cnt.procsize = self->get_row_value(row,'PROCSIZE',virtuals,names,di)
    cnt.sig_state = self->translate_sig(self->get_row_value(row,'SIG',virtuals,names,'T'))
    cnt.cal_state = self->translate_cal(self->get_row_value(row,'CAL',virtuals,names,'T')) 
    cnt.caltype = self->get_row_value(row,'CALTYPE',virtuals,names,'')
    cnt.twarm = self->get_row_value(row,'TWARM',virtuals,names,nan)
    cnt.tcold = self->get_row_value(row,'TCOLD',virtuals,names,nan)
    cnt.calposition = self->get_row_value(row,'CALPOSITION',virtuals,names,'Unknown')
    
    ; additional
    ; if_number - use value in SDFITS file if there, else value from index file
    cnt.if_number = self->get_row_value(row, 'IFNUM', virtuals, names, if_number)

    ptr_free,names.row
    ptr_free,names.missing
    ptr_free,names.virtuals

    return, cnt
    
END

;+
; Groups rows from index file according to file-extension
; @param row_info {in}{type=array} array of structs mirroring rows of index file
; @returns same structures passed in, but grouped by file-extension
; @private
;-
FUNCTION IO_SDFITS_CNTM::group_row_info, row_info

    ;row_group = {sdfits_row_group}
    
    ; get all files
    files = row_info.file
    unique_files = files[uniq(files[sort(files)])]
    
    group = {cntm_sdfits_row_group}
    
    for i = 0, (n_elements(unique_files)-1) do begin
        file_locals = row_info[ where(row_info.file eq unique_files[i]) ]
        exts = file_locals.extension
        unique_exts = exts[uniq(exts[sort(exts)])]
        for j = 0, (n_elements(unique_exts)-1) do begin
            file_ext_locals = file_locals[ where(file_locals.extension eq unique_exts[j]) ]
            ; collapse the array into one struct
            group.file = file_ext_locals[0].file
            group.extension = file_ext_locals[0].extension
            group.start_rows = ptr_new(file_ext_locals.start_row)
            group.num_rows = ptr_new(file_ext_locals.num_rows)
            group.strides = ptr_new(file_ext_locals.stride)
            ;group.integrations = ptr_new(file_ext_locals.integration)
            group.if_numbers = ptr_new(file_ext_locals.if_number)
            group.index = ptr_new(file_ext_locals.index)
            if (i eq 0) and (j eq 0) then groups = [group] else groups = [groups,group]
        endfor
    endfor
    
    return, groups

END

;+
; Updates the index file with all the information from the passed in sdfits file
; @param fits {in}{type=object} object that represents sdfits files whose info is feed to index file
; @uses CNTM_SDFITS::get_cntm_scan_properties
; @uses CNTM_INDEX::update_index_with_scan
; @uses INDEX_FILE::read_file
; @private
;-
PRO IO_SDFITS_CNTM::update_index_with_fits_file, fits
    compile_opt idl2
    
    ; if this fits file already has an index file, use it!
    index_name = self->get_expected_full_index_name(fits)
    if self->file_exists(index_name) and index_name ne  self.index->get_full_file_name() then begin
        if self->update_index_with_other_index(index_name) then begin
            if self.debug then print, "used fits index to update index: "+index_name
            return
        endif else begin
            if self.debug then print, "failed attempt to use fits index to update index: "+index_name
        endelse    
    endif    
 
    ; index file of expected name cant be used, must read fits file
    num_exts = fits->get_number_extensions()
    ; go through each extension, skipping the primary one
    for ext = 1, num_exts do begin
    
        num_rows = fits->get_ext_num_rows(ext)
        scan_starts = fits->get_scan_starts(ext)
    
        ; use the scan start info to load each scan 
        for i=0,n_elements(scan_starts)-1 do begin

            ; get the beginning and end of each scan
            start = scan_starts[i]
            if (i ne n_elements(scan_starts)-1) then begin
                end_row = scan_starts[i+1] - 1
            endif else begin
                end_row = num_rows
            endelse
            
            ; get key properties of this scan from the fits file
            row = fits->get_cntm_scan_properties(ext, start, end_row, project, samplers, sigs, cals, sampler_pols)
            
            if self.debug then begin
                print, "update_index_with_fits_file:"
                print, "start:end - ",start,end_row,format="(20a,2x,i5,2x,i5)"
                print, samplers
                print, sigs
                print, cals
                print, sampler_pols
            endif

            ; how many total data points for scan
            n_data = end_row - start + 1
    
            ; total data points per polarization
            data_per_sampler = n_data/n_elements(samplers)
    
            ;if self.debug then begin
            ;    print, "start row: "+string(start)
            ;    print, "end row: "+string(end_row)
            ;    print, "n_data: "+string(n_data)
            ;    print, "data/sampler: "+string(data_per_sampler)
            ;endif    
        
            file_name = fits->get_file_name()
            
            self.index->update_file_with_scan, row, project, file_name, ext, start, n_data, samplers, sigs, cals, sampler_pols
    
        endfor ; for each scan   
    
    endfor ; for each extension
    
    self.index->read_file
  
    self.index_synced = 1
    
END

;+
; frees the memory in each element of this array
; @param row_info {in}{type=array} array of structures
; @private
;-
PRO IO_SDFITS_CNTM::free_group_row_info, row_info
    compile_opt idl2

    for i=0, (n_elements(row_info)-1) do begin
        if ptr_valid(row_info[i].start_rows) then ptr_free, row_info[i].start_rows
        if ptr_valid(row_info[i].num_rows) then ptr_free, row_info[i].num_rows
        if ptr_valid(row_info[i].strides) then ptr_free, row_info[i].strides
        if ptr_valid(row_info[i].if_numbers) then ptr_free, row_info[i].if_numbers
        if ptr_valid(row_info[i].index) then ptr_free, row_info[i].index
    endfor

END

;+
; creates and returns a new object to represent an sdfits continuum file
; @param file_name {in}{type=string} full path name to the file to be represented by object
; @returns object of cntm_sdfits class
; @private
;-
FUNCTION IO_SDFITS_CNTM::get_new_fits_obj, file_name, _EXTRA=ex
    compile_opt idl2

    return, obj_new('cntm_sdfits',file_name,version=self.version,_EXTRA=ex)

END    

;+
; Stub method for updating the index file. TBD.
;-
PRO IO_SDFITS_CNTM::load_new_sdfits_rows
    compile_opt idl2

    message, "load_new_sdfits_rows not implemented yet for continuum", /info

END    

;+
; Stub method for updating the index file. TBD.
;-
PRO IO_SDFITS_CNTM::update
    compile_opt idl2

    message, "update not implemented yet for continuum", /info

END    

;+
; Stub method for updating the index file. TBD.
;-
PRO IO_SDFITS_CNTM::set_online, file_name
    compile_opt idl2

    message, "online mode not implemented yet for continuum", /info

END    

FUNCTION IO_SDFITS_CNTM::get_index_class_name
    compile_opt idl2

    return, "cntm_index"
END

FUNCTION IO_SDFITS_CNTM::get_index_section_class_name
  compile_opt idl2

  return, "cntm_index_section"
END
