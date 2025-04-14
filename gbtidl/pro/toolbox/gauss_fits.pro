; docformat = 'rst' 

;+
; This code came mostly from Tom Bania's GBT_IDL work.  Local
; modifications include:
; 
; * Allows multiple gauss fits in multiple regions
; * Results not printed here, nor analyzed: fits are just returned
; * All additional keywords used mpcurvefit can be used here as well.
; * Array syntax changed to [] and compile_opt idl2 used.
; * Indententation used to improve readability.
; * Some argument checks added.
; 
; Extra parameters are passed to mpcurvefit.
;
; :Params:
;   xx : in, required, type=array
;       The x-values to use in the fit.
;   yy : in, required, type=array
;       The data to be fit at xx.
;   nregions : in, required, type=long
;       The number of regions in which to fit gaussians
;   regions : in, required, type=2-D array
;       2-D array marking ends of each region.
;   inits : in, required, type=2-D array
;       2-D array of the form [[h,c,w],[h,c,w],[h,c,w],...], where h = height,
;       c = center, w = full width half maximum.  Each [h,c,w] corresponds to
;       a gaussian to fit.
;   ngauss : in, required, type=integer
;       The total number of gaussians to fit.
;   max_iters : in, required, type=long
;       max interations 
;   coefficients : out, required, type=2-D array
;       2-D array of the form [[h,c,w],[h,c,w],[h,c,w],...], where h, c, w are
;       the results for the fit of the height, center, and width.  If one of
;       these was specified as fixed, it will return identical to its value in
;       the inits param.
;   errors : out, required, type=2-D array
;       2-D array of the form [[h,c,w],[h,c,w],[h,c,w],...], where h, c, w are 
;       the 1-sigma errors for the results returned in the coefficients parameter
; 
; :Keywords:
;   parinfo : in, optional, type=array
;       Array of structures for placing different constraints on each parameter:
;       Each parameter is associated with one element of the array, in numerical order.
;       The structure can have the following entries (none are required):
; 
;       * .VALUE - the starting parameter value (but see the START_PARAMS
;         parameter for more information).
;  
;       * .FIXED - a boolean value, whether the parameter is to be held
;         fixed or not.  Fixed parameters are not varied by
;         MPFIT, but are passed on to MYFUNCT for evaluation.
;  
;       * .LIMITED - a two-element boolean array.  If the first/second
;         element is set, then the parameter is bounded on the
;         lower/upper side.  A parameter can be bounded on both
;         sides.  Both LIMITED and LIMITS must be given together.
;
;       * .LIMITS - a two-element float or double array.  Gives the
;         parameter limits on the lower and upper sides,
;         respectively.  Zero, one or two of these values can be
;         set, depending on the values of LIMITED.  Both LIMITED
;         and LIMITS must be given together.
;  
;       * .PARNAME - a string, giving the name of the parameter.  The
;         fitting code of MPFIT does not use this tag in any
;         way.  However, the default ITERPROC will print the
;         parameter name if available.
;  
;       * .STEP - the step size to be used in calculating the numerical
;         derivatives.  If set to zero, then the step size is
;         computed automatically.  Ignored when AUTODERIVATIVE=0.
;         This value is superceded by the RELSTEP value.
;
;       * .RELSTEP - the *relative* step size to be used in calculating
;         the numerical derivatives.  This number is the
;         fractional size of the step, compared to the
;         parameter value.  This value supercedes the STEP
;         setting.  If the parameter is zero, then a default
;         step size is chosen.
;
;       * .MPSIDE - the sidedness of the finite difference when computing
;         numerical derivatives.  This field can take four
;         values:
; 
;         * 0 - one-sided derivative computed automatically
;         * 1 - one-sided derivative (f(x+h) - f(x)  )/h
;         * -1 - one-sided derivative (f(x)   - f(x-h))/h
;         * 2 - two-sided derivative (f(x+h) - f(x-h))/(2*h)
; 
;         Where H is the STEP parameter described above.  The
;         "automatic" one-sided derivative method will chose a
;         direction for the finite difference which does not
;         violate any constraints.  The other methods do not
;         perform this check.  The two-sided method is in
;         principle more precise, but requires twice as many
;         function evaluations.  Default: 0.
;
;       * .MPMAXSTEP - the maximum change to be made in the parameter
;         value.  During the fitting process, the parameter
;         will never be changed by more than this value in
;         one iteration. A value of 0 indicates no maximum.
;         Default: 0.
;  
;       * .TIED - a string expression which "ties" the parameter to other
;         free or fixed parameters.  Any expression involving
;         constants and the parameter array P are permitted.
;         Example: if parameter 2 is always to be twice parameter
;         1 then use the following: parinfo(2).tied = '2 * P(1)'.
;         Since they are totally constrained, tied parameters are
;         considered to be fixed; no errors are computed for them.
;         [NOTE: the PARNAME can't be used in expressions.]
;
;       * .MPPRINT - if set to 1, then the default ITERPROC will print the
;         parameter value.  If set to 0, the parameter value
;         will not be printed.  This tag can be used to
;         selectively print only a few parameter values out of
;         many.  Default: 1 (all parameters printed)
; 
;  _EXTRA : in, optional, type=record
;       Extra keywords are passed to mpcurvefit.
;
; :Returns:
;   fits array: the fit for each region, back to back.  Use nregions and 
;   regions parameters to unwrap this result.
;
; 
; :Examples:
;
; simple example: one gaussian
;
; .. code-block:: IDL
;
;   ; make a simple gauss
;   x = lindgen(150)
;   h = 400000.
;   c = 75.
;   w = 15.
;   noise = 10000
;   data=h*exp(-4.0*alog(2)*(x-c)^2/w^2)+(randomn(seed,n_elements(x))*noise)
;   ; make an initial guess to this guassian
;   h = 400000.
;   c = 75.
;   w = 15.
;   inits = [h,c,w]
;   nregions = 1
;   regions = [[20,120]]
;   ngauss = 1
;   max_iters = 500
;   yfit = gauss_fits(x,data,nregions,regions,inits,ngauss,max_iters,coefficients,errors,quiet=1)
;   ; view the results
;   plot, data
;   gbtoplot, x[regions[0]:regions[1]], yfit, color=!red, /chan
;
; complex examle: multiple gaussians in multiple regions
;
; .. code-block:: IDL
; 
;   ; create 5 gaussians in the same plot
;   a1 = [400000.,35.,15.]
;   a2 = [100000.,15,7.5]
;   a3 = [200000.,110,8.0]
;   a4 = [100000.,150,5.5]
;   a5 = [100000.,170,5.5]
;   a = [a1,a2,a3,a4,a5]
;   x = lindgen(200)
;   data = make_gauss(x,a,10000.)
;   plot, data
;
;   ; specify 3 regions
;   nregions = 3
;   regions = [[5,75],[90,130],[135,190]]
;   inits = [[a1],[a2],[a3],[a4],[a5]]
;   ngauss = 5
;   max_iters = 500
;   p = replicate({value:0.D, fixed:0, limited:[0,0], $
;                      limits:[0.D,0]}, 15) 
;                      ; 15 = 5 gauss * 3 parameter per guass
;   p[*].value = a
;   ; hold the first gaussians height fixed
;   p[0].fixed = 1
;
;   ; find all the fits at once
;   yfit = gauss_fits(x,data,nregions,regions,inits,ngauss,max_iters,coefficients,errors,parinfo=p,quiet=1)
;
;   ; unwrap the results and plot them
;   ystart = 0
;   for i=0,(nregions-1) do begin
;       b = regions[0,i]
;       e = regions[1,i]
;       yend = ystart + (e-b)
;       y = yfit[ystart:yend]
;       ystart = yend + 1
;       gbtoplot, x[b:e], y, color=!red, /chan
;   endfor
;
; :Uses:
;   :idl:pro:`mpcurvefit`
;-
function gauss_fits,xx,yy,nregions,regions,inits,ngauss,max_iters,coefficients,errors,parinfo=parinfo,_EXTRA=ex
    compile_opt idl2

    ; argument checks
    if (n_elements(xx) ne n_elements(yy)) then $
        message, 'number of elements of xx is not equal to number of elements of yy'

    if (nregions lt 0) then message, 'nregions must be >= 0'
    
    sz = size(regions)
    if (sz[1] ne 2 ) then message, 'regions must be of dimension [[x,y],[x,y],...]'

    sz = size(inits)
    if (sz[0] eq 1) then begin
        n_inits = 1
    endif else begin
        n_inits = sz[2]
    endelse
    if (n_inits ne ngauss) then message, "ngauss is not consistent with the second dimension of inits"

    !except=0                   ; turn off underflow messages (and, alas, *all* math errors)

    ; build up the index given regions and nregions
    ; assumes regions are sorted and don't overlap
    ; we know there is at least one region
    indx = lindgen(regions[1,0]-regions[0,0]+1) + regions[0,0]
    if (nregions gt 1) then begin
        for i=1,(nregions-1) do begin
            indx = [indx,lindgen(regions[1,i]-regions[0,i]+1)+regions[0,i]]
        endfor
    endif

    mask = where(finite(yy[indx]))

    if mask[0] lt 0 then message, 'no unblanked data found in region to fit'

    indx = indx[mask]
    
    params = 0
    
    ; fit the guassians
    if keyword_set(parinfo) then begin
        params = parinfo[0:((ngauss*3)-1)]
    endif    
        
    ; convert the ginits 2-D array into a 1-D array
    a = fltarr(n_elements(inits))
    sigmaa = fltarr(n_elements(inits))
    a = float(inits[0:(n_elements(inits)-1)])

    ; wieght is 1.0 
    weightf = fltarr(n_elements(indx))+1.0
        
    ; fit the gaussians!
    if keyword_set(parinfo) then begin
        yfit = mpcurvefit(xx[indx],yy[indx],$
               weightf,a,sigmaa,function_name="gauss_fx",$
               chisq=chisq,itmax=max_iters,parinfo=params,_EXTRA=ex)    
    endif else begin 
        yfit = mpcurvefit(xx[indx],yy[indx],$
               weightf,a,sigmaa,function_name="gauss_fx",$
               chisq=chisq,itmax=max_iters,_EXTRA=ex)        
    endelse

    ; will eventually need to correct degrees of freedom (dof) for 
    ; parameters that have been held fixed in this fit
    dof = n_elements(xx[indx]) - n_elements(a)
    sigmaa *= sqrt(chisq/dof)
        
    
    ; translate the 1-D results into 2-D results
    coefficients = fltarr(3,ngauss)
    errors = fltarr(3,ngauss)
       
    for i=0,(ngauss-1) do begin
        coefficients[0,i] = a[(i*3)+0]
        coefficients[1,i] = a[(i*3)+1]
        coefficients[2,i] = a[(i*3)+2]
        errors[0,i] = sigmaa[(i*3)+0]
        errors[1,i] = sigmaa[(i*3)+1]
        errors[2,i] = sigmaa[(i*3)+2]
    endfor

    ; this clears it
    d=check_math()
    !except=1 ; return math error exceptions to default state

    return, yfit
    
end
