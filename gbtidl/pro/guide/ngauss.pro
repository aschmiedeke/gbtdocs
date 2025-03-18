;+
; Sets the value of !g.gauss.ngauss.  Must set this before fitting
; gaussians.  The <a href="fitgauss.html">fitgauss</a> procedure will set this for you as you mark 
; off individual gaussians to be fit.
;
; @param ng {in}{required}{type=integer} The total number of gauss to fit.
;
; @examples
; <pre>
; ; fit three gaussians
; ngauss, 3
; </pre>
;
; @version $Id$
;-
pro ngauss, ng
    compile_opt idl2

    if n_elements(ng) eq 0 then begin
        message,'Usage: ngauss, ng',/info
        return
    endif
    ; check dimensions of argument
    sz = size(!g.gauss.params)
    max_gauss = sz[2]
    if (ng gt max_gauss) then begin
        message, "Cannot fit more than "+string(max_gauss)+" gaussians.",/info
        return
    endif
    !g.gauss.ngauss = ng
    
end    
