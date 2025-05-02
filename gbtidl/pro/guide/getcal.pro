; docformat = 'rst'

;+
; This procedure retrieves the "cal" signal from a cal-switched scan. 
;
; This code can be used as a template for the user who may wish to
; develop more tailored calibration schemes.
;
; **Summary** 
;   * Data are selected using ``scan``, ``ifnum``, ``intnum``, ``plnum``, and
;     ``fdnum`` or, alternatively, ``sampler`` and ``intnum`` if you know the
;     specific sampler name (e.g. "A10").
;  
;   * Individual integrations are processed separately using
;     :idl:pro:`docal`.  This differences the two switching phases (with cal 
;     and without cal) and calculates a mean system temperature.
;
;   * Averaging of individual integrations is done using 
;     :idl:pro:`dcaccum`.  By default, integrations are weighted as described in 
;     dcaccum.  If the eqweight keyword is set, then integrations are
;     averaged with an equal weight.
;
;   * The final average is left in the primary data container (buffer
;     0), and a summary line is printed.  The printing of the summary
;     line can be suppressed by setting the quiet keyword.
; 
;   * This can be used on sig-switching data (frequency-switched
;     data). Use the sig_state keyword to select the signal state (1) or the
;     reference state (0).  Otherwise all data are used.
;  
; **Parameters**
; 
; The scan number is required.  Arguments to identify the IF number, 
; polarization number and feed number are optional.  The procedure 
; calculates  Tsys based on the Tcal values and the data. The Tcal value
; comes from the mean_tcal value in cal_off phase data container unless 
; the user supplies a value using the tcal keyword. In that case, one tcal
; value is supplied and that value is used for all integrations processed
; here.  The two switching phases are differenced and a system temperature
; (Tsys) is calculated in the :idl:pro:`docal` procedure. See the documentation
; for that procedure for details of the Tsys calculation.
; 
; If ifnum, fdnum, or plnum are not supplied then the lowest
; values for each of those where data exists (all combinations may not
; have data) will be used, using any user-supplied values.  The value
; of ifnum is determined first, followed by fdnum and finally plnum.  If a
; combination with data can not be found then :idl:pro:`showiftab`
; is used to show the user what the set of valid combinations are.
; The summary line includes the ifnum, fdnum, and plnum used.
; 
; **Weighting of Integrations in Scan Average**
; 
; By default, the averaging of integrations is weighted using
; tsys, exposure, and frequency_resolution as described in the 
; :idl:pro:`dcaccum` documentation.  To give all integrations equal 
; weight instead of the default weighting based on Tsys, use the
; ``/eqweight`` keyword. 
; 
; **Using or Ignoring Flags**
; 
; Flags (set via :idl:pro:`flag`) can be selectively
; applied or ignored using the useflag and skipflag keywords.  Only one of
; those two keywords can be used at a time (it is an error to use both
; at the same time).  Both can be either a boolean (``/useflag`` or ``/skipflag``)
; or an array of strings.  The default is /useflag, meaning that all flag
; rules that have been previously set are applied when the data is
; fetched from disk, blanking data as described by each rule.  If
; ``/skipflag`` is set, then all of the flag rules associated with this data
; are ignored and no data will be blanked when fetched from disk (it
; may still contain blanked values if the actual values in the disk
; file have already been blanked by some other process).  If ``useflag`` is a
; string or array of strings, then only those flag rules having the
; same idstring value are used to blank the data.  If ``skipflag`` is a
; string or array of strings, then all flag rules except those
; with the same idstring value are used to blank the data.
; 
; **Dealing With Duplicate Scan Numbers**
; 
; There are 3 ways to attempt to resolve ambiguities when the
; same scan number appears in the data source.  The instance keyword
; refers to the element of the returned array of scan_info structures
; that :idl:pro:`scan_info` returns.  So, if scan 23
; appears 3 times then instance=1 refers to the second time that scan 23
; appears as returned by scan_info.  The file keyword is useful if a 
; scan is unique to a specific file and multiple files have been accessed
; using :idl:pro:`dirin`.  If file is specified and instance
; is also specified, then instance refers to the instance of that scan
; just within that file (which may be different from its instance within
; all opened files when dirin is used).  The timestamp keyword is another
; way to resolve ambiguous scan numbers.  The timestamp here is a string
; used essentially as a label by the monitor and control system and is
; unique to each scan.  The format of the timestamp string is
; "YYYY_MM_DD_HH:MM:SS".  When timstamp is given, scan and instance
; are ignored.  If more than one match is found, an error is 
; printed and this procedure will not continue.  
;
; :Params:
; 
;   scan : in, required, type=integer
;       M&C scan number
; 
; :Keywords:
; 
;   ifnum : in, optional, type=integer
;       IF number starting with 0). Defaults to the lowest value associated
;       with data taking into account any user-supplied values for fdnum, 
;       and plnum.
;
;   intnum : in, optional, type=integer
;       Integration number (starting with 0), defaults to all integrations.
;
;   plnum : in, optional, type=integer
;       Polarization number (starting with 0).  Defaults to the lowest value
;       with data after determining the values of ifnum and fdnum if not 
;       supplied by the user.
;
;   fdnum : in, optional, type=integer
;       Feed number.  Defaults to the lowest value with data after determining
;       the value of ifnum if not supplied by the user and using any value of
;       plnum supplied by the user.  
;
;   sampler : in, optional, type=string
;       sampler name, this is an alternative way to specify ifnum,plnum, and fdnum.
;       When sampler name is given, ifnum, plnum, and fdnum must not be given.
;   
;   eqweight : in, optional, type=boolean
;       When set, all integrations are averaged with equal weight (1.0).  
;       Default is unset.
; 
;   tcal : in, optional, type=float
;       Cal temperature (K) to use in the Tsys calculation.  If not supplied, the 
;       mean_tcal value from the header of the cal_off switching phase data in each 
;       integration is used.  This must be a scalar, vector tcal is not yet supported.
;       The resulting data container will have it's mean_tcal header value set to this
;       keyword when it is set by the user.
; 
;   sig_state : in, optional, type=integer
;       For use with sig-switched data.  If sig_state is 1 then only the signal 
;       data are used, if sig_state is 0 then only the reference data are used.
; 
;   quiet : in, optional, type=boolean
;       When set, the normal status message on successful completion is not printed.
;       This will not affect error messages. Default is unset.
; 
;   keepints : in, optional, type=boolean
;       When set, the individual integrations are saved to the current output file
;       (fileout).  This keyword is ignored if a specific integration is requested
;       using the intnum keyword.  Default is unset.
; 
;   useflag : in, optional, type=boolean or string
;       Apply all or just some of the flag rules?  Default is set.
; 
;   skipflag : in, optional, type=boolean or string, default=unset
;       Do not apply any or do not apply a few of the flag rules?  Default is unset.
; 
;   instance : in, optional, type=integer
;       Which occurrence of this scan should be used.  Default is 0.
;   
;   file : in, optional, type=string
;       When specified, limit the search  for this scan (and instance) to this 
;       specific file.  Default is to search all files currently opened.
; 
;   timestamp : in, optional, type=string
;       The M&C timestamp associated with the desired scan. When supplied, scan and 
;       instance are ignored.
; 
;   status : out, optional, type=integer
;       An output parameter to indicate whether the procedure finished as expected.
;       A value of 1 means there were no problems, a value of -1 means there were
;       problems with the arguments before any data was processed, and a value of 0 
;       means that some of the individual integrations were processed (and possibly
;       saved to the output file if keepints was set) but there was a problem with 
;       the final average and the contents of buffer 0 likely contains just the result 
;       from the last integration processed. This keyword is primarily of use when 
;       using gecal within another procedure or function.
;
; :Uses:
; 
; :idl:pro:`accumave`
; :idl:pro:`accumclear`
; :idl:pro:`DATA_FREE`
; :idl:pro:`dcaccum`
; :idl:pro:`dcscale`
; :idl:pro:`docal`
; :idl:pro:`set_data_container`
; :idl:pro:`showiftab`
;
;-
pro getcal,scan,ifnum=ifnum,intnum=intnum,plnum=plnum,fdnum=fdnum,sampler=sampler,eqweight=eqweight, $
           tcal=tcal,sig_state=sig_state,quiet=quiet,keepints=keepints,useflag=useflag,$
           skipflag=skipflag,instance=instance,file=file,timestamp=timestamp,status=status
    compile_opt idl2

    status = -1

    ; basic argument checks
    argsOK=check_calib_args(scan,ifnum=ifnum,intnum=intnum,plnum=plnum,fdnum=fdnum,sampler=sampler, $
                            eqweight=eqweight,quiet=quiet,keepints=keepints,useflag=useflag, $
                            sig_state=sig_state,skipflag=skipflag,instance=instance,file=file,$
                            timestamp=timestamp,ret=ret,info=info)
    if not argsOK then return

    if size(info,/type) ne 8 then return

    ; This scan must have 1 or CAL states to be used here
    if info.n_cal_states gt 2 then begin
        message,string("This does not have 1 or 2 CAL switching states."),/info
        return
    endif

    ; If sig_state selection chosen but there is no sig switching
    ; then issue warning
    if ret.sig_state ge 0 and info.n_sig_states ne 2 then begin
        message,"sig_state argument can only be used for data where the sigref state changes (e.g. frequency switching)",/info
    endif
    
    ; Get the requested data
    data = get_calib_data(info, ret.ifnum, ret.plnum, ret.fdnum, ret.sampler, count, $
                          intnum=intnum, useflag=useflag, skipflag=skipflag, sig_state=ret.sig_state)

    if count le 0 then begin
        message,"No data found, can not continue.",/info
        return
    endif

    ; from this point on, data contains data containers that must be
    ; freed whenever this routine returns to avoid memory leaks

    if info.n_cal_states ne 2 then begin
       message,'getcal requires cal-switching data',/info
       return
    endif

    ; find where CAL is on and where CAL is off
    sigoff = where(data.cal_state eq 0, countOff)
    sigon = where(data.cal_state eq 1, countOn)

    ; Final sanity checks 

    ; In this calibration, we calibrate each integration separately 
    ; and then average the results.  That means that we need the
    ; same number of cal on as cal off values.
    if (countOff ne countOn) then begin 
       message,'Number of spectra with CAL off is not the same as the number with CAL on, can not continue',/info
       data_free, data
       return
    endif
        
    ; And finally, there should be one spectra per sig state per 
    ; integration for each cal state 
    if n_elements(intnum) eq 1 then begin
       nIntegrations = 1
    endif else begin
       ; find appropriate value for this sampler
       sampIndx = (where(info.samplers eq data[0].sampler_name))[0]
       nIntegrations = info.n_sampints[sampIndx]
    endelse

    expectedCount = info.n_sig_states * nIntegrations
    ; if sig selection, expect 1/2 that
    if ret.sig_state ge 0 then expectedCount = expectedCount / 2
    
    if (countOff ne expectedCount) then begin
        message,"Unexpected number of spectra retrieved, can not continue.",/info
        data_free, data
        return
    endif
   
    status = 0
    missing = 0

    ; process all integrations, averaging them as they are processed
    ; keep track of the number of integrations that are not 
    ; included in the average - this happens when the result of
    ; processing that integration was a spectra where all of the data 
    ; values were blanked.

    ; if eqweight is not set, then this next line won't set
    ; the weight value here and hence "weight" in the call
    ; to dcaccum later on will still be unset, causing 
    ; dcaccum to use it's default weighting.
    if keyword_set(eqweight) then weight = 1.0 ; else undefined and use default weight
    thisaccum = {accum_struct}
    for i = 0,(nIntegrations-1) do begin
       docal,result,data[sigoff[i]],data[sigon[i]],tcal=tcal
       dcaccum,thisaccum,result,weight=weight
       if keyword_set(keepints) then begin
          ; re-use raw data containers to conserve space
          ; defer the actual keep until later
          ; takes 3 steps because of the nature of IDL
          ; data passing (value vs reference)
          tmp = data[sigoff[i]]
          data_copy, result, tmp
          data[sigoff[i]] = tmp
       endif
    endfor

    if keyword_set(keepints) then begin
       putchunk, data[sigoff]
    endif

    naccum1 = thisaccum.n
    if naccum1 le 0 then begin
        ; nothing was actually accumed - all ints must have been blank
        message,'Result is all blanked - probably all of the data were flagged',/info
        ; make sure something is put into the PDC
        ; this can only happen if result is all blanks, use that
        set_data_container,result
        ; clean up
        accumclear, thisaccum
        data_free, result
        data_free, data
        return
    endif else begin
        ; get the average
        accumave,thisaccum, thisave, /quiet
        missing = naccum1 ne nIntegrations
        ; put it into the PDC
        set_data_container, thisave
        ; cleanup the averager
        data_free, thisave
        accumclear, thisaccum
        status = 1
    endelse
    ; clean up the result temporary
    data_free, result

    if not keyword_set(quiet) then begin
        if missing then nmiss = nIntegrations-naccum1
        calsummary,info.scan,!g.s[0].tsys,'',missingInts=nmiss, $
                   ifnum=ret.ifnum,fdnum=ret.fdnum,plnum=ret.plnum
    endif

    ; clean up the data
    data_free,data
end
