; docformat = 'rst' 

;+
; Performs basic checking of the values in the gaussian fitting section of
; the guide structure, !g.  Called by several gaussian fitting procedures.
; 
; :Returns:
;   0, 1
;
; @private_file
;-
function check_gauss_settings
    compile_opt idl2

    ; get max regions and max number of gaussians from guide structure
    sz = size(!g.gauss.regions)
    max_regions = sz[2]

    if (!g.gauss.nregion gt max_regions) then begin
        print, "!g.gauss.nregion exceeds max regions of: "+string(max_regions)
        return, 0
    endif

    ; should we check for malformed regions?

    sz = size(!g.gauss.params)
    max_gauss = sz[2]
    if (!g.gauss.ngauss gt max_gauss) or (!g.gauss.ngauss lt 0) then begin
        print, "!g.gauss.ngauss[i] must be between 0 and "+string(max_gauss) 
        return, 0
    endif
    
    return, 1

end    
