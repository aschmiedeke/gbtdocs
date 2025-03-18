;+
; IO_SDFITS is the base class for spectral line and continuum sdfits classes.  All the GENERAL functionality for reading, writing, navigating sdfits files, and for; translating their info to data containers is placed in this class.  See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just the line and continuum sdfits classes.
;
; @field file_path The path in which index and sdfits files are to be found
; @field fits_files An array of pointers to objects, one for each sdfits file
; @field index Object which manages the index file
; @field index_synced Flag which signals wether index and fits files are in sync
; @field update_expanded_files Flag determining wether index files are updated to keep in sink with an expanded fits file
; @field one_file Flag for determining if this object is locked into working with just one file
; @field Observer should not be here?
; @field tcal_table should not be here?
; @field backend should not be here?
; @field debug Flag that determines the verbosity of object
;
;
; @file_comments
; IO_SDFITS is the base class for spectral line and continuum sdfits classes.  All the general functionality for reading, writing, navigating sdfits files, and for; translating their info to data containers is placed in this class. See <a href="../../../IDL_IO_classes.jpg">UML</a> for all IO Classes, or <a href="../../../IDL_IO_io_sdfits_classes.jpg">IO_SDFITS UML</a> for just the line and continuum sdfits classes.
;
; @inherits io 
;
; @version $Id$
;-
PRO io_sdfits__define
    compile_opt idl2, hidden

    io = { io_sdfits, inherits io, $
    file_path:string(replicate(32B,256)), $
    fits_files:ptr_new(), $
    index:obj_new(), $
    flags:obj_new(), $
    index_synced:0L, $
    update_expanded_files:0L, $ 
    one_file:0L, $
    observer:string(replicate(32B,256)), $
    tcal_table:string(replicate(32B,256)), $
    backend:string(replicate(32B,256)), $
    last_record:0L, $
    online:0L, $
    update_in_progress:0L, $
    online_status:obj_new(), $
    debug:0L $
    }

END

;+
; Class Constructor. Initialize the object
;
; @uses IO::init
;
; @private
;-
FUNCTION IO_SDFITS::init  
    compile_opt idl2
    
    r = self->IO::init()
    self.flags = obj_new("flags")
    self.last_record = -1
    return, r
    
END

;+
; Class cleanup on deletion: cleans up index object and sdfits objects
;
; @private
;-
PRO IO_SDFITS::cleanup
    compile_opt idl2
    
    if (obj_valid(self.index) eq 1) then obj_destroy, self.index
    if (obj_valid(self.flags) eq 1) then obj_destroy, self.flags
    self->free_fits_objs
    
END

;+
; The class can be made to verbosly describe what its doing
;-
PRO IO_SDFITS::set_debug_on
    compile_opt idl2
    self.debug = 1
    if obj_valid(self.index) then self.index->set_debug_on
    if obj_valid(self.flags) then self.flags->set_debug_on
    self->set_debug_for_fits_objs, 1
END    
     
;+
; The class can be made to be quite 
;-
PRO IO_SDFITS::set_debug_off
    compile_opt idl2
    self.debug = 0
    if obj_valid(self.index) then self.index->set_debug_off
    if obj_valid(self.flags) then self.flags->set_debug_off
    self->set_debug_for_fits_objs, 0
END 

;+
; This method looks into the given directory and attempts to load any existing
; index file.  If the file does not exist, all sdfits files in this directory
; are loaded using the add_file method, and a new index is created. For a complete
; description, see the <a href="../../../set_project_flowchart.gif">flowchart</a>.
;
; @uses <a href="io_sdfits__define.html">add_file</a>
;
; @param dir {in}{type=string} The path in which all sdfits files and possibly
; the index file are to be found
;
; @examples
;   <pre>
;    path = '/users/me/my_project'
;    io = obj_new('io_sdfits_line')
;    io->set_project, path 
;   </pre>
;-
     
PRO IO_SDFITS::set_project, dir, _EXTRA=ex 
    compile_opt idl2

    if (self.one_file ne 0) then message, "this object is commited to using only one file"
    
    if (self->file_exists(dir) eq 0) then begin
        message, 'Cannot set project; directory does not exist'
        return
    endif

    ; parse the contents of the extra keywords
    new_index = 0
    if n_elements(ex) ne 0 then begin
        tags = tag_names(ex)
        for i=0,n_elements(tags)-1 do begin
            if tags[i] eq "NEW_INDEX" then begin
                if ex.(i) eq 1 then new_index = 1
            endif
        endfor
    endif
    
    ; set location of all sdfits files
    self->set_file_path, dir
    
    file_paths = file_search(dir+'/*.fits')

    if (self.debug eq 1) then print, file_paths
    
    files = file_basename(file_paths)

    ; create the name of the index file based off the 
    parts = strsplit(dir, "/", /extract)
    index_file_name = parts[n_elements(parts)-1]+".index"
    self.index->set_file_name, index_file_name
    
    ; place the index file in this same dir
    full_index_file_name = self.index->get_full_file_name()
    
    if self.debug then print, "index_file_name: "+index_file_name

    ; read existing index file, or create a new one
    if new_index then begin
        ; in this case ALL index files are rewritten
        self->set_project_create_index_file, file_paths
    endif else begin
        if (self->file_exists(full_index_file_name) eq 0) then begin
            ; index doesn't exist, so create one using all files in path
            for i=0,n_elements(files)-1 do begin
                self->add_file,files[i]
            endfor
        endif else begin    
            ; index exists use it
            self.index->read_file, file_name=file_name, ver_status
            ; could not read index; version number too old
            if ver_status eq 0 then begin
                message, 'cannot load index; version number too old. Creating new index.',/info
                self.index->reset
                for i=0,n_elements(files)-1 do begin
                    if i eq 0 then begin
                        self->add_file,files[i],/new_index
                    endif else begin
                        self->add_file,files[i]
                    endelse 
                endfor
            endif
            ; if the index info makes no sense, dont use it
            if (self.index->check_index_with_reality() eq 0) then begin
                message, 'cannot load pre-existing index; creating new index',/info
                self.index->reset
                for i=0,n_elements(files)-1 do begin
                    if i eq 0 then begin
                        self->add_file,files[i],/new_index
                    endif else begin
                        self->add_file,files[i]
                    endelse 
                endfor
                return
            endif
            ; create fits objs for files listed in index, if need be
            self->conform_fits_objs_to_index
            self.index_synced = 1
            ; add the additional files that might not be in this index already 
            index_files = self->get_index_files()
            for i=0,n_elements(files)-1 do begin
                cnt=0
                c = where(files[i] eq index_files,cnt)
                if (cnt eq 0) then begin
                    ; this file isn't in the index file - add it
                    self->add_file,files[i]
                endif
            endfor    

            ; index passes basic tests - load flags
            self->load_index_flag_info
            
        endelse  ; if index exists 
    endelse ; if new_index keyword set
END

;+
; This method can be used to lock the io object into working with only one
; sdfits file.  An index file is automatically created (overwrites pre-existing one).
; @uses <a href="io_sdfits__define.html">add_file</a>
; @param file_name {in}{type=string} The file name of the sdfits file (no path)
; @param status {out}{optional}{type=boolean} 1 - success, 0 - failure
;
; @keyword file_path {in}{optinal}{type=string} Where to find the sdfits file
; @keyword index_name {in}{optinal}{type=string}{default='file_name.index'} What to call the new index file
;
; @examples
;   <pre>
;   io = obj_new('io_sdfits_cntm')
;   io->set_file, 'TREG_04_01.dcr.raw.fits'
;   </pre>
;-

PRO IO_SDFITS::set_file, file_name, status, file_path=file_path, index_name=index_name, online=online, _EXTRA=ex

    compile_opt idl2

    status = 1

    if (self.one_file ne 0) then message, "this object is commited to using only one file"

    ; online mode supercedes all other keywords
    if keyword_set(online) then begin
        self->set_online, file_name
        return
    endif
    
    ; discard all other fits objects
    self->free_fits_objs

    ; see if file path is inlcuded seperately
    if keyword_set(file_path) then begin
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
    
    ; index file name == to file, or keyword?
    if keyword_set(index_name) then begin 
        index_file=index_name 
    endif else begin
        ;parts=strsplit(file_base,'.',/extract)
        ;index_file = strjoin(parts[0:n_elements(parts)-2],'.')+'.index'
        index_file = self->get_index_name_from_fits_name(file_base)
    endelse
    self->set_index_file_name, index_file

    ; add file, loading or creating a new index according to keyword
    self->add_file, file_base, status, _EXTRA=ex
    
    if status ne 1 then return

    ; mark this io object as dedicated to one file
    self.one_file = 1
    
END

;+
; This method is the main interface to the sdfits io classes.  It is used in turn
; by set_project and set_file.  Most of the logic for keeping the index file in 
; sync with the fits files is coded in this method.  For a complete description,
; see the <a href="../../../add_file_flowchart.gif">flowchart</a>.
;
; @param file_name {in}{type=string} Name of sdfits file to add (no path)
; @param status {out}{optional}{type=boolean} 1 - success, 0 - failure
;
; @keyword new_index {in}{optinal}{type=boolean}{default=0} Forces the creation
; of a new index file (overwrites pre-existing index)
;
; @examples 
; <pre>
;    path = '/users/me/my_project'
;    io = obj_new('io_sdfits_line')
;    io->set_file_path, path 
;    io->add_file, 'TREG_O1_04.acs.raw.fits'
; </pre>
;-
PRO IO_SDFITS::add_file, file_name, status, new_index=new_index, index_name=index_name, max_nrows=max_nrows
    compile_opt idl2
      
    status = 1

    if (self.one_file ne 0) then message, "this object is commited to using only one file"

    if keyword_set(new_index) then make_new_index=1 else make_new_index=0  

    if keyword_set(index_name) then self.index->set_file_name, index_name
    
    ; check file existence  
    if (self->file_exists(self->get_full_file_name(file_name)) eq 0 ) then begin
        message, "Cannot add file that does not exist: "+file_name
        status = 0
        return
    endif
    
    ; check fits object existence 
    fits_obj = self->get_fits(file_name)
    if (obj_valid(fits_obj) eq 0) then begin
        ; create an interface object for this file'
        self->add_fits_obj, file_name, result
        if not result then begin
            message, "Cannot add file: "+file_name,/info
            status = 0
            return
        endif    
        fits_obj = self->get_fits(file_name)
    endif else begin
        ; nothing will be done; not really an error
        message, 'this file has already been added to this object',/info
        return
    endelse    
    
    ; index must be brought in line with new fits file
    self.index_synced = 0

    ; force a new index file?
    if make_new_index then begin
        ; starting from scratch, we're done
        self->create_index_file
        return
    endif
    
    ; is there an index file loaded?
    if (self.index->is_file_loaded() eq 0) then begin

        if self.debug then print, 'index not loaded'

        ; try to load up the named index file; file exists?
        if(self.index->file_exists() eq 0) then begin
        
            if self.debug then print, 'index does not exist'

            if not self.online then begin
                ; index file does not exist, create it, we're done
                self->create_index_file
                return
            endif else begin
                message, "Cannot create index file: online directory is read-only.",/info
                status = 0
                return
            endelse    

        endif else begin
        
            if self.debug then print, 'index exists, reading'
        
            ; index file exists, load it
            self.index->read_file, ver_status, max_nrows=max_nrows

            ; if version keyword is wrong, this index file could not be read.
            if ver_status eq 0 then begin
                if not self.online then begin
                    ; we can recreate this index
                    print,"Index file is out of date ... updating to current version number."
                    self.index->reset
                    self->create_index_file
                endif else begin
                    ; we cant recreate an online index
                    print, "Index file is out of date: cannot connect to file in online directory." 
                    status = 0
                    return
                endelse
            endif
            
            ; dont do this check in the online case
            if not self.online then begin
                ; index file match reality? a fits file with larger extension is allowable
                expanded = 0
                index_matches = self.index->check_index_with_reality(expanded,/verbose)
                if (index_matches eq 0) then begin
                    ; something doesn't agree between the index file and reality
                    message, 'Cannot use this index file ... Creating new index file', /info
                    self.index->reset
                    self->create_index_file
                    return
                endif
            endif    

            ; index passes basic tests - load flags
            self->load_index_flag_info
        endelse ; if file exists
        
    endif ; if file loaded
    
    ; dont do any further checks if we are online
    if not self.online then begin
        ; check this file is in index
        files = self->get_index_files(/unique)
        ; is base file name in list of files in index?
        count = 0
        ind = where(fits_obj->get_file_name() eq files, count)
        if (count eq 0) then begin
        
            if self.debug then print, 'fits file not in index, updating index with it.'
            ;  file is not in index, update the index file, we're done
            self->update_index_with_fits_file, fits_obj
            return
    
        endif else begin
        
            ; file is in index, does index info match with fits info?
            expanded = 0
            file_info_matches = self.index->check_file_properties(fits_obj->get_file_name(),expanded,/verbose)
            
            if file_info_matches then begin
    
                if self.debug then print, 'fits file in index and properties match.'
            
                ; all extensions have same length, we're done
                self.index_synced = 1
                return
    
            endif else begin    
            
                if self.debug then print, 'fits file in index but properties do not match.'
    
                if expanded then begin
    
                    ; fits extension too big, updating?
                    if self.update_expanded_files then begin
    
                        message, 'update the damn files',/info
    
                    endif else begin
                    
                        ; no -error
                        message, 'cannot use this index file; file has been expanded since index creation.'
                        status = 0
                        return
    
                    endelse    
    
                
                endif else begin
    
                    message, 'cannot use this index file; file properties do not match index.'
                    status = 0
                    return
    
                endelse ; if file has been expanded since index creation
    
            endelse ; if file properties match index

        endelse ; if file found in index    
    
    endif else begin
        ; we're online - assume index is getting taken care of for us
        self.index_synced = 1
    endelse ; if online
          
    status = 1
    return

