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
; Class Constructor
; @private
;-
FUNCTION IO_SDFITS_WRITER::init
    compile_opt idl2
    
    self.sdfits_def = obj_new('sdfits',version=self.version)
    r = self->IO_SDFITS_LINE::init(index_file='io_sdfits_writer_index')
    return, r

END

;+
; Class Destructor
; @private
;-
PRO IO_SDFITS_WRITER::cleanup
    compile_opt idl2
    
    if obj_valid(self.sdfits_def) then obj_destroy, self.sdfits_def
    self->IO_SDFITS_LINE::cleanup

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
; Writes sdfits rows to the output file, managing wether to create new extension, or append to current one
; @param rows {in}{type=array} array of structs mirroring sdfits rows to be written
; @param virtuals {in}{type=struct} structure containing keyword-values of keywords in extension header to be written
; @param ext {out}{type=long} extension that these rows get written to
; @param start_row {out}{type=long} row at which these new rows will start getting written to in the extension, equal to the number of rows in extension before new rows are written 
; @private
;-
PRO IO_SDFITS_WRITER::write_rows_to_extension, rows, virtuals, ext, start_row
    compile_opt idl2
    
    ; HACK HACK HACK - are these constant over all rows?
    observer = rows[0].observer
    project = rows[0].projid 
    backend = rows[0].backend
    
    start_row = 0

    full_output_name = self->get_full_file_name(self.output_file)

    if (self->file_exists(full_output_name) eq 0) then begin

        if self.debug then print, "creating new fits object for non-existent output file"
        
        ; create new file and object for file
        self->add_fits_obj, self.output_file, /new
        fw = self->get_fits(self.output_file)
        fw->create_sdfits_file, full_output_name
        fw->write_rows_new_extension, rows, virtuals
        
        fw->update_file_properties
        extension = fw->get_number_extensions()
        
    endif else begin
    
        ; check if we have a fits writer object for this file
        fw = self->get_fits(self.output_file)
        if (obj_valid(fw) eq 0) then begin
            if self.debug then print, "creating new fits object for pre-existing output file"
            fw = self->get_new_fits_obj(self.output_file)
            if (obj_valid(fw) eq 0) then message, "Could not create valid sdfits object to update fits file: "+self.output_file
        endif
        fw->update_file_properties
        fw->update_last_extension_properties
        
        ; check if we are allowed to write to this file 
        if fw->is_gbtidl_file() eq 0 then begin
            message, "Cannot write to this sdfits file, was not created by GBTIDL: "+self.output_file, /info
            return
        endif    
            
        extension = fw->get_number_extensions()
        ; check if we append to existing table or create new one
        current_data_size = fw->get_last_extension_data_size()
        new_data_size = n_elements(rows[0].data)

        if (current_data_size eq new_data_size) then begin

            ; before appending to an extension, we need to double check that the rows
            ; are completely compatible with the current extension, i.e. the column types agree
            if fw->row_compatible_with_extension(rows[0],extension) then begin
            
                if self.debug then print, "appending to extension"
            
                ; how many rows already in this table?
                start_row = fw->get_ext_num_rows(extension)
            
                ; append to this table
                fw->append_rows_to_extension, rows
            
            endif else begin

                if self.debug then print, "rows differ from extension definition: writing to new extension"

                ; time to write a new extension table
                fw->write_rows_new_extension, rows, virtuals
                
            endelse
            
        endif else begin

            if self.debug then print, "writing new extension"
            
            ; time to write a new extension table
            fw->write_rows_new_extension, rows, virtuals
            
        endelse
        
    endelse
    
    ext = fw->get_number_extensions()
    
END

;+
; If these spectra have just been written to the output file-extension, then call this
; function to update the index file with the latest info
; @param spectra {in}{type=array} array of spectrum data containers that were just written to the output file
; @param extension {in}{type=long} the extension that just got written to
; @param start_row {in}{type=long} the row that the spectra started getting written to, should equal the current number of rows in extension
; @uses IO_SDFITS_WRITER::get_uniques_string
; @uses INDEX_FILE::is_file_loaded
; @uses INDEX_FILE::new_file
; @uses LINE_INDEX::udpate_with_spectra
; @uses INDEX_FILE::read_file
; @private

