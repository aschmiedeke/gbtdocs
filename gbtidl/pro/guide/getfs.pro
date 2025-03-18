;+
; This procedure retrieves and calibrates a frequency switched
; scan.  
;
; <p>This code could be used as a template for the user who may wish
; to develop more sophisticated calibration schemes. The spectrum is
; calibrated in Ta (K) by default.  Other recognized units are Ta* and
; Jy.
;
; <p><b>Summary</b>
;   <ul><li>Data are selected using scan, ifnum, intnum, plnum and
;   fdnum or, alternatively, sampler and intnum if you know the
;   specific sampler name (e.g. "A10").
;
;   <li>Individual integrations are processed separately.
;      Each integration is processed using <a href="../toolbox/dofreqswitch.html">dofreqswitch</a>
;
;   <li>The integrations are calibrated in Ta (K) by default.  If
;      units of Ta* or Jy are requested via the units keyword, then 
;      <a href="../toolbox/dcsetunits.html">dcsetunits</a> is used to convert to the desired units. 
;      This produces two spectra, one where the "sig" phase of the
;      integration was used as the "signal" and one where the "ref"
;      phase of the integration was used as the "signal".
;
;   <li>The two resulting data containers are combined using 
;      <a href="../toolbox/dcfold.html">dcfold</a> unless the nofold keyword is set.  This step is also 
;      skipped if the there is no frequency overlap between the two
;      spectra (the frequency switching distance is more than the
;      total number of channels).  In that case (out-of-band
;      frequency switching), the data can not be "fold"ed and this
;      step is skipped. 
;
;   <li>Averaging of individual integrations is then done using 
;      <a href="../toolbox/dcaccum.html">dcaccum</a>.  By default, integrations are weighted as described in dcaccum.  
;      If the eqweight keyword is set, then integrations are averaged with an
;      equal weight.  If the nofold keyword is set or the data is
;      out-of-band frequency-switched then the two results  are
;      averaged separately for each integration.   
;
;   <li>The final average is left in the primary data container
;      (buffer 0), and a summary line is printed. If the nofold keyword
;      is set then the other result is left in buffer 1.  These results
;      can be combined later by the user using <a href="fold.html">fold</a>  The printing of the
;      summary line can be suppressed by setting the quiet keyword. 
;
;   <li>The individual integration results can be saved to the
;      currently opened output file by setting the keepints keyword.  The
;      final average is still produced in that case.  If the nofold
;      keyword is set, the "signal" result is kept first followed by the
;      "reference" result for each integration, otherwise only the
;      folded result is saved for each integration.  In the case of
;      out-of-band frequency-switched data only the "signal" result is
;      saved unless the nofold keyword is explicitly set.
;   </ul>
; <p><b>Parameters</b>
; <p>
; The only required parameter is the scan number.  Arguments to
; identify the IF number, polarization number, and feed number are
; optional. 
; <p>
; <p> If ifnum, fdnum, or plnum are not supplied then the lowest
; values for each of those where data exists (all combinations may not
; have data) will be used, using any user-supplied values.  The value
; of ifnum is determined first, followed by fdnum and finally plnum.  If a
; combination with data can not be found then <a href="showiftab.html">showiftab</a>
; is used to show the user what the set of valid combinations are.
; The summary line includes the ifnum, fdnum, and plnum used.
; <p>
; <b>Tsys and Available Units</b>
; <p>
; The procedure calculates Tsys based on the Tcal values
; and the data.  The user can override this calculation by 
; entering a zenith system temperature.  The procedure will then correct the 
; user-supplied Tsys for the observed elevation.  If the data are
; calibrated to Ta* or Jy,  additional parameters are used.  A zenith
; opacity (tau) may be specified, and an aperture efficiency may be
; specified.  The user is strongly encouraged to enter values for
; these calibration parameters, but they will be estimated if none are
; provided.  The user can also supply a mean tcal using the tcal
; keyword.  That will override the tcal found in the data.
; <p>
; <b>Smoothing the Reference Spectra</b>
; <p>
; A parameter called smthoff can be used to smooth the reference
; spectrum in dofreqswitch.  In certain cases this can improve the
; signal to noise ratio, but it may degrade baseline shapes and
; artificially emphasize spectrometer glitches.  Use with care.  A
; value of smthoff=16 is often a good choice. 
; <p> 
; <b>Weighting of Integrations in Scan Average</b>
; <p> 
; By default, the averaging of integrations is weighted using tsys,
; exposure, and frequency_resolution as described in the <a href="../toolbox/dcaccum.html">dcaccum</a> 
; documentation. To give all integrations equal weight instead of the
; default weighting based on Tsys, use the /eqweight keyword.
; <p>
; If the data were taken with out-of-band frequency switching then no folding 
; will be done and the nofold argument is ignored.
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
; <b>Dealing with flagged channels</b>
; <p>
; When individual channels are flagged in the raw data (e.g. VEGAS
; spikes at the expected spike locations) the data values at those
; channels are replaced with Not a Number when the data is read from
; disk.  That presents a challenge when processing frequency switched
; data to avoid a spike appearing at the flagged channel locations
; after the fold step done by this procedure (unless nofold is
; selected).  When the data are combined at the fold step, each
; channel data average is the weighted average (using Tsys) of two
; data values, each from the same sky frequency but from different
; original channels in the raw data.  When indivual channels are
; flagged, that average can consist of just one finite value because
; the frequency shift will seldom lead to overlapping flagged
; channels. If there is any significant baseline structure across the
; bandpass then that single finite channel will be noticeably
; different from the local average of two channels.  That will lead to
; a noticable spike (positive or negative) at the location of a
; flagged channel, which is exactly the behavior that flagging the
; channel was trying to avoid.  
;
; <p>
; This procedure offers two ways of dealing with flagged channels to
; avoid that problem.  The default makes sure that both the original
; flagged channel and the corresponding channel in the other spectrum,
; after one of them has been shifted to align in frequency, is also
; flagged so that the final average has no finite values for that
; channel (i.e. it appears as a flagged channel).  Alternatively, the
; blankinterp keyword can be used to tell the fold procedure to
; interpolate across all blanked values before doing any shifting and
; averaging.  In the case of individually flagged channels, the
; blanked channel is replaced by the average of the two adjacent
; channels.  This obviously adds a new data value at the previously
; unknown (flagged) channel but it can make downstream data processing
; simpler by not having to worry that some of the channels contain
; non-finite values.  That may be important if the data are exported
; out of GBTIDL.  Finally, the nomask keyword can be used to turn
; off this special handling (masking) of flagged channels before the
; average (where spikes may result).  If blankinterp is used then
; nomask has no effect because the data are interpolated before the
; masking step happens.  If nofold is used then the data are never
; masked or interpolated.
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
; @param scan {in}{required}{type=integer} scan number
; @keyword ifnum {in}{optional}{type=integer} IF number
; (starting with 0). Defaults to the lowest value associated with data
; taking into account any user-supplied values for fdnum, and plnum.
; @keyword intnum {in}{optional}{type=integer} integration number,
; default is all integrations.
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
; @keyword tsys {in}{optional}{type=float} tsys at zenith, this is
; converted to a tsys at the observed elevation.  If not suppled, the
; tsys for each integration is calculated as described elsewhere.
; @keyword tau {in}{optional}{type=float} tau at zenith, if not
; supplied, it is estimated using <a href="../toolbox/get_tau.html">get_tau</a>
; tau is only used when the requested units are other than the default
; of Ta and when a user-supplied tsys value at zenith is to be used.
; @keyword ap_eff {in}{optional}{type=float} aperture efficiency, if
; not suppled, it is estimated using <a href="../toolbox/get_ap_eff.html">get_ap_eff<a>
; ap_eff is only used when the requested units are Jy.
; @keyword smthoff {in}{optional}{type=integer} smooth factor for reference spectrum
; @keyword units {in}{optional}{type=string} takes the value 'Jy',
; 'Ta', or 'Ta*', default is Ta.
; @keyword nofold {in}{optional}{type=boolean} When set, getfs does not fold
; the calibrated spectrum.  Buffer 0 then contains the result of
; (sig-ref)/ref while buffer 1 contains the result of
; (ref-sig)/sig, calibrated independently and averaged over all
; integrations.  Only data container 0 will be shown on the plotter.
; Default is unset (folded result).
; @keyword blankinterp {in}{optional}{type=boolean} When set, blanks
; are replaced, before the fold step, by a linear interpolation
; using the finite values found in the two spectra.  For isolated blanked
; channels, the replacement value is the average of the two adjacent
; channel values.  This argument is ignored if nofold is used.
; @keyword nomask {in}{optional}{type=boolean} When set, turn off the
; masking of blank channels from each spectrum on to the other, after
; the shift, when folding the data.  This may result in spikes at the
; location of blanked channels. This was the original behavior of this
; routine. This keyword is ignored if /nofold is used.
; @keyword eqweight {in}{optional}{type=boolean} When set, all
; integrations are averaged with equal weight (1.0).  Default is unset.
; @keyword tcal {in}{optional}{type=float} Cal temperature (K) to use
; in the Tsys calculation.  If not supplied, the mean_tcal value from
; the header of the cal_off switching phase data in each integration
; is used.  This must be a scalar, vector tcal is not yet supported.
; The resulting data container(s) will have it's mean_tcal header value
; set to this keyword when it is set by the user.
; @keyword quiet {in}{optional}{type=boolean} When set, the normal
; status message on successful completion is not printed.  This keyword will
; not affect error messages.  Default is unset.
; @keyword keepints {in}{optional}{type=boolean} When set, the
; individual integrations are saved to the current output file
; (as set by fileout).  This keyword is ignored if an integration is
; specified using the intnum keyword.  Default is unset.
; @keyword useflag {in}{optional}{type=boolean or string}
; Apply all or just some of the flag rules?  Default is set.
; @keyword skipflag {in}{optional}{type=boolean or string} Do not apply
; any or do not apply a few of the flag rules?  Default is unset.
; @keyword instance {in}{optional}{type=integer} Which occurence
; of this scan should be used.  Default is 0.
; @keyword file {in}{optional}{type=string} When specified, limit the search 
; for this scan (and instance) to this specific file.  Default is all files.
; @keyword timestamp {in}{optional}{type=string} The M&C timestamp associated
; with the desired scan. When supplied, scan and instance are ignored.
; @keyword status {out}{optional}{type=integer} An output value to indicate
; whether the procedure finished as expected.  A value of 1 means there were
; no problems, a value of -1 means there were problems with the
; arguments before any data was processed, and a value of 0 means that
; some of the individual integrations were processed (and possibly
; saved to the output file if keepints was set) but there was a
; problem with the final average, and the contents of the PDC remain
; unchanged. 
;
; @examples
; Typical use of getfs:
; <pre>
;    getfs,76
;    accum
;    getfs,77
;    accum
;    ave
;    show
; </pre>
; 
;
; In the following example, the spectrum is not folded and the two components
; of the calibration are shown overlaid on the plotter.  Then the data are
; folded 'by hand'. This example also shows how /skipflag can be used to
; ignore all previously set flags.
;
; <pre>
;    getfs,76,/nofold,/skipflag
;    oshow,1
;    fold
; </pre>
;
; @uses <a href="../toolbox/accumave.html">accumave</a>
; @uses <a href="../toolbox/accumclear.html">accumclear</a>
; @uses <a href="../../devel/guide/calsummary.html">calsummary</a>
; @uses <a href="../../devel/guide/check_calib_args.html">check_calib_args</a>
; @uses <a href="../toolbox/data_free.html">data_free</a>
; @uses <a href="../toolbox/dcaccum.html">dcaccum</a>
; @uses <a href="../toolbox/dcfold.html">dcfold</a>
; @uses <a href="../toolbox/dcscale.html">dcscale</a>
; @uses <a href="../toolbox/dcsetunits.html">dcsetunits</a>
; @uses <a href="../toolbox/dofreqswitch.html">dofreqswitch</a>
; @uses <a href="../../devel/guide/find_scan_info.html">find_scan_info</a>
; @uses <a href="../../devel/guide/get_calib_data.html">get_calib_data</a>
; @uses <a href="set_data_container.html">set_data_container</a>
; @uses <a href="showiftab.html">showiftab</a>
;
; @version $Id$
;-
pro getfs,scan,ifnum=ifnum,intnum=intnum,plnum=plnum,fdnum=fdnum,sampler=sampler,tsys=tsys,tau=tau,$
          ap_eff=ap_eff,smthoff=smthoff,units=units,nofold=nofold,blankinterp=blankinterp,$
          nomask=nomask,eqweight=eqweight,$
          tcal=tcal,quiet=quiet,keepints=keepints,useflag=useflag,skipflag=skipflag,$
          instance=instance,file=file,timestamp=timestamp,status=status
    compile_opt idl2

    status=-1

    ; basic argument checks
    argsOK=check_calib_args(scan,ifnum=ifnum,intnum=intnum,plnum=plnum,fdnum=fdnum,sampler=sampler, $
                            eqweight=eqweight,units=units,quiet=quiet,keepints=keepints,useflag=useflag, $
                            skipflag=skipflag,instance=instance,file=file,$
                            timestamp=timestamp,tau=tau,ap_eff=ap_eff,ret=ret,info=info)
    if not argsOK then return

    if size(info,/type) ne 8 then return

    ; FS data must have 4 swiching states, 2 CAL states and 2 SIG states.
    if info.n_switching_states ne 4 then begin
        message,'This does not appear to be standard frequency switched data.',/info
        if info.n_cal_states ne 2 then begin
            message,'The number of cal states is not 2, as needed for this procedure.',/info
        endif
        if info.n_sig_states ne 2 then begin
            message,'The number of sig states is not 2, as needed for this procedure.',/info
        endif
        return
    end

    ; Get the requested data
    data = get_calib_data(info, ret.ifnum, ret.plnum, ret.fdnum, ret.sampler, count, $
                          intnum=intnum, useflag=useflag, skipflag=skipflag)

    if count le 0 then begin
        message,"No data found, can not continue.",/info
        return
    endif

    ; from this point on, data contains data containers that must be
    ; freed whenever this routine returns to avoid memory leaks

    ; this test isn't available via scan_info, it has to wait until now
    if data[0].switch_state ne 'FSWITCH' then begin
        message,'This is apparently not frequency switched data.  switch_state = ' + data[0].switch_state,/info
        return
    endif

    ; find the 4 types of data container
    ; signal with cal, signal without cal,
    ; reference with cal, referece without cal
    sigwcal = where(data.cal_state eq 1 and data.sig_state eq 1, countSigwcal)
    sig = where(data.cal_state eq 0 and data.sig_state eq 1, countSig)
    refwcal = where(data.cal_state eq 1 and data.sig_state eq 0, countRefwcal)
    ref = where(data.cal_state eq 0 and data.sig_state eq 0, countRef)

    ; Final sanity checks

    ; In this calibration, we calibrate each integration separately
    ; and then average the results.  That means that we need the same
    ; number of data containers of each type, one per integration.
    if n_elements(intnum) eq 1 then begin
       expectedCount = 1
    endif else begin
       ; find appropriate number for this sampler
       sampIndx = (where(info.samplers eq data[0].sampler_name))[0]
       expectedCount = info.n_sampints[sampIndx]
    endelse
    if (countSigwcal ne expectedCount or countSigwcal ne countSig or $
        countSigwcal ne countRefwcal or countSigwcal ne countRef) then begin
        message,"Unexpected number of spectra retrieved for some or all of the switching phases, can not continue.",/info
        data_free, data
        return
    endif

    ; watch for out-of-band frequency switching, it's okay, just turn on nofold if true.
    thisnofold=keyword_set(nofold)
    sig0 = sig[0]
    ref0 = ref[0]
    sigF0 = chantofreq(data[sig0],0.d)
    refF0 = chantofreq(data[ref0],0.d)
    chan_shift = (refF0-sigF0)/data[sig0].frequency_interval
    npts = data_valid(data[sig0])
    if abs(chan_shift) ge npts then thisnofold = 1

    status = 0
    missing = 0

    if keyword_set(eqweight) then weight = 1.0 ; else undefined and use default weight

    res1accum = {accum_struct}
    if thisnofold then res2accum = {accum_struct}
    tauInts = fltarr(expectedCount)
    apEffInts = tauInts
    for n_int = 0,(expectedCount-1) do begin
        dofreqswitch,data[sigwcal[n_int]],data[sig[n_int]],data[refwcal[n_int]],data[ref[n_int]],smthoff,$
                     tsys=tsys,tau=tau,tcal=tcal,sigResult=sigResult,refResult=refResult
        if thisnofold then begin
            ; convert units on both result
            dcsetunits,sigResult,units,tau=tau,ap_eff=ap_eff
            dcsetunits,refResult,units,tau=tau,ap_eff=ap_eff,$
                       ret_tau=ret_tau,ret_ap_eff=ret_ap_eff
        endif else begin
            ; fold the two results
            folded = dcfold(sigResult,refResult,blankinterp=blankinterp,nomask=nomask)
            data_copy, folded, sigResult
            data_free, folded
            ; and convert theunits
            dcsetunits,sigResult,units,tau=tau,ap_eff=ap_eff,$
                       ret_tau=ret_tau,ret_ap_eff=ret_ap_eff
        endelse
        ; these are only used in the status line at the end
        tauInts[n_int] = ret_tau
        apEffInts[n_int] = ret_ap_eff

        dcaccum,res1accum,sigResult,weight=weight
        if thisnofold then dcaccum,res2accum,refResult,weight=weight
        if keyword_set(keepints) then begin
            ; re-use existing DCs so space isn't wasted.
            ; can't use the array element directly as it would
            ; not be passed by reference so would not be changed
            ; won't work : data_copy,sigResult,data[sig[n_int]]
            ; instead, do this
            tmp = data[sig[n_int]] ; gets the right pointer
            data_copy, sigResult, tmp ; copies header, re-uses pointer
            data[sig[n_int]] = tmp ; puts it back in place
            if keyword_set(nofold) then begin
                ; same here
                tmp = data[ref[n_int]] ; gets the right pointer
                data_copy, refResult, tmp ; copies header, re-uses pointer
                data[ref[n_int]] = tmp ; puts it back in place
            endif
        endif
    endfor
    if keyword_set(keepints) then begin
        putchunk,data[sig]
        if keyword_set(nofold) then putchunk,data[ref]
    endif
    naccum1 = res1accum.n
    if naccum1 le 0 then begin
        message,'Result is all blanked - probably all of the data were flagged',/info
        ; sigResult must therefor be all blanked, use it as the end result
        set_data_container, sigResult
        data_free, sigResult
        if data_valid(refResult) gt 0 then data_free, refResult
        if data_valid(res2accum) gt 0 then data_free, res2accum
        data_free, data
        return
    endif
    accumave,res1accum,sigResult,/quiet
    missing = naccum1 ne expectedCount
    if thisnofold then begin
        naccum2 = res2accum.n
        if naccum2 le 0 then begin
            message,'Result in buffer 1 is all blanked - probably at least one phase in each integration was blanked.',/info
            message,'Can not continue - units of result in primary data container may not be as expected.',/info
            ; refResult must be all blanked, use it as the result in buffer 1
            set_data_container, refResult, buffer=1
            ; clean up
            data_free,sigResult
            data_free,refResult
            data_free, data
            return
        endif
        accumave,res2accum,refResult,/quiet
        missing = missing or naccum2 ne expectedCount
    endif

    status = 1
    set_data_container, sigResult
    if thisnofold then set_data_container, refResult, buffer=1
    if not keyword_set(quiet) then begin
        if missing then nmiss = expectedCount-naccum1
        calsummary, info.scan, sigResult.tsys, sigResult.units, $
                    tauInts=tauInts, apEffInts=apEffInts, missingInts=nmiss, $
                    ifnum=ret.ifnum,plnum=ret.plnum,fdnum=ret.fdnum
    endif
                                                          
    data_free, data
    data_free, sigResult
    if data_valid(refResult) gt 0 then data_free, refResult

end
