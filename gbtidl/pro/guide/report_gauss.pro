;+
; Procedure for printing what the current regions and gaussians are in
; the guide structure, and the most recently reported fits for these
; gaussians. 
;
; If /fits is the only keyword set, then only the fitted parameters
; will be reported.  If /params is the only keyword set, then only the
; intiial guesses will be reported.  If both are set or neither are
; set (the default) then both initial guesses and fits are reported
; for each Gaussian.
;
; @keyword fits {in}{optional}{type=boolean} displays the fits for all
; gaussians 
; @keyword params {in}{optional}{type=boolean} displays the initial
; parameters for all gaussians
; 
; @version $Id
;-
pro report_gauss, fits=fits, params=params
    compile_opt idl2
    common gbtplot_common,mystate,xarray    

    show_fits = 0
    show_params = 0
    if keyword_set(fits) then show_fits=1
    if keyword_set(params) then show_params=1
    if (keyword_set(fits) eq 0) and (keyword_set(params) eq 0) then begin 
        show_fits=1
        show_params=1
    endif
    
    nregions = !g.gauss.nregion
    regions = !g.gauss.regions
    ngauss = !g.gauss.ngauss

    widthScale = 1.0
    centerUnit = ' (' + mystate.xunit + ')'
    if (mystate.xunit eq 'Channels') then centerUnit='(chan)'
    widthUnit = centerUnit
    if (mystate.xunit eq 'GHz') then begin
        widthScale = 1.0d+3
        widthUnit = '(MHz)'
    endif else begin
        if (mystate.xunit eq 'MHz') then begin
            widthScale = 1.0d+3
            widthUnit = '(kHz)'
        endif
    endelse
   
;    ; loop through each region
;    ; Regions are always shown
;    print, "***** Regions"
;    for i=0,nregions-1 do begin
;        print, (i+1),"[",regions[0,i],",",regions[1,i],"]",format='(6x,i3,1x,A1,i10,A1,i10,A1)'
;    endfor

    if show_params then begin
        print,"***** Initial Guesses"
        print, leftjustify(centerUnit,7), leftjustify(widthUnit,7),format='(10x,"G#",6x,"Height",7x,"Center ",A7,3x,"FWHM ",A7)'
        for i=0,ngauss-1 do begin
            params = !g.gauss.params[*,i]
            frmt = '(A5,2x,i5,2x,g10.4,4x,g14.8,4x,g10.4)'
            ; report values in current x-units, ; values are stored as channels
            left=params[1].value-params[2].value/2.0d
            right=left+params[2].value
            xvals = chantox([params[1].value,left,right])
            params[1].value = xvals[0]
            params[2].value = abs(xvals[2]-xvals[1])
            params[2].value *= widthScale
            print,'Init:',(i+1),params[0].value, params[1].value,params[2].value,format=frmt
        endfor  ; for each gauss
    endif ; show initial guesses

    if show_fits then begin
        print,""
        print,"***** Fitted Gaussians"
        print, centerUnit, widthUnit, format='(8x,"Height",20x,"Center",A7,15x,"FWHM",A7)'
        for i=0,ngauss-1 do begin
            fit = !g.gauss.fit[*,i]
            fitrms = !g.gauss.fitrms[*,i]
            frmt = '(i2,2x, g10.4," (",g10.4,")",2x,g12.8," (",g10.4,")",2x,g10.4," (",g10.4,")")'
            ; report values in current x-units, values are stored as channels
            ; these two are used to get the width in x-units
            left=fit[1]-fit[2]/2.0d
            right=left+fit[2]
            ; these two are used to get the center error in x-units
            leftErr = fit[1] - fitrms[1]
            rightErr = fit[1] + fitrms[1]
            ; these two are used to get the width error in x-units
            leftWidErr = fit[1] - fitrms[2]
            rightWidErr = fit[1] + fitrms[2]
            ; convert them all in one GO
            xvals = chantox([fit[1],left,right,leftErr,rightErr,leftWidErr,rightWidErr])
            fit[1] = xvals[0]
            fit[2] = abs(xvals[2]-xvals[1])
            fitrms[1] = abs(xvals[4]-xvals[3])/2.0
            fitrms[2] = abs(xvals[6]-xvals[5])/2.0
            ; scale the width and error to a possibly different unit
            fit[2] *= widthScale
            fitrms[2] *= widthScale
            print,(i+1), fit[0], fitrms[0], fit[1], fitrms[1], fit[2], fitrms[2],format=frmt
        endfor ; for each gauss
    endif ; show fits

end