END

;+
; For every sdfits file managed by the current index file, the flags object
; is updated with info from these files.
;-
PRO IO_SDFITS::load_index_flag_info
    compile_opt idl2, hidden

    ; get the file names
    files =  self.index->get_column_values("FILE",/unique)

    for i=0, n_elements(files)-1 do begin
        fits_file = self->get_full_file_name(files[i])
        fits_obj= self->get_new_fits_obj(fits_file)
        self->update_flags_with_fits_file, fits_obj
        obj_destroy, fits_obj
    endfor

END

;+
; Creates a new index file using current info (file_path, observer, etc.) for index header.
; 
; @private
;-
PRO IO_SDFITS::init_index
    compile_opt idl2
    
    self.index->set_file_name, self.index->get_file_name()
    self.index->new_file, self.observer, self.backend, self.tcal_table, self.file_path

END

;+
; This method will read an index file, check that the index agrees with 
; the sdfits files on disk, and create fits objects for the files listed
; in its index.
;
; @param file_name {in}{type=string} Index file name (no path)
;
; @keyword file_path {in}{optinal}{type=string} Where to find index file and sdfits files
;
; @examples 
; <pre>
;    path = '/users/me/my_project'
;    io = obj_new('io_sdfits_line')
;    io->load_index, 'my_index', file_path='/users/me/my_project'
; </pre>
;-
PRO IO_SDFITS::load_index, file_name, file_path=file_path
    compile_opt idl2
    
    if keyword_set(file_path) then self->set_file_path, file_path
    ; load the index info
    self.index->read_file, file_name=file_name, ver_status
    ; if the version number is old, then we can't even read it
    if ver_status eq 0 then begin
        message, "Cannot load pre-existing index: old version number."
        return
    endif
    ; if the index info makes no sense, dont use it
    if (self.index->check_index_with_reality() eq 0) then begin
        message, 'Cannot load pre-existing index: does not match files'
        return
    endif
    ; create fits objs for files listed in index, if need be
    self->conform_fits_objs_to_index
    ; we're good to go
    self.index_synced = 1

END

;+
; Calls index file's read_file method
; @param file_name {in}{type=string} full path name to the index file
; @uses INDEX_FILE::read_file
; @private
;-
PRO IO_SDFITS::read_index, file_name
    compile_opt idl2
    
    self.index->read_file, file_name=file_name

END

;+
; Creates a fits object for the file name passed to it, and adds it to the list of fits objects
; @param file_name {in}{type=string} full path name of the sdfits file to add
; @uses IO_SDFITS::get_full_file_name
; @uses IO_SDFITS::get_new_fits_obj
; @private
;-
PRO IO_SDFITS::add_fits_obj, file_name, result, _EXTRA=ex

    result = 0

    ; get the full path
    full_file_name = self->get_full_file_name(file_name)
    
    ; check to see if this fits object already exists
    if (self->find_fits(full_file_name) ne -1) then begin
        message, "Cannot add fits file, fits object exists already for fits file: "+full_file_name, /info
        return
    endif
    
    new_fits = self->get_new_fits_obj(full_file_name, _EXTRA=ex)

    ; pass on the debug state
    if self.debug then new_fits->set_debug_on

    if (obj_valid(new_fits) eq 0) then begin
        message, "Could not create valid sdfits object for file: "+full_file_name,/info
        return
    endif 

    if ptr_valid(self.fits_files) then begin
        *self.fits_files = [*self.fits_files, new_fits]
    endif else begin
        self.fits_files = ptr_new([new_fits])
    endelse

    ; if we added the fits object properly, add this info to the flags object
    self.flags->check_flag_file_for_fits_file, file_name
    
    result = 1
    
END

;+
; From an array of full path names to sdfits files, create an array of sdfits objects
; @private
;-
PRO IO_SDFITS::add_fits_objs, file_names
    compile_opt idl2
    
    for i=0,n_elements(file_names)-1 do begin
        self->add_fits_obj, file_names[i]
    endfor

END

;+
; Creates a new index file, populating it with information from all 
; the fits object
; @param index_file_name {in}{type=string} full path name to index file
; @uses SDFITS::get_rows
; @uses FITS::get_extension_header_value
; @uses IO_SDFITS::init_index
; @uses IO_SDFITS::update_index_with_fits_file
; @private
;-
PRO IO_SDFITS::create_index_file, index_file_name
    compile_opt idl2
    
    print, "About to create Index..."
    
    ; need to keep flags object in sync with fits files in index file
    ; so, reset this object
    if obj_valid(self.flags) then obj_destroy, self.flags
    self.flags = obj_new("flags",file_path=self.file_path,debug=self.debug)
    
    fits_files = *self.fits_files
    ; HACK HACK HACK
    ; use the first fits object to init index with common info
    fits_obj = fits_files[0]
    ;rows = fits_obj->get_rows(ext=ext,row_nums=[0])
    ;self.observer = rows[0].observer
    self.observer = 'unknown' 
    self.backend = fits_obj->get_extension_header_value('BACKEND')
    self.tcal_table = 'unknown'

    self->init_index
    
    ; use fits objects to populate index file
    for i = 0, (n_elements(fits_files)-1) do begin
        fits_obj = fits_files[i]

        ; update the index file
        self->update_index_with_fits_file, fits_obj

    endfor

    self.index_synced = 1

    print, "Index file created."

END

;+
; Creates a new index files for an entire project, 
; this includes the master index file for the directory
; and all the auxillary index files, one per fits file.
; This is a variation of create_index_file.
; @param file_paths {in}{type=array}{required} array of full path names to fits files
; @private
;-
PRO IO_SDFITS::set_project_create_index_file, file_paths
    compile_opt idl2
    
    print, "About to create Index..."
    
    ; create new fits objects for all files in directory
    self->free_fits_objs
    for i = 0,n_elements(file_paths)-1 do begin
        self->add_fits_obj, file_paths[i], result
        if not result then begin
            message, "Cannot add file: "+file_paths[i],/info
            return
        endif    
    endfor    
    
    ; need to keep flags object in sync with fits files in index file
    ; so, reset this object
    if obj_valid(self.flags) then obj_destroy, self.flags
    self.flags = obj_new("flags",file_path=self.file_path,debug=self.debug)
    
    fits_files = *self.fits_files
    ; HACK HACK HACK
    ; use the first fits object to init index with common info
    fits_obj = fits_files[0]
    ;rows = fits_obj->get_rows(ext=ext,row_nums=[0])
    ;self.observer = rows[0].observer
    self.observer = 'unknown' 
    self.backend = fits_obj->get_extension_header_value('BACKEND')
    self.tcal_table = 'unknown'

    self->init_index

    indexNames = strarr(n_elements(fits_files))
    
    ; use fits objects to populate index file
    for i = 0, n_elements(fits_files)-1 do begin
        ; create an auxillary index for each fits file
        status = 1
        fits_obj = fits_files[i]
        index_name = self->get_expected_full_index_name(fits_obj)
        indexNames[i] = index_name
        self->create_index_for_fits_obj, index_name, fits_obj, status
        if status eq 0 then begin
            message, "failed to created index: " + index_name
        endif    
     endfor

    ; sort the index names - makes the result less surprising
    indexNames = indexNames[sort(indexNames)]

    indxIters = objarr(n_elements(indexNames))
    nextIds = strarr(n_elements(indexNames))
    for i = 0, n_elements(indexNames)-1 do begin 
       indxIters[i] = obj_new('index_iterator',indexNames[i],self->get_index_section_class_name())
       nextIds[i] = (indxIters[i])->next_id()
    endfor

                                ; start with the minimum (should be
                                ; earliest) nextId, excluding empty
                                ; strings
    while 1 do begin
       idsOK = where(strlen(nextIds) gt 0, count)
       if count eq 0 then break

       ; there are IDs that are OK to use - keep iterating
       minID = min(nextids[idsOK])
       minLoc = where(nextIds eq minID,count)
       for i=0,(count-1) do begin
          thisIter = indxIters[minLoc[i]]
          rows = thisIter->next()
          nextIds[minLoc[i]] = thisIter->next_id()
          if self.index->update_file_with_row_structs(rows) eq 0 then begin
             message, "failed attempt to use fits index to update index: "+thsiIter->get_name()
          endif
          if strlen(thisIter->next_id()) eq 0 then begin
                                ; can destroy this iterator at this
                                ; point - no longer needed
             obj_destroy, thisIter
          endif
       endfor
    endwhile
                                ; no clean up necessary, the iterators
                                ; must all be destroyed to get here
    self.index->read_file
    self.index_synced = 1

                                ; must wait to update flag files here
                                ; - needs index to be there for this
                                ;   flag file as its updated
    for i = 0, n_elements(fits_files)-1 do begin
        ; update the flag files
        self->update_flags_with_fits_file, fits_files[i]
     endfor

    print, "Index file created."

END

;+
; Every sdfits file that is read in must have an index file.  Even if multiple 
; sdfits files are managed by a single index file, this master index file gets
; its info from the individual index files.
; This method creates an index file for the given fits object.
;-
PRO IO_SDFITS::create_index_for_fits_obj, index_file_name, fits_obj, status
    compile_opt idl2
    
    status = 0
    fits_name = fits_obj->get_file_name()
    print, "About to create Auxillary Index for fits file: "+fits_name+" ..."
    
    ; init index
    index_name = self->get_index_name_from_fits_name(fits_name) 
    auxillary_index = obj_new(self->get_index_class_name(),file_name=index_name,version=self.version)
    auxillary_index->set_file_path, self.file_path
    observer = 'unknown' 
    ; "BACKEND" is a keyword in SDFITS, but a column in SDFITS from gbtidl.
    backend = fits_obj->get_extension_header_value('BACKEND')
    if size(backend, /type) eq 2 then backend = "unknown"
    tcal_table = 'unknown'
    auxillary_index->set_file_name, auxillary_index->get_file_name()
    auxillary_index->new_file, observer, backend, tcal_table, self.file_path
    
    ; use fits objects to populate index file
    self->update_index_obj_with_fits_obj, auxillary_index, fits_obj

    ; cleanup, since all we need to do is create the file
    if obj_valid(auxillary_index) then obj_destroy, auxillary_index

    print, "Auxillary Index file created."
    status = 1
    
END

;+
; For every sdfits file managed by the current index file, the flags object
; must be able to convert the record numbers in the current index file to
; record numbers stored in each flag file.  
; @param fits_obj {in}{required}{type=object} object representing an sdfits file referred to in the current index.
;-
PRO IO_SDFITS::update_flags_with_fits_file, fits_obj
    compile_opt idl2, hidden

    ; get the name of the fits file
    fits_name = fits_obj->get_file_name()
    
    ; get the first index number for this fits file
    base_index = self.index->get_base_index_for_file(fits_name)

    self.flags->set_file_path, self.file_path

    ; update the flags object to load this flag file (if found) and its info
    self.flags->update_flags, fits_name, base_index