;-
PRO IO_SDFITS_WRITER::update_index_with_spectra, spectra, extension, start_row
    compile_opt idl2
    
    if (n_params() eq 3) then start = start_row else start = 0    

    observers = self->get_uniques_string(spectra.observer)
    backends = self->get_uniques_string(spectra.backend)

    if (self.index->is_file_loaded() eq 0) then begin
        self.index->new_file, observers, backends, 'unknown', self.file_path 
    endif
    ;for i=0,n_elements(spectra)-1 do begin
    ;    self.index->update_with_spectra, spectra[i]
    ;endfor    
    self.index->update_with_spectra, spectra, file_basename(self.output_file), extension, start

    ;self.index->read_file

    self.index_synced = 1
    
END

;+
; Sorts input array, and then reduces sorted array to unique values. 
; Unique values are then put in a comma separated string
; @param arr {in}{type=array} array to find uniques of
; @returns comma separated string of unique values in input array
; @private
;-
FUNCTION IO_SDFITS_WRITER::get_uniques_string, arr

    s = arr[sort(arr)]
    u = s[uniq(s)]
    u_str = ''
    for i=0,n_elements(u)-1 do begin
        if (i eq 0) then u_str=u[i] else u_str=u_str+','+u[i] 
    endfor
    return, u_str

END

;+
; Goes through array of spectrum data containers and checks to see if they
; all have the same data length.
; @param spectra {in}{type=array} array of spectrum data containers
; @returns 0,1
; @private
;-
FUNCTION IO_SDFITS_WRITER::check_spectrum_size_uniformity, spectra
    compile_opt idl2
    i = 0
    uniform = 1

    first_data_size = n_elements(*spectra[0].data_ptr)

    while (uniform eq 1) and (i lt n_elements(spectra)) do begin

        data_size = n_elements(*spectra[i].data_ptr)
        if (data_size ne first_data_size) then uniform = 0 else i = i + 1
    
    endwhile
    
    return, uniform

END    


;+
; Translates an array of spectra into sdfits rows
; @param spectra {in}{type=array} array of spectrum data containers
; @param virtuals {out}{type=struct} keywords to be written to the file-extension header
; @returns array of structures that mirror the sdfits rows to be written
; @uses IO_SDFITS_WRITER::define_sdfits_row
; @uses IO_SDFITS_WRITER::spectrum_to_row
; @private
;-
FUNCTION IO_SDFITS_WRITER::spectra_to_rows, spectra, virtuals
    compile_opt idl2
    num_specs = n_elements(spectra)
    
    data_size = n_elements(*(spectra[0]).data_ptr)
    rows = make_array(num_specs, value=self->define_sdfits_row(data_size))
    for i = 0, (num_specs-1) do begin
        row = self->spectrum_to_row(spectra[i],virtuals)
        rows[i] = row
    endfor
    
    return, rows

END

