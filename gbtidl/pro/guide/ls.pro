;+
; List files (defaults to *.fits in the current directory).  This
; invokes the unix "ls" command using the pattern and optional
; arguments.  If pattern is not provide, it defaults to "*.fits".
;
; @param pattern {in}{optional}{type=string}{default='*.fits'} The
; pattern to list.
;
; @keyword options {in}{optional}{type=string}{default=''} Any arguments to
; the unix "ls" command.
;
; @examples
; <pre>
; ; show all the fits files in the current directory
; ls
; ; show all the files in the current directory
; ls,''
; ; show all the fits files in a directory relative to this one
; ls,'../mydata'
; ; do a long listing
; ls,options='-l'
; </pre>
; 
; @version $Id$
;-
pro ls, pattern, options=options
    compile_opt idl2

    cmd = 'ls '
    if (n_elements(options) ne 0) then cmd = cmd + options + ' '

    if n_elements(pattern) eq 0 then begin
        cmd = cmd + '*.fits'
    endif else begin
        cmd = cmd + pattern
    endelse

    spawn, cmd

end