END

;+
; Checks to make sure index file that is loaded agrees with this object,
; and will create new sdfits objects if necessary to conform.
; @uses INDEX_FILE::get_column_values
; @uses INDEX_FILE::get_header_value
; @uses IO_SDFITS::file_exists
; @uses INDEX_FILE::search_for_row_info
; @uses IO_SDFITS::group_row_info
; @uses FITS_OPEN
; @uses FITS_CLOSE
; @uses IO_SDFITS::free_group_row_info
; @uses IO_SDFITS::conform_fits_objs
; @uses IO_SDFITS::set_file_path
; @private
;-
FUNCTION IO_SDFITS::conform_to_index
    compile_opt idl2
    
    ; check that files in index all exist
    files = self.index->get_column_values("file",/unique)
    file_path = self.index->get_header_value("file_path")
    for i = 0, n_elements(files)-1 do begin
        if (file_path ne '') then begin
            file_name = file_path + '/' + files[i]
        endif else begin
            file_name = files[i]
        endelse
        if (self->file_exists(file_name) eq 0) then begin
            message, 'Cannot confirm index: file does not exist: '+file_name
            return, 0
        endif
        if (i eq 0) then file_names=[file_name] else file_names=[file_names,file_name]
    endfor
    ; check the extensions, get all rows
    row_infos = self.index->search_for_row_info()
    ; group all rows in index file by filename and extension
    row_groups = self->group_row_info(row_infos)
    ; check the extensions
    for i = 0, n_elements(row_groups)-1 do begin
        if (file_path ne '') then begin
            file_name = file_path + '/' + row_groups[i].file
        endif else begin
            file_name = row_groups[i].file
        endelse
        FITS_OPEN, file_name,fcb,/no_abort, message=msg
        if strlen(msg) ne 0 then begin
            message,'FITS_OPEN failed in FITS::conform_to_index',/info
            message,msg,/info
            message,'problem file : '+ file_name,/info
            fileDir = file_dirname(file_name)
            if file_test(fileDir,/directory,/write) then begin
                badDir = fileDir + '/badfits'
                if not file_test(badDir,/write) then begin
                    file_mkdir,badDir
                endif
                if file_test(badDir,/directory,/write) then begin
                    thisfileBase = file_basename(file_name)
                    copyFile = badDir + '/' + thisfileBase
                    if file_test(copyFile) then begin
                        copyFile = copyFile + strtrim(string(round(systime(/sec)-1.129e9)),2)
                    endif
                    if not file_test(copyFile) then begin
                        file_copy,file_name,copyFile,/overwrite
                        message,'Copied to '+copyFile,/info
                    endif else begin
                        message,'Could not copy file, file already exists',/info
                    endelse
                endif else begin
                    message,'Could not copy file, no write permission in '+badDir,/info
                endelse
            endif   
            retall
        endif
        num_extensions = fcb.nextend
        FITS_CLOSE,fcb
        if (row_groups[i].extension gt num_extensions) then begin
            message, 'Cannot confirm: file does not contain extension: '+string(row_groups[i].extension)
            return, 0
        endif
    endfor
    self->free_group_row_info, row_groups
    ; check that we have the fits objects for these files
    self->conform_fits_objs, file_names
    ; we can set our member variables according to the index file
    self->set_file_path, file_path
    
    ; return success
    return, 1
    
END

;+
; Called after loading an index, gets all files in index and calls conform_fits_objs
; @uses IO_SDFITS::get_index_files
; @uses IO_SDFITS::conform_fits_objs
; @private
;-
PRO IO_SDFITS::conform_fits_objs_to_index

    file_names = self->get_index_files()
    if (self.file_path ne '') then begin
        file_names = self.file_path +'/'+file_names
    endif
    self->conform_fits_objs, file_names
END

;+
; Checks that the list of file names passed to it are all represented by fits objects. 
; If not, the fits objects are created from scratch.
; @param file_names {in}{type=array} array of full path names to sdfits files
; @uses IO_SDFITS::get_fits
; @uses IO_SDFITS::add_fits_objs
; @private
;-
PRO IO_SDFITS::conform_fits_objs, file_names
    compile_opt idl2

    missing_fits = 0
    for i = 0, n_elements(file_names)-1 do begin
        fits = self->get_fits(file_names[i])
        if (obj_valid(fits) eq 0) then missing_fits = 1
    endfor
    ; if we are missing a fits object, we can recover from this
    if (missing_fits eq 1) then begin
        ; recreate ALL fits objects
        if self.debug then print, "creating new fits objects for all files:"
        if self.debug then print, file_names
        self->free_fits_objs
        self->add_fits_objs, file_names
    endif
    return

END

;+
; Takes in a file name string and returns the full path, with prepended path if needed.
; If the object has no file path, then the file name is returned unaltered.  If 
; the object DOES have a file path, then the passed in file name is checked for backslashes.
; If there is no backslash, the objects file path is prepended to the file name and passed back.
; @param file_name {in}{type=string} a file name, can be full path or not.
; @returns Either the original passed in file name, or the full path file name.
; @private
;-
FUNCTION IO_SDFITS::get_full_file_name, file_name
    compile_opt idl2
    
    ; if there is no file path, do nothing
    if (self.file_path eq '') then begin
        full_file_name = file_name
    endif else begin
        ; if there is a file path, see if the file_name already has one
        if (strpos(file_name,'/') eq -1) then begin 
            ; we must add the file path
            full_file_name = self.file_path + '/' + file_name
        endif else begin
            ; the name already has some kind of path in it
            full_file_name = file_name
        endelse    
    endelse
    return, full_file_name

END    

;+
; Sets the path where index file and all sdfits files are to be found
;
; @param file_path {in}{type=string} Path where index file and all sdfits files are to be found. 
;
; @examples 
; <pre>
;    path = '/users/me/my_project'
;    io = obj_new('io_sdfits_line')
;    io->set_file_path, path 
; </pre>
;-
PRO IO_SDFITS::set_file_path, file_path
    compile_opt idl2
    
    self.file_path = file_path
    self.index->set_file_path, file_path
    self.flags->set_file_path, file_path

END

;+
; Gets the path where index file and all sdfits files are to be found
;
; @returns {type=string} Path where index file and all sdfits files are to be found. 
;
; @examples 
; <pre>
;    path = '/users/me/my_project'
;    io = obj_new('io_sdfits_line')
;    io->set_project, path
;    print, io->get_file_path()
;    '/users/me/my_project'
; </pre>
;-
FUNCTION IO_SDFITS::get_file_path
    compile_opt idl2
    
    return, self.file_path

END

;+
; Checks to see if this object has any sdfits files connected to it.
; @returns 0 - data is not loaded; 1 - data is loaded.
;-
FUNCTION IO_SDFITS::is_data_loaded
    compile_opt idl2

    return, self.index_synced
 
END

;+
; Sets the file name of the index file.
;-
PRO IO_SDFITS::set_index_file_name, file_name
    compile_opt idl2

    self.index->set_file_name, file_name

END

;+
; Retrieves the file name of the index file.
; @keyword full {in}{optional}{type=boolean} wether to return the full path name of the index file or not
; @returns The file name of the index file
;-
FUNCTION IO_SDFITS::get_index_file_name, full=full
    compile_opt idl2

    if keyword_set(full) then begin
        file_name = self.index->get_full_file_name()
    endif else begin
        file_name = self.index->get_file_name()
    endelse

    return, file_name

END

;+
; Given the full path name of an sdfits file, returns the object
; that represents that file
; @param file_name {in}{type=string} full path name to an sdfits file
; @uses IO_SDFITS::get_full_file_name
; @returns The index for the sdfits object to represent that represents this file, or -1 if object not found
; @private
;-
FUNCTION IO_SDFITS::find_fits, file_name
    compile_opt idl2

    full_file_name = self->get_full_file_name(file_name)

    if self.debug then print, "searching for: "+full_file_name +" in list: "

    if (ptr_valid(self.fits_files) eq 0) then return, -1
    
    fits_files = *self.fits_files
    fits_found = 0
    i = 0
    while (fits_found eq 0) and (i lt n_elements(*self.fits_files)) do begin
        fits_obj = fits_files[i]
        if self.debug then print, "fits obj #"+string(i)+" "+fits_obj->get_full_file_name()
        if (full_file_name eq fits_obj->get_full_file_name()) then fits_found = 1 else i = i + 1
    endwhile
    
    if self.debug then print, "fits found: "+string(fits_found)
    
    if (fits_found eq 1) then return, i else return, -1

END  

;+
; @returns an array of the file names of all of the FITS files
; associated with this io_sdfits object.  Returns -1 if none or not
; initialized. 
; @private
;-
FUNCTION IO_SDFITS::get_fits_file_names
  compile_opt idl2

  if (ptr_valid(self.fits_files) eq 0) then begin
     return, -1
  endif

  result = strarr(n_elements(*self.fits_files))
  for i=0,(n_elements(result)-1) do begin
     result[i] = (*self.fits_files)[i]->get_file_name()
  endfor
  return,result
end

;+
; @param file_name {in}{type=string} full path name to an sdfits file
; @uses IO_SDFITS::find_fits
; @returns The the sdfits object to represent that represents this file, or -1 if object not found
; @private
;-
FUNCTION IO_SDFITS::get_fits, file_name
    compile_opt idl2
    
    index = self->find_fits(file_name)

    if (index eq -1) then begin 
        return, -1 
    endif else begin
        fits_files = *self.fits_files
        return, fits_files[index]
    endelse

END

;+
; Retrieves the number of extensions for the given sdfits file
; @param file_name {in}{type=string} full file name of the sdfits file in question
; @returns number of extensions for file_name
; @private
;-
FUNCTION IO_SDFITS::get_number_extensions, file_name
    compile_opt idl2
    
    fits = self->get_fits(file_name)
    if obj_valid(fits) then return, fits->get_number_extensions() else return, -1

END    

;+
; Retrieves the extension type for the given sdfits file and extension
; @param ext_num {in}{type=long} extension (1-based)
; @param file_name {in}{type=string} full file name of the sdfits file in question
; @returns extension type for file_name and extension
; @private
;-
FUNCTION IO_SDFITS::get_extension_type, ext_num, file_name
    compile_opt idl2
    
    fits = self->get_fits(file_name)
    if obj_valid(fits) then return, fits->get_extension_type(ext_num) else return, -1

END

;+
; Retrieves the extension name for the given sdfits file and extension
; @param ext_num {in}{type=long} extension (1-based)
; @param file_name {in}{type=string} full file name of the sdfits file in question
; @returns extension name for file_name and extension number
; @private
;-
FUNCTION IO_SDFITS::get_extension_name, ext_num, file_name
    compile_opt idl2
    
    fits = self->get_fits(file_name)
    if obj_valid(fits) then return, fits->get_extension_name(ext_num) else return, -1

END    

;+
; Retrieves the number of rows for the given sdfits file and extension
; @param ext_num {in}{type=long} extension (1-based)
; @param file_name {in}{type=string} full file name of the sdfits file in question
; @returns number of rows for file_name and extension
; @private
;-
FUNCTION IO_SDFITS::get_ext_num_rows, ext_num, file_name
    compile_opt idl2
    
    fits = self->get_fits(file_name)
    if obj_valid(fits) then return, fits->get_ext_num_rows(ext_num) else return, -1

END    

;+
; Prints out rows from the index file used by object.  For exact search parameters
; to enter, see <a href="line_index__define.html">LINE_INDEX::search_index</a> or 
; <a href="cntm_index__define.html">CNTM_INDEX::search_index</a> 
;
; @param start {in}{optional}{type=long} where to start the range to list
; @param finish {in}{optional}{type=long} where to stop the range to list
; @keyword sortcol {in}{optional}{type=string} what index column name to order listwith
; @keyword verbose {in}{optinal}{type=boolean}{default=0} Print out ALL information? 
; @keyword user {in}{optional}{type=boolean} print out columns specified using set_user_columns? Takes precedence over verbose keyword
; @keyword columns {in}{optional}{type=string array} array of column
; names to print out upon list command. Takes precedence over user and
; verbose keywords.
; @keyword file {in}{optional}{type=string}{default=/dev/tty} The file
; to write to.  Defaults to the current screen, using "more" to page
; the output.
;
;-