;+
; Translates a spectrum data container into a structure that mirrors the sdfits (v1.2) row to be written
; @param spec {in}{type=struct} spectrum data container to translate
; @param virtuals {out}{type=struct} keywords to be written to the sdfits extension header
; @keyword data_mode {in}{optional}{type=long} determines what data mode sdfits to be written in (not set uses raw mode)
; @returns structure that mirrors the sdfits row to be written
; @uses IO_SDFITS_WRITER::define_sdfits_row
; @uses IO_SDFITS_WRITER::get_sdfits_row_sizes
; @uses IO_SDFITS_WRITER::buffer_string
; @uses IO_SDFITS_WRITER::frequency_type_to_ctype1
; @uses IO_SDFITS_WRITER::coord_types_from_mode
; @uses IO_SDFITS_WRITER::pol_to_sdfits
; @uses IO_SDFITS_WRITER::create_obsmode
; @uses IO_SDFITS_WRITER::translate_bool_int
; makefitsdate
; @private
;-
FUNCTION IO_SDFITS_WRITER::spectrum_to_row, spec, virtuals, data_mode=data_mode
    compile_opt idl2

    ; virtuals are keywords to be written to the binary ext. header
    ; if data containers from different projects, or even different telescopes
    ; are to be written to the same fits file extension, then many of the virtuals
    ; from an sdfits-filled fits file need to be columns with a gbtidl-filled one.
    virtuals = { $ 
        ;backend:spec.backend, $
        ;projid:spec.projid, $
        ;telescop:'NRAO_GBT', $
        extname:'SINGLE DISH', $
        ctype4:'STOKES  ' $
        ;sitelong:spec.site_location[0], $
        ;sitelat:spec.site_location[1], $
        ;siteelev:spec.site_location[2] $
    }
    
    data_points = n_elements(*spec.data_ptr)

    row = self->define_sdfits_row(data_points)
    sizes = self->get_sdfits_row_sizes()

    tdim7 = '('+strtrim(string(data_points),2)+',1,1,1)'
    row.tdim7 = self->buffer_string(tdim7,sizes.tdim7)
    row.object = self->buffer_string(spec.source,sizes.object)
    row.observer = self->buffer_string(spec.observer,sizes.observer) 
    row.obsid = self->buffer_string(spec.obsid,sizes.obsid) 
    row.procscan = self->buffer_string(spec.procscan,sizes.procscan)
    row.proctype = self->buffer_string(spec.proctype,sizes.proctype)
    row.bandwid = spec.bandwidth
    fdate = makefitsdate(spec.mjd,precision=2)
    row.date_obs = self->buffer_string(fdate,sizes.date_obs)
    row.timestamp = self->buffer_string(spec.timestamp,sizes.timestamp)
    row.exposure = spec.exposure
    row.duration = spec.duration
    row.tsys = spec.tsys
    ;row.tsysref = spec.tsysref
    row.data = *spec.data_ptr
    row.tunit7 = self->buffer_string(spec.units,sizes.tunit7)
    ctype1 = self->frequency_type_to_ctype1(spec.frequency_type)
    row.ctype1 = self->buffer_string(ctype1,sizes.ctype1)
    row.crval1 = spec.reference_frequency
    ; ref channel 1-based in sdfits, 0-based in idl
    row.crpix1 = spec.reference_channel + 1.0
    row.cdelt1 = spec.frequency_interval
    types = self->coord_types_from_mode(spec.coordinate_mode)
    row.ctype2 = self->buffer_string(types[0],sizes.ctype2)
    row.ctype3 = self->buffer_string(types[1],sizes.ctype3) 
    row.equinox = spec.equinox
    row.radesys = self->buffer_string(spec.radesys, sizes.radesys)
    row.trgtlong = spec.target_longitude
    row.trgtlat = spec.target_latitude
    row.crval2 = spec.longitude_axis
    row.crval3 = spec.latitude_axis
    row.crval4 = self->pol_to_sdfits(spec.polarization)
    row.scan = spec.scan_number
    if (strlen(spec.switch_state) eq 0 and strlen(spec.switch_sig) eq 0) then begin
        if strmatch(spec.telescope,'*NRAO*') then begin
           ; most likely this is old UNIPOPS data, reconstruct old OBSMODE
           obsmode = 'LINE' + strtrim(spec.procedure,2)
       endif
    endif else begin
        obsmode = self->create_obsmode(spec.procedure,spec.switch_state, spec.switch_sig)
    endelse
    row.obsmode = self->buffer_string(obsmode,sizes.obsmode) 
    row.frontend = self->buffer_string(spec.frontend,sizes.frontend) ; frontend
    row.tcal =spec.mean_tcal
    row.veldef =  self->buffer_string(spec.velocity_definition,sizes.veldef)
    row.vframe = spec.frame_velocity
    row.obsfreq = spec.observed_frequency
    row.azimuth = spec.azimuth
    row.elevatio = spec.elevation
    row.tambient = spec.tambient
    row.pressure = spec.pressure / 133.322368d ; Pa -> mm Hg
    row.humidity = spec.humidity
    row.lst = spec.lst
    row.restfreq = spec.line_rest_frequency
    row.dopfreq = spec.doppler_frequency
    row.freqres = spec.frequency_resolution
    row.sampler = self->buffer_string(spec.sampler_name,sizes.sampler) 
    row.feed = spec.feed
    row.srfeed = spec.srfeed
    row.sideband = spec.sideband
    row.procseqn = spec.procseqn
    row.procsize = spec.procsize
    row.velocity = spec.source_velocity
    row.feedxoff = spec.feedxoff
    row.feedeoff = spec.feedeoff
    row.subref_state = spec.subref_state
    row.qd_xel = spec.qd_xel
    row.qd_el = spec.qd_el
    row.qd_bad = spec.qd_bad
    row.qd_method = spec.qd_method
    row.foffref1 = spec.freq_switch_offset
    row.zerochan = spec.zero_channel
    row.adcsampf = spec.adcsampf
    row.vspdelt = spec.vspdelt
    row.vsprpix = spec.vsprpix
    row.vsprval = spec.vsprval
    row.sig = self->translate_bool_int(spec.sig_state)
    row.cal = self->translate_bool_int(spec.cal_state)
    row.caltype = self->buffer_string(spec.caltype, sizes.caltype)
    row.twarm = spec.twarm
    row.tcold = spec.tcold
    row.calposition = self->buffer_string(spec.calposition, sizes.calposition)
    ; the below columns are keywords in an sdfits-filled fits file
    row.backend = self->buffer_string(spec.backend,sizes.backend)
    row.projid = self->buffer_string(spec.projid,sizes.projid)
    telescop = spec.telescope
    if strlen(telescop) eq 0 then telescop = 'UNKNOWN'    
    row.telescop = self->buffer_string(telescop,sizes.telescop)
    row.sitelong = spec.site_location[0]
    row.sitelat = spec.site_location[1]
    row.siteelev = spec.site_location[2]
    ; the below are only found in gbtidl-filled sdfits files
    row.ifnum = spec.if_number
    row.plnum = spec.polarization_num
    row.fdnum = spec.feed_num
    row.int = spec.integration
    row.nsave = spec.nsave

    return, row
