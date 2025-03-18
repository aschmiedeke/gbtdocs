;+
; Child class of INDEX_FILE, contains special functionality for dealing with zpectrometer data.
; This mostly entails the translation of sdfits-like zpectrometer data into contents of the index file.
; See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or
; <a href="../../../IDL_IO_index_classes.jpg">INDEX UML</a> for just index classes.
; This class is responsible for establishing the correct class for managing the
; row section of the index file, the translation between zpectrometer fits and index rows, 
; translation from zpectrometer row to index rows, and provides the search gateway.
;
;
; @file_comments
; Child class of INDEX_FILE, contains special functionality for dealing with zpectrometer data.
; This mostly entails the translation of sdfits-like zpectrometer data into contents of the index file.
; See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or
; <a href="../../../IDL_IO_index_classes.jpg">INDEX UML</a> for just index classes.
; This class is responsible for establishing the correct class for managing the
; row section of the index file, the translation between zpectrometer fits and index rows, 
; translation from zpectrometer row to index rows, and provides the search gateway.
; @private_file
;-
;+
; Class Constructor - special formats for zpectrometer initialized here
; @private
;-
FUNCTION Z_INDEX::init, _EXTRA=ex
    compile_opt idl2, hidden

    self.rows_class = "z_index_section"   
    r = self->INDEX_FILE::init(_EXTRA=ex)

    return, r

END

;+
; Class Destructor - cleanup resources
; @private
;-
PRO Z_INDEX::cleanup
    compile_opt idl2, hidden

    self->INDEX_FILE::cleanup

END

;+
; Returns the special structure needed for zpectrometer data
; @returns z_row_info_strct structure
; @private
; -
FUNCTION Z_INDEX::get_row_info_strct

    @z_row_info
    return, {z_row_info_strct}

END

