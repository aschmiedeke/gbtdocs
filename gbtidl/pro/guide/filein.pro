; docformat = 'rst' 

;+
; Specify the SDFITS file from which data will be read.
;
; In line mode, this sets the line input data file, in continuum
; mode, this sets the continuum input data file.  Both files can be
; opened at the same time and the mode (line or continuum) determines
; where data is retrieved from (e.g. get).  Only one line and one
; continuum data source (single file or single directory) can be
; opened at the same time.  Use of filein or dirin always first closes
; any previously opened line or continuum data file or directory
; before opening a new one. 
;
; The opened input file or directory name is stored in
; ``!g.line_filein_name`` (line mode) or ``!g.cont_filein_name``
; (continuum mode).
;
; :Params:
;   file_name : in, optional, type=string
;       The file name to use. If omitted, a file selector GUI will 
;       appear and you can select the file to use.  You can not select
;       a directory in that case. If the file_name is a directory, the
;       underlying code will recognize that and it will be as if you
;       had used :idl:pro:`dirin` instead.
; 
; :Keywords:
;   new_index : in, optional, type=boolean
;       When set, a new index is generated, whether it needed to be
;       or not. By default, the io code tries to re-use an existing
;       index unless it is seen to be out of date.  Regenerating the 
;       index file can take some time, but no information should be
;       lost in the process.  Usually, the io code can trusted to 
;       regenerate the index file only when necessary.  
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       filein                          ; Use a GUI to select the 
;                                       ; SDFITS file to open
;       filein,'mydata.fits',/new_index ; force a new index
;
; :Uses:
;   :idl:pro:`sdfitsin`
;
;-
pro filein, file_name, new_index=new_index
    if (!g.line) then begin
        new_io = sdfitsin(file_name, new_index=new_index)
        if (obj_valid(new_io)) then begin
            if (obj_valid(!g.lineio)) then obj_destroy, !g.lineio
            !g.lineio = new_io
            !g.line_filein_name = file_name
        endif
    endif else begin
        new_io = sdfitsin(file_name, /continuum, new_index=new_index)
        if (obj_valid(new_io)) then begin
            if (obj_valid(!g.contio)) then obj_destroy, !g.contio
            !g.contio = new_io
            !g.cont_filein_name = file_name
        endif
    endelse
end
