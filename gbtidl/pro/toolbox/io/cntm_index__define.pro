;+
; Child class of INDEX_FILE, contains special functionality for dealing with continuum data.
; This mostly entails the translation of sdfits data into contents of the index file.
; See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or
; <a href="../../../IDL_IO_index_classes.jpg">INDEX UML</a> for just index classes.
; This class is responsible for establishing the correct class for managing the
; row section of the index file, the translation between sdfits and index rows, 
; and provides the search gateway.
; @file_comments
; Child class of INDEX_FILE, contains special functionality for dealing with continuum data.
; This mostly entails the translation of sdfits data into contents of the index file.
; See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or
; <a href="../../../IDL_IO_index_classes.jpg">INDEX UML</a> for just index classes.
; This class is responsible for establishing the correct class for managing the
; row section of the index file, the translation between sdfits and index rows, 
; and provides the search gateway.
; @private_file
;-
PRO cntm_index__define

    cif = { CNTM_INDEX, inherits INDEX_FILE }

END

FUNCTION CNTM_INDEX::init, _EXTRA=ex
    compile_opt idl2, hidden

    self.rows_class = "cntm_index_section"   
    r = self->INDEX_FILE::init(_EXTRA=ex)

    return, r

END

;+
; Returns the specail structure needed for continuum data
; @returns cntm_row_info_strct structure
; @private
; -
FUNCTION CNTM_INDEX::get_row_info_strct


    @cntm_row_info
    return, {cntm_row_info_strct}

END

;+
; This method searches the rows in the index file using the optional keywords.
; Not using any keywords returns all rows.  Use of more then one keyword is like
; using an AND.
;
; @param start {in}{optional}{type=long} where to start the range to search in
; @param finish {in}{optional}{type=long} where to stop the range to search in
;
; @keyword index {in}{optional}{type=long} What index # to search for 
; @keyword project {in}{optional}{type=string} What projects to search for
; @keyword file {in}{optional}{type=string} What sdfits files to search for
; @keyword extension {in}{optional}{type=long} What sdfits extension numbers to search for
; @keyword firstrow {in}{optional}{type=long} What sdfits row numbers to search for
; @keyword numrows {in}{optional}{type=long} What number of rows to search for
; @keyword stride {in}{optional}{type=long} What stride to search for
; @keyword source {in}{optional}{type=string} What source names to search for 
; @keyword procedure {in}{optional}{type=string} What procecures to search for 
; @keyword obsid {in}{optional}{type=string} What obsid to search for
; @keyword procscan {in}{optional}{type=string} What procscan to search for
; @keyword proctype {in}{optional}{type=string} What proctype to search for
; @keyword scan {in}{optional}{type=long }What M&C scan numbers to search for 
; @keyword procseqn {in}{optional}{type=long }What M&C procedure
; sequence numbers to search for 
; @keyword e2escan {in}{optional}{type=long }What e2e scan numbers to search for (not yet supported) 
; @keyword ifnum {in}{optional}{type=long }What if numbers to search for 
; @keyword polarization {in}{optional}{type=string} What polarizations to search for
; @keyword trgtlong {in}{optional}{type=float} What target longitude to search for.
; @keyword trgtlat {in}{optional}{type=float} What target latitude to search for.
; @keyword sig {in}{optional}{type=string} What sig states to search for
; @keyword cal {in}{optional}{type=string} What cal states to search for
; @keyword nsave {in}{optional}{type=string} What nsaves to search for
;
; @returns Array of structures, each element corresponding to a line of the index file that matches the search
;
;-
FUNCTION CNTM_INDEX::search_index, start, finish, SEARCH=search, INDEX=index, PROJECT=project, FILE=file, EXTENSION=extension, FIRSTROW=firstrow, NUMROWS=numrows, STRIDE=stride, SOURCE=source, PROCEDURE=procedure, OBSID=obsid, PROCSCAN=procscan, PROCTYPE=proctype, SCAN=scan, PROCSEQN=procseqn, E2ESCAN=e2escan, POLARIZATION=polarization, IFNUM=ifnum, TRGTLONG=trgtlong, TRGTLAT=trgtlat, SIG=sig, CAL=cal, NSAVE=nsave

    if (self.file_loaded eq 0) then begin
        print, 'File not loaded, cannot search index. Use read_file method'
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
    search_result = self->search_range(start,finish,search_result)
    
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
    if n_elements(FIRSTROW) ne 0 then begin 
        self->find_values_plus_and,(*self.row_lines).start_row,firstrow,search_result,"FIRSTROW"
    endif   
    if n_elements(NUMROWS) ne 0 then begin 
        self->find_values_plus_and,(*self.row_lines).num_rows,numrows,search_result,"NUMROWS"
    endif   
    if n_elements(STRIDE) ne 0 then begin 
        self->find_values_plus_and,(*self.row_lines).stride,stride,search_result,"STRIDE"
    endif   
    if n_elements(source) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).source,source,search_result,"SOURCE"
    endif
    if n_elements(procedure) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).procedure,procedure,search_result,"PROCEDURE"
    endif
    if n_elements(obsid) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).osbid,obsid,search_result,"OBSID"
    endif
    if n_elements(procscan) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).procscan,procscan,search_result,"PROCSCAN"
    endif
    if n_elements(proctype) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).proctype,proctype,search_result,"PROCTYPE"
    endif
    if n_elements(scan) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).mc_scan,scan,search_result,"SCAN"
    endif
    if n_elements(procseqn) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).procseqn,procseqn,search_result,"PROCSEQN"
    endif
    if n_elements(e2escan) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).scan,e2escan,search_result,"E2ESCAN"
    endif
    if n_elements(polarization) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).polarization,polarization,search_result,"POLARIZATION"
    endif
    if n_elements(ifnum) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).if_number,ifnum,search_result,"IFNUM"
    endif
    if n_elements(trgtlong) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).trgtlong,trgtlong,search_result,"TRGTLONG"
    endif
    if n_elements(trgtlat) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).trgtlat,trgtlat,search_result,"TRGTLAT"
    endif
    if n_elements(sig) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).sig_state,sig,search_result,"SIG"
    endif
    if n_elements(cal) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).cal_state,cal,search_result,"CAL"
    endif
    if n_elements(nsave) ne 0 then begin
        self->find_values_plus_and,(*self.row_lines).nsave,nsave,search_result,"NSAVE"
    endif
    
    return, search_result
