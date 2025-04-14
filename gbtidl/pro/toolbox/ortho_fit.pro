; docformat = 'rst' 

;+
; Function uses general orthogonal polynomial to do least squares
; fitting.
;
; This code came from Tom Bania's GBT_IDL work.  Local
; modifications include:
; 
; * Documentation modified for use by idldoc
; * Array syntax changed to [] and compile_opt idl2 used.
; * Indententation used to improve readability.
; * Unnecessary code removed.
; * Some argument checks added.
; 
; :Params:
;   xx : in, required
;       The x-values to use in the fit.
;   yy : in, required 
;       The data to be fit at xx.
;   nfit : in, required, type=integer
;       The order of the polynomial to fit.
;   cfit : out, required
;       On return, cfit has coefficients of the polynomial 
;       :math:`fit = sum(m) a_m x^m`  because of round-off using this
;       form gives unreliable results above about order 15 even for 
;       double precision. See :idl:pro:`ortho_poly` for a better 
;       discussion on the contents of cfit.
;   rms : out, required
;       The rms error for each polynomial up to order nfit.
;
; :Returns:
;   polyfit array: contains information for fitting to arbitrary
; points using the recursion relations
;
; :Examples:
; 
;   fit a 3rd order polynomial to the data in !g.s[0]
; 
;   .. code-block:: IDL
;   
;       yy = *(!g.s[0].data_ptr)
;       xx = dindgen(n_elements(yy))
;       f = ortho_fit(xx, yy, 3, cfit, rms)
;
;-
function ortho_fit,xx,yy,nfit,cfit,rms
    compile_opt idl2

    ; argument checks
    if (n_elements(xx) ne n_elements(yy)) then $
        message, 'number of elements of xx is not equal to number of elements of yy'

    if (nfit lt 0) then message, 'nfit must be >= 0'

    n = n_elements(xx)

    ; initialize needed arrays
    polyfit = dblarr(4,nfit+1)
    rms = dblarr(nfit+1)
    coef = dblarr(nfit+1)
    ; dblarr initializes these to 0.0, no need to do so here
    c0 = coef 
    c1 = coef
    c2 = coef
    cfit = coef 
    
    fit = dblarr(n)
    p0 = fit
    p1 = fit
    pnp1 = fit 
    pn = fit 
    pnm1 = fit

    ; copy values to ensure double precision 
    x = double(xx)
    f = double(yy)

    ; get the first couple of polynomials and fit coefficients

    p0[0:n-1] = 1.0
    xnorm = sqrt(total(p0^2))
    p0 = p0/xnorm
    c0[0] = 1./xnorm
    coef[0] = total(f*p0)
    polyfit[0,0] = c0[0]
    polyfit[3,0] = coef[0]
    rms[0] = total( (f-coef[0]*p0)^2)
    
    if (nfit eq 0) then begin
        cfit = coef[0]*c0
        return, polyfit
    endif

    a = total(x*p0)
    p1 = x - a*p0
    xnorm = sqrt(total(p1^2))
    c1[1] = 1.0
    p1 = p1/xnorm
    c1 = (c1 - a*c0)/xnorm
 
    ; first couple of fit coefficients
    coef[1] = total(f*p1)
    polyfit[0:1,1] = c1[0:1]
    polyfit[3,1] = coef[1]
    cfit = coef[0]*c0 + coef[1]*c1
    fit = coef[0]*p0 + coef[1]*p1
    rms[1] = total( (f-fit)^2 )

    ; loop up the order, using general recursion relation
    pnm1 = p0
    pn = p1
    cnm1 = c0
    cn = c1
    ;  print, 'cfit before loop', cfit
    ; in IDL, this loop is not entered if nfit < 2
    for m=2,nfit do begin
        a = -1./total(x*pn*pnm1)
        b = -a*total(x*pn^2)
        ;  print,'iteration ',m,a,b
        pnp1 = (a*x + b)*pn + pnm1
     
        xnorm = sqrt(total(pnp1^2))
        pnp1 = pnp1/xnorm
        coef[m] = total(f*pnp1)
        ctmp = shift(cn,1)
        ctmp[0] = 0.
        cnp1 = (a*ctmp + b*cn + cnm1)/xnorm
        cfit = cfit + coef[m]*cnp1
        fit = fit + coef[m]*pnp1
        polyfit[0,m] = 1./xnorm
        polyfit[1,m] = b/xnorm
        polyfit[2,m] = a/xnorm
        polyfit[3,m] = coef[m]
        rms[m] = total( (f-fit)^2 )
        cnm1 = cn
        cn = cnp1
        pnm1 = pn
        pn = pnp1
    endfor

    rms = sqrt( rms/double(n) )

    return, polyfit
end
