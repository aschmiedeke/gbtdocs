; docformat = 'rst' 

;+
; Returns a gaussian, given coefficients and an x axis.  Noise and offset can be added.
; Used in guide layer and in tests.
;
; :Params:
;   x : in, required, type=array
;       x-axis
;   a : n, required, type=array
;       coefficents for gaussian: [height, center, width] 
;   noise : in, required, type=double
;       noise to inject
;   offset : in, optional, type=double
;       offset to add to gaussian
; 
; :Returns:
;   the gaussian evaluated at x with noise added
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       ; create two gaussians
;       a = [400000.,75.,15.]
;       a = [a,[200000,35,5.]]
;       x = lindgen(150)
;       y = make_gauss_data, x, a, 100.
;       plot, x, y
; 
;-
function make_gauss_data, x, a, noise, offset

    ;a = [400000.,75.,15.]
    ;a = [a,[200000,35,5.]]
    ;x = lindgen(150)

    !except=0                   ; turn off underflow messages (and, alas, *all* math errors)

    if (n_elements(offset) eq 0) then off = 0 else off = offset

    seed = 123321

    ngauss=n_elements(a)/3                          ;  'a' stores the Gaussian coeffs 
    f=fltarr(n_elements(x))
    for i=0,ngauss-1 do begin
         h=a(i*3+0)          
         c=a(i*3+1)
         w=a(i*3+2)
         fx=h*exp(-4.0*alog(2)*(x-c)^2/w^2)+(randomn(seed,n_elements(x))*noise)+off
         f=f+fx
    end

    r=check_math()    ; call this to clear the status
    !except=1                   ; return math error flag to default

    return, f

end