END

;+
; Appends row info to an index file, given a group of rows from sdfits files.  Used 
; for first loading in an sdfits file 
; @param first_row {in}{type=struct} represents the first row in the sdfits file of the scan 
; @param proj {in}{type=string} project for scan
; @param file_name {in}{type=string} file location
; @param ext {in}{type=long} extension location 
; @param start_row {in}{type=long} where this scan starts in the extension
; @param n_data {in}{type=long} length of a continuum in this scan
; @param samplers {in}{type=array} array of sampler names used in this scan
; @param sigs {in}{type=array} array of unique signal states in scan
; @param cals {in}{type=array} array of unique cal states in scan
; @param pols {in}{type=array} array of polarizations for each sampler 
; @uses CNTM_INDEX::parse_scan_info
; @uses CNTM_INDEX::update_index_file
;-
PRO CNTM_INDEX::update_file_with_scan, first_row, proj,file_name, ext, start_row, n_data, samplers, sigs, cals, pols

    info_rows = self->parse_scan_info(first_row, proj,file_name,ext, start_row, n_data, samplers, sigs, cals, pols)
    self->update_index_file, info_rows
    
END

;+
; Takes in information about a continuum scan, and converts that to several rows in the index
; file.  A single scan may have several continua (or rows in index) depending on the switching type, receiver type, etc...
; @param first_row {in}{type=struct} represents the first row in the sdfits file of the scan 
; @param proj {in}{type=string} project for scan
; @param file_name {in}{type=string} file location
; @param ext {in}{type=long} extension location 
; @param start_row {in}{type=long} where this scan starts in the extension, should be zero for the first scan
; @param n_data {in}{type=long} length of a continuum in this scan
; @param unique_samplers {in}{type=array} array of sampler names used in this scan
; @param sigs {in}{type=array} array of unique signal states in scan
; @param cals {in}{type=array} array of unique cal states in scan
; @param sampler_pols {in}{type=array} array of polarizations for each sampler 
; returns array of structures representing new rows for the index file (all for just this scan)
; @private
;-
FUNCTION CNTM_INDEX::parse_scan_info,first_row,proj, file_name, ext, start_row, n_data, unique_samplers, sigs, cals, sampler_pols
    compile_opt idl2
    
    row_info = self->get_row_info_strct()
    
    n_samplers = n_elements(unique_samplers)
    n_sigs = n_elements(sigs)
    n_cals = n_elements(cals)
    
    count = 0
    ;row_number = self.current_rows
    row_number = self.rows->get_num_rows()
    current_rows = self.rows->get_num_rows()

    ; total data points per polarization
    ;data_per_sampler = n_elements(data)/n_samplers
    data_per_sampler = n_data/n_samplers

    index_len = (n_data/(n_samplers*n_sigs*n_cals))
    if (index_len eq 0) then index_len = 1
    seed_index = lindgen(index_len)
    seed_index = seed_index*n_sigs*n_cals

    rowTags = tag_names(first_row)
    tmp = where(rowTags eq 'procscan',count)
    hasProcScan = count eq 1
    tmp = where(rowTags eq 'proctype',count)
    hasProcType = count eq 1

    ; make the array where each element will be a row in the index file
    info_rows = make_array((n_samplers*n_sigs*n_cals),value= self->get_row_info_strct())

    if self.debug then help, info_rows
    
    ; cycle through pols
    for i_sampler=0,n_samplers-1 do begin 
    
        pol_index = seed_index + (data_per_sampler*i_sampler)
        
        pol = sampler_pols[i_sampler]
        sampler = unique_samplers[i_sampler]
         ; cycle through sigs
        for i_sig=0,n_sigs-1 do begin
        
            sig_index = pol_index + (2*i_sig)
        
            ; what's the sig?
            if (i_sig eq 0) then sig = 'T' else sig = 'F'
        
            ; cycle throuh cals
            for i_cal=0,n_cals-1 do begin
        
                index = sig_index + i_cal
            
                ; what's the cal?
                if (i_cal eq 0) then cal = 'F' else cal = 'T'
        
                if self.debug then print, "count: "+string(count)+"sampler: "+string(i_sampler)+" sig: "+string(i_sig)+" cal: "+string(i_cal)
                
                ; get info to put in index file
                start_row_in_file = start_row + index[0]  
                num_rows = n_elements(index)
                if (num_rows gt 1) then begin
                    stride = index[1] - index[0]
                endif else begin
                    stride = 1
                endelse    
                
                ; this structure represents a line in the index file
                row_info = self->get_row_info_strct()

                row_info.start_row = start_row_in_file
                row_info.num_rows = num_rows
                row_info.stride = stride
                row_info.index = current_rows
                row_info.project = proj
                row_info.file = file_name
                row_info.extension = ext
                row_info.mc_scan = first_row.scan
                row_info.source = strtrim(first_row.object,2)
                row_info.procedure = self->get_procedure_from_obsmode(first_row.obsmode[0])
                row_info.obsid = first_row.obsid[0]
                ; these 2 may not be in all CNTM files
                if hasProcScan then begin
                   row_info.procscan = first_row.procscan[0]
                endif else begin
                   row_info.procscan = "unknown"
                endelse
                if hasProcType then begin
                   row_info.proctype = first_row.proctype[0]
                endif else begin
                   row_info.proctype = "unknown"
                endelse

                row_info.procseqn = first_row.procseqn[0]
                row_info.polarization = self->translate_polarization(pol)
                ; these two columns may not exist, this needs to eventually
                ; use index:get_row_value
                if where(tag_names(first_row) eq 'TRGTLONG') ge 0 then begin
                    row_info.target_longitude = first_row.trgtlong
                endif else begin
                    row_info.target_longitude = 0.0
                endelse
                if where(tag_names(first_row) eq 'TRGTLAT') ge 0 then begin
                    row_info.target_latitude = first_row.trgtlat
                endif else begin
                    row_info.target_latitude = 0.0
                endelse
                row_info.sig_state = sig
                row_info.cal_state = cal
                row_info.nsave = -1
                
                if self.debug then help, row_info, /str
                
                info_rows[count] = row_info
                count = count + 1
                current_rows = current_rows + 1
                
             endfor ; for each cal
             
         endfor ; for each sig
         
     endfor ; for each sampler    

    return, info_rows
