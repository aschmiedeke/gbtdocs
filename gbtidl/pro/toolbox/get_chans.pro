;+
; Return a vector of channel numbers appropriate for the given data container.
; 
; If nregion is not set or is 0, all channels are returned.  If nregion is set
; and is not zero then regions must be provided.  Ignores any regions or
; parts of region that extend beyond the end of the data container.
;
; @param dc {in}{required}{type=data container} The data container to
; use.
; @param nregion {in}{optional}{type=integer} The number of regions to
; use.  If not set, then all channels are returned.
; @param regions {in}{optional}{type=2D array} Limit the channel
; numbers returned to only those channels that fall in these regions.
; This assumes the regions follows the same rules as used in
; !g.nregions.  That the regions don't overlap and are properly sorted
; with the first channel of each region at regions[0,*] and the last
; channel of each region at regions[1,*].  The nregion argument
; determines how many regions are used here.  If nregion is supplied
; and is > 0 then regions is required.
;
; @examples
; <pre>
;    ; equivalent to dindgen(n_elements(*dc.data_ptr))
;    c = get_chans(dc)
;    ; get the chans corresponding to recently set global regions
;    c = get_chans(dc, !g.nregions, !g.regions)
;  </pre>
;
; @returns Array of channel numbers.  Returns -1 if there was a
; problem.
;
; @uses <a href="data_valid.html">data_valid</a>
;
; @version $Id$
;-
function get_chans, dc, nregion, regions
    compile_opt idl2

    ; argument check here, dc valid
    nmax = data_valid(dc) - 1

    result = -1
    if (nmax < 0) then begin
        message, 'no valid data in dc', /info
        return, result
    endif

    if (n_elements(nregion) eq 0) then thisNregion = 0 else thisNregion = nregion

    if (thisNregion gt 0) then begin
        nres = 0
        for i=0,(thisNregion-1) do begin
            start = regions[0,i]
            stop = regions[1,i]
            if start lt 0 then start = 0
            if stop ge start and start le nmax then begin
                stop = stop gt nmax ? nmax : stop
                result = nres eq 0 ? seq(start,stop) : [result,seq(start,stop)]
                nres += 1
            endif
        endfor
    endif else begin
        result = lindgen(n_elements(*dc.data_ptr))
    endelse
    return, result
end
