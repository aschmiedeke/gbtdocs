;+
;
; The Gaussian function required by curvefit, and used by gauss_fits.
; Used to fit the sum of a number of Gaussians.
; Taken from ASTROLIB.
;
; @param x {in}{required}{type=float array} The x-location to evaluate the
; gaussians at.
; @param a {in}{required}{type=float array} The gaussians are described by
; a.
; @param f {out}{required}{type=float array} The evaluated value.
; @param pder {out}{required}{type=float array} The derivatives with
; respect to each parameter.
;
;-
pro gauss_fx,x,a,f,pder
;
ngauss=n_elements(a)/3                          ;  'a' stores the Gaussian coeffs 
f=fltarr(n_elements(x))
pder=fltarr(n_elements(x),n_elements(a))
;
for i=0,ngauss-1 do begin
     h=a(i*3+0)          
     c=a(i*3+1)
     w=a(i*3+2)
     fx=h*exp(-4.0*alog(2)*(x-c)^2/w^2)
     f=f+fx
     pder(*,i*3+0)=fx/h
     pder(*,i*3+1)=fx*8.0*alog(2)*(x-c)/w^2
     pder(*,i*3+2)=fx*8.0*alog(2)*(x-c)^2/w^3
endfor
;
return
end
