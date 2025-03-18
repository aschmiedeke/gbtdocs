;+
; This procedure thins the spectrum at the primary data container (the
; PDC, buffer 0) by selecting out and keeping the data at every nth
; channel.  This can also operate on other buffers. 
;
; <p>The frequency interval and reference channel are adjusted
; appropriately so that the x-axis labels for the decimated data are
; still appropriate.
;
; <p>This can not be used on continuum data containers.
;
; @param nchan {in}{optional}{type=integer}{default=2} Thin the spectrum by
; keeping the value at every nchan channels starting from the startat
; channel   This defaults to 2.
; @keyword startat {in}{optional}{type=integer}{default=0} The
; starting channel. This defaults to 0.
; @keyword buffer {in}{optional}{type=buffer}{default=0} The buffer to
; decimate.  This defaults to buffer 0 (the PDC).
; @keyword ok {out}{optional}{type=boolean} Returns 1 if everything
; went ok, 0 if it did not (invalid or empty dc at buffer).
;
; @examples
; <pre>
;    getrec,1
;    show
;    decimate,2
;    show
;    decimate,3,startat=1
;    show
;    decimate,2,buffer=1
;    show, 1
; </pre>
;
; @uses <a href="../toolbox/dcdecimate.html">dcdecimate</a>
; @uses <a href="../plotter/show.html">show</a>
;
; @version $Id$
;-

pro decimate, nchan, startat=startat, buffer=buffer, ok=ok
    compile_opt idl2

    ok = 0
    if n_elements(nchan) eq 0 then begin
        usage,'decimate'
        return
    endif

    if n_elements(buffer) eq 0 then buffer = 0
    maxBuffer = !g.line ? n_elements(!g.s): n_elements(!g.c)
    if buffer lt 0 or buffer gt maxBuffer then begin
        message,string(maxBuffer,format="('buffer must be >= 0 and <= ',i2)"),/info
        return
    endif
    thisdc = !g.line ? !g.s[buffer] : !g.c[buffer]
    dcdecimate,thisdc,nchan,startat=startat,ok=ok
    if not ok then return

    if !g.line then begin
        !g.s[0] = thisdc        ; copy everything back
    endif else begin
        !g.c[0] = thisdc
    endelse
    
    if !g.frozen eq 0 then show
end
