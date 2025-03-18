;+
; Interpolate across blanked channels in the primary data container
; (buffer 0) or one of the other buffers.
;
; <p>This uses the IDL INTERPOL function to replace blanked values in
; the buffer with unblanked values according to the interpolation
; method selected. 
;
; <p>You can limit the range of channels to consider using bchan and
; echan.  When not supplied, all of the channels are used.
;
; <p>The default interpolation method is linear. The other
; interpolations may not be particularly useful across large gaps.
;
; <p>If all of the data in the requested range is good (unblanked)
; then no interpolation is done and this routine silently returns
; without changing anything in dc.
;
; <p>It is an error to request more than one interpolation method.
;
; @param buffer {in}{optional}{type=integer}{default=0} The data
; container to smooth to the new resolution.  This defaults to the
; primary data container (buffer 0).
; @keyword bchan {in}{optional}{type=integer} The starting channel
; number.  If not specified, bchan=0.
; @keyword echan {in}{optional}{type=integer} The last channel number.
; If not specified use all channels from bchan to the end.
;
; @keyword linear {in}{optional}{type=boolean} When set, use the
; linear interpolation provided by INTERPOL.  This is the default
; interpolation when no other method is specified.
;
; @keyword quadratic {in}{optional}{type=boolean} When set, use the
; quadratic interpolation provided by INTERPOL.
;
; @keyword lsquadratic {in}{optional}{type=boolean} When set, use the
; lsquadratic (lest squares quadratic) interpolation provided by
; INTERPOL.
;
; @keyword spline {in}{optional}{type=boolean} When set, use the
; spline interpolation provided by INTERPOL.
;
; @examples
; <pre>
;   clip, -100.0, 100.0, /blank    ; blank bad data
;   ginterp      ; linear interpolation across the blanked regions
; </pre>
;
; @uses <a href="../toolbox/dcinterp.html">dcinterp</a>
; @uses <a href="../toolbox/show.html">show</a>
;
; @version $Id$
;-
pro ginterp, buffer, bchan=bchan, echan=echan, linear=linear, $
             quadratic=quadratic, lsquadratic=lsquadratic, $
             spline=spline
    compile_opt idl2

    if n_elements(buffer) eq 0 then thisBuffer = 0 else thisBuffer=buffer

    if !g.line then begin
        if thisBuffer lt 0 or thisBuffer gt n_elements(!g.s) then begin
            message,string((n_elements(!g.s)-1),format='("buffer must be >= 0 and <= ",i2)'),/info
            return
        endif
        thisdc = !g.s[thisBuffer] ; this only copies pointers, not values
    endif else begin
        if thisBuffer lt 0 or thisBuffer gt n_elements(!g.c) then begin
            message,string((n_elements(!g.c)-1),format='("buffer must be >= 0 and <= ",i2)'),/info
            return
        endif
        thisdc = !g.c[thisBuffer] ; this only copies pointers, not values
    endelse

    dcinterp, thisdc, bchan=bchan, echan=echan, linear=linear, quadratic=quadratic, $
              lsquadratic=lsquadratic, spline=spline, ok = ok

    if ok and thisBuffer eq 0 and not !g.frozen then show

end
