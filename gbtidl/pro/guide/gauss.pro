;+ 
; Fits Gaussians to the data in the primary data container (!g.s[0])
; based on initial values that can be set by procedures <a href="gregion.html">gregion</a>,
; <a href="ngauss.html">ngauss</a>, <a href="gmaxiter.html">gmaxiter</a>, and <a href="gparamvalues.html">gparamvalues</a>.
;
; <p>Other data containers can be fit using the buffer keyword.
; 
; <p>Multiple gaussians in multiple regions can be fit at the same
; time.
;
; <p>The initial guesses and the most recent fit are available in the
; !g.gauss structure.
;
; @keyword buffer {in}{optional}{type=long}{default=0} global buffer
; number whose data is to be fit. Defaults to the primary data
; container.
; @keyword modelbuffer {in}{optional}{type=long}{default=-1} buffer
; number to hold the resulting model.  If not set (the default) then
; no global buffer is filled with the model.   
; @param fit {out}{optional}{type=array} results of fit. identical to
; !g.gauss.fit 
; @param fitrms {out}{optional}{type=array} errors of fit. identical
; to !g.gauss.fitrms 
; @keyword ok {out}{optional}{type=long} result; 1 - good, 0 - bad 
; @keyword quiet {in}{optional}{type=boolean}{default=F} When set, no
; report of the fits and initial guesses is printed.
;
; @examples
; Typically, fitgauss will be used to set the initial guesses and do
; the fit, using gauss.  Internally, fitgauss does these steps.
; <pre>
;    ; using the user-identified points, set the region(s)
;    gregion,[4120,4400]   ; channels 4120 through 4400 inclusive
;    ngauss,2              ; fit 2 gaussians
;    ; for each gaussian, do this
;    gparamvalues, 0, [2.4, 4359.0, 12.3]  ; [height, center, fwhm]
;    gparamvalues, 1, [0.5, 4370.0, 9.2] 
;    gauss
;    gshow
; </pre>
;
; <p>Continuum data containers can also be fit (must be in continuum mode).
; <pre>
;    cont                ; switch to cont mode
;    filein,'peaks.fits'
;    get,buffer=1        ; get some data
;    ; setup the gauss fit
;    gregion,[60,80]
;    ngauss,1
;    gmaxiter,500
;    gparamvalues, 0, [400000.,70.,100.]
;    ; find and show the fit
;    gauss
;    gshow
; </pre>
;
; @uses gauss_fits
; @uses report_gauss
;
; @version $Id$
;-
pro gauss, buffer=buffer, modelbuffer=modelbuffer, ok=ok, quiet=quiet, fit, fitrms
    compile_opt idl2

    ; init output
    fit = -1
    fitrms = -1

    ; argument checks
    ok = 0
    if (n_elements(buffer) eq 0) then buffer=0

    maxbuffer = !g.line ? n_elements(!g.s) : n_elements(!g.c)

    if  (buffer lt 0 or buffer gt maxbuffer) then begin
        message, 'requested buffer does not exist',/info
        return
    endif

    npts = !g.line ? data_valid(!g.s[buffer]) : data_valid(!g.c[buffer])
    if (npts lt 1) then begin
        message, 'no data at requested buffer', /info
        return
    endif

    if (n_elements(modelbuffer) eq 0) then modelbuffer=-1

    if (modelbuffer gt maxbuffer) then begin
        message, 'requested model buffer does not exist', /info
        return
    endif

    if (check_gauss_settings() eq 0) then message, "cannot fit gaussians with guide structure in bad state"
    
    ; look at only those regions specified
    nregions = !g.gauss.nregion
    if (nregions le 0) then return

    regions = !g.gauss.regions[*,0:(nregions-1)]
    ngauss = !g.gauss.ngauss

    if (ngauss le 0) then return
    
    ; prepare for fitting data
    allChans = dindgen(npts)

    data = !g.line ? *!g.s[buffer].data_ptr : *!g.c[buffer].data_ptr

    ; convert the parameter values to a simpler array[3,total(ngauss)]
    inits = dblarr(3,ngauss)
    for i = 0, (ngauss-1) do begin
        inits[0,i] = !g.gauss.params[0,i].value
        inits[1,i] = !g.gauss.params[1,i].value
        inits[2,i] = !g.gauss.params[2,i].value
    endfor

    ; dont let users forget to set the maximum number of iterations. use 500 if they have
    maxiter = (!g.gauss.maxiter eq 0) ? 500 : !g.gauss.maxiter
    
    ; fit all gaussians using all regions, each fits model is returned in an appended array. params are not used yet
    yfits = gauss_fits(allChans,data,nregions,regions,inits,ngauss,maxiter,coefficients,errors,quiet=1)
  
    ; add up yfits and write results to !g
    model=make_gauss_data(allChans,coefficients,0.0)
    ; add these results to !g

    !g.gauss.fit[*,0:(ngauss-1)] = coefficients
    !g.gauss.fitrms[*,0:(ngauss-1)] = errors

    ; if specified, then copy over the model data to it's location
    if (modelbuffer ge 0) then begin
        copy, 0, modelbuffer
        setdata,model,buffer=modelbuffer
    endif

    ; print out the results
    if (not keyword_set(quiet)) then report_gauss

    ; optional output
    fit = coefficients
    fitrms = errors

    ok = 1

end    