;+
; This method searches the rows in the index file using the optional keywords.
; Not using any keywords returns all rows.  Multiple keywords are combined with
; a logical AND.
;
; @param start {in}{optional}{type=long} where to start the range to search in
; @param finish {in}{optional}{type=long} where to stop the range to search in
;
; @keyword search {in}{optional}{type=array of longs} The row numbers
; to search, often this is the result of a previous search that you
; wish to refine.
; @keyword index {in}{optional}{type=long} index (zero-based)
; @keyword project {in}{optional}{type=string} project name
; @keyword file {in}{optional}{type=string} sdfits file
; @keyword extension {in}{optional}{type=long} sdfits extension number
; @keyword row {in}{optional}{type=long} sdfits row number
; @keyword source {in}{optional}{type=string} source name 
; @keyword procedure {in}{optional}{type=string} procecure
; @keyword mc_scan {in}{optional}{type=long} M&C scan number
; @keyword subscan {in}{optional}{type=long} Subscan number
; @keyword scan {in}{optional}{type=long} Scan number
; @keyword beindex {in}{optional}{type=long} Backend index number
; @keyword azimuth {in}{optional}{type=string} azimuth
; @keyword elevation {in}{optional}{type=string} elevation
; @keyword longitude {in}{optional}{type=string} longitude axis (ex:ra) value 
; @keyword latitude {in}{optional}{type=string} latitude axis (ex:dec) value 
; @keyword timestamp {in}{optional}{type=string} the start of the scan
; @keyword exposure {in}{optional}{type=double} exposure 
; @keyword trckbeam {in}{optional}{type=integer} Tracking beam ID
; @keyword obsfreq {in}{optional}{type=string} observed frequency
; @keyword diode {in}{optional}{type=integer} Diode value
; @keyword subref {in}{optional}{type=integer} Subreflector state (0=moving, 1, or -1)
;
; @returns Array of longs, each element corresponding to a line number of the index file that matches the search
;
;-
FUNCTION Z_INDEX::search_index, start, finish, SEARCH=search, INDEX=index, PROJECT=project, FILE=file, EXTENSION=extension, ROW=row, SOURCE=source, PROCEDURE=procedure, MC_SCAN=mc_scan, SUBSCAN=subscan, SCAN=scan, BEINDEX=beindex, AZIMUTH=azimuth, ELEVATION=elevation, LONGITUDE=longitude, LATITUDE=latitude, TIMESTAMP=timestamp, EXPOSURE=exposure, TRCKBEAM=trckbeam, OBSFREQ=obsfreq, DIODE=diode, SUBREF=subref

    if (self.file_loaded eq 0) then begin
        message, 'File not loaded, cannot search index. Use read_file method'
        return, -1
    endif
    
    if n_elements(SEARCH) eq 0 then begin
        ; init the search result to include all row indicies
        search_result = lindgen(n_elements(*self.row_lines))
    endif else begin
        ; init the search to include only previous results passed in
        search_result = search
    endelse    
    
    ; if the start and finish parameters have been used, use them for limiting our search to a range.
    ; some methods always call search_index with start, finish set to the full range.  If that's the
    ; case don't waste cpu time on this step
    if n_elements(start) ne 0 or n_elements(finish) ne 0 then begin
        if n_elements(start) eq 0 then start = 0
        if n_elements(finish) eq 0 then finish = n_elements(*self.row_lines)-1
        if start ne 0 or finish ne (n_elements(*self.row_lines)-1) then begin
            search_result = self->search_range(start,finish,search_result)
        endif    
    endif

    ; for each keyword, par down the search result for each criteria
    if n_elements(INDEX) ne 0 then begin 
        self->find_values_plus_and,(*self.row_lines).index,index,search_result,"INDEX"
    endif   
    if n_elements(PROJECT) ne 0 then begin 
        self->find_values_plus_and,(*self.row_lines).project,project,search_result,"PROJECT"
    endif   
    if n_elements(FILE) ne 0 then begin 
        self->find_values_plus_and,(*self.row_lines).file,file,search_result,"FILE"
    endif   
    if n_elements(EXTENSION) ne 0 then begin 
        self->find_values_plus_and,(*self.row_lines).extension,extension,search_result,"EXTENSION"
    endif   
    if n_elements(ROW) ne 0 then begin 
        self->find_values_plus_and,(*self.row_lines).row_num,row,search_result,"ROW"
    endif   
    if n_elements(SOURCE) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).source,source,search_result,"SOURCE"
    endif
    if n_elements(PROCEDURE) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).procedure,procedure,search_result,"PROCEDURE"
    endif
    if n_elements(MC_SCAN) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).mc_scan,mc_scan,search_result,"MC_SCAN"
    endif
    if n_elements(SUBSCAN) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).subscan,subscan,search_result,"SUBSCAN"
    endif
    if n_elements(SCAN) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).scan,scan,search_result,"SCAN"
    endif
    if n_elements(BEINDEX) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).beindex,beindex,search_result,"BEINDEX"
    endif
    if n_elements(TRCKBEAM) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).trckbeam,trckbeam,search_result,"TRCKBEAM"
    endif
    if n_elements(OBSFREQ) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).obsfreq,obsfreq,search_result,"OBSFREQ"
    endif
    if n_elements(DIODE) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).diode,diode,search_result,"DIODE"
    endif
    if n_elements(SUBREF) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).subref,subref,search_result,"SUBREF"
    endif
    if n_elements(AZIMUTH) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).azimuth,azimuth,search_result,"AZIMUTH"
    endif
    if n_elements(ELEVATION) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).elevation,elevation,search_result,"ELEVATION"
    endif
    if n_elements(LONGITUDE) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).longitude_axis,longitude,search_result,"LONGITUDE"
    endif
    if n_elements(LATITUDE) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).latitude_axis,latitude,search_result,"LATITUDE"
    endif
    if n_elements(TIMESTAMP) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).timestamp,timestamp,search_result,"TIMESTAMP"
    endif
    if n_elements(EXPOSURE) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).exposure,exposure,search_result,"EXPOSURE"
    endif
    
    return, search_result
END

