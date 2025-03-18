;+
; Specify a directory from which data will be read.  Compare to
; filein, which identifies a single file as the input source.
;
; <p>When dirin is used, data can be retrieved from any of the
; SDFITS files in that dir without the need to issue a new filein
; command. 
;
; <p>In line mode, this sets the line input data directory, in
; continuum mode, this sets the continuum input data directory.  Both
; directories can be opened at the same time and the mode (line or
; continuum) determines where data is retrieved from (e.g. get).  Only
; one line and one continuum data source (single file or single
; directory) can be opened at the same time.  Use of dirin or filein
; always first closes any previously opened line or continuum data
; source before opening a new one.
;
; <p>The opened input file or directory name is stored in
; !g.line_filein_name (line mode) or !g.cont_filein_name (continuum
; mode).
;
; @param dir_name {in}{optional}{type=string} The directory name to
; use.  If omitted, a file selector GUI will appear and you can select
; the directory to use.  You must select a directory in that case.  If
; the dir_name isn't a directory, the underlying code will recognize
; that and it will be as if you had used
; <a href="filein.html">filein</a> instead.
;
; @keyword new_index {in}{optional}{type=boolean} When set, a new
; index is generated, whether it needed to be or not.  By
; default, the io code tries to re-use an existing index unless it is
; seen to be out of date.  Regenerating the index file can take some
; time, but no information should be lost in the process.  Usually,
; the io code can be trusted to regenerate the index file only when
; necessary.
;
; @examples
; <pre>
;   dirin            ; Use a GUI to select the directory
;   cont             ; switch to continuum mode
;   dirin,'mydcr'    ; open up all FITS files in a specific directory
; </pre>
;
; @uses <a href="../../devel/guide/sdfitsin.html">sdfitsin</a>
;
; @version $Id$
;-
pro dirin, dir_name, new_index=new_index
    if (!g.line) then begin
        new_io = sdfitsin(dir_name,/directory,new_index=new_index)
        if (obj_valid(new_io)) then begin
            if (obj_valid(!g.lineio)) then obj_destroy, !g.lineio
            !g.lineio = new_io
            !g.line_filein_name = dir_name
        endif
    endif else begin
        new_io = sdfitsin(dir_name,/directory,/continuum,new_index=new_index)
        if (obj_valid(new_io)) then begin
            if (obj_valid(!g.contio)) then obj_destroy, !g.contio
            !g.contio = new_io
            !g.cont_filein_name = dir_name
        endif
    endelse
end