PRO IO_SDFITS::list, start, finish, sortcol=sortcol,verbose=verbose, user=user,$
                     columns=columns,file=file,_EXTRA=ex
    compile_opt idl2

    ; validate search arguments
    if self.index->validate_search_keywords(ex) eq 0 then begin
        message, "Error with search keywords, cannot perform list", /info
        return
    endif
    if self->check_search_param_syntax(_EXTRA=ex) eq 0 then return 
    
    ; validate columns to be listed
    if n_elements(columns) ne 0 then begin
        if self.index->validate_column_names(columns) eq 0 then begin
            message, "Error with column names, cannot perform list", /info
            return
        endif
    endif

    ; if we're online, read in the latest index rows into memory
    if self.online then self->update

    ; find the rows in the index file that meat our search criteria
    results = self.index->search_index(start, finish, _EXTRA=ex) 
    if (size(results,/dim) eq 0) then begin 
        if results eq -1 then return
    endif    

    ; order the search results
    if n_elements(sortcol) ne 0 then begin
        results = self->sort_search_results(results,sortcol)
    endif
    
    ; print out the requested information
    self.index->list, rows=results,verbose=verbose,columns=columns,user=user, file=file,_EXTRA=ex

END

;+
; Returns indicies of rows in index file that match search.  For exact search parameters
; to enter, see <a href="line_index__define.html">LINE_INDEX::search_index</a> or 
; <a href="cntm_index__define.html">CNTM_INDEX::search_index</a> 
; @uses INDEX_FILE::search_index
; @returns Long array of indicies of rows in index file that match search
;-

FUNCTION IO_SDFITS::get_index, _EXTRA=ex
    compile_opt idl2
    
    ; if we're online, read in the latest index rows into memory
    if self.online then self->update

    if self.index->validate_search_keywords(ex) eq 0 then begin
        message, "Error with search keywords, cannot perform search", /info
        return, -1
    endif
    
    ind = self.index->search_index(_EXTRA=ex) 
    if (size(ind,/dim) eq 0) then begin
        if (ind lt 0) then return, -1
    endif
    return, ind
        
END

;+
;  Returns an array of structures that contains info about the scan number given, such
;  as scan number, procedure name, number of integrations, ifs, etc..
;  A separate element is returned for each unique TIMESTAMP and file
;  for all rows having that scan number.
;  @param scan_number {in}{type=long} scan number information is
;  queried for 
;  @param file {in}{optional}{type=string} Limit the search for the
;  scan number to a specific file name.
;  @keyword count {out}{type=integer} The number of elements of the
;  returned array of structures.
;  @keyword quiet {in}{optional}{type=boolean} When set, suppress most
;  error messages.
;  @uses INDEX_FILE::get_scan_info
;  @returns Array of structure containing info on scan
;-
FUNCTION IO_SDFITS::get_scan_info, scan_number, file, count=count, quiet=quiet
    compile_opt idl2

    ; if we're online, read in the latest index rows into memory
    if self.online then self->update

    scan_info = self.index->get_scan_info(scan_number,file,count=count,quiet=quiet)
    return, scan_info

END

;+
; Prints out the header section of the index file used by this object
; @uses INDEX_FILE::list_header
;-
PRO IO_SDFITS::list_index_header
    compile_opt idl2
    
    self.index->list_header    

END

;+
; Returns the values contained in the index file column used by this object
; @param column_name {in}{required}{type=string} name of the column to query
; @uses INDEX_FILE::get_column_values
; @returns the values found in the index column name specified. 
;-
FUNCTION IO_SDFITS::get_index_values, column_name, _EXTRA=ex
    compile_opt idl2
    
    ; if we're online, read in the latest index rows into memory
    if self.online then self->update
    
    if self.index->validate_search_keywords(ex) eq 0 then begin
        message, "Error with search keywords, cannot perform search", /info
        return, -1
    endif

    return, self.index->get_column_values(column_name,_EXTRA=ex)

END

;+
; Returns the unique file names (no path) contained in the index file used by this object
; @uses INDEX_FILE::get_column_values
; @returns The unique file names (no path) contained in the index file used by this object
;-
FUNCTION IO_SDFITS::get_index_files, _EXTRA=ex, full=full
    compile_opt idl2

    ; if we're online, read in the latest index rows into memory
    if self.online then self->update

    if keyword_set(full) then begin
        f =  self.index->get_column_values("file",/unique)
        path = self->get_file_path()
        files = strarr(n_elements(f))
        for i =0, n_elements(f) - 1 do begin
            files[i] = path + '/' + f[i]
        endfor
    endif else begin
        files =  self.index->get_column_values("file",/unique)
    endelse

    return, files

END

;+
; Returns the unique project names (no path) contained in the index file used by this object
; @uses INDEX_FILE::get_column_values
; @returns The unique project names (no path) contained in the index file used by this object
;-
FUNCTION IO_SDFITS::get_index_projects, _EXTRA=ex
    compile_opt idl2
    
    ; if we're online, read in the latest index rows into memory
    if self.online then self->update
    
    return, self.index->get_column_values("project",/unique)

END

;+
; Returns the unique source names (no path) contained in the index file used by this object
; @uses INDEX_FILE::get_column_values
; @returns The unique source names (no path) contained in the index file used by this object
;-
FUNCTION IO_SDFITS::get_index_sources, _EXTRA=ex
    compile_opt idl2
    
    ; if we're online, read in the latest index rows into memory
    if self.online then self->update
    
    return, self.index->get_column_values("source",/unique)

END

;+
; Returns the unique procedure names (no path) contained in the index file used by this object
; @uses INDEX_FILE::get_column_values
; @returns The unique procedure names (no path) contained in the index file used by this object
;-
FUNCTION IO_SDFITS::get_index_procedures, _EXTRA=ex
    compile_opt idl2 
   
    ; if we're online, read in the latest index rows into memory
    if self.online then self->update
    
    return, self.index->get_column_values("procedure",/unique)

END

;+
; Returns the unique scan names (no path) contained in the index file used by this object
; @uses INDEX_FILE::get_column_values
; @returns The unique scan names (no path) contained in the index file used by this object
;-
FUNCTION IO_SDFITS::get_index_scans, _EXTRA=ex
    compile_opt idl2 
   
    ; if we're online, read in the latest index rows into memory
    if self.online then self->update
    
    return, self.index->get_column_values("SCAN",/unique, _EXTRA=ex)

END

;+
; Groups rows from the index table and sorts them by file-extension, since if we read these rows
; we want to do that efficiently (one file-extension at a time).
; @param row_info {in}{type=array} array of structures that mirror rows in the index file
; @returns an array of structures, each struct representing index file rows grouped by file-extension.
; @private
;-
FUNCTION IO_SDFITS::group_row_info, row_info
    compile_opt idl2 
   
    ; get all files
    files = row_info.file
    unique_files = files[uniq(files[sort(files)])]
    
    group = {sdfits_row_group}
    
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
            group.integrations = ptr_new(file_ext_locals.integration)
            group.if_numbers = ptr_new(file_ext_locals.if_number)
            if (i eq 0) and (j eq 0) then groups = [group] else groups = [groups,group]
        endfor
    endfor
    
    return, groups

END

;+
; Deprecated function: given a listing of rows from the same file-extension, this uses 
; an sdfits objects to simply return those rows from the file.
; @param row_group {in}{type=struct} struct that specifies location of rows to be read from a file-extension
; @uses IO_SDFITS::get_fits
; @uses SDFITS::get_sdfits_rows
; @returns array of structs mirroring the rows in the sdfits file specified to read in.
; @private
;-
FUNCTION IO_SDFITS::get_sdfits_rows, row_group
    compile_opt idl2 
   
    rows_ptr = row_group.rows
    ext = row_group.extension
    rows = *rows_ptr
    fits = self->get_fits(row_group.file)
    if obj_valid(fits) then begin
        if self.debug then print, fits->get_file_name()
        if self.debug then print, fits->get_full_file_name()
        sdfits_rows = fits->get_sdfits_rows(ext=ext, row_nums=rows)
    endif else begin
        message, 'no fits object for: '+row_group.file
        return, -1
    endelse    
    
    return, sdfits_rows 

END   

;+
; Given a listing of rows from the same file-extension, this uses 
; an sdfits object to simply return those rows from the file and evaluate what
; columns are missing and what are the keywords for the extension
; @param row_group {in}{type=struct} struct that specifies location of rows to be read from a file-extension
; @param missing {out}{type=array} array of column names that were expected in extension, but are missing
; @param virtuals {out}{type=struct} struct that contains keywords
; that were found in the extension header
; @param apply_offsets {out}{type=boolean} If 1 (true) then any
; non-zero beam offsets should be applied and the positions adjusted
; accordingly.
; @uses IO_SDFITS::get_fits
; @uses SDFITS::get_and_eval_rows
; @returns array of structs mirroring the rows in the sdfits file specified to read in.
; @private
;-
FUNCTION IO_SDFITS::get_and_eval_rows, row_group, missing, virtuals, apply_offsets

    rows_ptr = row_group.rows
    ext = row_group.extension
    rows = *rows_ptr
    fits = self->get_fits(row_group.file)
    if obj_valid(fits) then begin
        sdfits_rows = fits->get_and_eval_rows(missing, virtuals, rows, ext=ext)
        apply_offsets = fits->auto_apply_offsets()
    endif else begin
        message, 'no fits object for: '+row_group.file
        return, -1
    endelse    
    return, sdfits_rows 

END



;+
; Method for attempting to extract a value from an sdfits row.  If the row contains the
; tag name requested, that value is passed back.  If that tag name actually specifies a 
; keyword in the extension-header, and NOT a column, then that value is returned.  Finally,
; if the tag name matches one of the expected column names that were not found in this
; extension, the default value is returned.
; @param row {in}{type=struct} structure that mirrors a row in an sdfits file
; @param tag_name {in}{type=string} name of the value that we want to retrieve
; @param virtuals {in}{type=struct} struct giving the keyword-values found in the file-extension
; @param names {in}{type=struct} struct contiaining pointers to the names of columns in the row, missing columns, and tag names in the virtuals struct
; @param default_value {in} value to be returned if the tag_name is of a missing column
; @returns either the value of row.tag_name, virtauls.tag_name, or default_value
; @private
;-

FUNCTION IO_SDFITS::get_row_value, row, tag_name, virtuals, names, default_value
    compile_opt idl2

    ; look for the tag name inside each member of 'names'
    i = where(tag_name eq *names.row)
    if (i ne -1) then begin
        ; its in the sdfits row
        value = row.(i)
    endif else begin
        ; see if there are virtual cols to check
        if (size(*names.virtuals,/dim) ne 0) then begin
            i = where(tag_name eq *names.virtuals)
        endif else begin
            i = -1
        endelse    
        if (i ne -1) then begin
            ; its a keyword in ext header (virtual)
            value = virtuals.(i)
        endif else begin
            ; see if there are missing cols to check
            if (size(*names.missing,/dim) ne 0) then begin
                i = where(tag_name eq *names.missing)
            endif else begin
                i = -1
            endelse    
            if (i ne -1) then begin
                ; its a missing column from sdfits row
                value = default_value ;missing.(i)
            endif else begin
                ; use the default value again
                ;print, 'tag_name: '+tag_name+' not found in row, missing, or virtuals'
                value = default_value
            endelse
        endelse
    endelse
    ; strip off trailing whitespace
    if size(value,/type) eq 7 then value = strtrim(value)

    return, value

END


;+
; Translates the polarization from the sdfits integer value into a char based value
; @returns Char representation of polarization
; @private
;-
FUNCTION IO_SDFITS::format_sdfits_polarization, pol
    compile_opt idl2
    case pol of
        1: value = 'I'
        2: value = 'Q'
        3: value = 'U'
        4: value = 'V'
       -1: value = 'RR' 
       -2: value = 'LL'
       -3: value = 'RL'
       -4: value = 'LR'
       -5: value = 'XX'
       -6: value = 'YY'
       -7: value = 'XY'
       -8: value = 'YX'
       else: value = '?'
    endcase

    return, value

END