END

;+
; Returns sizes needed for ASCII columns in sdfits.
; Problems: this exists here AND in IO_SDFITS_WRITER.
; @returns structure with sizes for ASCII columsn in sdfits
; @private
;-
FUNCTION IO_SDFITS_WRITER::get_sdfits_row_sizes
   compile_opt idl2

   return, self.sdfits_def->get_sdfits_row_sizes()

END

;+
; Defines an anonymous structure that can be used with mrdfits to write an sdfits row
; @param data_points {in}{type=long} the size of the data array in data column
; @uses SDFITS::define_sdfits_row
; @returns anonymous structure that can be used with mrdfits to write an sdfits row
; @private
;-
FUNCTION IO_SDFITS_WRITER::define_sdfits_row, data_points
   compile_opt idl2

   return, self.sdfits_def->define_sdfits_row(data_points)
   
END

;+
; Crops or pads the input string to exactly the length specified
; @param str {in}{type=string} string to buffer
; @param length {in}{type=long} length that string should be buffered to
; @returns The input string, cropped or padded to specified length
; @private
;-
FUNCTION IO_SDFITS_WRITER::buffer_string, str, length
    compile_opt idl2
    
    new_str = str
    current_length = strlen(new_str)

    ; if string is exact length, nothing to do
    if (current_length eq length) then return, new_str

    ; if string is too long, trim it
    if (current_length gt length) then begin
        new_str = strmid(new_str,0,length)
    endif

    ; if string is too short, buffer on the right with white space
    if (current_length lt length) then begin
       new_str = new_str + string(replicate(32B,(length - current_length)))
    endif
    
    return, new_str
END