END

;+
; Checks basic file properties to see if they agree with what the index file has listed.
; @param file_name {in}{type=string} sdfits file to check
; @param expanded {in}{optional}{type=boolean} has this file been expanded since its listing in the index file?
; @keyword verbose {in}{optional}{type=boolean} print out details of errors?
; @returns 0,1
; @private
;-
FUNCTION CNTM_INDEX::check_file_properties, file_name, expanded, verbose=verbose

    if (n_params() eq 2) then checking_expansion = 1 else checking_expansion = 0    
    if checking_expansion then expanded = 0
    if keyword_set(verbose) then loud =1 else loud = 0

    ; get the number of extensions and rows/ext. according to the index file
    self->get_file_properties_in_index, file_name, index_exts, index_rows

    ; open this fits file and get same properties
    fits = obj_new('fits',self->get_full_file_name(file_name))
    file_exts = lindgen(fits->get_number_extensions())+1
    file_rows = make_array(n_elements(file_exts),value=0L)
    for i=0,n_elements(file_rows)-1 do begin
        file_rows[i] = fits->get_ext_num_rows(file_exts[i])
    endfor
    obj_destroy, fits

    ; check number of extensions
    if (n_elements(index_exts) ne n_elements(file_exts)) then begin
        ; if the file has more extensions then index, its expandable
        if (index_exts lt file_exts) and checking_expansion then expanded = 1
        if loud then print, 'file: '+file_name+' does not have same number of extensions as index reports'
        return, 0
    endif    

    ; file properties match index
    return, 1
   
