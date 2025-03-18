;+
; This procedure truncates (clips) data above and below given
; intensity limits.  Data value can alternatively be blanked using the
; /blank flag. In that case, data values outside the limits are
; replaced by blanks (NaN).
;
; @param dc {in}{required}{type=data container} data container (spectrum or continuum)
; @param datamin {in}{required}{type=float} min data value
; @param datamax {in}{required}{type=float} max data value
; @keyword blank {in}{optional}{type=boolean} Replace clipped values
; with NaN instead of the clipping limit.
;
; @examples
; <pre>
;    getrec,1
;    a = data_new()
;    data_copy,!g.s[0],a
;    show
;    dcclip,a,-1.0,2.0
;    show,a
; </pre>
;
; @version $Id$
;-

pro dcclip,dc,datamin,datamax,blank=blank

    compile_opt idl2

    if (data_valid(dc) le 0) then begin
        message, "dcclip: invalid data structure",/info
        usage,'dcclip'
        return
    endif

    indexMinClip = where(*dc.data_ptr le datamin,minClipCount)
    indexMaxClip = where(*dc.data_ptr ge datamax,maxClipCount)
    if keyword_set(blank) then begin
        if minClipCount gt 0 then (*dc.data_ptr)[indexMinClip] = !values.f_nan
        if maxClipCount gt 0 then (*dc.data_ptr)[indexMaxClip] = !values.f_nan
    endif else begin
        if minClipCount gt 0 then (*dc.data_ptr)[indexMinClip] = datamin
        if maxClipCount gt 0 then (*dc.data_ptr)[indexMaxClip] = datamax
    endelse    
end
