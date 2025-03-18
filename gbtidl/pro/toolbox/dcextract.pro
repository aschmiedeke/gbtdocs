;+
; Extract a region from a data container, producing a new data
; container with fewer elements in it. The caller is responsible for
; eventually freeing the pointer(s) contained in the returned data
; container using <a href="data_free.html">data_free</a>.  The only
; header words modified are the reference_channel and
; frequency_interval for spectral line data.  If only the dc is
; supplied, this function is equivalent to data_copy.
;
; @param dc {in}{required}{type=data container} The data container to
; extract the region from.
;
; @param startat {in}{optional}{type=integer}{default=0} The first element to
; include in the extracted region.
; @param endat {in}{optional}{type=integer} The last element to include
; in the extracted region.  If not supplied, the last element is
; used.  endat must be greater than or equal to startat.
; @param stride {in}{optional}{type=integer}{default=1} The increment
; in elements to extract, starting with startat.  stride must be greater
; than 0.
;
; @returns The extracted data container.  The user is responsible for
; eventually freeing this using data_free.  Returns -1 on error.
;
; @version $Id$
;-
function dcextract, dc, startat, endat, stride
    compile_opt idl2

    nch = data_valid(dc,name=name)
    if nch le 0 then begin
        message,'dc is empty or invalid',/info
        return, -1
    endif

    if n_elements(startat) eq 0 then startat=0
    if n_elements(endat) eq 0 then endat=(nch-1)
    if n_elements(stride) eq 0 then stride=1
    startat = long(startat)
    endat = long(endat)
    stride = long(stride)

    if startat lt 0 or startat gt (nch-1) then begin
        message,'startat is out of range',/info
        return,-1
    endif

    if (endat lt 0 or endat gt (nch-1)) then begin
        message,'endat is out of range',/info
        return,-1
    endif

    if (endat lt startat) then begin
        message,'endat is before startat',/info
        return,-1
    endif
    
    if (stride le 0) then begin
        message,'stride must be positive',/info
        return,-1
    endif

    data_copy,dc,result
    
    *result.data_ptr = (*dc.data_ptr)[startat:endat:stride]

    if (name eq 'SPECTRUM_STRUCT') then begin
        result.reference_channel = (dc.reference_channel-startat)/double(stride)
        result.frequency_interval *= double(stride)
        result.bandwidth = abs(result.frequency_interval) * n_elements(*result.data_ptr)
    endif else begin
        ; assume CONTINUUM_STRUCT
        *result.date = (*dc.date)[startat:endat:stride]
        *result.utc = (*dc.utc)[startat:endat:stride]
        *result.mjd = (*dc.mjd)[startat:endat:stride]
        *result.longitude_axis = (*dc.longitude_axis)[startat:endat:stride]
        *result.latitude_axis = (*dc.latitude_axis)[startat:endat:stride]
        *result.lst = (*dc.lst)[startat:endat:stride]
        *result.azimuth = (*dc.azimuth)[startat:endat:stride]
        *result.elevation = (*dc.elevation)[startat:endat:stride]
    endelse
    return,result
end
