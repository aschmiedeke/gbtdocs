;+
; Procedure getbs retrieves and calibrates a beam switched Nod scan pair.  
; <p>
; Beam switched modes are not recommended on the GBT.  Total power Nod
; should be used instead.  To process total power nod data use getnod
; instead of this routine.  This procedure is provided only to
; accommodate old data.
; <p>
; The getbs routine produces a spectrum calibrated in Ta (K).  Other
; recognized unit are Ta* and Jy.
;
; <p><b>Summary</b>
;   <ul><li>Data are selected using scan, ifnum, intnum and plnum or,
;      alternatively, sampler and intnum if you know the specific
;      sampler name (e.g. "A10").  The other scan in the scan pair is 
;      found using scan (see comments below).  
;
;   <li>In beam switched data, there are two beams in each scan, some 
;      of that data comes from the signal phase, some of it from the 
;      reference phase and in each of those there is cal on and cal
;      off data.  So, there are 4 switching states in this data.
;
;   <li>Individual integrations are processed separately with the same
;      integration number in the two scans processed together.  Both
;      scans must have the same number of integrations.  Each
;      integration is processed using <a href="../toolbox/donod.html">donod</a>
;
;   <li>The integrations are calibrated in Ta (K).  If units of Ta* or
;      Jy are requested via the units keyword, then <a href="../toolbox/dcsetunits.html">dcsetunits</a>  is 
;      used to convert to the desired units.
;
;   <li>Within each integration, there are spectra identified as
;      coming from beam 1 and other spectra identified as combing from
;      beam 2.  Some of those in each scan come from the signal
;      switching phase and some come from the reference switching
;      phase.  The signal data from each integration is processed
;      together using donod and the reference data from each
;      integration is processed together also using donod.  The
;      reference data is multiplied by -1 before it is averaged with
;      the signal data for that integration. The bswitch keyword can
;      be used to limit which data is processed. 
;
;   <li>Averaging of individual integrations is then done using 
;      <a href="../toolbox/dcaccum.html">dcaccum</a>  By default, integrations are weighted as described in 
;      dcaccum.  If the eqweight keyword is set, then integrations are
;      averaged with an equal weight.
;
;   <li>The final average is left in the primary data container
;      (buffer 0), and a summary line is printed.  The printing of the
;      summary line can be suppressed by setting the quiet keyword.
;      The first Tys displayed is that of the result.  The other 4
;      Tsys values displayed are weighted averages of the Tsys values
;      from each of the 4 spectra that make up each integration (see
;      donod for more details).  In the case of bswitch=0, the signal
;      and reference tsys values are averaged together.  This can be
;      useful in assessing the quality of the parts of the data that
;      make up the final result. 
;
;   <li>The individual integration results can be saved to the
;      currently opened output file by setting the keepints keyword.
;      The final average is still produced in that case.  In the case
;      of bswitch=0, all 8 spectra comprising each integration are kept.
;   </ul>
; <p><b>Parameters</b>
;
; <p>The scan number is required.  Either scan in the "Nod"
; scan pair can be given.  Arguments to identify the IF number,
; polarization number, and feed number are optional.  The default
; tracking feed number, trackfdnum, (0) is the lowest numbered FEED
; found in the data.  This feed number is interpreted as the tracking
; (source) feed for the first scan in the signal phase.  Specify
; trackfdnum=1 to identify the second FEED as the tracking
; feed. Tracking feed in this context means that the source signal was
; in that beam during the source phase of the first scan of the two
; "Nod" scans. 
; <p>
; <p> If ifnum, trackfdnum, or plnum are not supplied then the lowest
; values for each of those where data exists (all combinations may not
; have data) will be used, after using any user-supplied values.  The
; value of ifnum is determined first, followed by trackfdnum and
; finally plnum.  If a combination with data can not be found then
; <a href="showiftab.html">showiftab</a> is used to show the user what
; the set of valid combinations are.  The summary line includes the
; ifnum, trackfdnum, and plnum used. 
; <p>
; <b>Tsys and Available Units</b>
; <p>
; The procedure calculates Tsys based on the Tcal values and the data
; in the non-source feeds (both scans).  The user can override this
; calculation by entering a zenith system temperature.  The procedure
; will then correct the user-supplied Tsys for the observed elevation.
; If the data are calibrated to Ta* or Jy, additional parameters  
; are used.  A zenith opacity (tau) may be specified, and an aperture
; efficiency may be specified.  The user is strongly encouraged to
; enter values for these calibration parameters, but they will be
; estimated if none are provided. The user can also supply a mean Tcal
; using the tcal keyword.  That will override the tcal found in the data.
; <p>
; <b>Smoothing the Reference Spectra</b>
; <p>
; A parameter called smthoff can be used to smooth the reference
; spectra prior to calibration.  In certain cases this can improve
; the signal to noise ratio, but it may degrade baseline shapes and
; artificially emphasize spectrometer glitches.  Use with care.  A
; value of smthoff=16 is often a good choice. 
; <p>
; <b>The Special "bswitch" Keyword</b>
; <p>
; A parameter called bswitch allows the user to select between using
; all of the data (the detault, bswitch=0) or using only data when the
; beam switch is in the "cross" (reference) or "thru" (signal)
; position.  Data taken in beam switched mode should be examined
; carefully in both cross and thru positions. 
; <p> 
; <b>Weighting of Integrations in Scan Average</b>
; <p>
; By default, internal averaging of integrations is weighted using
; tsys, exposure and frequency_resolution as described in the
; <a href="../toolbox/dcaccum.html">dcaccum</a> documentation.
; To give all integrations equal weight instead of the default
; weighting based on Tsys, use the /eqweight keyword.
; <p>
; <b>Summary Information</b>
; <p>
; The scan number printed in the status line is that of the first
; scan in the "Nod" pair - no matter which scan number you actually
; provided as the scan parameter here.  The values of ifnum,
; trackfdnum, and plnum are shown after the scan number.  The first
; Tsys printed is the tsys value in the result.  This is a weighted
; average of the Tsys values in the reference beams from both scans as
; described in <a href="../toolbox/donod.html">donod</a>  The other 4 Tsys values
; printed on the status line are the 4 Tsys values calculated by donod
; and averaged (using the appropriate weighting scheme) over all
; integrations and beam switch positions.
; <p>
; <b>Using or Ignoring Flags</b>
; <p>
; Flags (set via <a href="flag.html">flag</a>) can be selectively
; applied or ignored using the useflag and skipflag keywords.  Only
; one of  those two keywords can be used at a time (it is an error to
; use both at the same time).  Both can be either a boolean (/useflag
; or /skipflag) or an array of strings.  The default is /useflag,
; meaning that all flag rules that have been previously set are
; applied when the data is fetched from disk, blanking any data as
; described by each rule.  If /skipflag is set, then all of the flag
; rules associated with this data are ignored and no data will be
; blanked when fetched from disk (it may still contain blanked values
; if the actual values in the disk file have already been blanked by
; some other process).  If useflag is a string or array of strings,
; then only those flag rules having the same idstring value are used
; to blank the data.  If skipflag is a string or array of strings,
; then all flag rules except those with the same idstring value are
; used to blank the data. 
; <p>
; <b>Dealing With Duplicate Scan Numbers</b>
; <p>
; There are 3 ways to attempt to resolve ambiguities when the
; same scan number appears in the data source.  The instance keyword 
; refers to the element of the returned array of scan_info structures 
; that <a href="scan_info.html">scan_info</a> returns.  So, if scan 23
; appears 3 times then instance=1 refers to the second time that scan
; 23 appears as returned by scan_info.  The file keyword is useful if
; a scan is unique to a specific file and multiple files have been
; accessed using <a href="dirin.html">dirin</a>.  If file is specified and instance is also 
; specified, then instance refers to the instance of that scan just
; within that file (which may be different from its instance within
; all opened files when dirin is used).  The timestamp keyword is
; another way to resolve ambiguous scan numbers.  The timestamp here
; is a string used essentially as a label by the monitor and control
; system and is unique to each scan.  The format of the timestamp
; string is "YYYY_MM_DD_HH:MM:SS".  When timstamp is given, scan and
; instance are ignored.  If more than one match is found, an error is
; printed and this procedure will not continue.  
;
; <p>Once a unique match is found to the desired scan (using instance,
; file, or timestamp) then the scan paired with that scan necessary to
; finish this procedure is found.  The match must be found within the
; same file as the desired scan.  It must have the appropriate matching
; scan number (scan-1 if scan is the second scan in the procedure or
; scan+1 if scan is the first scan in the procedure).  If those two
; rules are not sufficient to find a unique match, the matching
; scan with the closest timestamp in the appropriate direction (before
; or after depending on which procseqn is associate with scan) is used.
; Finally, the matched pair must have the appropriate procseqn given the
; procseqn that scan is.
;
; <p>
; <b>Note</b>: if you see the message "No data found, can not continue" the
; most likely explanation is that the IF numbers are confused,
; probably due to a bad configuration (e.g. both feeds do not have
; data from the same IF and polarization).  Consequently, this calibration
; routine can not reduce that data.  It is likely that all of the
; IFNUM values for this data are -1. 
;
; @param scan {in}{required}{type=integer} M&C scan number
; @keyword ifnum {in}{optional}{type=integer} IF number
; (starting with 0). Defaults to the lowest value associated with data
; taking into account any user-supplied values for trackfdnum, and plnum.
; @keyword intnum {in}{optional}{type=integer} Integration number,
; defaults to all integrations.
; @keyword plnum {in}{optional}{type=integer} Polarization number
; (starting with 0).  Defaults to the lowest value with data after
; determining the values of ifnum and trackfdnum if not supplied by the
; user.
; @keyword sampler {in}{optional}{type=string} sampler name, this is
; an alternative way to specify ifnum and plnum.  When sampler
; name is given, ifnum and plnum must not be given.   Note that data
; from the associated switched sampler will also be used.
; @keyword trackfdnum {in}{optional}{type=integer} Tracking feed
; number.  Defaults to the lowest value with data after determining
; the value of ifnum if not supplied by the user and using any value
; of plnum supplied by the user.  
; @keyword bswitch {in}{optional}{type=integer} determines which
; beamswitch positions are used.  0=both, 1=ref, 2=sig (default 0)
; @keyword tau {in}{optional}{type=float} tau at zenith, if not
; supplied, it is estimated using <a href="../toolbox/get_tau.html">get_tau</a>
; tau is only used when the requested units are other than the default
; of Ta and when a user-supplied tsys value at zenith is to be used.
; @keyword tsys {in}{optional}{type=float} Tsys at zenith, this is
; converted to a Tsys at the observed elevation.  If not suppled, the
; Tsys for each integration is calculated as described elsewhere.
; @keyword ap_eff {in}{optional}{type=float} Aperture efficiency, if
; not suppled, it is estimated using <a href="../toolbox/get_ap_eff.html">get_ap_eff<a>
; ap_eff is only used when the requested units are Jy.
; @keyword smthoff {in}{optional}{type=integer} smooth factor for
; reference spectrum, defaults to 1 (no smoothing).
; @keyword units {in}{optional}{type=string} takes the value 'Jy',
; 'Ta', or 'Ta*', default 'Ta'.
; @keyword tcal {in}{optional}{type=float} Cal temperature (K) to use
; in the Tsys calculation.  If not supplied, the mean_tcal value from
; the header of the cal_off switching phase data in each integration
; is used.  This must be a scalar, vector tcal is not yet supported.
; The resulting data container will have it's mean_tcal header value
; set to this keyword when it is set by the user.
; @keyword eqweight {in}{optional}{type=boolean} When set, all integrations
; are averaged with equal weight (1.0).  Default is unset.
; @keyword quiet {in}{optional}{type=boolean} When set, the normal
; status message on successful completion is not printed.  This will
; not have any effect on error messages.  Default is unset.
; @keyword keepints {in}{optional}{type=boolean} When set, the
; individual integrations are saved to the current output file
; (fileout).  This is ignored if a specific integration is requested
; using the intnum keyword.  Default is unset.
; @keyword useflag {in}{optional}{type=boolean or string}
; Apply all or just some of the flag rules?  Default is set.
; @keyword skipflag {in}{optional}{type=boolean or string} Do not apply
; any or do not apply a few of the flag rules?  Default is unset.
; @keyword instance {in}{optional}{type=integer} Which occurrence
; of this scan should be used.  Default is 0.
; @keyword file {in}{optional}{type=string} When specified, limit the search 
; for this scan (and instance) to this specific file.  Default is all
; files currently opened.
; @keyword timestamp {in}{optional}{type=string} The M&C timestamp associated
; with the desired scan. When supplied, scan and instance are ignored.
; @keyword status {out}{optional}{type=integer} An output parameter to indicate
; whether the procedure finished as expected.  A value of 1 means there were
; no problems, a value of -1 means there were problems with the
; arguments before any data was processed, and a value of 0 means that
; some of the individual integrations were processed (and possible
; saved to the output file if keepints was set) but there was a
; problem with the final average and buffer 0 likely
; contains just the result from the last integration processed. This
; keyword is primarily of use when using getbs within another
; procedure or function.
;
; @examples
; <pre>
;    ; average both polarizations from ifnum=1
;    sclear
;    getbs, 76, ifnum=1, plnum=0
;    accum
;    getbs, 76, ifnum=1, plnum=1
;    accum
;    ave
; </pre>
;
; @uses <a href="../toolbox/accumave.html">accumave</a>
; @uses <a href="../toolbox/accumclear.html">accumclear</a>
; @uses <a href="../../devel/guide/calsummary.html">calsummary</a>
; @uses <a href="../../devel/guide/check_calib_args.html">check_calib_args</a>
; @uses <a href="../toolbox/data_free.html">data_free</a>
; @uses <a href="../toolbox/dcaccum.html">dcaccum</a>
; @uses <a href="../toolbox/dcscale.html">dcscale</a>
; @uses <a href="../toolbox/dcsetunits.html">dcsetunits</a>
; @uses <a href="../toolbox/donod.html">donod</a>
; @uses <a href="find_paired_info.html">find_paired_info</a>
; @uses <a href="../../devel/guide/find_scan_info.html">find_scan_info</a>
; @uses <a href="../../devel/guide/get_calib_data.html">get_calib_data</a>
; @uses <a href="set_data_container.html">set_data_container</a>
; @uses <a href="showiftab.html">showiftab</a>
;
; @version $Id$
;-

