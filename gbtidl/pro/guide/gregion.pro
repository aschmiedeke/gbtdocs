; docformat = 'rst'

;+
; Set some regions for use by GUIDE gaussian procedures and functions.
; 
; This sets the !g.gauss.regions structure with the regions described
; by the regions argument.  Overlaps in regions are eliminated and the
; resulting content of !g.gauss.regions is a set of unique,
; non-overlapping regions.  Regions are expressed as channel numbers.  
; This procedure always clears the contents of !g.gauss.regions before
; starting. 
;
; **Note: there is a limit of 100 regions.** If you need to use
; more regions you will need to either use the fitting functions
; directly or make a local copy of the guide_struct file which defines
; the !g structure and edit the sizes in there.
;
; :Params:
;   regions : in, required, type=integer array
;       The regions to set. If this is a 1D array, then it is interpreted
;       as a sequence of beginning and ending channels which define 
;       n_elements/2 regions, inclusive. A warning is issued in that case
;       if n_elements is not a multiple of 2. The trailing, unmatched value
;       will be ignored. Values after the first negative value encountered 
;       are also ignored. If this is a 2D array, then the first dimension
;       must be 2 and the second dimension is the number of regions. A 
;       warning is issued if this argument gives more than 100 regions.  
;       Only the first 100 regions are used in that case.  Overlapping 
;       regions are eliminated.
;
; :Examples:
; 
;   All of these produce identical results
; 
;   ..code-block:: IDL
; 
;       ; as 1-D array
;       gregion, [125,180,215,300,320,475]
;       ; as 2-D array
;       gregion, [[125,180],[215,300],[320,475]]
;       ; same regions, beginning and end channels swapped
;       gregion, [180,125,300,215,320,475]
;       ; overlapping regions
;       gregion, [125,160,150,180,215,300,320,420,400,475]
;
;-
pro gregion, regions
    compile_opt idl2

    ; check argument
    rsize = size(regions)

    maxregions = n_elements(!g.gauss.regions)

    ; 1 or 2-D
    ndim = rsize[0]
    if (ndim lt 1 or ndim gt 2L) then begin
        message, 'regions must be 1 or 2 dimensions', /info
        return
    endif

    if (ndim eq 2) then begin
        if (rsize[1] ne 2L) then begin
            message, 'The first dimension of 2-D regions must be 2', /info
            return
        endif
        nregions = rsize[2]
    endif else begin
        nelem = rsize[3]
        if (nelem mod 2L) then begin
            message, 'Number of elements is not a multiple of 2, ignoring last element in regions', /info
            nelem -= 1L
        endif
        nregions = nelem / 2L;
    endelse

    if (nregions lt 1L) then begin
        message, 'No regions specified',/info
        return
    endif

    if (nregions gt maxregions) then begin
        message, 'No more than '+string(maxregions)+' regions can be specified, ignoring all regions beyond that limit',/info
        nregions = maxregions
    endif

    if (ndim eq 2) then begin
        start = regions[0,0:(nregions-1)]
        stop = regions[1,0:(nregions-1)]
    endif else begin
        mask = lindgen(nregions) * 2L
        start = regions[mask]
        mask += 1
        stop = regions[mask]
    endelse

    for i=0,(nregions-1) do begin
        if (start[i] gt stop[i]) then begin
            tmp = start[i]
            start[i] = stop[i]
            stop[i] = tmp
        endif
    endfor

    ; sort start and stop so that overlaps can be removed
    order = sort(start)
    thisregion = 0
    !g.gauss.regions[0,0] = start[order[0]]
    !g.gauss.regions[1,0] = stop[order[0]]
    for i=1,(nregions-1) do begin
        inRegion = order[i]
        if (start[inRegion] le !g.gauss.regions[1,thisregion]) then begin
            ; this overlaps previous
            if (stop[inRegion] gt !g.gauss.regions[1,thisregion]) then begin
                ; new stop, else fully contained in previous region
                !g.gauss.regions[1,thisregion] = stop[inRegion]
            endif
        endif else begin
            ; new region
            thisregion += 1
            !g.gauss.regions[0,thisregion] = start[inRegion]
            !g.gauss.regions[1,thisregion] = stop[inRegion]
        endelse
    endfor

   !g.gauss.nregion = thisregion+1

    ; and set the rest to -1
    if (thisregion lt 9) then begin
        !g.gauss.regions[0:1,(thisregion+1):9] = -1
    endif
end
