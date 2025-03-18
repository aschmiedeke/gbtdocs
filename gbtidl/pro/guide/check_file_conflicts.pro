;+
; Performs checking of the filenames in the 
; the guide structure, !g.  Called by filein, dirin, and fileout.
; 
; Files selected for input cannot be used as output, and vice versa.
;
; @param files {in}{required}{type=array} array of file names
;
; @keyword in {in}{optional}{type=boolean} the filenames are ment for input
; @keyword out {in}{optional}{type=boolean} the filename is ment for output
;
; @returns 0, 1
;
; @private_file
;-
function check_file_conflicts, files, in=in, out=out
    compile_opt idl2

    if n_elements(files) eq 0 then  message, "must pass name of file(s) to check"
    if keyword_set(in) and keyword_set(out) then message, "file(s) must be ment for either input OR output - cannot set both keywords"

    if not keyword_set(in) and not keyword_set(out) then $
        message, "Must specifiy in or out keyword"
        
    if keyword_set(out) then begin
        ; this file is ment for output
        ; only one file name can be used to specify output
        if n_elements(files) gt 1 then $
            message, "Only one filename can be specified for output"

        ; make sure that this file is not in the list of files used for input
        ; is the input a file or a directory?
        info = file_info(!g.line_filein_name)
        if info.directory then begin
            last_char = strmid(!g.line_filein_name,strlen(!g.line_filein_name)-1,1)
            if last_char eq "/" then begin 
                path = !g.line_filein_name + "*.fits"
            endif else begin    
                path = !g.line_filein_name + "/*.fits"
            endelse    
            in_files = file_search(path)
        endif else begin
            in_files = strarr(1)
            in_files[0] = !g.line_filein_name
        endelse

        for i=0,n_elements(in_files)-1 do begin
            if files eq in_files[i] then begin
                print, "Conflict found; File for output: ",files," is same as file for input: ",in_files[i]
                return, 0
            endif
        endfor  
    endif else begin
        ; this file is meant for input
        ; is the input a file or a directory?
        info = file_info(files)
        if info.directory then begin
            last_char = strmid(files,strlen(files)-1,1)
            if last_char eq "/" then begin 
                path = files + "*.fits"
            endif else begin    
                path = files + "/*.fits"
            endelse    
            in_files = file_search(path)
        endif else begin
            in_files = strarr(1)
            in_files[0] = files
        endelse
        ; check the file names
        for i=0,n_elements(in_files)-1 do begin
            if !g.line_fileout_name eq in_files[i] then begin
                print, "Conflict found; File for output: ",!g.line_fileout_name," is same as file for input: ",in_files[i]
                return, 0
            endif
        endfor
    endelse
    
    return, 1

end    
