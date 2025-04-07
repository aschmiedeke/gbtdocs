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
; Class destructor
;-
PRO IO_SDFITS_LINE::cleanup  
    compile_opt idl2, hidden

    self->IO_SDFITS::cleanup
    obj_destroy,self.online_status
    
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
