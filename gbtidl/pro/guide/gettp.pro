;+
; This procedure retrieves and calibrates a total power scan. 
;
; <p>This code can be used as a template for the user who may wish to
; develop more tailored calibration schemes.
;
;<p><b>Summary</b>
;  <ul><li>Data are selected using scan, ifnum, intnum, plnum, and
;     fdnum or, alternatively, sampler and intnum if you know the
;     specific sampler name (e.g. "A10").
;  
;  <li>Individual integrations are processed separately using
;     <a href="../toolbox/dototalpower.html">dototalpower</a>.  This averages the two switching phases (with cal 
;     and without cal) and calculates a mean system temperature.
;     For scans without any CAL switching data (TPnoCal) then
;     nothing is done at this step.  <b>Note:</b> this step is done
;     even when the data from only one state is requested using the
;     cal_state or sig_state keywords.  If the data from one of the
;     two states is blanked for a given integration then the resulting
;     Tsys will be set to Not A Number.  If the default weighting is
;     used then none of the data from any integration with a non-finite
;     Tsys will be used in the final average.  The eqweight keyword
;     can be used to turn off the default weighting.
;
;  <li>Averaging of individual integrations is done using 
;      <a href="../toolbox/dcaccum.html">dcaccum</a>.  By default, integrations are weighted as described in 
;      dcaccum.  If the eqweight keyword is set, then integrations are
;      averaged with an equal weight.
;
;  <li>The final average is left in the primary data container (buffer
;      0), and a summary line is printed.  The printing of the summary
;      line can be suppressed by setting the quiet keyword.
;
;  <li>This can be used on sig-switching data (frequency-switched
;      data).  Use the sig_state keyword to select the signal
;      state (1) or the reference state (0).  Otherwise all data are
;      used.  In the case of all data being used, each individual
;      switching state is first processed (Tsys is determined and
;      the two cal states are averaged) and then the results are all
;      averaged using Tsys weighting unless eqweight is set.
;
;  <li>If cal_state is used then only that cal_state is used in the
;      average (or individual integrations).  Both cal states are
;      still  used to determine tsys.  Options are: 0 or 1.  If 1 then
;      the cal is on, if 0 it is off.
;  </ul>
; <p><b>Parameters</b>
; <p>
; The scan number is a required parameter.  Arguments to identify the
; IF number, polarization number and feed number are optional.  The
; procedure calculates  Tsys based on the Tcal values and the data.
; The Tcal value comes from the mean_tcal value in cal_off phase data
; container unless the user supplies a value using the tcal keyword.
; In that case, one tcal value is supplied and that value is used for
; all integrations processed here.  The two switching phases are
; averaged and a system temperature (Tsys) is calculated in the 
; <a href="../toolbox/dototalpower.html">dototalpower</a> procedure.
; See the documentation for that procedure for details of the Tsys
; calculation.
;
; <p> If ifnum, fdnum, or plnum are not supplied then the lowest
; values for each of those where data exists (all combinations may not
; have data) will be used, using any user-supplied values.  The value
; of ifnum is determined first, followed by fdnum and finally plnum.  If a
; combination with data can not be found then <a href="showiftab.html">showiftab</a>
; is used to show the user what the set of valid combinations are.
; The summary line includes the ifnum, fdnum, and plnum used.
; <p>
; <b>Weighting of Integrations in Scan Average</b>
; <p> 
; By default, the averaging of integrations is weighted using
; tsys, exposure, and frequency_resolution as described in the 
; <a href="../toolbox/dcaccum.html">dcaccum</a> documentation.  To give all integrations equal 
; weight instead of the default weighting based on Tsys, use the
; /eqweight keyword. 
; <p>
; <b>Using or Ignoring Flags</b>
; <p>
; Flags (set via <a href="flag.html">flag</a>) can be selectively
; applied or ignored using the useflag and skipflag keywords.  Only one of
; those two keywords can be used at a time (it is an error to use both
; at the same time).  Both can be either a boolean (/useflag or /skipflag)
; or an array of strings.  The default is /useflag, meaning that all flag
; rules that have been previously set are applied when the data is
; fetched from disk, blanking data as described by each rule.  If
; /skipflag is set, then all of the flag rules associated with this data
; are ignored and no data will be blanked when fetched from disk (it
; may still contain blanked values if the actual values in the disk
; file have already been blanked by some other process).  If useflag is a
; string or array of strings, then only those flag rules having the
; same idstring value are used to blank the data.  If skipflag is a
; string or array of strings, then all flag rules except those
; with the same idstring value are used to blank the data.
; <p>
; <b>Dealing With Duplicate Scan Numbers</b>
; <p>
; There are 3 ways to attempt to resolve ambiguities when the
; same scan number appears in the data source.  The instance keyword
; refers to the element of the returned array of scan_info structures
; that <a href="scan_info.html">scan_info</a> returns.  So, if scan 23
; appears 3 times then instance=1 refers to the second time that scan 23
; appears as returned by scan_info.  The file keyword is useful if a 
; scan is unique to a specific file and multiple files have been accessed
; using <a href="dirin.html">dirin</a>.  If file is specified and instance
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
; @param scan {in}{required}{type=integer} M&C scan number
; @keyword ifnum {in}{optional}{type=integer} IF number
; (starting with 0). Defaults to the lowest value associated with data
; taking into account any user-supplied values for fdnum, and plnum.
; @keyword intnum {in}{optional}{type=integer} Integration
; number (starting with 0), defaults to all integrations.
; @keyword plnum {in}{optional}{type=integer} Polarization number
; (starting with 0).  Defaults to the lowest value with data after
; determining the values of ifnum and fdnum if not supplied by the
; user.
; @keyword fdnum {in}{optional}{type=integer} Feed number.  Defaults
; to the lowest value with data after determining the value of ifnum
; if not supplied by the user and using any value of plnum supplied by
; the user.  
; @keyword sampler {in}{optional}{type=string} sampler name, this is
; an alternative way to specify ifnum,plnum, and fdnum.  When sampler
; name is given, ifnum, plnum, and fdnum must not be given.
; @keyword eqweight {in}{optional}{type=boolean} When set, all
; integrations are averaged with equal weight (1.0).  Default is unset.
; @keyword tcal {in}{optional}{type=float} Cal temperature (K) to use
; in the Tsys calculation.  If not supplied, the mean_tcal value from
; the header of the cal_off switching phase data in each integration
; is used.  This must be a scalar, vector tcal is not yet supported.
; The resulting data container will have it's mean_tcal header value
; set to this keyword when it is set by the user.
; @keyword sig_state {in}{optional}{type=integer} For use with
; sig-switched data.  If sig_state is 1 then only the signal data are
; used, if sig_state is 0 then only the reference data are used.
; @keyword cal_state {in}{optional}{type=integer} If cal_state is 1
; then only the cal-on data is used to calculate the average or
; integration values.  If cal_state is 0 then only the cal-off data
; are used.  If unset then all cal switching states are used.  Both
; states are always used to determine Tsys.
; @keyword wcalpos {in}{optional}{type=string} Only select data
; matching this wcalpos value (the WBand calposition label).  If not
; supplied (the default) no selection on wcalpos will be done.
; @keyword subref {in}{optional}{type=integer} Only select data
; matching this subref value (the subref_state value used when
; subreflector nodding to indicate the position of the subreflector: 1
; and -1 are the two positions and 0 indicates motion during that
; integration).  If not supplied (the default) no selection on subref
; will be done.
; @keyword quiet {in}{optional}{type=boolean} When set, the normal
; status message on successful completion is not printed.  This will
; not affect error messages. Default is unset.
; @keyword keepints {in}{optional}{type=boolean} When set, the
; individual integrations are saved to the current output file
; (fileout).  This keyword is ignored if a specific integration is requested
; using the intnum keyword.  Default is unset.
; @keyword useflag {in}{optional}{type=boolean or string}
; Apply all or just some of the flag rules?  Default is set.
; @keyword skipflag {in}{optional}{type=boolean or string}{default=unset} Do not apply
; any or do not apply a few of the flag rules?  Default is unset.
; @keyword instance {in}{optional}{type=integer} Which occurrence
; of this scan should be used.  Default is 0.
; @keyword file {in}{optional}{type=string} When specified, limit the search 
; for this scan (and instance) to this specific file.  Default is to
; search all files currently opened.
; @keyword timestamp {in}{optional}{type=string} The M&C timestamp associated
; with the desired scan. When supplied, scan and instance are
; ignored.
; @keyword status {out}{optional}{type=integer} An output parameter to indicate
; whether the procedure finished as expected.  A value of 1 means there were
; no problems, a value of -1 means there were problems with the
; arguments before any data was processed, and a value of 0 means that
; some of the individual integrations were processed (and possibly
; saved to the output file if keepints was set) but there was a
; problem with the final average and the contents of buffer 0 likely
; contains just the result from the last integration processed. This
; keyword is primarily of use when using gettp within another
; procedure or function.
;q
; @examples
; A simple version of (on-off)/off using two total power scan.
; <pre>
;   gettp, 24   ; this is the "on" data
;   copy,0,10
;   gettp, 31   ; this is the "off" data
;   copy,0,11
;   subtract, 10, 11  ; result in 0
;   divide, 0, 11     ; overwrites result in 0; </pre>
;
; @uses <a href="../toolbox/accumave.html">accumave</a>
; @uses <a href="../toolbox/accumclear.html">accumclear</a>
; @uses <a href="../../devel/guide/calsummary.html">calsummary</a>
; @uses <a href="../../devel/guide/check_calib_args.html">check_calib_args</a>
; @uses <a href="../toolbox/data_free.html">data_free</a>
; @uses <a href="../toolbox/dcaccum.html">dcaccum</a>
; @uses <a href="../toolbox/dcscale.html">dcscale</a>
; @uses <a href="../toolbox/dcsetunits.html">dcsetunits</a>
; @uses <a href="../toolbox/dototalpower.html">dototalpower</a>
; @uses <a href="../../devel/guide/find_scan_info.html">find_scan_info</a>
; @uses <a href="../../devel/guide/get_calib_data.html">get_calib_data</a>
; @uses <a href="set_data_container.html">set_data_container</a>
; @uses <a href="showiftab.html">showiftab</a>
;
; @version $Id$
;-