;+
; Creates sdfits obsmode column value from the procedure, switch state, and switch signal
; obsmode = 'procedure:switchstate:swtchsig'
; @param proc {in}{type=string} procedure
; @param swstate {in}{type=string} switch state
; @param swtchsig {in}{type=string} switch signal
; @returns obsmode
; @private
;-
FUNCTION IO_SDFITS_WRITER::create_obsmode, proc, swstate, swtchsig

    obsmode = strtrim(proc,2)
    noSwstate = 1
    if strlen(swstate) gt 0 then begin
        swstate = strtrim(swstate,2)
        obsmode = obsmode+':'+swstate
        noSwstate = 0
    endif
    if strlen(swtchsig) gt 0 then begin
        swtchsig = strtrim(swtchsig,2)
        ; if there's no swstate, make that field blank
        if noSwstate then obsmode = obsmode + ':'
        obsmode = obsmode+':'+swtchsig
    endif else begin
        ; if a swstate has been written, make this field blank
        if not noSwstate then begin
            obsmode = obsmode+':'
        endif
    endelse
    ; at this point, obsmode is either just PROC if both swstate and 
    ; swtchsig are empty or PROC:swstate:swtchsig if at least one of
    ; those two is not empty
    
    return, obsmode
    
END

;+
; Tranlate coordinate mode to the two values needed for long. type and lat. type
; @examples
;    case mode of
;        'RADEC': value =  ['RA  ','DEC ']
;        'GALACTIC': value = ['GLON','GLAT']
;        'HADEC': value = ['HA  ','DEC ']
;        'AZEL': value = ['AZ  ','EL  ']
;        'OTHER': value = ['OLON','OLAT']
;        else: value = ['OLON','OLAT']
;    endcase
; @private
;-
FUNCTION IO_SDFITS_WRITER::coord_types_from_mode, mode
    compile_opt idl2

    mode = strtrim(strupcase(mode),2)
    
    case mode of
        'RADEC': value =  ['RA  ','DEC ']
        'GALACTIC': value = ['GLON','GLAT']
        'HADEC': value = ['HA  ','DEC ']
        'AZEL': value = ['AZ  ','EL  ']
        'OTHER': value = ['OLON','OLAT']
        else: value = ['OLON','OLAT']
    endcase

    return, value

END

;+
; converts spectrums integer value for columns such as cal or sig
; to ascii value used in sdfits
; @param bool_int {in}{type=long} 0 or 1
; @returns 'T' or 'F'
; @private
;-
FUNCTION IO_SDFITS_WRITER::translate_bool_int, bool_int
    compile_opt idl2

    if (bool_int eq 1) then return, 'T' else return, 'F'

END

;+
; Translates char polarization used by spectrum data container to integer
; values used by sdfits
; @param pol {in}{type=string} char representation of polarization
; @returns integer rep of polarization
; @private
;-
FUNCTION IO_SDFITS_WRITER::pol_to_sdfits, pol
    compile_opt idl2

    case pol of
        'I': value = 1
        'Q': value = 2
        'U': value = 3
        'V': value = 4
       'RR': value = -1 
       'LL': value = -2
       'RL': value = -3
       'LR': value = -4
       'XX': value = -5
       'YY': value = -6
       'XY': value = -7
       'YX': value = -8
       else: value = 0
    endcase

    return, value

END

;+
; Translates spectrum data container representation of frequency type
; to rep used by sdfits.  See comments in IO_SDFITS::format_sdfits_freq_type
; @param freq_type {in}{type=string} rep of frequency type
; @returns sdfits rep of frequency type (ctype1)
; @private
;-
FUNCTION IO_SDFITS_WRITER::frequency_type_to_ctype1, freq_type
    compile_opt idl2

    ; Of these, LGR and CMB aren't supported yet internally in GBTIDL,
    ; but they can be produced by the GBT so include them here.
    ; TOPO is translated to OBS on output.
    legalTypes = ["TOPO","GEO","BAR","HEL","GAL","LSR","LSD","LGR","CMB"]
    if (where(legalTypes eq freq_type) ne -1) then begin
        thisType = freq_type
        if thisType eq "TOPO" then thisType = "OBS"
        ctype1 = 'FREQ-'+strtrim(thisType,2)
    endif else begin
        ctype1 = 'unknown'
    endelse
    return, ctype1

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

