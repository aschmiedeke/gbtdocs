;+
; This procedure smooths a spectrum with a hanning filter.
;
; <p>Replaces the contents of the data being smoothed with the
; smoothed data.  Blanked data values are ignored.
;
; <p>For spectrum data containers, the frequency_resolution is set 
; using <a href="esthanres.html">esthanres</a> 
;
; @param dc {in}{required}{type=data container} data container (spectrum or continuum)
; @keyword decimate {in}{optional}{type=keyword} decimate the
; spectrum?
; @keyword ok {out}{optional}{type=boolean} Returns 1 if everything
; went ok, 0 if it did not (missing dc parameter, invalid or empty dc)
;
; @examples
; <pre>
;    get,index=1
;    a = data_new()
;    data_copy,!g.s[0],a
;    show
;    dchanning,a,/decimate
;    show,a
; </pre>
;
; @uses <a href="dcconvol.html">dcconvol</a>
; @uses <a href="dcdecimate.html">dcdecimate</a>
;
; @version $Id$
;-

pro dchanning,dc,decimate=decimate,ok=ok
    compile_opt idl2

    ok = 0
    if n_elements(dc) eq 0 then begin
        usage,'dchanning'
        return
    endif

    ; Do the smoothing first
    ; hanning kernel
    kernel = [0.25, 0.5, 0.25]
    dcconvol, dc, kernel, ok=ok, /nan, /edge_truncate, /normalize

    if tag_names(dc,/structure_name) eq 'SPECTRUM_STRUCT' then begin
        chanRes = dc.frequency_resolution / abs(dc.frequency_interval)
        chanRes = esthanres(chanRes)
        dc.frequency_resolution = chanRes * abs(dc.frequency_interval)
    endif

    ; Check for decimation

    if ok and keyword_set(decimate) then dcdecimate,dc,2
end