;+
; Translates the sdfits string for frequency type to the gbtidl representation
;
; CTYPE1 has two parts:
; 
; First 4 characters are the type of quantity on that axis.  Possible 
; values are:
; 
; FREQ == frequency.  The axis is linear in frequency.
; VELO == velocity.  The axis is linear in velocity.
; FELO == The axis is linear in frequency, but the quantities describing 
; it are given in velocity units in the optical convention.
; 
; These all date from a AIPS memo by Eric Griesen from November of 1983.  
; The WCS paper III finally gets it right and eventually we'll have to 
; update SDFITS to do that as Arecibo apparently has done.  SDFITS, 
; though, is still stuck in 1983.
; 
; The second 4 characters describe the reference frame.  These come
; from M&C, which uses these codes:
; OBS - observed (sky frequencies)
; GEO - geocentric
; BAR - barycentric
; HEL - heliocentric
; GAL - galactic
; LSR - Local Standard of Rest (equivalent to Kinematic LSR or LSRK)
; LSD - Dynamic Local Standard of Rest
; LGR - Local group
; CMB - Cosmic Microwave Background
; 
; There's a "-" as the first character in this second set of 4.
; 
; For reasons I can't remember, we decided that OBS should be translated 
; to TOPO
; but everything else was okay as is.
; 
; The sdfits tool at the moment always sets CTYPE1=FREQ-OBS, but of course 
; other
; SDFITS files might have other combinations.
; 
; For the moment, ensure that the first 4 characters are FREQ, and set 
; frequency_type
; to the characters after the "-", translating "OBS" to "TOPO".
; 
; Eventually, we'll want to translate VELO and FELO to true FREQ axes in the
; data container, but I think you should just reject those for now and 
; come back to it
; later.
; @private
;-
FUNCTION IO_SDFITS::format_sdfits_freq_type, freq_type
    compile_opt idl2

    freq_type = strtrim(freq_type,2)
    first_half = strmid(freq_type,0,4)
    ; first part must be FREQ or its an error
    if (first_half eq 'FREQ' ) then begin
        ; ignore any dashes in the second half
        first_char  = strmid(freq_type,4,1)
        if (first_char eq '-') then begin
            second_half = strmid(freq_type,5,3)
        endif else begin
            second_half = strmid(freq_type,4,4)
        endelse
        ; translate some second half values
        if (second_half eq 'OBS') then second_half = 'TOPO'
        value = second_half
    endif else begin
        value = 'unknown'
    endelse    
    return, value
    
END

;+
; Deprecated
; @private
;-
FUNCTION IO_SDFITS::format_sdfits_procedure, obsmode
    compile_opt idl2
    obsmodes = strsplit(obsmode,":",/extract)
    return, obsmodes[0]

END

;+
; Translates the sdfits value for obsmode into seperate procedure, switch state and switch signal values
; @param obsmode {in}{type=string} the obsmode column from sdfits; takes form 'proc:swstate:swtchsig'
; @param proc {out}{type=string} procedure
; @param swstate {out}{type=string} switch state
; @param swtchsig {out}{type=string} switch signal
; @private
;-
PRO IO_SDFITS::parse_sdfits_obsmode, obsmode, proc, swstate, swtchsig

    parts = strsplit(strtrim(obsmode),":",/extract)
    if (n_elements(parts) ne 3) then begin
        if (n_elements(parts) eq 1) then begin
            ; only one part, give it to proc
            proc = parts
        endif else begin
            ; I have no clude, give all of obsmode to proc as is
            proc = strtrim(obsmode)      ; give all of obsmode to proc
        endelse
        ; either way, these are unknown
        swstate = 'unknown'
        swtchsig = 'unknown'
    endif else begin
        proc = parts[0]
        swstate = parts[1]
        swtchsig = parts[2]
    endelse

END

;+
; Incomplete: Translates the sdfits values for longitutde and latitude type into a coordinate mode.
; @param long_type {in}{type=string} type of longitude coordinate
; @param lat_type {in}{type=string} type of latitude coordinate
; @returns coordinate mode
; @private
;-
FUNCTION IO_SDFITS::coord_mode_from_types, long_type, lat_type
    compile_opt idl2

    ; default value
    value = 'OTHER'
    
    long_type = strtrim(strupcase(long_type),2)
    lat_type = strtrim(strupcase(lat_type),2)
    
    if (long_type eq 'RA') and (lat_type eq 'DEC') then begin
        value = 'RADEC'
    endif 
        
    if (long_type eq 'GLON') and (lat_type eq 'GLAT') then begin
        value = 'GALACTIC'
    endif 
    
    if (long_type eq 'HA') and (lat_type eq 'DEC') then begin
        value = 'HADEC'
    endif 
    
    if (long_type eq 'AZ') and (lat_type eq 'EL') then begin
        value = 'AZEL'
    endif 
    
    if (long_type eq 'OLON') and (lat_type eq 'OLAT') then begin
        value = 'OTHER'
    endif 
    
    return, value

END

;+
; Translates sdfits cal string value into 1 or 0
; @param cal {in}{type=string} sdfits sig value
; @returns 1,0
; @private
;-
FUNCTION IO_SDFITS::translate_cal, cal
    compile_opt idl2
    ; cal default is 0
    if (cal eq 'T') then return, 1 else return, 0

END    

;+
; Translates sdfits sig string value into 1 or 0
; @param sig {in}{type=string} sdfits sig value
; @returns 1,0
; @private
;-
FUNCTION IO_SDFITS::translate_sig, sig
    compile_opt idl2
    ; sig default is 1
    if (sig eq 'T') or (sig eq 'U') then return, 1 else return, 0

END    


;+
; Releases the memory for all the current sdfits objects for this object
; @private
;-
PRO IO_SDFITS::free_fits_objs
    compile_opt idl2

    if (ptr_valid(self.fits_files)) then begin
        fits_files = *self.fits_files
        for i = 0,(n_elements(fits_files)-1) do begin
            if obj_valid(fits_files[i]) then obj_destroy,fits_files[i]
        endfor
        ptr_free,self.fits_files
    endif

END

;+
; Sets debug flag for all fits objs
; @private
;-
PRO IO_SDFITS::set_debug_for_fits_objs, debug
    compile_opt idl2

    if (ptr_valid(self.fits_files)) then begin
        fits_files = *self.fits_files
        for i = 0,(n_elements(fits_files)-1) do begin
            if debug then begin
                if obj_valid(fits_files[i]) then fits_files[i]->set_debug_on
            endif else begin    
                if obj_valid(fits_files[i]) then fits_files[i]->set_debug_off
            endelse    
        endfor
        ptr_free,self.fits_files
    endif

END

;+
; Diagnostic function to determine if index file indicies are unique (as they should be)
; @returns 0 - bad, 1 - good
;-
FUNCTION IO_SDFITS::are_index_file_indicies_unique
    compile_opt idl2

    return, self.index->are_index_file_indicies_unique()
    
END

;+
;   Sets the object to print rows using the interactive 'more' format 
;-
PRO IO_SDFITS::set_more_format_on
    compile_opt idl2, hidden

    self.index->set_more_format_on

END    

;+
;   Sets the object NOT to print rows using the interactive 'more' format 
;-
PRO IO_SDFITS::set_more_format_off
    compile_opt idl2, hidden

    self.index->set_more_format_off

END

;+
;  Prints the available columns from the rows section for list;
;  these are also the valid search keywords
;-
PRO IO_SDFITS::list_available_columns
    compile_opt idl2, hidden

    self.index->list_available_columns

END

;+
;  Sets what columns should be used for user listing
;  @param columns {in}{required}{type=string array} array of columns to print on list command
;-
PRO IO_SDFITS::set_user_columns, columns
    compile_opt idl2, hidden

    self.index->set_user_columns, columns

END

;+
;  Prints the columns currently selected for the user specified listing
;-
PRO IO_SDFITS::list_user_columns
    compile_opt idl2, hidden

    self.index->list_user_columns

END    

;+
; Retrieves number of records the object is connected to - or how many rows
; currently in the index file
; @returns number of records this object is connected to
;-
FUNCTION IO_SDFITS::get_num_index_rows
    compile_opt idl2, hidden
   
    if self.online then self->update
    return, self.index->get_num_index_rows()

END

;+
;
;  Given an integer array representing some rows in the index,
;  sorts this array by a given column name in the index file
;
;  @param results {in}{required}{type=array} integer array representing some rows in the index file  
;  @param column {in}{required}{type=string} must be uniquely identify a column in the index file
;
;-
FUNCTION IO_SDFITS::sort_search_results, results, column
    compile_opt idl2, hidden

    column = strtrim(strupcase(column),2)

    ; make sure this is a valid column name
    if not self.index->validate_column_names(column) then begin
        message, "Cannot sort search results; column name invalid: "+column, /info
        return, results
    endif
    
    ; sort the results - first get the values for the column in question
    values = self.index->get_column_values( column, subset=results)
    sorted_values = values[sort(values)]
    sorted_results = make_array(n_elements(values),/long)
    used = -1
    if self.debug then print, "values: ", values
    ; reorder the results according to the sorted values array
    for i=0,n_elements(values)-1 do begin
        cnt = 0
        ind = where(sorted_values[i] eq values, cnt)
        if self.debug then print, "sorted_values[i]: ", sorted_values[i]
        if self.debug then print, "are found at: ", ind
        if cnt gt 1 then begin
            ; this sorted value is not unique, have we used any of these values yet?
            if n_elements(used) eq 1 then if used eq -1 then first=1 else first=0
            if first then begin
                ; no, just use the first value for the sorted result
                sorted_results[i] = results[ind[0]]
                used = [ind[0]]
                if self.debug then print, "first used: ", used
            endif else begin
                ; we have used some of these values already
                ; use just the first one that hasn't been placed in the sorted result
                if self.debug then print, "used: ", used
                next_not_used = ind[n_elements(used)]
                if self.debug then print, "next_not_used: ", next_not_used
                sorted_results[i] = results[next_not_used]
                used = [used,next_not_used]
                ; was this the last one?
                if n_elements(used) eq n_elements(ind) then used = -1
            endelse
        endif else begin
            ; this sorted value is unique, we can place it in the sorted results
            sorted_results[i] = results[ind]
            used = -1
        endelse
    endfor
    
    return, sorted_results

END    

;+
;  Given a fits file name of form '/path/filename.fits', returns the expected name
;  of its index: '/path/filename.index'
;  @param fits_obj {in}{required}{type=object} fits object for fits file
;  @returns expected name of index for given fits object
;-
FUNCTION IO_SDFITS::get_expected_full_index_name, fits_obj
    compile_opt idl2

    full_file_name = fits_obj->get_full_file_name()
    fits_file_name = fits_obj->get_file_name()

    parts = strsplit(full_file_name,"/",/extract)

    ; check for absolute vs. relative paths
    leading_char = strmid(full_file_name,0,1)
    if leading_char ne "/" then leading_char = ""

    if n_elements(parts) gt 1 then begin
        path = leading_char+strjoin(parts[0:n_elements(parts)-2],"/")
    endif else begin
        path = ""
    endelse     

    parts = strsplit(fits_file_name,".",/extract)
    if n_elements(parts) gt 1 then begin
        index_file_name = strjoin(parts[0:n_elements(parts)-2],".")+".index"
    endif else begin
        index_file_name = fits_file_name + ".index"
    endelse    

    if path ne "" then index_file_name = path + "/" + index_file_name
    
    return, index_file_name
    
END    

;+
;  Instead of adding rows to an index file by reading in an sdfits file, this
;  method attempts to take advantage of a pre-existing index files info.
;  @param index_name {in}{required}{type=string} full path name to index file to read
;  @returns 0 - failure, 1 - success
;-
FUNCTION IO_SDFITS::update_index_with_other_index, index_name
    compile_opt idl2

    ; double check that the additional index file can be found
    if not self->file_exists(index_name) then begin
        message, "File does not exist, cannot use to update: "+index_name, /info
        return, 0
    endif    

    ; create a temporary index object for this 
    other_index = obj_new(self->get_index_class_name(),file_name=index_name,version=self.version)

    ; read in the additional index file
    other_index->read_file, ver_status

    ; HACK HACK HACK: had to add this step after we removed the file path from the index header.
    other_index->set_file_path, self.file_path
    
    ; make sure it's valid
    if ver_status eq 0 then begin
        message, "Cannot use fits files index, version is out of date: "+index_name, /info
        if obj_valid(other_index) then obj_destroy, other_index
        return, 0
    endif
    if (other_index->check_index_with_reality() eq 0) then begin
        message, 'Cannot use fits files index, is not up to date: '+index_name ,/info
        if obj_valid(other_index) then obj_destroy, other_index
        return, 0
    endif    
    
    print, "Updating directory index with ", index_name
    ; transfer this additional index file's info to our internal index object
    if not self.index->update_file_with_row_structs(other_index->get_row_structs()) then begin
        return, 0
    endif    
 
    self.index->read_file

    self.index_synced = 1

    ; cleanup
    if obj_valid(other_index) then obj_destroy, other_index
    
    return, 1

