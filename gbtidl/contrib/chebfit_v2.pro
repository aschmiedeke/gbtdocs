;+
;svdcheb - chebyshev fitting function for svdfit
;<p>
;Used by chebfit_v2 in call to svdfit.
;-
function svdcheb,X,M
;
;
        XX=X[0]                 ; ensure scalar XX
        basis=dblarr(m)
        basis[0]=1.0D
        basis[1]=xx
        FOR i=2,M-1 DO basis[i]=2.D*basis[i-1]*XX-basis(i-2)
    return,basis
end
;+
;chebfit_v2 - chebyshev polynomial fit to data
;<p>
;   Do a chebyshev polynomial fit of order deg to the x,y data. Merr
;are the measurement errors (see idl svdfit routine).
;Return the coefs for the fit as well as the mapping of the xrange
;into [-1,1]. 
;<p> 
;SEE ALSO:
;   chebeval() to evaluate the coef.
;<p>
;NOTE:
;The fitting function svdcheb() is contained in this file. If the
;routine gives an error that it cannot find svdcheb() just compile
;this routine explicitly (.compile chebfit_v2).
;
; <p><B>Contributed By: Karen O'Neil, NRAO-GB</B>
; @param x {in}{required}{type=float/double} independent variable
; @param y {in}{required}{type=float/double} measured dependent
; variable, same number of elements as x.
; @param deg {in}{required}{type=integer} degree of fit (ge 1)
; @keyword merr {in}{optional}{type=float/double} measurement errors
; for y, same number of elements as y.  Default is uniform.
; @keyword yfit {out}{optional}{type=float/double} fit evaluated at x
; locations.
; @keyword rangex {out}{optional}{type=float/double} 2-element array
; giving min and max values of x used for fit.  These were used to map
; the x-axis into [-1,1] for the fit.
; @returns coef[deg+1].  coefs from fit
;
; @version $Id$
;-           
function chebfit_v2,x,y,deg,yfit=yfit,rangex=rangex,merr=merr
;
;   map x,y to min,max   
;
    xmin=min(x,max=xmax) 
    xloc=(2.d*x-(xmax+xmin))/(xmax-xmin)            ; scale -1 1
    coef=svdfit(xloc,y,deg+1,function_name='svdcheb',chisq=chisq,$
        covar=covar,/double,yfit=yfit,singular=sng,measure_err=merr)
    if  sng ne 0 then  print,"svdfit returned singularity"
    rangex=[xmin,xmax]
    return,coef
end
