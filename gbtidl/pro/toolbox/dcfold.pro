; docformat = 'rst' 

;+
; Average two parts of in-band frequency switching (signal and
; reference phases, with the cal-switching phases already calibrated).
; Typically this happens after getfs.  It does not matter which data
; container containers which part since their relative distance in 
; frequency is used to determine how one is shifted to align with the
; other. The returned result is a new data container that the user must
; eventually free using :idl:pro:`data_free` in order to avoid any memory 
; leaks.  sig and ref must have the same number of channels and the same 
; spacing between channels.  If sig and ref are already aligned, then 
; this is a simple average (a warning message will be printed).  If the 
; shift necessary to align ref with sig is more than the total number of 
; channels, there is no overlap and this procedure will print an error 
; message and return without altering sig and ref.
;
; The "ref" data container is shifted to align in sky frequency with the 
; "sig" data container using :idl:pro:`dcshift` and the two data containers 
; are averaged - weighting each by the inverse of square of their system 
; temperatures.  The system temperature in the result is the weighted 
; average of the two system temperatures.
;
; If there are any blanked channels in either "sig" or "ref" then
; the corresponding channels in the other spectrum, after "ref" has
; been shifted to align in sky frequency with "sig", are also blanked
; so that the average at those channels is blanked.  This is done to
; avoid the appearance of a spike at a blanked channel where the
; contribution from the other spectrum, after the shift, is typically
; not blanked and not equal to the local average of surrounding,
; non-blanked, channels.  This behavior can be turned off by the
; nomask keyword.  Alternatively, all blanked channels in "sig" and
; "ref" can be replaced using a linear interpolation from adjacent
; non-blanked channels (a simple average in the case of single,
; isolated, blanked channels) using the blankinterp keyword.
;
; :Params:
;   sig : in, out, required, type=spectrum
;       The data container to use as the signal part in the average.
;
;   ref : in, out, required, type=spectrum
;       The data container to use as the reference part in the average.
;       This data is shifted using :idl:pro:`dcshift` to align with
;       "sig" before averaging. 
;
; :Keywords:
;   ftol : in, optional, type=double, default=0.005
;       The fractional channel shift tolerance.  If the fractional part of
;       the channel shift necessary to align the two parts is less than 
;       this value, no fractional shift as described in the documentation
;       for :idl:pro:`dcshift` will be done.  It might be useful to turn 
;       off the fractional shift because it can cause aliases and ringing
;       in the case of very strong lines or other sharp features. If ftol 
;       > 0.5 no fractional shifts will be done.
;
;   blankinterp : in, optional, type=boolean
;       When set, blanks are replaced before shifting and averaging by a 
;       linear interpolation using the finite values found in the two spectra.
;       The :idl:pro:`dcinterp` procedure is used.  For single blanked
;       channels, the replacement value is the average of the two adjacent
;       channel values.
;
;   nomask : in, optional, type=boolean
;       When set, turn off the masking of blank channels from each spectrum 
;       on to the other, after the shift.  This may result in spikes at the 
;       location of blanked channels. This was the original behavior of this 
;       routine.  This keyword has no effect if blankinterp is set.
;
; :Returns:
;   data container.  The user is responsible for freeing this.
;   returns -1 on error.
;
; :Uses:
;   :idl:pro:`dcshift`
;   :idl:pro:`dcinterp`
;   :idl:pro:`data_free`
;   :idl:pro:`data_valid`
;
;-
function dcfold, sig, ref, ftol=ftol, blankinterp=blankinterp, nomask=nomask
    compile_opt idl2

    catch, error_status
    if (error_status ne 0) then begin
        ; print out the error and return
        help,/last_message,output=errtext
        print,errtext[0]
        return, -1
    endif

    if n_params() ne 2 then begin
        usage,'dcfold'
        return, -1
    endif

    if n_elements(ftol) eq 0 then ftol=0.005

    nsig = data_valid(sig)
    if (nsig le 0) then begin
        message, 'sig data is empty or invalid'
    endif

    nref = data_valid(ref)
    if (nref le 0) then begin
        message, 'ref data is empty or invalid'
    endif

    if (nref ne nsig) then begin
        message,'sig and ref have different numbers of channels, can not fold',/info
        return,-1
    endif

    if (sig.frequency_interval ne ref.frequency_interval) then begin
        message,'sig and ref have different channel spacings, can not fold',/info
        return,-1
    endif

    sigF0 = chantofreq(sig,0.d)
    refF0 = chantofreq(ref,0.d)
    chan_shift = (refF0-sigF0)/sig.frequency_interval
    
    if chan_shift eq 0.0 then begin
        message,'Frequency switch is 0 channels - result is an average of sig and ref',/info
    endif

    if abs(chan_shift) ge nsig then begin
        message, 'Frequency switch is > number of channels, no overlap'
     endif

    if keyword_set(blankinterp) then begin
       dcinterp,sig,/quiet
       dcinterp,ref,/quiet
    endif

    ; note any blanks in sig
    sigBlanks = where(finite(*sig.data_ptr) eq 0, sigBlankCount)

    ; dcshift shifts things in place
    ; copy ref to where the result will go and shift it
    ; noting where the shifted blanks in ref are
    data_copy,ref,result
    dcshift,result,chan_shift,ftol=ftol,blanks=refBlanks
    if refBlanks[0] eq -1 then begin
       refBlankCount = 0
    endif else begin
       refBlankCount = n_elements(refBlanks)
    endelse

    if not keyword_set(nomask) then begin
                                ; mask sig by refBlanks and ref by sigBlanks
       if sigBlankCount gt 0 then begin
                                ; shifted ref is in result
          (*result.data_ptr)[sigBlanks] = !values.f_nan
       endif
       if refBlankCount gt 0 then begin
          (*sig.data_ptr)[refBlanks] = !values.f_nan
       endif
    endif

    ; average them together
    a = {accum_struct}
    dcaccum,a,sig
    dcaccum,a,result
    accumave,a,result,/quiet,count=count
    if (count ne 2) then begin
        if count lt 0 then begin
            message,'unexpected problems in averaging 2 parts of data during fold',/info
            if data_valid(result) ge 0 then data_free, result
            return,-1
        endif else begin
            ; one of these was all NaNs, return it as the result!
            if not finite((*sig.data_ptr)[0]) then begin
                data_copy, sig, result
            endif else begin
                data_copy, ref, result
            endelse
        endelse
    endif
        
    accumclear,a

    return, result
end