END    

;+
; Takes a file named *.fits and returns a string equal to *.index
; @param fits_name {in}{required}{type=string} fits file name
; @returns name of the file passed in, with extension changed to index
;-
FUNCTION IO_SDFITS::get_index_name_from_fits_name, fits_name
    compile_opt idl2, hidden

    parts=strsplit(fits_name,'.',/extract)
    index_file = strjoin(parts[0:n_elements(parts)-2],'.')+'.index'
    return, index_file

END    

;+
; Sets a flagging rule for a given scan(s) along with other options
; according to the current flagging version.
; With the current version, the flagging options include:
; intnum, fdnum, plnum, ifnum, bchan, echan, and idstring.
; @param scan {in}{required}{type=long} scan or scans to be flagged.
;-
PRO IO_SDFITS::set_flag, scan, _EXTRA=ex
    compile_opt idl2, hidden

    if not self->check_flag_param_syntax(_EXTRA=ex) then begin
        message, "Could not set flag.",/info
        return
    endif

    scan = self->get_scans_in_index(scan, cnt)
    if cnt eq 0 then begin
        message, "Could not set flag.",/info
        return
    endif
    
    if not self.flags->check_channels_range(_EXTRA=ex) then begin
        message, "Could not set flag.",/info
        return
    endif

    files = self->get_flag_file_names(count, scan=scan) ;, _EXTRA=ex)

    if count ne 0 then begin
        ; for each file, set the flags
        for i=0,n_elements(files)-1 do begin
            self.flags->set_flag, files[i], scan, _EXTRA=ex
        endfor
    endif

END

;+
; Sets a flagging rule for a given record number(s) along with other options
; according to the current flagging version.
; With the current version, the flagging options include:
; bchan, echan, and idstring.
; @param recnum {in}{required}{type=long} recnum or recnums to be flagged.
;-
PRO IO_SDFITS::set_flag_rec, recnum, _EXTRA=ex 
    compile_opt idl2, hidden

    if not self->check_flag_param_syntax(_EXTRA=ex) then begin
        message, "Could not set flag.",/info
        return
    endif

    recnum = self->get_recnums_in_index(recnum, cnt)
    if cnt eq 0 then begin
        message, "Could not set flag.",/info
        return
    endif
    
    if not self.flags->check_channels_range(_EXTRA=ex) then begin
        message, "Could not set flag.",/info
        return
    endif

    files = self->get_flag_file_names(count, recnum=recnum)

    if count ne 0 then begin
        ; for each file, set the flags
        for i=0,n_elements(files)-1 do begin
            self.flags->set_flag_rec, files[i], recnum, _EXTRA=ex
        endfor
    endif

END


;+
; Given a set of scan numbers, returns which scans can currently
; be found in the index file.
; @param scans {in}{required}{type=long} scan num(s) to search for
; @param count {out}{optional}{type=long} the num of scans found in index
; @keyword quiet {in}{optional}{type=bool} inform the user when scan is missing?
; @returns an array of the scans that were found in the index file.
;-
FUNCTION IO_SDFITS::get_scans_in_index, scans, count, quiet=quiet
    compile_opt idl2, hidden
    
    count = 0
    for i=0,n_elements(scans)-1 do begin
        row_info = self.index->search_for_row_info(scan=scans[i])
        if size(row_info,/dim) ne 0 then begin
            if count eq 0 then index_scans=scans[i] else $
                index_scans=[index_scans,scans[i]]
            count += 1
        endif else begin
            if keyword_set(quiet) eq 0 then begin
                message, "Scan not found: " + strtrim(scans[i],2),/info
            endif
        endelse    
    endfor
    if count eq 0 then return, 1 else return, index_scans
    
END

;+
; Given a set of record numbers, returns which records can currently
; be found in the index file.
; @param recnums {in}{required}{type=long} record num(s) to search for
; @param count {out}{optional}{type=long} the num of records found in index
; @keyword quiet {in}{optional}{type=bool} inform the user when rec is missing?
; @returns an array of the recs that were found in the index file.
;-
FUNCTION IO_SDFITS::get_recnums_in_index, recnums, count, quiet=quiet
    compile_opt idl2, hidden
    
    count = 0
    for i=0,n_elements(recnums)-1 do begin
        row_info = self.index->search_for_row_info(index=recnums[i])
        if size(row_info,/dim) ne 0 then begin
            if count eq 0 then index_recnums=recnums[i] else $
                index_recnums=[index_recnums,recnums[i]]
            count += 1
        endif else begin
            if keyword_set(quiet) eq 0 then begin
                message, "Recnum not found: "+string(recnums[i]),/info
            endif
        endelse    
    endfor
    if count eq 0 then return, 1 else return, index_recnums
    
END

;+
; When certain spectra are being flagged, which flag files need to be used?
; This can be determined by finding in which fits file the record and scan
; numbers being flagged reside.
; @param count {out}{optional}{type=long} number of flag files found
; @keyword recnum {in}{optional}{type=long} record number(s) to look for
; @keyword scan {in}{optional}{type=long} scan number(s) to look for
; @returns arrary of flag file names.
;-
FUNCTION IO_SDFITS::get_flag_file_names, count, recnum=recnum, scan=scan ;, intnum=intnum
    compile_opt idl2, hidden
    
    ; which fits files in the index actually contain spectra that match our criteria?
    row_info = self.index->search_for_row_info(index=recnum, scan=scan) ;, int=intnum)
    if size(row_info,/dim) eq 0 then begin
        message, "Search for data to flag failed.",/info
        count = 0
        return, -1
    endif
    all_files = row_info.file
    files = all_files[uniq(all_files,sort(all_files))]
    count = n_elements(files)

    return, files

END

;+
; For printing flag files' contents
;-
PRO IO_SDFITS::list_flags, _EXTRA=ex
    compile_opt idl2, hidden

    self.flags->list, _EXTRA=ex

END    

;+
; Prints all unique IDSTRINGS in flag files
;-
PRO IO_SDFITS::list_flag_ids
    compile_opt idl2, hidden

    self.flags->list_ids

END

;+
; Returns contents of all flag files
; idstring keyword allows retrieving only specific IDSTRINGs
; @param count {out}{optional}{type=long} number of lines returned
; @returns string array representing contents of all flag files
;-
FUNCTION IO_SDFITS::get_flag_lines, count, _EXTRA=ex
    compile_opt idl2, hidden

    return, self.flags->get_index_value_lines(count, _EXTRA=ex)

END    

;+
; Removes the flag(s) associated with the id passed in.  If the id passe in is 
; a string, then this is an IDSTRING, and whatever flags using this IDSTRING are
; removed.  If id passed in is an integer, then this is a unique ID, and only
; one flag is removed.
; @param id {in}{required}{type=string,long} ID or IDSTRING of flag to
; remove.
; @keyword all {in}{optional}{type=boolean} When set, unflag all IDs.
; @keyword quiet {in}{optopnal}{type=boolean} When set, suppress the
; warning message when the requested ID was not found.
; Any value of ID is ignored.
;-
PRO IO_SDFITS::unflag, id, all=all, quiet=quiet
    compile_opt idl2, hidden

    self.flags->unflag, id, all=all, quiet=quiet

END    

;+
; Finds where multiple values occur in an array.
; @param search_arr {in}{required} array to be searched
; @param values {in}{required} the values to search array for
; @param total_count {out}{optional}{type=long} the total number of times each value is found in the search array
; @returns the indicies showing where the values were found in the search array.
;-
FUNCTION IO_SDFITS::find_exact_matches, search_arr, values, total_count
    compile_opt idl2

    total_count = 0
    count = 0
    for i=0, (n_elements(values)-1) do begin
        value = values[i]
        temp_inds = where(search_arr eq value, count)
        if (count ne 0) then begin
            if (n_elements(indicies) eq 0) then indicies = temp_inds else indicies = [indicies,temp_inds]
            total_count = total_count + count
        endif
    endfor

    if (total_count eq 0) then indicies = -1

    return, indicies

END


;+
; Used for making a search in an array and ANDing the results with previous searches
; @examples
; <pre>
; >a = [1,2,3,4]
; >b = ['dog','cat','mouse','moose']
; >;init the search results
; >and_result = [0,1,2,3]
; >io->find_values_plus_and,a,'1:',and_result
; >print,and_result
; >[1,2,3]
; >io->find_values_plus_and,b,'dog,mo*',and_result
; >print,and_result
; >[2,3]
; </pre>
; @private
;-
PRO IO_SDFITS::find_values_plus_and, array, values, and_result
    compile_opt idl2

    if n_elements(and_result) eq 1 then begin
        if and_result eq -1 then return
    endif

    values_result = self->find_exact_matches(array[and_result], values, status)
     if n_elements(values_result) eq 1 then begin
        if values_result eq -1 then begin
            and_result = -1
        endif else begin
            and_result = and_result[values_result]
        endelse
    endif else begin
        and_result = and_result[values_result]
    endelse

END

;+
; For a given flag structure, determines which of the given data containers' this 
; flag applies to.  This is done by checking the flags contents against the data
; containers' scan_number, integration, polarization_num, feed_num, and if_number
; fields.
; @param dcs {in}{required}{type=data container array} data containers to check
; @param flag {in}{required}{type=flag structure} structure representing a line in a flag file
; @param count {out}{optional}{type=long} number of data containers that the flag applies to
; @returns indicies of the data containers that the flag applies to, -1 if none.
;-
FUNCTION IO_SDFITS::find_flagged_data, dcs, flag, count
    compile_opt idl2, hidden

    result = lindgen(n_elements(dcs))

    if flag.scan eq '*' and flag.intnum eq '*' then begin
        count = 0
        return, -1
    endif

    result = self->find_flagged_data_field(dcs.scan_number, flag, "scan", result)
    result = self->find_flagged_data_field(dcs.integration, flag, "intnum", result)
    result = self->find_flagged_data_field(dcs.polarization_num, flag, "plnum", result)
    result = self->find_flagged_data_field(dcs.feed_num, flag, "fdnum", result)
    result = self->find_flagged_data_field(dcs.if_number, flag, "ifnum", result)

    if n_elements(result) eq 1 then begin
        if result eq -1 then count=0 else count=1
    endif else begin
        count = n_elements(result)
    endelse

    return, result

END

;+
; Looks for matches between a given array of values, and a field in a given 
; flagging structure.  The flag structure holds strings, which magy need to
; be converted to integer arrays before the search can be done.
; @param data_field {in}{required}{type=array} array to be searched
; @param flag_strct {in}{required}{type=flag structure} flag  structure
; @param flag_field_name {in}{required}{type=string} the name of the field in the flag structure whose value will be matched in the search array
; @returns the indicies where the flag structure's field appears in the search array
;-
FUNCTION IO_SDFITS::find_flagged_data_field, data_field, flag_strct, flag_field_name, result
    compile_opt idl2, hidden

    ; check to make sure that the flag structure contains the flag field name
    flag_field_name = strupcase(flag_field_name)
    tags = tag_names(flag_strct)
    ind = where(tags eq flag_field_name, count)
    if count eq 0 then begin
        return, result
    endif else begin
        flag_field = flag_strct.(ind)
    endelse
    
    if flag_field eq "*" then begin
        return, result
    endif else begin
        flag_field_ints = self.flags->get_int_array_from_flag_string(flag_field)
        self->find_values_plus_and,data_field, flag_field_ints, result
        return, result
    endelse

END

