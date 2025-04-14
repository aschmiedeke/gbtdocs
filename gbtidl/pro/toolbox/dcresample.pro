; docformat = 'rst' 

;+
; Resample a spectrum using one of 4 possible interpolation methods 
; onto a new frequency axis.
;
; Takes the data values in the given data container and 
; interpolates them onto a new frequency axis 
; derived from the newinterval and keychan arguments.  The 
; reference_frequency is unchanged by this operation.  
; The new frequency_interval is given by the **newinterval** 
; argument.  The new frequency axis is determined by choosing 
; one channel in the original frequency axis and requiring
; that the frequency at that channel be centered on one of the
; channels in the interpolated data (the **keychan**
; argument).  This sets the new reference frequency. When not
; supplied, **keychan** defaults to the channel nearest to the
; original reference channel.
;
; The **dc** argument is altered by this operation.  The data
; values will contain the interpolated values and the header will
; describe the new frequency axis.  The number of channels in the
; resulting interpolated data is just enough to use as much of the
; original data as possible without trying to interpolate beyond the
; ends of that data.
;
; Interpolation is done using INTERPOL or internally (nearest).  
; The channel number are used as the abscissa.  Blanked values (NaN) 
; are ignored.  See the documentation for INTERPOL for details 
; about the various interpolation methods.
;
; This only works with spectrum data containers.
;
; :Params:
;   dc : in, out, required, type=data container
;       The data container to work on.
;   newinterval : in, required, type=real
;       The new frequency_interval to use in the interpolation. This
;       must be non-zero.  If it has opposite sign from the input 
;       frequency interval, :idl:pro:`dcinvert` will be used to first
;       reverse the sense of the frequency axis.
;   keychan : in, optional, type=integer
;       The new frequency axis will have one channel where the 
;       frequency value equals the original frequency value at the
;       keychan channel.  When not supplied, this defaults to the 
;       channel nearest to the reference_channel.
; 
; :Keywords:
;   nearest : in, optional, type=boolean
;       When set do nearest-neighbor interpolation.
;   linear : in, optional, type=boolean
;       When set (the default) do a linear interpolation.
;   lsquadratic : in, optional, type=boolean
;       When set do least squares quadratic fit interpolation.
;   quadratic : in, optional, type=boolean
;       When set do a quadratic fit interpolation.
;   spline : in, optional, type=boolean
;       When set do a spline interpolation.
;   ok : out, optional, type=boolean
;       This is set to 1 on success, otherwise it is 0 (bad arguments,
;       bad data).
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       ; get a data container from the GUIDE structure
;       data_copy,!g.s[2], mydc ; this is a copy
;       ; do a linear interpolation to 1.5 x the channel spacing
;       dcresample,dc,dc.frequency_interval*1.5
;       show,dc
;       ; this is exactly equivalent to "dcinvert"
;       dcresample,dc,-dc.frequency_interval
;       ; get a fresh copy, use channel 0 as the keychan and
;       ; do a spline interpolation, make sure things are ok
;       data_copy,!g.s[2],mydc
;       dcresample,dc,dc.frequency_interval*1.5,0,/spline,ok=ok
;       if ok then show,dc
;
; :Uses:
;   :idl:pro:`data_valid`
;   :idl:pro:`dcinvert`
;
;-
pro dcresample, dc, newinterval, keychan, $
                nearest=nearest, linear=linear, lsquadratic=lsquadratic, $
                quadratic=quadratic, spline=spline, ok=ok
    compile_opt idl2

    ok = 0

    if n_params() lt 2 then begin
        usage,'dcresample'
        return
    endif

    nels = data_valid(dc,name=name)
    if nels le 0 then begin
        message,'dc is empty or invalid',/info
        return
    endif

    if name ne 'SPECTRUM_STRUCT' then begin
        message,'dcresample only works on spectrum data containers',/info
        return
    endif

    if newinterval eq 0 then begin
        message,'newinterval can not be 0',/info
        return
    endif

    if ((keyword_set(nearest) + keyword_set(linear) + keyword_set(lsquadratic) + keyword_set(quadratic) + keyword_set(spline)) gt 1) then begin
        message,'Must choose one of /nearest, /linear, /lsquadratic, /quadratic, or /spline',/info
        return
    endif

    if newinterval*dc.frequency_interval lt 0 then dcinvert,dc

    if newinterval eq dc.frequency_interval then begin
        ok = 1
        return
    endif

    if n_elements(keychan) eq 0 then keychan = dc.reference_channel
    ; just make sure keychan is an integer
    keychan = round(keychan)
    ; and that its in the range of actual channels
    if keychan lt 0 then keychan = 0
    if keychan ge nels then keychan = (nels-1)

    keyfreq = dc.reference_frequency + (keychan - dc.reference_channel)*dc.frequency_interval
    zerofreq = dc.reference_frequency - dc.reference_channel*dc.frequency_interval

    ; first guess at new keychan
    newkeychan = (keyfreq - zerofreq)/newinterval
    ; but that must be an integer and it must be < newkeychan . i.e.
    newkeychan = floor(newkeychan)

    ; and that determines where zerofreq is
    zerofreq = keyfreq - newkeychan*newinterval

    ; and that determines the new reference_channel
    newrefchan = (dc.reference_frequency - keyfreq)/newinterval + newkeychan

    ; first guess at new nels
    endfreq = dc.reference_frequency + (double(nels) - 1.0 - dc.reference_channel)*dc.frequency_interval
    newnels = (endfreq - dc.reference_frequency) / newinterval + 1 + newrefchan
    newnels = floor(newnels)

    if newnels le 1 then begin
        message,'newinterval is too large, would result in single channel',/info
        return
    endif

    newf = (dindgen(newnels) - newrefchan)*newinterval + dc.reference_frequency

    ; express new channels in terms of old channels
    newAsOldChans = (newf - dc.reference_frequency)/dc.frequency_interval + dc.reference_channel
    oldChans = dindgen(nels)

    if keyword_set(nearest) then begin
        ; nearest neighbor
        nearestChans = round(newAsOldChans)
        newdata = (*dc.data_ptr)[nearestChans]
    endif else begin
        ; everything else uses interpol
        ; only use finite values
        finiteMask = where(finite(*dc.data_ptr) eq 1, count)
        newdata = interpol((*dc.data_ptr)[finiteMask],oldChans[finiteMask],newAsOldChans,$
                          lsquadratic=lsquadratic,quadratic=quadratic,spline=spline)
        if count ne nels then begin
            ; some data has been blanked, blank appropriately in newdata
            blankedChans = where(finite(*dc.data_ptr) eq 0)
            blankedFreqs = dc.reference_frequency + (double(blankedChans) - dc.reference_channel)*dc.frequency_interval
            newBlankedChans = (blankedFreqs - dc.reference_frequency)/newinterval + newrefchan
            newBlankedChans = round(newBlankedChans)
            newdata[newBlankedChans] = !values.f_nan
        endif
    endelse

    *dc.data_ptr = newdata
    dc.reference_channel = newrefchan
    dc.frequency_interval = newinterval
    dc.bandwidth = abs(dc.frequency_interval) * n_elements(*dc.data_ptr)

    ok = 1
end
        

    
