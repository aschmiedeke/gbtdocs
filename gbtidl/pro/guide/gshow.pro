;docformat = 'rst' 

;+
; Show the most recently fit gaussians and annotate the plot with
; their peak, center, width values.
;
; The gaussians are plotted on top of the whatever is already
; plotted.
;
; :Keywords:
;   modelbuffer : in, optional, type=integer
;       The data container buffer containing the model of the most 
;       recent gaussian fit.  If this is omitted, a value of -1 is 
;       assumed.  If this is -1 then a model is constructed from 
;       the fit parameters in ``!g.gauss``.  This is ignored if parts
;       is set.
;   parts : in, optional, type=boolean
;       When set, show the individual gaussians as separate plots. 
;       This always constructs the gaussians from the parameters
;       in !g.gauss.  modelbuffer is ignored when this keyword is set.
;   color : in, optional, type=integer, default=``!g.gshowcolor``
;       A color to use for the plots.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       ; assumes initial guesses already set
;       gauss
;       gshow,/parts
;
;-
pro gshow, modelbuffer=modelbuffer, parts=parts, color=color

    if (n_elements(modelbuffer) eq 0) then modelbuffer = -1

    if (n_elements(color) eq 0) then color=!g.gshowcolor

    ; do we show the entire model, or just the fit for each gaussian
    if (keyword_set(parts) eq 0) then begin
    
        ; get the data to be plotted: from model, or coefficients?
        if (modelbuffer ne -1) then begin
            ; over plot the model data
            if !g.line then begin
                data = *!g.s[modelbuffer].data_ptr 
            endif else begin
                data = *!g.c[modelbuffer].data_ptr 
            endelse
            ; plot it
            gbtoplot, data, color=color, /chan
        endif else begin
            ng = !g.gauss.ngauss
            if (ng le 0) then return

            ; create the model from the coefficients in !g
            if !g.line then begin
                npts = data_valid(!g.s[0])
            endif else begin
                npts = data_valid(!g.c[0])
            endelse
            if (npts le 0) then begin
                message, 'No data at buffer 0 to base the model on.',/info
                return
            endif

            x = lindgen(npts)
            oplotfn,'gauss_plot_fn',{a:!g.gauss.fit[*,0:(ng-1)],noise:0.0,offset:0},color=color,/noshow
        endelse

    endif else begin
    
        ; create a gaussian from each set of coefficients, and plot them

        ng = !g.gauss.ngauss
        if (ng le 0) then return
        
        if !g.line then begin
            npts = data_valid(!g.s[0])
        endif else begin
            npts = data_valid(!g.c[0])
        endelse
        if npts le 0 then return

        x = lindgen(npts)

        ; go through each gauss
        mc = machar()
        ; data is floating point prec, so don't plot anything
        ; that would require more than that precision to represent
        for i=0,ng-1 do begin
            params = !g.gauss.fit[*,i]
            oplotfn,'gauss_plot_fn',{a:!g.gauss.fit[*,i],noise:0.0,offset:0.0},/noshow
        endfor 

    endelse

    clearannotations,/noshow

    ; annotate the gaussians
    lab='       P        C         W'

    off=-.03
    annotate,.13,.71,lab,/normal,charsize=1.4,color=!g.gausstextcolor,/noshow ; label
    for i=0,!g.gauss.ngauss-1 do begin
        ; convert those to x-axis coordinate values
        left=!g.gauss.fit[1,i]-!g.gauss.fit[2,i]/2.0d
        right=left+!g.gauss.fit[2,i]
        xvals = chantox([!g.gauss.fit[1,i],left,right])

        sh=string(!g.gauss.fit[0,i],form='(f10.3)')
        sc=string(xvals[0],form='(f10.3)')
        sw=string(abs(xvals[2]-xvals[1]),form='(f10.3)')

        y = .67+i*off
        annotate,.13,y,sh,/normal,charsize=1.5,color=!g.gausstextcolor,/noshow ; peak
        annotate,.22,y,sc,/normal,charsize=1.5,color=!g.gausstextcolor,/noshow ; center
        annotate,.31,y,sw,/normal,charsize=1.5,color=!g.gausstextcolor,/noshow ; width

    endfor
    reshow

end    