;+
; Once it has been determined which flags apply to which data containers, this
; method actually blanks the data containers data, using the bchan and echan
; fields.
; @param dcs {in}{required}{type=data container array} array of data contianers to be flagged by single flag
; @param flag {in}{required}{type=flag structure} structure representing a line in a flag file
;-
PRO IO_SDFITS::flag_data, dcs, flag
    compile_opt idl2, hidden

    for i=0,n_elements(dcs)-1 do begin
        dc = dcs[i]
        len = n_elements(*dc.data_ptr)

        ; channels can cover multiple ranges
        uses_range = strpos(flag.bchan,",")
        
        if uses_range eq -1 then begin

            if flag.bchan eq '*' then begin 
                bchan=0
            endif else begin
                bchan=long(flag.bchan)
                if bchan gt len then bchan = len-1
                if bchan lt 0 then bchan = 0
            endelse
    
            if flag.echan eq '*' then begin
                echan=len-1 
            endif else begin
                echan=long(flag.echan)
                if echan gt len then echan = len-1
                if echan lt 0 then echan = 0
            endelse
    
            if bchan gt echan then begin
                tmp = echan
                echan = bchan
                bchan = tmp
            endif
            
            ; finally, blank the data
            (*dc.data_ptr)[bchan:echan] = !values.f_nan 
            
        endif else begin

            ; the channels are given in multiple ranges
            branges = strsplit(flag.bchan,",",/extract)
            eranges = strsplit(flag.echan,",",/extract)
            
            ; assume the beginnings and ending arrays are of same length
            for j=0,n_elements(branges)-1 do begin
            
                bchan = long(branges[j])    
                echan = long(eranges[j])    
                
                if bchan gt echan then begin
                    tmp = echan
                    echan = bchan
                    bchan = tmp
                endif
                if bchan lt 0 then bchan = 0
                if bchan ge len then bchan = (len-1)
                if echan lt 0 then echan = 0
                if echan ge len then echan = (len-1)
                
                ; finally, blank the data
                (*dc.data_ptr)[bchan:echan] = !values.f_nan 
                
            endfor ; each channel range
            
        endelse ; uses range or not

    endfor ; each data container

 END

;+
; Find if the specific scan has been flagged at all.
;
; @param scan {in}{required}{integer} Scan number to check.
; @keyword idstring {in}{optional}{string}{default all ids} If given,
; only find if the scan has been flagged with that idstring.
; @returns 1 if it has been flagged in some way, otherwise 0.
;-
FUNCTION IO_SDFITS::IS_SCAN_FLAGGED, scan, idstring=idstring
  compile_opt idl2

  ; if we're online, read in the latest index rows into memory
  if self.online then self->update

  flags = self.flags->get_flag_strcts(count,indxRec,useflag=idstring)
  if count eq 0 then return, 0

  scanRec = -1

  ; record flagging is expensive to check
  for j=0,n_elements(indxRec)-1 do begin
     if indxRec[j] ne '*' then begin
        ; there is actually something there to expand
        recnums = decompress_ints(indxRec[j])
        if scanRec[0] eq -1 then begin
           ; get indices for this scan
           indx = self->get_index_values('index')
           allScans = self->get_index_values('scan')
           wScan = where(allScans eq scan, count)
           ; if that scan isn't found, it can't be flagged, give up
           ; could give up completely here, but check specific scan
           ; content of the flags themselves - might be confusing otherwise
           if count eq 0 then break
           scanRec = indx[wScan]
        endif
        ; combine the scan records with the flag records
        result = lindgen(n_elements(scanRec))
        self->find_values_plus_and, scanRec, recnums, result
        if result[0] ne -1 then begin
           ; this scan is flagged, can stop now
           return, 1
        endif
     endif
  end

  ; check for this scan
  for j=0,n_elements(flags)-1 do begin
     if flags[j].scan ne '*' then begin
        flaggedScans = decompress_ints(flags[j].scan)
        w = where(flaggedScans eq scan,count)
        if count gt 0 then begin
           ; it is flagged
           return, 1
        endif
     endif
  end
  return,0
END

;+
; Get the named columns as a set of vectors in a structure from
; the associated data file(s) using any supplied selection criteria.
;
; @param columns {in}{required}{type=string array} The list of columns
; to fetch.  Column names are not the same as the names found in the
; data container.  The column name must match the name as found in the
; associated FITS file(s) (including case).
; There will be a field named "missing" that will list any missing columns. 
; @keyword _EXTRA {in}{optional}{type=structure} see <a href="line_index__define.html">search_for_row_info</a> for more info 
; @returns structure - one field for each requested column.  Returns
; -1 on any errors.
;-
FUNCTION IO_SDFITS::get_columns, columns, _EXTRA=ex
  compile_opt idl2

  if n_elements(columns) eq 0 then begin
     message,'columns is required',level=-1,/info
     return,-1
  endif

  if n_elements(columns) le 0 then begin
     message,'columns must contain at least one named column',level=-1,/info
     return,-1
  endif

  if size(columns,/type) ne 7 then begin
     message,'columns must be a string or array of strings',level=-1,/info
     return,-1
  endif

  if self.index->validate_search_keywords(ex) eq 0 then begin
     message,'invalid selection keywords',level=-1,/info
     return, -1
  endif

  ; if we're online, read the latex index rows into memory
  if self.online then self->update

  ; find the files,extensions, and rows that match the specified criteria
  row_info = self.index->search_for_row_info(indicies, _EXTRA=ex)
    
  if (size(row_info,/dimension) eq 0) then begin
     if row_info eq -1 then begin
        count = 0
        print,'nothing there'
        return, -1
     endif
  endif

  ; group rows found in index file by filename and extension
  groups = self->group_row_info(row_info)

  ; construct outline of the structure
  nrows = n_elements(indicies)
  result = -1
  missingCols = -1
    
                                ; must read each extension seperately
                                ; because they may contain varying
                                ; data sizes
  startRow = 0
  actualCols = -1
  for i = 0, n_elements(groups)-1 do begin
     ; open the appropriate file
     thisGroup = groups[i]
     ext = thisGroup.extension
     thisFits = self->get_fits(thisGroup.file)
     thisFitsPath = thisFits->get_full_file_name()
     errmsg = ""
     fxbopen, fun, thisFitsPath, ext, hdr, /no_tdim, errmsg=errmsg
     if errmsg ne '' then begin
        ; some error, give up and return as if everything is missing
        self->free_group_row_info, groups
        return,create_struct('missing',columns)
     endif
     if size(actualCols,/type) ne 7 then begin
                                ; columns with "_" may need to be seen as "-" if not found
        for j=0, n_elements(columns)-1 do begin
           thisCol = columns[j]
           actualCol = thisCol
           undPos = strpos(thisCol,'_')
           if undPos ge 0 then begin
              if fxbcolnum(fun,thisCol,errmsg=errmsg) le 0 then begin
                 while undPos ge 0 do begin
                    strput,thisCol,'-',undPos
                    undPos = strpos(thisCol,'_')
                 endwhile
                 if fxbcolnum(fun,thisCol,errmsg=errmsg) gt 0 then begin
                    actualCol = thisCol
                 endif
              endif
           endif
           if j eq 0 then begin
              actualCols = [actualCol]
           endif else begin
              actualCols = [actualCols,actualCol]
           endelse
        endfor
     endif
     theseRows = *(thisGroup.rows)
     minRow = min(theseRows)
     maxRow = max(theseRows)
     warnmsg = ""
     status = -1
     fxbreadm, fun, actualCols, row=[minRow+1,maxRow+1], pass_method='pointer', pointers=pntrs, errmsg=errmsg, warnmsg=warnmsg, status=status
     ; in any event, done reading, can close
     fxbclose, fun
     if errmsg ne '' then begin
                                ; some fatal error, give up and return
                                ; as if everything is missing
        self->free_group_row_info, groups
        ptr_free, pntrs
        return,create_struct('missing',columns)
     endif
     rowOffsets = theseRows-minRow
     if size(result,/type) ne 8 then begin
                                ; construct structure using existing
                                ; type info of returned rows
        for j = 0, n_elements(columns)-1 do begin
           thisCol = columns[j]
           if status[j] eq 1 then begin
                                ; this column exists
              thisPtr = pntrs[j]
              colVal = (*thisPtr)[0]
              colArray = make_array(nrows,value=colVal[0])
              if size(result,/type) ne 8 then begin
                 ; first field
                 result = create_struct(thisCol,colArray)
              endif else begin
                 result = create_struct(thisCol,colArray, result)
              endelse
           endif else begin
                                ; this column is missing - also
                                ; accompanied by a warnmsg,
                                ; which we're ignoring.
              if size(missingCols,/type) ne 7 then begin
                 ; first example
                 missingCols = [thisCol]
              endif else begin
                 missingCols = [missingCols,thisCol]
              endelse
           endelse
        endfor
                                ; the case for all columns not being
                                ; found generates an errmsg and is
                                ; caught above
        resultCols = tag_names(result)
     endif
     nNewRows = n_elements(theseRows)
     endRow = startRow + nNewRows - 1
     for j=0, n_elements(columns)-1 do begin
        if status[j] eq 1 then begin
           thisPtr = pntrs[j]
           if n_elements(rowOffsets) eq (maxRow-minRow+1) then begin
              theseValues = (*thisPtr)
           endif else begin
              theseValues = (*(thisPtr))[rowOffsets]
           endelse
           thisCol = columns[j]
           colIndx = where(resultCols eq thisCol)
           resultVal = result.(colIndx)
           resultVal[startRow:endRow] = theseValues
           result.(colIndx) = resultVal
        endif
        ;  else it's missing columns   
     endfor
     startRow = startRow + nNewRows
     ; delete the returned ptrs from fxbreadm
     ptr_free, pntrs
  endfor
  ; add in the 'missing' field
  result = create_struct('missing',missingCols,result)
  self->free_group_row_info, groups
  return,result
end

;+
; For finding what data containers have been flagged via record number.
; Finds matches between a given array of index record numbers, and a string containing
; a compressed list of index numbers.
; @param indicies {in}{required}{type=long} array of index record numbers
; @param recnum_string {in}{required}{type=string} compressed list of index record numbers to match against search array
; @param count {out}{optional}{type=long} number of matches found
; @returns the indicies where a record number in the compressed string is found in the search array
;-
FUNCTION IO_SDFITS::find_flagged_index_data, indicies, recnum_string, count
    compile_opt idl2, hidden

    ; if the record number was not used, nothing to search for
    if recnum_string eq '*' then begin
        count = 0
        return, -1
    endif

    ; convert the string passed into an integer array of record numbers
    recnums = decompress_ints(recnum_string) 

    ; search for matches 
    result = lindgen(n_elements(indicies))
    self->find_values_plus_and, indicies, recnums, result
    if n_elements(result) eq 1 then begin
        if result eq -1 then count=0 else count=1
    endif else begin
        count = n_elements(result)
    endelse
    
    return, result
    
END

;+
; For testing purposes only.  Allows overriding of flag format to use
;-
PRO IO_SDFITS::set_flag_file_version, version_num, version_class
    compile_opt idl2, hidden
    if obj_valid(self.flags) then self.flags->set_flag_file_version, version_num, version_class
END

;+
; Checks a given value against a given type
; @param value {in}{required} value to be checked
; @param type {in}{required}{type=string} type
; @param name {in}{required}{type=string} name of the keyword being checked.
; @keyword quiet {in}{optional}{type=bool} quiet on errors?
; @returns 0 - not valid, 1 - valid
;-
FUNCTION IO_SDFITS::validate_param_value_type, value, type, name, quiet=quiet
    compile_opt idl2, hidden

    value_type = size(value, /type)
    valid = 1
 
    case type of
        "string": if value_type ne 7 then valid = 0 
        "integer": if value_type ne 2 and value_type ne 3 then valid = 0
        "float": if value_type ne 4 and value_type ne 5 then valid = 0
        "scalar_integer": if (value_type ne 2 and value_type ne 3) or n_elements(value) ne 1 then valid = 0
    endcase  

    if valid then begin
        return, 1
    endif else begin
        if keyword_set(quiet) eq 0 then print, name+" must be of type "+type
        return, 0
    endelse    
    
END

;+
; Checks to make sure that the given value is one of the given types.  If its
; a string, it also makes sure that is is in the correct form.  This is used
; to make sure that keywords for index searches and flagging commands are
; correctly used.
; @param value {in}{required} value to be checked
; @param types {in}{required}{type=string} comma separated types
; @param name {in}{required}{type=string} name of the keyword being checked.
; @keyword quiet {in}{optional}{type=bool} quiet on errors?
; @returns 0 - not valid, 1 - valid
;-
FUNCTION IO_SDFITS::validate_param_value_types, value, types, name, quiet=quiet
    compile_opt idl2, hidden

    one_valid = 0
    value_type = size(value, /type)
    type_elements = strsplit(types,",",/extract) 
    for i=0,n_elements(type_elements)-1 do begin
        valid = self->validate_param_value_type(value,type_elements[i],name,/quiet)
        if valid then one_valid = 1
    endfor
    if one_valid ne 1 then begin
        if keyword_set(quiet) eq 0 then $
            print, name+" must be of one of the following types: ", types
        return, 0
    endif
    if value_type eq 7 then begin
        if not self->validate_string_value(value, types, /quiet) then begin
            if keyword_set(quiet) eq 0 then $
                print, name+" does not contain a valid search range: ", value
            return, 0
        endif    
    endif
    return, 1