;+
; Translates raw sdfits-like zpectrometer rows into the rows to be written to the index file.
; @param rows {in}{type=array} array of structs representing sdfits rows
; @param proj {in}{type=string} project id shared by all rows
; @param file_name {in}{type=string} file location shared by all rows
; @param ext {in}{type=long} extension location shared by all rows
; @param missing {in}{type=array} string array of columns missing from the sdfits file
; @param virtuals {in}{type=struct} key-value pairs from sdfits extension header (not including col descriptions)
; @param start {in}{type=long} row number that these rows start at 4
; @returns arrays of structures representing lines to be written to index file
; @uses INDEX_FILE::get_row_info_strct
; @uses INDEX_FILE::get_row_value
;-
FUNCTION Z_INDEX::parse_extension_rows, rows, proj, file_name, ext, missing, virtuals, start
    compile_opt idl2

    names = {row:ptr_new(tag_names(rows[0])),missing:ptr_new(missing),virtuals:ptr_new(tag_names(virtuals))}
    
    info = make_array(n_elements(rows),value=self->get_row_info_strct())

    ; defaults for missing columns in sdfits row
    di = -1L
    df = 0.0
    dd = 0.0D
    ds = ''

    ; find the primary ID to use in constructing the index
    ; use timestamp if available, else scan
    if (size(missing, /type) ne 3) then begin
        ind = where("TIMESTAMP" eq missing, cnt)
    endif else begin
        cnt = 1
    endelse    
    if cnt eq 0 then begin
        ; the TIMESTAMP column was found
        ids = rows.timestamp 
    endif else begin
        ; we will have to use the scan numbers
        ids = rows.scan 
    endelse

    ; start indexing from the current number of rows
    firstIndex = self.rows->get_num_rows()

    nrows = n_elements(rows)
    if nrows gt 1000 then progress_bar=1 else progress_bar=0
    if progress_bar then begin
        total_bar = '__________'
        step_size = long(n_elements(rows)/10)
        step = 0
        print, "Parsing scan info:"
        print, total_bar
    endif
    
    ; loop until out of rows to process
    startRow = 0
    while (startRow lt nrows) do begin
        id = ids[startRow]
        lastRow = startRow + 1
        while (lastRow lt nrows) do begin
            if ids[lastRow] ne id then break
            lastRow++
        endwhile
        lastRow--

        if self.debug then print, "ID: "+string(id)
        if self.debug then print, "rows to process: "+string(lastRow-startRow+1)
        
        ; run algorithms (if needed) for determining if, integration,         ; polarization, and feed numbers             
        index_start = startRow + firstIndex
        index_end = lastRow + firstIndex


        ; HACK HACK HACK
        number_of_rows = n_elements(rows[startRow:lastRow])
        
        ; for each row in the FITS file for this id, create its line in the index
        for j=0,number_of_rows-1 do begin
        
            row_index = j + startRow
            row = rows[row_index]
            row_info = self->get_row_info_strct() 

           
            ; copy basic info
            ; index number is zero-based
            row_info.index = row_index + firstIndex
            row_info.project = proj
            row_info.file = file_name
            row_info.extension = ext
            row_info.mc_scan = self->get_row_value(row,'MC_SCAN',virtuals,names,di)
            row_info.scan = self->get_row_value(row,'SCAN',virtuals,names,di)
            row_info.row_num = row_index + start
            source = self->get_row_value(row,'OBJECT',virtuals,names,'source')
            row_info.source = strtrim(source,2)
            row_info.procedure = strtrim(self->get_row_value(row,'PROCNAME',virtuals,names,'proc'),2)
            row_info.subscan = self->get_row_value(row,'SUBSCAN',virtuals,names,0)
            row_info.beindex = self->get_row_value(row,'BEINDEX',virtuals,names,di )
            row_info.azimuth = self->get_row_value(row,'AZIMUTH',virtuals,names,dd )
            row_info.elevation = self->get_row_value(row,'ELEVATIO',virtuals,names,dd )
            row_info.longitude = self->get_row_value(row,'CRVAL2',virtuals,names,dd )
            row_info.latitude = self->get_row_value(row,'CRVAL3',virtuals,names,dd )
            row_info.timestamp = self->get_row_value(row,'TIMESTAMP',virtuals,names,ds)
            row_info.exposure = self->get_row_value(row,'EXPOSURE',virtuals,names,dd )
            row_info.trckbeam = strtrim(self->get_row_value(row,'TRCKBEAM',virtuals,names,ds),2)
            row_info.obsfreq = self->get_row_value(row,'OBSFREQ',virtuals,names,ds )
            row_info.diode = self->get_row_value(row,'DIODE',virtuals,names,di )
            row_info.subref = self->get_row_value(row,'SUBREF_STATE',virtuals,names,1)

            ; append this line to list of lines
            info[row_index] = row_info
            
            ; update the progress bar
            if progress_bar then begin
                if step eq step_size then begin
                    step = 0
                    print, format='("X",$)'
                endif else begin
                    step += 1
                endelse    
            endif    

        endfor ; for each row of this ID
        startRow = lastRow + 1

    endwhile ; for loop through IDs 
   
    ; terminate progress bar
    if progress_bar then print, format='(/)'
    
    ; clean up
    if ptr_valid(names.row) then ptr_free,names.row
    if ptr_valid(names.missing) then ptr_free,names.missing
    if ptr_valid(names.virtuals) then ptr_free,names.virtuals

    return, info    
        
