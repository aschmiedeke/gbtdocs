;+
; Flip the data end-to-end in the indicated buffer in the global data
; containers.  
;
; <p>For line data the value of frequency_increment and reference_channel
; are also changed appropriately so that, as displayed, there will be
; no change in appearance.  This is useful if you need to combine
; (e.g. average) two data containers where the frequency increments
; have opposite signs.  
;
; <p>For continuum data (where the need to invert is less obvious), all
; of the time-dependent arrays are also flipped (utc, mjd, etc).
;
; <p>The invert is done in place. Use <a href="../toolbox/dcinvert.html">dcinvert</a> to flip a data
; container that is not one of the global data containers.
;
; <p>Note that when displayed, this will only be noticable when the
; x-axis is channels.  The velocity and frequency axes always increases
; from left to right, independent of the actual channel increment from
; low channel number to high channel number.
;
; @keyword buffer {in}{optional}{type=integer}{default=0} guide data
; container to use.  Defaults to buffer 0.
;
; @uses <a href="../toolbox/dcinvert.html">dcinvert</a>
;
; @examples
; <pre>
;   invert             ; invert buffer 0
;   invert, buffer=10  ; invert buffer 10
; </pre>
;
; @version $Id$
;-
pro invert, buffer=buffer
    compile_opt idl2

    if n_elements(buffer) eq 0 then buffer=0

    if !g.line then begin
        if buffer lt 0 or buffer gt n_elements(!g.s) then begin
            message,string(n_elements(!g.s),format='("Buffer must be between 0 and ",i2)'),/info
            return
        endif
        nch=data_valid(!g.s[buffer])
        if nch le 0 then begin
            message, 'No valid data found to invert.',/info
            return
        endif
        *!g.s[buffer].data_ptr = reverse(*!g.s[buffer].data_ptr)
        !g.s[buffer].frequency_interval = -!g.s[buffer].frequency_interval
        !g.s[buffer].reference_channel = nch - 1 - !g.s[buffer].reference_channel
    endif else begin
        if buffer lt 0 or buffer gt n_elements(!g.c) then begin
            message,string(n_elements(!g.c),format='("Buffer must be between 0 and ", i2)'),/info
            return
        endif
        nch=data_valid(!g.c[buffer])
        if nch le 0 then begin
            message, 'No valid data found to invert.',/info
            return
        endif
        *!g.c[buffer].data_ptr = reverse(*!g.c[buffer].data_ptr)
        *!g.c[buffer].date = reverse(*!g.c[buffer].date)
        *!g.c[buffer].utc = reverse(*!g.c[buffer].utc)
        *!g.c[buffer].mjd = reverse(*!g.c[buffer].mjd)
        *!g.c[buffer].longitude_axis = reverse(*!g.c[buffer].longitude_axis)
        *!g.c[buffer].latitude_axis = reverse(*!g.c[buffer].latitude_axis)
        *!g.c[buffer].lst = reverse(*!g.c[buffer].lst)
        *!g.c[buffer].azimuth = reverse(*!g.c[buffer].azimuth)
        *!g.c[buffer].elevation = reverse(*!g.c[buffer].elevation)
   endelse
   ; even though it won't appear to have changed, update the display 
   ; anyway if not frozen so that what appears there is a faithful 
   ; copy of the this data container.
    if not !g.frozen and buffer eq 0 then show
end
