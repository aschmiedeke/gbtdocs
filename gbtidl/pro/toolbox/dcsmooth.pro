;+
; Smooth the data with a GAUSSIAN such that the spectrum in the given
; data container with an original resolution of frequency_resolution
; now has a resolution of NEWRES, where NEWRES is expressed in channels.  
; 
; <p>Optionally also decimate the spectrum by keeping only every 
; NEWRES channels.
;
; <p>The frequency_resolution field is set to newres *
; abs(frequency_interval) after this procedure is used.
;
; <p>The width of the smoothing Gaussian is sqrt(newres2-oldres^2).
;
; @param dc {in}{required}{type=data container} The data container to
; smooth.
; @param newres {in}{required}{type=real} The desired new resolution
; in units of channels.  This must be >= the frequency_resoltuion also
; expressed in channels.  If it is equal to the oldres value this
; procedure does not change the data.
; @keyword decimate {in}{optional}{type=boolean} When set, only every
; NEWRES channels are kept, starting from the original 0 channel.  If
; NEWRES is not an integer, this may not be a wise thing to do (the
; decimation rounds to the nearest integer).
; @keyword ok {out}{optional}{type=boolean} Returns 1 if everything went
; ok, 0 if it did not (missing parameter, empty or invalid dc, bad kernel).
; 
; @examples
; <pre>
;    ; dc already exists and is a valid data container
;    ; smooth to 2 channels
;    dcsmooth,dc,2
;    ; do it again, now to 4 channels, decimate this time
;    dcsmooth,dc,4,/decimate
; </pre>
;
; @uses <a href="data_valid.html">data_valid</a>
; @uses <a href="dcconvol.html">dcconvol</a>
; @uses <a href="dcdecimate.html">dcdecimate</a>
; @uses <a href="make_gauss_data.html">make_gauss_data</a>
;
; @version $Id$
;-

pro dcsmooth, dc, newres, decimate=decimate, ok=ok
    compile_opt idl2

    ok = 0
    if n_params() ne 2 then begin
        usage,'dcsmooth'
        return
    endif

    nels = data_valid(dc,name=name)
    if name ne 'SPECTRUM_STRUCT' then begin
        message,'dcsmooth only works on spectrum data containers',/info
        return
    endif
    if nels le 0 then begin
        message,'Data container is empty',/info
        return
    endif
    
    oldres = dc.frequency_resolution / abs(dc.frequency_interval)

    if newres eq oldres then return

    if newres lt oldres then begin
        resStr = strtrim(string(oldres),2)
        message,string(resStr,format='("newres must be > ",a)'),/info
        return
    endif

    ok = 1
    ; FWHM of the convolving function
                                ; promote newres to a double before
                                ; using.  It might be a short integer
                                ; and hence newres*newres might not
                                ; fit into a short integer
    dnewres = double(newres)
    conres = sqrt(dnewres*dnewres - oldres*oldres)
    ; 1 std dev = FWHM/2*sqrt(2*ln(2)) 
    ; go out +- 4 std devs from center
    conwid = round(4.0*conres / sqrt(2.0*alog(2.0)))
    ; minimum of 11 channels - purely arbitrary here
    if conwid lt 11 then conwid = 11
    ; make it an odd number
    if conwid mod 2 eq 0 then conwid = conwid + 1
    ; must have fewer values than the data
    if conwid ge nels then conwid = nels-1

    conCenter = (conwid-1.0)/2.0
    conHeight = (2.0/conres) * sqrt(alog(2.0)/!pi)
    conGauss = make_gauss_data(findgen(conwid),[conHeight,conCenter,conres],0.0)

    dcconvol, dc, conGauss, ok=ok, /nan, /edge_truncate, /normalize

    dc.frequency_resolution = dnewres * abs(dc.frequency_interval)

    if keyword_set(decimate) then begin
        dcdecimate,dc,round(dnewres)
    endif
end