END

;+
; Appends row info to an index file, given a group of rows from 
; zpectrometer sdfits-like files.  Used for first loading in a
; zpectrometer file  
; @param ext_rows {in}{type=array} array of sdfits rows
; @param proj {in}{type=string} project shared by all rows
; @param file_name {in}{type=string} file location shared by all extensions
; @param ext {in}{type=long} extension location shared by all extensions
; @param missing {in}{type=array} string array of columns missing from the ext_rows param
; @param virtuals {in}{type=struct} keywords from extension header not describing columns
; @param start_row {in}{type=long} where these spectra start in the extension
; @uses LINE_INDEX::update_index_file
;-
PRO Z_INDEX::update_file, ext_rows, proj, file_name, ext, missing, virtuals, start_row
    compile_opt idl2

    if (n_params() eq 7) then start=start_row else start=0
    rows_info = self->parse_extension_rows(ext_rows,proj,file_name,ext, missing, virtuals, start)
    self->update_index_file, rows_info
    
END


;+
;  Returns a structure or array of structures that contains info about
;  the scan number given, such as scan number, procedure name, number
;  of integrations, ifs, etc..  One element in the array for each
;  unique TIMESTAMP value for all rows having that scan number.

;  @param scan_number {in}{type=long} scan number information is
;  queried for
;  @param file {in}{optional}{type=string} Limit the search for the
;  scan number to a specific file name.
;  @keyword count {out}{type=integer} The number of elements of the
;  returned array of scan_info structures.
;  @keyword quiet {in}{optional}{type=boolean} When set, suppress most
;  error messages.
;
;  @returns Array of structures containing info on scan, returns -1 on
;  failure.
;-
FUNCTION Z_INDEX::get_scan_info, scan_number, file, count=count, quiet=quiet
    compile_opt idl2

    rows = self->search_for_row_info(mc_scan=scan_number,file=file)

    if (size(rows,/dimension) eq 0) then begin
        if not keyword_set(quiet) then begin
            if n_elements(file) eq 0 then begin	
                message, 'Scan number not found: '+string(scan_number),/info
            endif else begin
                message, 'Scan number not found in ' + file + " : " +strtrim(string(scan_number),2),/info
            endelse
        endif
        return, -1   
    endif

    uniqueTimes = rows[uniq(rows.timestamp)].timestamp
    count = 0

    ; two passes, first gets the counts of things that determine array
    ; sizes and the second actually fills in the scan info structures

    ; loop over times first, then files.  Generally, times will be
    ; sufficient but older files may not have a timestamp and so
    ; files will be one more way of separating out duplicate scans.
    for i=0,(n_elements(uniqueTimes)-1) do begin
        theseRowsIndex = where(rows.timestamp eq uniqueTimes[i],numRowsToHandle)
        theseTimesRows = rows[theseRowsIndex]
        seqDiff = theseTimesRows[0].index
        fullSeq = lindgen(numRowsToHandle)
        while (numRowsToHandle gt 0) do begin
            ; handle sequential indexes in each pass in this loop
            sequentialRows = where((theseTimesRows.index-fullSeq) eq seqDiff,seqRowCount)
            theseRows = theseTimesRows[sequentialRows]

            uniqueFiles = theseRows[uniq(theseRows.file)].file
            for j=0,(n_elements(uniqueFiles)-1) do begin
                theseFileRowsIndex = where(theseRows.file eq uniqueFiles[j],theseCount)
                theseFileRows = theseRows[theseFileRowsIndex]

                if count eq 0 then begin
                    rowStart = sequentialRows[0]
                    nrows = seqRowCount
                endif else begin
                    rowStart = [rowStart,sequentialRows[0]]
                    nrows = [nrows,seqRowCount]
                endelse
                count += 1
            endfor
            ; prepare for next loop, if necessary
            numRowsToHandle = numRowsToHandle - seqRowCount
            if numRowsToHandle gt 0 then begin
                nextSeqStart = sequentialRows[seqRowCount-1]+1
                seqDiff = theseTimesRows[nextSeqStart].index - fullSeq[nextSeqStart]
            endif
        endwhile
    endfor

    ; this changes significantly for Zpectrometer data due to the lack
    ; of switching states, if info, polarization, etc.
    scan_info_struct = {mc_scan:0L,subscan:0L,timestamp:'',file:'', procedure:'',$
                        n_integrations:0L, $
                        n_cal_states:0L, $
                        index_start:0L, nrecords:0L}
        
    scan_info = replicate(scan_info_struct,count)

    for j=0,(count-1) do begin
        theseRowsIndex = lindgen(nrows[j]) + rowStart[j]
        theseRows = rows[theseRowsIndex]

        ; init arrays in structure

        ; strings should already be initialized to ''
        ; bandwidths already initialized to 0.0
    
        ; to help find this scan, no matter what
        scan_info[j].index_start = theseRows[0].index
        scan_info[j].nrecords = nrows[j]
    
        ; this info is constant for scan 
        scan_info[j].mc_scan = theseFileRows[0].mc_scan
        scan_info[j].subscan = theseFileRows[0].subscan
        scan_info[j].timestamp = theseFileRows[0].timestamp
        scan_info[j].file = theseFileRows[0].file
        scan_info[j].procedure = theseFileRows[0].procedure
        
        ; collect info about scan
        scan_info[j].n_integrations = 1 
        n_cals = n_elements(self->get_uniques(theseFileRows.diode))
        scan_info[j].n_cal_states = n_cals
        
    endfor
    
    return, scan_info

