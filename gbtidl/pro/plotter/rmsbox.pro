;+
; Overplots a box from xstart to xend, with uper and lower bounds the
; mean + sigma and mean - sigma of the yarray passed in
;
; @param xstart {in}{required}{type=long} where box starts in yarray
; @param xend {in}{required}{type=long} where box ends in yarray
; @param yarray {in}{required}{type=array} data array for rms box
; @keyword idstring {in}{optional}{type=string} An idstring to pass to
; gbtoplots to tag this box.
;
; @private_file
;-
pro rmsbox, xstart, xend, yarray, idstring=idstring
    compile_opt idl2
    
    if (n_params() ne 3) then begin
        message,'Usage: rmsbox, xstart, xend, yarray',/info
        return
    endif
    if xstart gt xend then begin
        tmp = xend
        xend = xstart
        xstart = tmp
    endif
    
    if xend lt 0 then xend = 0
    if xstart lt 0 then xstart = 0
    nchan = n_elements(yarray)
    if xend gt nchan then xend = (nchan-1)
    if xstart gt nchan then xstart = (nchan-1)

    if xstart eq xend then begin
        sigmay = yarray[xstart]
        meany = yarray[xstart]
    endif else begin
        moms = moment(yarray[xstart:xend],/nan)
        meany = moms[0]
        sigmay = sqrt(moms[1])
    endelse
    
    box = [[xstart,meany+sigmay],[xend,meany+sigmay],[xend,meany-sigmay],[xstart,meany-sigmay]]
    
    xbox = [box[0,0],box[0,1],box[0,2],box[0,3],box[0,0]]
    ybox = [box[1,0],box[1,1],box[1,2],box[1,3],box[1,0]]
    ; plot this box, starting at the top, left-hand corner and going clockwise
    gbtoplot,xbox,ybox,color=!cyan, /chan, idstring=idstring
end
