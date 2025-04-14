; docformat = 'rst' 

;+
; Check if a file name exists. Return 1 if it does, 0 if it doesn't.
; Also return the fully qualified name where the file was found.
;
; If keyword dir is supplied then search through all of the directories
; in the string array dir. In this case filename should not contain a 
; directory path.
;   
; This routine is handy to search for the location of an online datafile.
; They start in /share/olcor/ but get moved to /proj/projid/ directories
; at some later point.
;
; NOTE: this routine will only find regular files, a
; directory name will return a non-existant file.
;
; This code came from `Phil Perillat <http://www.naic.edu/~phil/>`_
; at Arecibo.
; Local changes:
; 
; * modify this documentation for use by idldoc.
; 
; :Params:
;   filename : in, required, type=string
;       filename to search for
;
;   fullname : out, optional, type=string
;       full directory/filename where file was found.
;
; :Keywords:
;   dir : in, optional, type=string
;       If supplied then search through these directories. May be a vector.
;
; size : in, out, optional
;       If supplied then set this to the file size in bytes, if it exists.
;
; :Returns:
;   1 file found, 0 not found
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       istat=file_exists('/share/olcor/corfile.13aug02.x101.1',fullname)
;
;       dir=['/share/olcor/','/proj/x101cor/']
;       istat=file_exists('corfile.13aug02.x101.1',fullname,dir=dir)
;
;-
function file_exists,filename,fullname,dir=dir,size=size

    ndir=n_elements(dir)
    fullname=''
    if strtrim(filename) eq '' then return,0
    if (ndir eq 0) or (not keyword_set(dir)) then begin
;        ffile=(findfile(filename))[0]
;        if ffile ne '' then begin 
;            fullname=filename
;            goto,gotit
;        endif
        if file_test(filename)  then begin 
            fullname=filename
            goto,gotit
        endif
    endif else begin
        for i=0,n_elements(dir)-1 do begin
            dirl=dir[i]
            if strmid(dirl,0,1,/reverse_offset) ne '/' then dirl=dirl+'/'
            ; ffile=(findfile(dirl+filename))[0]
            if file_test(dirl+filename) then begin  &$
               fullname=dirl+filename
               goto,gotit
            endif
        endfor
    endelse
    return,0
gotit:
    if arg_present(size) then begin
        size=0l
        openr,lun,fullname,/get_lun,error=ioerr
        if ioerr ne 0 then begin
            size=-1L
        endif else begin
            f=fstat(lun)
            free_lun,lun
            size=f.size
        endelse
    endif
    return,1
end