END

;+
; Appends row info to an index file, given a group of zpectrometer
; data containers.  Used for when these data have been written to an
; sdifts file.
; @param zdc {in}{type=array} array of zpectrometer data containers
; @param file_name {in}{type=string} file location shared by all extensions
; @param extension {in}{type=long} extension location shared by all extensions
; @param start_row {in}{type=long} where these zdc start in the extension, should be the current number of rows in extension
; @uses LINE_INDEX::spectra_to_info
; @uses LINE_INDEX::update_index_file
;-
PRO Z_INDEX::update_with_spectra, zdc, file_name, extension, start_row
    compile_opt idl2
    
    if (n_params() eq 4) then start=start_row else start=0
    rows_info = self->spectra_to_info(zdc, file_name, extension, start)
    self->update_index_file, rows_info
 
END

;+
; Replaces a line specified by index number in the index rows section, with information derived
; from a given zpectrometer data container, and that data's location (sdfits file, ext, row)
; Used when a row has been rewritten in an sdfits file with a new spectra (via nsave, for example).
; @param zdc {in}{type=array} zpectrometer data container
; @param file_name {in}{type=string} file location where zdc was written
; @param extension {in}{type=long} extension location where this zdc was written
; @param row_num {in}{type=long} row number where this zdc was written
; @uses LINE_INDEX::spectra_to_info
;-
PRO Z_INDEX::replace_with_spectrum, index, zdc, file_name, extension, row_num
    compile_opt idl2
    
    row_info = self->spectrum_to_info(zdc, index, file_name, extension, row_num)
    self.rows->overwrite_row, index, row_info
    self.row_lines = self.rows->get_rows_ptr()
    
