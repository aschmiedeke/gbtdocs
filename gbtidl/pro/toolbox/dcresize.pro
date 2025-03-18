;+
; Change the size of an existing data container.
;
; <p>If new channels are added to the end of an existing data
; container, they are filled with the blanked value (not a number,
; NAN) unless the /zero flag is set (in which case they are replaced
; with zeros).  If /beginning is set then the extra channels are added
; to the beginning of the data and reference_channel value is adjust
; accordingly.
;
; <p>This only works for spectrum data containers where the x-axis is
; linear in frequency and so the x-axis values are always
; well-determined when extending a spectrum data container.
;
; @param dc {in}{out}{required}{type=data container} The data
; container to resize.
; @param newsize {in}{required}{type=integer} The new number of
; channels.  This must be > 0.
; @keyword zero {in}{optional}{type=boolean} If set, any new channels
; are filled with zero instead of NAN.
;
; @examples
; <pre>
;    ; double the size of dc, new channels are filled with NAN
;    nels = data_valid(dc)
;    dcresize,dc,nels*2
;    ; back to its original size
;    dcresize,dc,nels
;    ; add 100 channels, fill with 0.0
;    dcresize,dc,(nels+100),/zero
;    ; to use this, or any toolbox function, on a DC in the !g
;    ; structure, do this
;    dc = !g.s[0]
;    nels = data_valid(dc)
;    dcresizse,dc,nels+200
; @version $Id$
;-
pro dcresize,dc,newsize,zero=zero,beginning=beginning
    compile_opt idl2

    if n_params() ne 2 then begin
        usage,'dcresize'
        return
    endif

    nels = data_valid(dc,name=name)
    if name ne "SPECTRUM_STRUCT" then begin
        message,"resize only works with spectrum data containers",/info
        return
    endif

    if nels le 0 then begin
        message,'dc is empty or invalid, can not continue',/info
        return
    endif

    thisNewsize = round(newsize)
    if thisNewsize le 0 then begin
        message,'newsize must be > 0',/info
        return
    endif

    if thisNewsize eq nels then return

    if thisNewsize lt nels then begin
        *dc.data_ptr = (*dc.data_ptr)[0:(thisNewsize-1)]
    endif else begin
        newvalue = !values.f_nan
        if keyword_set(zero) then newvalue = 0.0
        newchans = make_array(thisNewsize - nels, /float, value=newvalue)
        if keyword_set(beginning) then begin
            *dc.data_ptr = [newchans, *dc.data_ptr]
            dc.reference_channel = dc.reference_channel + n_elements(newchans)
        endif else begin
            *dc.data_ptr = [*dc.data_ptr, newchans]
        endelse
    endelse
    return
end