pro getbs,scan,ifnum=ifnum,intnum=intnum,plnum=plnum,trackfdnum=trackfdnum,sampler=sampler,bswitch=bswitch,tau=tau,$
          tsys=tsys,ap_eff=ap_eff,smthoff=smthoff,units=units,eqweight=eqweight, $
          tcal=tcal,quiet=quiet, keepints=keepints, useflag=useflag, skipflag=skipflag, $
          instance=instance, file=file, timestamp=timestamp, status=status
    compile_opt idl2

    status = -1

    ; basic argument checks
    argsOK=check_calib_args(scan,ifnum=ifnum,intnum=intnum,plnum=plnum,fdnum=trackfdnum, $
                            sampler=sampler,eqweight=eqweight,units=units,bswitch=bswitch,$
                            quiet=quiet,keepints=keepints,useflag=useflag, $
                            skipflag=skipflag,instance=instance,file=file,$
                            timestamp=timestamp,tau=tau,ap_eff=ap_eff,/twofeeds,ret=ret, info=info)
    if not argsOK then return

    scan1Info = info
    if size(scan1Info,/type) ne 8 then return

    ; check for appropriate info in the scan found
    ; it must be 'Nod'
    if scan1Info.procedure ne 'Nod' then begin
        message,"Cannot handle this scan: Procedure = " + strcompress(scan1Info.procedure,/remove_all),/info
        return
    end
    ; it must be one of a pair of scans
    if scan1Info.procseqn gt 2 then begin
        sProcseqn = strcompress(string(scan1Info.procseqn),/remove_all)
        message,"More than two scans in this procedure - can not continue. At least : " + sProcseqn, /info
        return
    endif

    ; locate the paired scan
    scan2Info = find_paired_info(scan1Info)
    if size(scan2Info,/type) ne 8 then begin
        message,'The other scan for this beam-switched Nod procedure can not be found.',/info
        return
    endif

    ; make sure we have them in the right order
    if (scan2Info.scan lt scan1Info.scan) then begin
        tmp = scan2Info
        scan2Info = scan1Info
        scan1Info = tmp
    endif

    ; each scan must have 4 switching states, which must
    ; be 2 CAL states and 2 sig states
    if scan1Info.n_switching_states ne 4 then begin
        message,"This does not appeat to be beam-switched Nod data - must have 4 switching states in each scan.",/info
        return
    endif
    if scan1Info.n_cal_states ne 2 then begin
        message,"This does not appear to be beam-switched Nod data - must have 2 cal states in each scan.",/info
        return
    endif
    if scan1Info.n_sig_states ne 2 then begin
        message,"This does not appear to be beam-switched Nod data - must have 2 sig states in each scan.",/info
        return
    endif

    ; get the requested data
    scan1Data = get_calib_data(scan1Info, ret.ifnum, ret.plnum, ret.fdnum, ret.sampler, scan1count, $
                               intnum=intnum, useflag=useflag,skipflag=skipflag, /twofeeds)
    if scan1count le 0 then begin
        message,'No data found for the first scan in this pair, can not continue',/info
        return
    endif

    scan2Data = get_calib_data(scan2Info, ret.ifnum, ret.plnum, ret.fdnum, ret.sampler, scan2count, $
                               intnum=intnum, useflag=useflag, skipflag=skipflag, /twofeeds)
    if scan2count le 0 then begin
        message,'No data found for the second scan in this pair, can not continue',/info
        data_free,scan1Data
        return
    endif

    ; from this point on, sigdata and refdata contain data containers 
    ; that must be freed whenever this routine returns to avoid memory leaks.
        
    ; find the 16 types of spectra
    feed1 = scan1Info.feeds[ret.fdnum]
    feed2 = scan1Info.feeds[(ret.fdnum eq 0) ? 1:0]
   
    s1_b1_ref_off = where(scan1Data.feed eq feed1 and scan1Data.cal_state eq 0 and scan1Data.sig_state eq 0 ,s1_b1_ref_off_count)
    s1_b1_ref_on  = where(scan1Data.feed eq feed1 and scan1Data.cal_state eq 1 and scan1Data.sig_state eq 0 ,s1_b1_ref_on_count)
    s2_b1_ref_off = where(scan2Data.feed eq feed1 and scan2Data.cal_state eq 0 and scan2Data.sig_state eq 0 ,s2_b1_ref_off_count)
    s2_b1_ref_on  = where(scan2Data.feed eq feed1 and scan2Data.cal_state eq 1 and scan2Data.sig_state eq 0 ,s2_b1_ref_on_count)
    s1_b2_ref_off = where(scan1Data.feed eq feed2 and scan1Data.cal_state eq 0 and scan1Data.sig_state eq 0 ,s1_b2_ref_off_count)
    s1_b2_ref_on  = where(scan1Data.feed eq feed2 and scan1Data.cal_state eq 1 and scan1Data.sig_state eq 0 ,s1_b2_ref_on_count)
    s2_b2_ref_off = where(scan2Data.feed eq feed2 and scan2Data.cal_state eq 0 and scan2Data.sig_state eq 0 ,s2_b2_ref_off_count)
    s2_b2_ref_on  = where(scan2Data.feed eq feed2 and scan2Data.cal_state eq 1 and scan2Data.sig_state eq 0 ,s2_b2_ref_on_count)
    s1_b1_sig_off = where(scan1Data.feed eq feed1 and scan1Data.cal_state eq 0 and scan1Data.sig_state eq 1 ,s1_b1_sig_off_count)
    s1_b1_sig_on  = where(scan1Data.feed eq feed1 and scan1Data.cal_state eq 1 and scan1Data.sig_state eq 1 ,s1_b1_sig_on_count)
    s2_b1_sig_off = where(scan2Data.feed eq feed1 and scan2Data.cal_state eq 0 and scan2Data.sig_state eq 1 ,s2_b1_sig_off_count)
    s2_b1_sig_on  = where(scan2Data.feed eq feed1 and scan2Data.cal_state eq 1 and scan2Data.sig_state eq 1 ,s2_b1_sig_on_count)
    s1_b2_sig_off = where(scan1Data.feed eq feed2 and scan1Data.cal_state eq 0 and scan1Data.sig_state eq 1 ,s1_b2_sig_off_count)
    s1_b2_sig_on  = where(scan1Data.feed eq feed2 and scan1Data.cal_state eq 1 and scan1Data.sig_state eq 1 ,s1_b2_sig_on_count)
    s2_b2_sig_off = where(scan2Data.feed eq feed2 and scan2Data.cal_state eq 0 and scan2Data.sig_state eq 1 ,s2_b2_sig_off_count)
    s2_b2_sig_on  = where(scan2Data.feed eq feed2 and scan2Data.cal_state eq 1 and scan2Data.sig_state eq 1 ,s2_b2_sig_on_count)
   
    ; final sanity checks
    ; Each type of data container must have the same count and that
    ; must be equal to the number of integrations to be processed
    if n_elements(intnum) eq 1 then begin
       expectedCount = 1
    endif else begin
       ; use nIntegrations appropriate to the given sampler
       ; must be the same between scans
       sampIndx = (where(scan1Info.samplers eq scan1Data[0].sampler_name))[0]
       nIntScan1 = scan1Info.n_sampints[sampIndx]
       sampIndx = (where(scan2Info.samplers eq scan2Data[0].sampler_name))[0]
       nIntScan2 = scan2Info.n_sampints[sampIndx]
       ; number of integrations must be the same in both scans
       if nIntScan1 ne nIntScan2 then begin
          message,"The two scans have different number of integrations for this plnum and ifnum (sampler)",/info
          data_free, data
          return
       endif
       expectedCount = nIntScan1
    endelse

    if (s1_b1_ref_off_count ne expectedCount or $
        s1_b1_ref_off_count ne s1_b1_ref_on_count or s1_b1_ref_off_count ne s2_b1_ref_off_count or s1_b1_ref_off_count ne s2_b1_ref_on_count or $
        s1_b1_ref_off_count ne s1_b2_ref_on_count or s1_b1_ref_off_count ne s2_b2_ref_off_count or s1_b1_ref_off_count ne s2_b2_ref_on_count or $
        s1_b1_ref_off_count ne s1_b2_ref_off_count or $
        s1_b1_sig_off_count ne expectedCount or $
        s1_b1_sig_off_count ne s1_b1_sig_on_count or s1_b1_sig_off_count ne s2_b1_sig_off_count or s1_b1_sig_off_count ne s2_b1_sig_on_count or $
        s1_b1_sig_off_count ne s1_b2_sig_on_count or s1_b1_sig_off_count ne s2_b2_sig_off_count or s1_b1_sig_off_count ne s2_b2_sig_on_count or $
        s1_b1_sig_off_count ne s1_b2_sig_off_count) then begin
        message,"Unexpected number of spectra retrieved for some or all of the switching phases, can not continue.",/info
        data_free, data
        return
    endif
   
    status = 0
    missing = 0
    missingBeam = 0

    if keyword_set(eqweight) then weight = 1.0 ; else undefined and use default weight

    thisaccum = {accum_struct}
    tauInts = fltarr(expectedCount)
    apEffInts = tauInts
    ntsysPerInt = (ret.bswitch eq 0) ? 8:4
    tsysInts = fltarr(expectedCount,ntsysPerInt)
    b1count = 0
    b2count = 0
    lastcount = 0
    for i = 0,(expectedCount-1) do begin
        if (ret.bswitch eq 0 or ret.bswitch eq 1) then begin
            donod,result,$
                  scan1Data[s1_b1_ref_off[i]],scan1Data[s1_b1_ref_on[i]],scan2Data[s2_b1_ref_off[i]],scan2Data[s2_b1_ref_on[i]],$
                  scan1Data[s1_b2_ref_off[i]],scan1Data[s1_b2_ref_on[i]],scan2Data[s2_b2_ref_off[i]],scan2Data[s2_b2_ref_on[i]],$
                  smthoff,ret_tsys,tsys=tsys,tau=tau,tcal=tcal,eqweight=eqweight,single_beam=single_beam
            ; invert so that any signal is positive
            dcscale, result, -1.0
            ; convert to the desired units
            dcsetunits,result,units,tau=tau,ap_eff=ap_eff,ret_tau=ret_tau,ret_ap_eff=ret_ap_eff
            ; these are only used in the status line at the end
            tauInts = ret_tau
            apEffInts = ret_ap_eff
            tsysInts[i,0:3] = ret_tsys
            
            dcaccum,thisaccum,result,weight=weight
            if thisaccum.n gt lastcount then b1count += 1
            lastcount = thisaccum.n
            missingBeam += keyword_set(single_beam)
            if keyword_set(keepints) then begin
                ; re-use raw data containers to conserve space
                ; defer the actual keep until later
                ; takes 3 steps because of the nature of IDL
                ; data passing (value vs reference)
                tmp = scan1Data[s1_b1_ref_off[i]]
                data_copy, result, tmp
                scan1Data[s1_b1_ref_off[i]] = tmp
            endif
        endif
        if (ret.bswitch eq 0 or ret.bswitch eq 2) then begin
            donod,result,$
                  scan1Data[s1_b1_sig_off[i]],scan1Data[s1_b1_sig_on[i]],scan2Data[s2_b1_sig_off[i]],scan2Data[s2_b1_sig_on[i]],$
                  scan1Data[s1_b2_sig_off[i]],scan1Data[s1_b2_sig_on[i]],scan2Data[s2_b2_sig_off[i]],scan2Data[s2_b2_sig_on[i]],$
                  smthoff,ret_tsys,tsys=tsys,tau=tau,tcal=tcal,eqweight=eqweight,single_beam=single_beam
            ; convert to the desired units
            dcsetunits,result,units,tau=tau,ap_eff=ap_eff,ret_tau=ret_tau,ret_ap_eff=ret_ap_eff
            ; these are only used in the status line at the end
            tauInts = ret_tau
            apEffInts = ret_ap_eff
            if ret.bswitch eq 0 then begin
                tsysInts[i,4:7] = ret_tsys
            endif else begin
                tsysInts[i,0:3] = ret_tsys
            endelse
            
            dcaccum,thisaccum,result,weight=weight
            if thisaccum.n gt lastcount then b2count += 1
            lastcount = thisaccum.n
            missingBeam += keyword_set(single_beam)
            if keyword_set(keepints) then begin
                ; re-use raw data containers to conserve space
                ; defer the actual keep until later
                ; takes 3 steps because of the nature of IDL
                ; data passing (value vs reference)
                tmp = scan1Data[s1_b1_sig_off[i]]
                data_copy, result, tmp
                scan1Data[s1_b1_sig_off[i]] = tmp
            endif
        endif 
    endfor
    if keyword_set(keepints) then begin
        if ret.bswitch eq 0 or ret.bswitch eq 1 then putchunk,scan1Data[s1_b1_ref_off]
        if ret.bswitch eq 0 or ret.bswitch eq 2 then putchunk,scan1Data[s1_b1_sig_off]
    endif
    naccum1 = thisaccum.n
    if naccum1 le 0 then begin
        message,'Result is all blanked - probably both beams in all integrations were flagged',/info
        ; this can only happen if result is all blanked
        set_data_container,result
        ; clean up
        accumclear, thisaccum
        data_free, scan1Data
        data_free, scan2Data
        data_free,result
        return
    endif
    accumave,thisaccum, result, /quiet
    if ret.bswitch eq 0 or ret.bswitch eq 1 then missing = b1count ne expectedCount
    if ret.bswitch eq 0 or ret.bswitch eq 2 then missing = missing or b2count ne expectedCount
    if ret.bswitch eq 2 then missingBeam = missingBeam / 2 ; symetric
    accumclear, thisaccum

    set_data_container,result
    status = 1
    if not keyword_set(quiet) then begin
        if missing then begin 
            nmissRef = expectedCount-b1count
            nmissSig = expectedCount-b2count
            if ret.bswitch eq 1 then nmissSig = 0
            if ret.bswitch eq 2 then nmissRef = 0
        endif
        
        calsummary, scan1Info.scan, result.tsys, result.units, $
                    tsysInts=tsysInts, tauInts=tauInts, apEffInts=apEffInts, $
                    missingInts=nmissSig, missingRefInts=nmissRef,$
                    missingBeam=missingBeam, eqweight=eqweight, bswitch=ret.bswitch, $
                    ifnum=ret.ifnum,plnum=ret.plnum,fdnum=ret.fdnum
    endif
    
    data_free, scan1Data
    data_free, scan2Data
    data_free, result
   
end

