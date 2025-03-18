; docformat = 'rst'

;+
; Create a new io_sdfits object and associate the indicated filename
; with it.
;
; If filename is a directory, the io_sdfits::set_project method is
; used and hence the contents of all sdfits files in that directory 
; will be accessible through this single io object.
;
; :Params: 
; 
;   filename : in, optional, type=string
;       If the filename is not supplied, a graphical file chooser will
;       be launched to allow the user to select one.
;
; :Keywords:
; 
;   directory : in, optional, type=boolean
;       If this keyword exists and filename was omitted, then the file
;       chooser is launched allowing the user to select a directory, 
;       otherwise a single, regular file must be selected.
;
;   continuum : in, optional, type=boolean
;       If this keyword exists then a continuum io_sdfits object will
;       be returned. Otherwise (the default), a line io_sdfits object 
;       will be returned.
;
;   new_index : in, optional, type=boolean
;       When set,, a new index is generated, whether it needed to be
;       or not. By default, the io code tries to re-use an existing 
;       index unless it is seen to be out of date.  Regenerating the 
;       index file can take some time, but no information should be 
;       lost in the process. Usually, the io code can trusted to 
;       regenerate the index file only when necessary.
;
; :Returns:
; 
;   io_sdfits : line or cntm
;       object on success or -1 on failure
;
; @private_file
;
;-
FUNCTION SDFITSIN, filename, directory=directory, continuum=continuum, new_index=new_index
    compile_opt idl2

    result = -1

    catch, error
    if (error ne 0) then begin
       catch,/cancel
       message,'Problems opening requested file.  Can not continue',/info
       ; completely reset the appropriate io
       if keyword_set(continuum) then begin
          obj_destroy,!g.contio
          !g.contio = obj_new('io_sdfits_cntm')
          !g.cont_filein_name = ''
       endif else begin
          obj_destroy, !g.lineio
          !g.lineio = obj_new('io_sdfits_line')
          !g.line_filein_name = ''
       endelse
       heap_gc
       return,-1
    endif
    catch,/cancel

    objtype = "io_sdfits_line"
    startPath = file_dirname(!g.line_filein_name)
    if (keyword_set(continuum)) then begin
       objtype = "io_sdfits_cntm"
       startPath = file_dirname(!g.cont_filein_name)
    endif

    if (n_elements(filename) eq 0) then begin
        if (keyword_set(directory)) then begin
            filename = dialog_pickfile(/must_exist,/read,/directory)
        endif else begin
            filename = dialog_pickfile(filter='*.fits',/must_exist,/read)
        endelse
        if (strlen(filename) eq 0) then return, -1
    endif else begin
        if (n_elements(filename) gt 1) then begin
            message, 'More than one filename, all but the first one will be ignored', /info
        endif
        filename = filename[0]
    endelse

    ; does it exist
    finfo = file_info(filename)
    if (not finfo.exists) then begin
        message, filename + " does not exist.", /info
        return, -1
    endif

    if (not finfo.read) then begin
        message, filename + " is unreadable.", /info
        return, -1
    endif

    if (finfo.directory) then begin
        ; check to make sure this file(s) isn't being used by the output object
        if not check_file_conflicts(filename,/in) then begin
            print, "Cannot use same file for input as is used for output."
            print, "Try moving output file to a different directory."
            return, -1
        endif   
        if file_basename(filename) eq "." then begin
            dirfile = file_expand_path(filename)
        endif else begin
            dirfile = filename
        endelse
        result = obj_new(objtype)
        result->set_project, dirfile, new_index=new_index
    endif else begin
        if (finfo.regular) then begin
            ; check to make sure this file isn't being used by the output object
            if not check_file_conflicts(filename,/in) then begin
                print, "Cannot use same file for input as is used for output."
                return, -1
            endif    
            result = obj_new(objtype)
            result->set_file, filename, status, new_index=new_index
            if status ne 1 then return, -1
        endif else begin
            message, filename + " is not a directory or regular file.", /info
        endelse
    endelse

    ; if this is in batch mode, dont use the 'more' style paging
    if !g.interactive eq 0 then begin
        result->set_more_format_off
    endif
    
    return, result
END
