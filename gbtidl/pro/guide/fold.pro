; docformat = 'rst'

;+
; Average two parts of in-band frequency switching (signal and
; reference phases, with the cal-switching phases already calibrated).
;
; Typically this happens during or after getfs.  The two data
; containers are assumed to be in 0 and 1.  It does not matter which
; data container contains which part since their relative distance in
; frequency is used to determine how one is shifted to align with the
; other. The result is always placed in data container 0.  If the two
; data containers do not overlap in frequency, then there is nothing
; to fold and an error message will be printed.
;
; The "ref" data container is shifted to align in sky frequency
; with the "sig" data container using :idl:pro:`dcshift` and the two data 
; containers are averaged - weighting each by the inverse of square of
; their system temperatures.  The system temperature in the result is
; the weighted average of the two system temperatures.
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
;   sig : in, optional, type=integer, default=0
;       The global buffer number to use as the signal part in the average.
;       The result will contain a copy of this data container's header 
;       information except for tsys as described above. The data at sig
;       is overwritten by the result if sig is 0 (the default)
;   ref : in, optional, type=integer, default=1
;       The global buffer number to use as the reference part in the
;       average. This data is shifted using :idl:pro:`dcshift` to align
;       with "sig" before averaging.  The data in ref are never altered 
;       by this procedure.
;
; :Keywords:
;   ftol ; in, optional, type=double}{default=0.005} The fractional
;       channel shift tolerance.  If the fractional part of the channel
;       shift necessary to align the two parts is less than this value, no
;       fractional shift as described in the documentation for 
;       :idl:pro:`dcshift`  will be done.  It might be useful to
;       turn off the fractional shift because it can cause aliases and
;       ringing in the case of very strong lines or other sharp features.
;       If ftol > 0.5 no fractional shifts will be done.
;   blankinterp : in, optional, type=boolean
;       When set, blanks are replaced before shifting and averaging by a
;       linear interpolation using the finite values found in the two
;       spectra.  The :idl:pro:`dcinterp` procedure is used. For isolated
;       blanked channels, the replacement value is the average of the two
;       adjacent channel values.
;   nomask : in, optional, type=boolean
;       When set, turn off the masking of blank channels from each spectrum
;       on to the other, after the shift.  This may result in spikes at the
;       location of blanked channels. This was the original behavior of this
;       routine.  This keyword has no effect if blankinterp is set.
;
; :Examples:
;
;   .. code-block:: IDL
; 
;       getfs, 64, /nofold
;       fold, ftol=1.0       ; no fractional shifting is done
;
; :Uses:
;   :idl:pro:`dcfold`
;   :idl:pro:`data_free`
;   :idl:pro:`set_data_container`
;
;-
pro fold, sig, ref, ftol=ftol, blankinterp=blankinterp, nomask=nomask
    compile_opt idl2

    if not !g.line then begin
        message,'FOLD does not work on continuum data, sorry.',/info
        return
    endif

    catch, error_status
    if (error_status ne 0) then begin
        ; print out the error and return
        help,/last_message,output=errtext
        print,errtext[0]
        return
    endif

    if n_elements(sig) eq 0 then sig=0
    if n_elements(ref) eq 0 then ref=1
    if n_elements(ftol) eq 0 then ftol=0.005

    if (sig eq ref) then begin
        message,'Sig and ref must be different buffers',/info
        return
    endif

    nmaxind = n_elements(!g.s)
    if (sig lt 0 or sig gt nmaxind or ref lt 0 or ref gt nmaxind) then begin
        message,string(nmaxind,format='("sig and ref must be >= 0 and < ",i2)'),/info
        return
    endif

    new = dcfold(!g.s[sig],!g.s[ref],ftol=ftol,blankinterp=blankinterp,nomask=nomask)
    set_data_container,new
    data_free,new
end