END    

;+
; Generic method used for checking keywords used in both flagging commands and 
; index searches.  The names and types for each keyword are stored in the 2-D
; string arrays in the flag and index objects.  These arrays are passed in to
; this method, along with the keywords used (passed in as a structure).
; In this method, for each keyword used, first the keyword is checked if it's
; name is valid, and then its type and range syntax is checked.
; @param values_strct {in}{required}{type=structure} keywords passed in via inheritance
; @param param_types {in}{required}{type=string array} contains param names and their types
;-
FUNCTION IO_SDFITS::validate_param_list_types, values_strct, param_types, _EXTRA=ex
    compile_opt idl2, hidden

    ; deconstruct the parameter names and types
    ; how many params?
    sz = size(param_types)
    np = sz[2]
    param_names = param_types[0,0:np-1]
    param_types = param_types[1,0:np-1]
    for i=0,n_elements(param_names)-1 do begin
        param_names[i] = strupcase(param_names[i])
    endfor
    
    value_names = tag_names(values_strct)

    ; validate each keyword passed down
    list_valid = 1
    for i=0,n_elements(value_names)-1 do begin
        name = value_names[i]
        value = values_strct.(i)
        ;param_ind = where(param_names eq name, cnt)
        param_ind = self->get_param_index(param_names, name, cnt)
        if cnt eq 0 then begin
            if keyword_set(quiet) eq 0 then print, "Parameter not a valid name: ", name
            return, 0
        endif
        types = param_types[param_ind]
        valid = self->validate_param_value_types(value,types,name,_EXTRA=ex)
        if not valid then list_valid = 0
    endfor
        
    return, list_valid

END

;+
; Looks for a keyword passed in for such methods as index searches or
; or flag commands in the list of valid names.  A keyword shortened to
; it's most unambigious abbreviation is valid.
; @param param_names {in}{required}{type=string array} list of valid names
; @param param_name {in}{required}{type=string} parameter name, may be abbreviated
; @param count {out}{optional}{type=long} number of times name is found
; @returns the index of the keyword in the list of valid names
;-
FUNCTION IO_SDFITS::get_param_index, param_names, param_name, count
    compile_opt idl2, hidden

    for i=0,n_elements(param_names)-1 do param_names[i]=strupcase(param_names[i])
    itsparam = strtrim(strupcase(param_name),2)
    paramregex = '^' + itsparam + '.*'
    index = where(stregex(param_names,paramregex,/boolean),count)
    return, index

END


FUNCTION IO_SDFITS::check_param_syntax, param_name, value, _EXTRA=ex
    compile_opt idl2, hidden

    ;if self.index->validate_search_keywords(ex) eq 0 then begin
    ;    count = 0
    ;    return, -1
    ;endif    

    param_types = self->get_single_param_types(param_name)
    if param_types eq "" then begin
        if keyword_set(quiet) eq 0 then $
            print, param_name+" is not a valid parameter name."
        return, 0
    endif else begin    
        return,  self->validate_param_value_types(value,param_types,param_name,_EXTRA=ex)
    endelse    
    
END

FUNCTION IO_SDFITS::get_single_param_types, param_name
    compile_opt idl2, hidden
    
    param_types = self->get_index_param_types()
    ; deconstruct the parameter names and types
    ; how many params?
    sz = size(param_types)
    np = sz[2]
    param_names = param_types[0,0:np-1]
    param_types = param_types[1,0:np-1]
    for i=0,n_elements(param_names)-1 do begin
        param_names[i] = strupcase(param_names[i])
    endfor
    param_name = strupcase(param_name)

    ind = where(param_names eq param_name, cnt)
    if cnt eq 0 then begin
        return, ""
    endif

    return, param_types[ind]
    
END

;+
; All the index file columns can be searched against, using keyword arguments.
; The types of each column are stored in memory in the index object, which this
; method retrieves.  This way, the keywords used in a search can be checked
FUNCTION IO_SDFITS::get_index_param_types
    compile_opt idl2, hidden

    if obj_valid(self.index) then begin
        return, self.index->get_param_types()
    endif else begin
        return, -1
    endelse

END

;+
; Most of the keywords used in a flagging command match against the columns found
; in a flag file.  These columns, along with the CHANS and CHANWIDTH columns have
; their names and types stored in a 2-D string array in the flag object.  This
; method retrieves this info so that the keywords used with a flagging command
; can be checked for valid type and range syntax before the command progresses.
;-
FUNCTION IO_SDFITS::get_flag_param_types
    compile_opt idl2, hidden

    if obj_valid(self.flags) then begin
        return, self.flags->get_param_types()
    endif else begin
        return, -1
    endelse

END

;+
; Checks the parameters used in a flagging command 
; Checks for validity of both type and range syntax.
; First the param types for a flagging commmand are found, which are stored
; as a 2-D array in the flag object, and then these values are used to 
; check against the search parameters actually used.
; _EXTRA=ex refers to all keywords valid in a flagging command.
; @keyword quiet {in}{optional}{type=bool} wether or not to be quiet on errors
;-
FUNCTION IO_SDFITS::check_flag_param_syntax, _EXTRA=ex, quiet=quiet
    compile_opt idl2, hidden

    ; could be called with no search parameters
    if n_elements(ex) eq 0 then return, 1
    
    if n_elements(quiet) eq 0 then quiet = 0

    param_types = self->get_flag_param_types()
    result = self->validate_param_list_types(ex, param_types, quiet=quiet) 
    ; nifty trick to inherit keywords
    if 0 then self.flag->set_flag, 0, _EXTRA=ex
    return, result

END

;+
; Checks the parameters used for a search, be it for a list command, or get_* 
; method.  Checks for validity of both type and range syntax.
; First the param types for an index file search are found, which are stored
; as a 2-D array in the index object, and then these values are used to 
; check against the search parameters actually used.
; _EXTRA=ex refers to all keywords valid for a search.
; @keyword quiet {in}{optional}{type=bool} wether or not to be quiet on errors
;-
FUNCTION IO_SDFITS::check_search_param_syntax, _EXTRA=ex, quiet=quiet
    compile_opt idl2, hidden

    ; could be called with no search parameters
    if n_elements(ex) eq 0 then return, 1
    
    if n_elements(quiet) eq 0 then quiet = 0

    param_types = self->get_index_param_types()
    result = self->validate_param_list_types(ex, param_types, quiet=quiet) 
    ; nifty trick to inherit keywords
    if 0 then self.index->search_index, _EXTRA=ex
    return, result

END

;+
; Used to check the validaty of values passed into keywords used with index and
; flagging commands.  Integer and float ranges can sometimes be passed in with 
; string values, and strings themselves sometimes can use wildcards.
; @param value {in}{required}{type=string} value to be validated
; @param types {in}{required}{type=string} comma separated types
; @returns 0 - not valid, 1 - valid
;-
FUNCTION IO_SDFITS::validate_string_value, value, types, quiet=quiet
    compile_opt idl2, hidden

    case types[0] of
        "integer,string": valid = self->validate_integer_range(value)
        "float,string": valid = self->validate_float_range(value)
        "string": valid = self->validate_string_range(value)
    end
    return, valid
    
END    

;+
; Sometimes keywords that take integers can be passed in a string representing a 
; a range of integers.  This checks that the value
; passed in conforms to the correct syntax.
; @param value {in}{required}{type=string} value to be checked
; @returns 0 - does not conform to syntax, 1 - does conform
;-
FUNCTION IO_SDFITS::validate_integer_range, value
    compile_opt idl2, hidden
    
    ON_IOERROR, non_integer
    
    ; get rid of leading and trailing whitespace
    value = strtrim(value,2)
   
    ; special case
    if value eq ":" then return, 0

    ; go through each range
    ranges = strsplit(value,",",/extract)
    for i=0,n_elements(ranges)-1 do begin
        range = ranges[i]
        ; determine the type of range, and find results
        colon_pos = strpos(range,":")
        count = 0
        case colon_pos of
            0: begin ; less then
                limit = long(strmid(range,1,strlen(range)-1))
            end
            strlen(range)-1: begin ; greater then
                limit = long(strmid(range,0,strlen(range)-1))
            end
            -1: begin ; simple integer
                limit = long(range)
            end
            else: begin ; range
                limits = strsplit(range,":",/extract)
                low_limit = long(limits[0])
                up_limit = long(limits[1])
            end
        endcase    
    endfor

    return, 1
    non_integer : return, 0

END    

;+
; Sometimes keywords that take floats can be passed in a string representing a 
; float to a certain perscion, or a range of floats.  This checks that the value
; passed in conforms to the correct syntax.
; @param value {in}{required}{type=string} value to be checked
; @returns 0 - does not conform to syntax, 1 - does conform
;-
FUNCTION IO_SDFITS::validate_float_range, value
    compile_opt idl2, hidden

    ON_IOERROR, non_float

    ; get rid of leading and trailing whitespace
    value = strtrim(value,2)
    
    ; special case
    if value eq ":" then return, 0

    ; go through each range
    ranges = strsplit(value,",",/extract)
    for i=0,n_elements(ranges)-1 do begin
        range = ranges[i]
        ; determine the type of range, and find limits
        colon_pos = strpos(range,":")
        count = 0
        case colon_pos of
            0: begin ; less then
                limit = double(strmid(range,1,strlen(range)-1))
            end
            strlen(range)-1: begin ; greater then
                limit = double(strmid(range,0,strlen(range)-1))
            end
            -1: begin ; simple float - treat like a small range
                parts = strsplit(range,'.',/extract)
                base_range = double(range)
                if (n_elements(parts) eq 1) then begin
                    offset = 0.5
                endif else begin
                    precision = strlen(parts[1])
                    offset = 5.0/(10^(precision+1))
                endelse    
                low_limit = base_range - offset 
                up_limit = base_range + offset
            end
            else: begin ; range
                limits = strsplit(range,":",/extract)
                low_limit = double(limits[0])
                up_limit = double(limits[1])
            end
        endcase    
    endfor

    return, 1
    non_float : return, 0

END    

;+
; For some keywords, strings can be used with wildcards either at the begining
; or end of the string.  This makes sure that the passed in string conforms
; to this syntax
; @param values {in}{required}{type=string array} values to be checked
; @returns 0 - does not conform to syntax, 1 - does conform
;-
FUNCTION IO_SDFITS::validate_string_range, values
    compile_opt idl2

    ON_IOERROR, bad_string
    ; go through each value
    for i=0,n_elements(values)-1 do begin
        value = values[i]
        value = strtrim(value,2)
        count = 0
        ; look for a wildcard
        wildcard_pos = strpos(value,'*')
        case wildcard_pos of
            0: begin ; wildcard at begining
                ; we are now only looking for string that match with the last n chars
                search_value = strmid(value,1)
            end
            strlen(value)-1: begin ; wildcard at end
                ; we are now only looking for string that match with the first n chars
                search_value = strmid(value,0,strlen(value)-1)
            end
            else: begin
                if wildcard_pos ne -1 then begin
                    ; wildcards only allowed at beginning and end
                    return, 0
                endif    
            end    
        endcase    
    endfor

    return, 1 
    bad_string : return, 0

END

;+
; Retrieves the last record, or index number to be retrieved from a get_* method
; @returns last record member variable
;-
FUNCTION IO_SDFITS::get_last_record
    compile_opt idl2
    
    return, self.last_record

 END

;+
; Get access to the associated flags object
;-
FUNCTION IO_SDFITS::get_flags_obj
  compile_opt idl2

  return, self.flags
END

;+
; Debugging function to explore the FLAG state
;-
PRO IO_SDFITS::flags_show_state
  compile_opt idl2

  print,"IO_SDFITS flag state, FITS files and associated FLAG file"
  files = self->get_fits_file_names()
  if size(files,/type) ne 7 then begin
     print,"no valid FITS files yet"
     return
  endif
  for i=0,n_elements(files)-1 do begin
     print,"   ", files[i], " --> ", self.flags->fits_filename_to_flag_filename(files[i])
  endfor
  print,"END IO_SDFITS flag state"
  self.flags->show_state
END