END 

;+
;  Returns an array of structures that contains info about
;  the scan number given, such as scan number, procedure name, number
;  of integrations, ifs, etc.. One element in the array for each
;  unique FILE value for all rows having that scan number (there is no
;  TIMESTAMP available yet for continuum data).
;
;  @param scan_number {in}{type=long} scan number information is queried for
;  @param file {in}{optional}{type=string} Limit the search for the
;  scan number to a specific file name.
;  @keyword count {out}{type=integer} The number of elements of the
;  returned array of scan_info structures.
;  @keyword quiet {in}{optional}{type=boolean} When set, suppress most
;  error messages.
;
;  @returns array of structures containing info on scan, returns -1 on
;  failure.
;-
FUNCTION CNTM_INDEX::get_scan_info, scan_number, file, count=count, quiet=quiet
    compile_opt idl2

    rows = self->search_for_row_info(scan=scan_number)

    if (size(rows,/dimension) eq 0) then begin
	if not keyword_set(quiet) then begin
            if n_elements(file) eq 0 then begin
                message, 'Scan number not found: '+string(scan_number), /info
            endif else begin
                message, 'Scan number not found in ' + file + " : " +strtrim(string(scan_number),2), /info
            endelse
        endif
        return,-1
    endif

    ; timestamp not available yet for continuum data
    ; this code commented out until such time as that is possible
    ; time_sorted_rows = sort(rows.timestamp)
    ; sortedTimes = rows.timestamp[time_sorted_rows]
    ; uniqueTimes = sortedTimes[uniq(sortedTimes)]
    uniqueTimes = 0.0
    count = 0

    ; two passes, first gets the counts of things that determine array
    ; sizes and the second actually fills in the scan info structures

    ; loop over times first, then files.  Generally, times will be
    ; sufficient but older files may not have a timestamp and so
    ; files will be one more way of separating out duplicate scans.

    for i=0,(n_elements(uniqueTimes)-1) do begin
        ; theseRowsIndex = where(rows.timestamp eq uniqueTimes[i])
        ; theseRows = rows[theseRowsIndex]
        theseRows = rows
        file_sorted_rows = sort(theseRows.file)
        sortedFiles = rows.file[file_sorted_rows]
        uniqueFiles = sortedFiles[uniq(sortedFiles)]
        for j=0,(n_elements(uniqueFiles)-1) do begin
            theseFileRowsIndex = where(theseRows.file eq uniqueFiles[j])
            theseFileRows = theseRows[theseFileRowsIndex]
            ; for cont, feed and pol_number not yet there
            ; nfeed is always 1
            ; nf = n_elements(self->get_uniques(theseFileRows.feed))
            nf = 1
            ; use polarization in place of pol_number
            ;  np =n_elements(self->get_uniques(theseFileRows.pol_number))
            np = n_elements(self->get_uniques(theseFileRows.polarization))
            nif = n_elements(self->get_uniques(theseFileRows.if_number))
            if count eq 0 then begin
                nfeeds = nf
                npols= np
                nifs = nif
            endif else begin
                nfeeds = [nfeeds,nf]
                npols = [npols,np]
                nifs = [nifs,nif]
            endelse
            count += 1
        endfor
    endfor
    maxNfeeds = max(nfeeds)
    maxNpols = max(npols)
    maxNif = max(nifs)
    scan_info_struct = {scan:0L,procseqn:0L,timestamp:'',file:'', procedure:'',$
                        n_integrations:0L, n_feeds:0L, n_ifs:0L, $
                        n_cal_states:0L, n_sig_states:0L, n_switching_states:0L, $
                        n_polarizations:0L, polarizations:strarr(maxNpols), $
                        plnums:lonarr(maxNpols), feeds:lonarr(maxNfeeds), $
                        bandwidths:dblarr(maxNif), n_channels:0L}
        
    scan_info = replicate(scan_info_struct,count)

    count = 0
    for j=0,(n_elements(uniqueTimes)-1) do begin
        ; theseRowsIndex = where(rows.timestamp eq uniqueTimes[j])
        ; theseRows = rows[theseRowsIndex]
        theseRows = rows


        file_sorted_rows = sort(theseRows.file)
        sortedFiles = rows.file[file_sorted_rows]
        uniqueFiles = sortedFiles[uniq(sortedFiles)]
        for k=0,(n_elements(uniqueFiles)-1) do begin
            theseFileRowsIndex = where(theseRows.file eq uniqueFiles[k])
            theseFileRows = theseRows[theseFileRowsIndex]

            ; init arrays in structure
            for i=0,(maxNfeeds-1) do scan_info[count].feeds[i] = -1
            for i=0,(maxNpols-1) do scan_info[count].plnums[i] = -1
            ; strings should already be initialized to ''
            ; bandwidths are already initialized to 0.0
    
            ; feed information is not yet in the continuum index
            ;    feeds = self->get_uniques(theseFileRows.feed)
            ; plnum is not yet part of the continuum index
            ;    plnums = self->get_uniques(theseFileRows.pol_number)
            ; just leave them as -1 so no one is tempted to use them as is
            pols = self->get_uniques(theseFileRows.polarization)
            ifs = self->get_uniques(theseFileRows.if_number)
    
            ; this info is constant for scan 
            scan_info[count].scan = theseFileRows[0].mc_scan
            scan_info[count].procseqn = theseFileRows[0].procseqn
            ; scan_info[count].timestamp = theseFileRows[0].timestamp
                                
            ; there might be multiple files involved in this scan (unlikely for DCR)
            scan_info[count].file = self->file_match(theseFileRows.file)

            scan_info[count].procedure = theseFileRows[0].procedure
            scan_info[count].n_channels = 1

            ; collect info about scan
            scan_info[count].n_integrations = theseFileRows[0].num_rows
            scan_info[count].n_feeds = nfeeds[count]
            scan_info[count].n_ifs = nifs[count]
            scan_info[count].n_polarizations = npols[count]
            n_sigs = n_elements(self->get_uniques(theseFileRows.sig_state))
            n_cals = n_elements(self->get_uniques(theseFileRows.cal_state))
            scan_info[count].n_switching_states = n_sigs*n_cals
            scan_info[count].n_cal_states = n_cals
            scan_info[count].n_sig_states = n_sigs

 
            for i=0,(npols[count]-1) do begin
                scan_info[count].polarizations[i] = pols[i]
            endfor
            ;    for i=0,(nfeeds[count]-1) do begin
            ;        scan_info[count].feeds[i] = feeds[i]
            ;    endfor
            ; bandwidth not yet available in continuum index
            ; for i=0,(nifs[count]-1) do begin
            ;     indx = where(theseFileRows.if_number eq ifs[i])
            ;     scan_info[count].bandwidths[i] = theseFileRows[indx[0]].bandwidth
            ; endfor
            count+= 1
        endfor
    endfor

    return, scan_info

END

;+
; Finds the number and sizes of extensions for a file listed in the index file, according to the index file.
; @param file_name {in}{type=string} file whose properties are being queried
; @param extensions {out}{type=long} number of extensions for this file
; @param num_rows {out}{type=array} array showing how many rows in each extension for this file
; @uses INDEX_FILE::search_for_row_info
; @private
;-
PRO CNTM_INDEX::get_file_properties_in_index, file_name, extensions, num_rows
    compile_opt idl2
    
    ; get all rows for this file name
    row_info = self->search_for_row_info( file=file_name )
    ; get the unique extension numbers for this file
    exts = row_info.extension
    s_exts = exts[sort(exts)]
    unique_exts = s_exts[uniq(s_exts)]
    ; set the output parameters
    extensions = unique_exts
    num_rows = make_array(n_elements(extensions),value=0L)
    ; gather the number of rows for each extension
    for i=0,n_elements(extensions)-1 do begin
        ext = extensions[i]
        row_info = self->search_for_row_info( file=file_name, ext=ext )
        num_rows[i] = n_elements(row_info)
    endfor
    return

END    