END

;+
; Translates information in a single zpectrometer data container, along with this data containers
; location in the sdfits file and index file, into a line in the rows section of the index file
; @param zdc {in}{type=struct} zpectrometer data container
; @param index {in}{type=long} index number that this row will have in index file
; @param file_name {in}{type=string} file that this zdc is from
; @param extension {in}{type=long} extension that this zdc are from
; @param row_num {in}{type=long} the row that this zdc is from
; @uses INDEX_FILE::get_row_info_strct
; @returns structure representing a row in the index file
; @private
;-
FUNCTION Z_INDEX::spectrum_to_info, zdc, index, file_name, extension, row_num
    compile_opt idl2

    ; we don't know the structure of the data container!!!!

    row_info = self->get_row_info_strct()    

    ; copy over basic info
    row_info.index = index
    row_info.project = "unknown" ;spectrum.projid
    row_info.file = file_name
    row_info.extension = extension
    row_info.row_num = row_num
    row_info.mc_scan = -1 ;spectrum.scan_number
    row_info.source = "unknown" ;spectrum.source
    row_info.procedure = "unknown" ;spectrum.procedure
    row_info.subscan = -1 ;spectrum.subscan

    return, row_info

END

;+
; Translates spectral line data containers directly into the rows to be written to index file.  
; No specail coding here, since an index file was used to create this data container at some point.
; This assumes that the spectra have been recenlty appended to the file in param file_name.
; @param spectra {in}{type=array} array of spectrum data containers
; @param file_name {in}{type=string} file that these spectra are from
; @param extension {in}{type=long} extension that these spectra are from
; @param start {in}{type=long} the row at which these spectra start in their file-extension location, should be the current number of rows in extension
; @uses INDEX_FILE::get_row_info_strct
; @uses LINE_INDEX::spectrum_to_info
; @returns structures representing a row in the index file
; @private
;-
FUNCTION Z_INDEX::spectra_to_info, spectra, file_name, extension, start
    compile_opt idl2

    info = make_array(n_elements(spectra),value=self->get_row_info_strct())
    
    new_index = self.rows->get_num_rows()

    for i = 0, n_elements(spectra)-1 do begin
        row_info = self->get_row_info_strct() 
        row_info = self->spectrum_to_info(spectra[i], new_index, file_name, extension, (i+start))
        new_index = new_index + 1
        ; append this line to list of lines
        info[i] = row_info
    
    endfor

    
    return, info
    
END

;+
; Makes object verbose
;-
PRO Z_INDEX::set_debug_on
    compile_opt idl2
    
    self->INDEX_FILE::set_debug_on

END    

;+
; Makes object quiet
PRO Z_INDEX::set_debug_off
    compile_opt idl2
   
    self->INDEX_FILE::set_debug_off

END    

;+
; Finds the number and sizes of extensions for a file listed in the index file, according to the index file.
; @param file_name {in}{type=string} file whose properties are being queried
; @param extensions {out}{type=long} number of extensions for this file
; @param num_rows {out}{type=array} array showing how many rows in each extension for this file
; @private
;-

PRO Z_INDEX::get_file_properties_in_index, file_name, extensions, num_rows
    compile_opt idl2

    files = (*self.row_lines).file
    exts = (*self.row_lines).extension
    row_nums = (*self.row_lines).row_num

    file_exts = exts[where(files eq file_name)]
    extensions = file_exts[uniq(file_exts,sort(file_exts))]

    num_rows = lonarr(n_elements(extensions))

    for i=0,n_elements(extensions)-1 do begin
        ind = where(files eq file_name and exts eq extensions[i], count)
        num_rows[i] = count
    endfor
    
END

;+
; Defines class structure
; @private
;-
PRO z_index__define

    ifile = { Z_INDEX, inherits INDEX_FILE $
    }

END