pro gettp,scan,ifnum=ifnum,intnum=intnum,plnum=plnum,fdnum=fdnum,sampler=sampler,eqweight=eqweight, $
          tcal=tcal,sig_state=sig_state,cal_state=cal_state,wcalpos=wcalpos,subref=subref, $
          quiet=quiet,keepints=keepints,useflag=useflag, $
          skipflag=skipflag,instance=instance,file=file,timestamp=timestamp,status=status
    compile_opt idl2

    status = -1

    ; basic argument checks
    argsOK=check_calib_args(scan,ifnum=ifnum,intnum=intnum,plnum=plnum,fdnum=fdnum,sampler=sampler, $
                            eqweight=eqweight,quiet=quiet,keepints=keepints,useflag=useflag, $
                            sig_state=sig_state,skipflag=skipflag,instance=instance,file=file,$
                            timestamp=timestamp,ret=ret, info=info)
    if not argsOK then return

    ; Is the info look ok?
    if size(info,/type) ne 8 then return
    
    ; This scan must have 1 or CAL states to be used here
    if info.n_cal_states gt 2 then begin
        message,string("This does not have 1 or 2 CAL switching states."),/info
        return
    endif

    ; If sig_state selection chosen but there is no sig switching - error
    if ret.sig_state ge 0 and info.n_sig_states ne 2 then begin
        message,"sig_state argument can only be used for data where the sigref state changes (e.g. frequency switching)",/info
        return
     endif

    ; if wcalpos selection is chosen make sure the string exists in this scan
    if n_elements(wcalpos) gt 1 then begin
       message,"Can only select a single WCALPOS value at a time",/info
       return
    endif
    if n_elements(wcalpos) ne 0 then begin
       if where(info.wcalpos eq wcalpos) lt 0 then begin
          message,'WCALPOS value is not found in this scan.  Choose from :' + strjoin(info.wcalpos,' '),level=-1,/info
          return
       endif
    endif

    ; if subref selection is chosen, value must be 1, 0 or -1.
    if n_elements(subref) gt 1 then begin
       message,"Can only select a single SUBREF value at a time",/info
       return
    endif
    if n_elements(subref) ne 0 then begin
       if subref ne 1 and subref ne 0 and subref ne -1 then begin
          message,'SUBREF value must be 1, 0 or -1.',level=-1,/info
          return
       endif
    endif
    ; Get the requested data
    data = get_calib_data(info, ret.ifnum, ret.plnum, ret.fdnum, ret.sampler, count, $
                          intnum=intnum, useflag=useflag, skipflag=skipflag, sig_state=ret.sig_state, wcalpos=wcalpos, subref=subref)

    if count le 0 then begin
        message,"No data found, can not continue.",/info
        return
     endif

    ; from this point on, data contains data containers that must be
    ; freed whenever this routine returns to avoid memory leaks

    doTPcal = info.n_cal_states eq 2
    doSingleCal = 0
    if n_elements(cal_state) ne 0 then begin
        ; cal state selection is being tried
        if ~doTPcal then begin
            ; this is an error
            message,"cal_state argument can only be used for cal-switched data",/info
            data_free, dataX
            return
        endif
        if cal_state ne 0 and cal_state ne 1 then begin
            message,"cal_state must be 0 or 1",/info
            data_free, data
            return
        endif
        doSingleCal = 1
    endif
    if doTPcal then begin
        ; tp with cal

        ; find where CAL is on and where CAL is off
        caloff = where(data.cal_state eq 0, countOff)
        calon = where(data.cal_state eq 1, countOn)

        ; Final sanity checks 

        ; In this calibration, we calibrate each integration separately 
        ; and then average the results.  That means that we need the
        ; same number of cal on as cal off values.
        if (countOff ne countOn) then begin 
            message,'Number of spectra with CAL off is not the same as the number with CAL on, can not continue',/info
            data_free, data
            return
        endif
        checkCount = countOff
    endif else begin
        checkCount = count
    endelse
        
    ; And finally, there should be one spectra per sig state per 
    ; integration for each cal state 
    ; this check is only important for 2-cal state data
    ; sampler_name should be constant in data, use first row value
    sampIndx = (where(info.samplers eq data[0].sampler_name))[0]
    nIntegrations = info.n_sampints[sampIndx]
    ; only do the full check if there is cal switching and 
    ; there is no subref selection
    if info.n_cal_states eq 2 and n_elements(subref) eq 0 then begin
       ; print,'Doing full check'
       nIntegrations = (n_elements(intnum) eq 1) ? 1 : nIntegrations
       expectedCount = info.n_sig_states * nIntegrations
                                ; if sig selection, expect 1/2 that
       if ret.sig_state ge 0 then expectedCount = expectedCount / 2
    
       if (checkCount ne expectedCount) then begin
          message,"Unexpected number of spectra retrieved, can not continue.",/info
          ; one possible cause - probably a bad configuration
          if total(data.sampler_name eq data[0].sampler_name) ne n_elements(data) then begin
             message,"More than one sampler was selected.  This is not normally possible for the GBT.",/info
             message,"It may indicate a problem with the configuration.",/info
             message,"Single samplers can be selected by gettp using the 'sampler' argument'",/info
             message,"Valid samplers for this data are: "+strjoin(info.samplers,' '),/info
          endif
          data_free, data
          return
       endif
       ; this ensures we use all selected sig_states
       nIntegrations = expectedCount
    endif else begin
       ; print,'Partial check'
       ; either way, expected count is what we got
       expectedCount = checkCount
       ; divide by total number of states to get number 
       ; of integrations
       nStates = info.n_sig_states * info.n_cal_states
       nIntegrations = expectedCount / nStates
    endelse
   
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
        if doTPcal then begin
            dototalpower,result,data[caloff[i]],data[calon[i]],tcal=tcal
        endif else begin
            data_copy,data[i],result
        endelse
        if doSingleCal then begin
            if cal_state eq 0 then begin
                data[caloff[i]].tsys = result.tsys
                dcaccum,thisaccum,data[caloff[i]],weight=weight
            endif else begin
                data[calon[i]].tsys = result.tsys
                dcaccum,thisaccum,data[calon[i]],weight=weight
            endelse
        endif else begin
            dcaccum,thisaccum,result,weight=weight
        endelse
        if doTPcal and keyword_set(keepints) then begin
            ; re-use raw data containers to conserve space
            ; defer the actual keep until later
            ; takes 3 steps because of the nature of IDL
            ; data passing (value vs reference)
            if doSingleCal then begin
                if cal_state eq 1 then begin
                    tmp = data[caloff[i]]
                    data_copy, data[calon[i]], tmp
                    data[caloff[i]] = tmp
                endif
                    ; cal_state = 1 is caloff, which is all 
                    ; ready to be written out - no additional
                    ; copy needed
            endif  else begin
                tmp = data[caloff[i]]
                data_copy, result, tmp
                data[caloff[i]] = tmp
            endelse
        endif
    endfor

    if keyword_set(keepints) then begin
        if doTPcal then begin
            putchunk, data[caloff]
        endif else begin
            putchunk, data
        endelse
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
                   ifnum=ret.ifnum,plnum=ret.plnum,fdnum=ret.fdnum
    endif

    ; clean up the data
    data_free,data
end
