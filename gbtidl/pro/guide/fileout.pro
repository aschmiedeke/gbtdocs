; docformat = 'rst' 

;+
; Specify the file to which data will be written.
;
; The filename is stored in the ``!g.line_fileout_name`` field.  At
; startup, this is set to "GBTIDL_KEEP.fits" so that it is possible to
; save data without ever using this procedure. The output file name must
; use the ".fits" suffix.
;
; *Note:* It is currently not possible to save continuum data.
;
; :Params:
;   file_name : in, required, type=string
;       The file to which data will be written. If the file does not
;       exist, it will be created when the first spectrum is saved to 
;       this file (e.g. using :idl:pro:`keep`).
;
; :Keywords:
;   new : in, optional, type=boolean
;       When set a new output file will be created. If file_name already
;       exists, it will first be removed. If there is a problem in
;       removing that file this procedure will return without opening
;       the file_name.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       getrec,1
;       show
;       fileout,'savedfile.fits'
;       keep
;
;-
pro fileout, file_name, new=new
    compile_opt idl2
    if n_elements(file_name) eq 0 then begin
        usage,'fileout'
        return
    endif

    ; check to make sure this file isn't being used by the input object
    if not check_file_conflicts(file_name,/out) then begin
        print, "Cannot use same file for output as is used for input."
        print, "Try moving output file to a different directory."
        return
    endif  
    if (!g.line) then begin
        if (not stregex(file_name,'.*\.fits$',/boolean)) then begin
            message, 'file_name must be of the form *.fits',/info
            return
        endif
        new_io = obj_new('io_sdfits_writer')
        if (obj_valid(new_io)) then begin
            if (obj_valid(!g.lineoutio)) then obj_destroy, !g.lineoutio
            !g.lineoutio = new_io
            if (keyword_set(new) and (!g.lineoutio->file_exists(file_name) eq 1)) then begin
                ; try and remove file_name
                catch, error_status
                if (error_status ne 0) then begin
                    print, 'Problems removing ', file_name
                    print, !error_state.msg
                    return
                endif
                file_delete, file_name, /verbose
                ; try and delete the index file
                parts=strsplit(file_name,'.',/extract)
                index_file = strjoin(parts[0:n_elements(parts)-2],'.') + '.index'
                if (!g.lineoutio->file_exists(index_file) eq 1) then file_delete, index_file, /verbose
                catch, /cancel
            endif
            if (!g.lineoutio->file_exists(file_name) eq 1) then begin
                !g.lineoutio->set_file, file_name
                !g.line_fileout_name = file_name
            endif else begin
                if (strpos(file_name,'/') ne -1) then begin
                    !g.lineoutio->set_file_path, file_dirname(file_name)
                    file_base = file_basename(file_name)
                endif else begin
                    file_base = file_name
                endelse
                parts=strsplit(file_base,'.',/extract)
                index_file = strjoin(parts[0:n_elements(parts)-2],'.') + '.index'
                !g.lineoutio->set_index_file_name, index_file
                !g.lineoutio->set_output_file, file_base
                !g.line_fileout_name = file_name
            endelse
        endif
    endif else begin
        message, 'continuum data can not be saved', /info
    endelse
end
