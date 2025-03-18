;+
; <p>
; This procedure retrieves and calibrates a total power position switched scan pair,
; which is followed by a on+off observation of a noise diode.  If the third or first
; scan in the sequence is not a noise diode observation, the users must give the scan number
; for the noise diode observation, using the "cal=" option.
; The data must be taken with the "OnOff" or "OffOn" procedures.
; This procedure will reject data not taken with one of those two
; procedures.  The routine produces a spectrum calibrated in
; Ta (K).  Other recognized units are 'Ta*' and 'Jy'.
; <p>
; The only required parameter is the scan number.  This can be either scan
; in the sequence of two total power scans, and the paired scan is determined
; from the header.  Arguments to identify the IF number,
; polarization number and feed number are optional.  
; The program calculates Tsys based on the Tcal values, and cal_on/cal_off observations.
; However, a median tsys for the spectra is applied, as we do not have any gain
; versus frequency information available.
; The tcal value comes from the gbt_tsys routine.
; The user can override this calculation by entering a system temperature.
; The procedure will NOT correct the Tsys for the observed elevation.
; If the data are calibrated to Ta* or Jy, then additional parameters are used.
; A tau value may be specified, and an aperture efficiency may be specified.
; The user is *strongly* encouraged to enter values for these calibration parameters,
; but they will be estimated if none is provided.
; <p>
; A parameter called smthoff can be used to smooth the reference spectrum prior
; to calibration.  In certain cases this can improve the signal to noise ratio,
; but it may degrade baseline shapes and artificially emphasize spectrometer
; glitches.  Use with care.  A value of smthoff=16 is often a good choice.
; <p> 
; By default, internal averaging of integrations is weighted by Tsys.
; To give all integrations equal weight instead, use the /eqweight
; flag.
;
; <p>
; NOTE: the procedure assumes you are firing a high cal (preferred for this type of observation).
; if you are not, you must say so, as this information is NOT recorded in the sdfits files.
;
; <p><B>Contributed By: Karen O'Neil, NRAO-GB</B>
;
; @param scan {in}{required}{type=integer} M&C scan number
; @keyword ifnum {in}{optional}{type=integer} IF number (starting with 0)
; @keyword intnum {in}{optional}{type=integer} Integration number (default=all}
; @keyword plnum {in}{optional}{type=integer} polarization number (default 0)
; @keyword fdnum {in}{optional}{type=integer} feed number (default 0)
; @keyword tau {in}{optional}{type=float} tau at zenith
; @keyword tsys {in}{optional}{type=float} tsys at zenith
; @keyword ap_eff {in}{optional}{type=float} aperture efficiency
; @keyword smthoff {in}{optional}{type=integer} smooth factor for reference spectrum
; @keyword units {in}{optional}{type=string} takes the value 'Jy', 'Ta', or 'Ta*'
; @keyword eqweight {in}{optional}{type=flag} if set, the default
; weighting is turned off and all integrations are averaged with the
; same weight (1.0).
; @keyword calscan {in}{optional}{type=integer} scan number for the calibration scan
; default is that it is the first or last scan of the three scan series
; @keyword ifile {in}{optional}{type=string} sdfits file name is there is more than
; one scan number within the index file (default is unique scan number)
; @keyword caltype {in}{optional}{type=string} 'hi' or 'lo' noise
; diode voltage (default is hi)
;
; @version $Id$
;-

pro getps_v2,scan,ifnum=ifnum,intnum=intnum,plnum=plnum,fdnum=fdnum,tau=tau,$
            tsys=tsys,ap_eff=ap_eff,smthoff=smthoff,units=units,eqweight=eqweight,$
	    calscan=calscan,ifile=ifile,caltype=caltype
    compile_opt idl2

    if (n_elements(scan) eq 0) then begin
        message, 'The scan number is required', /info
        return
    endif

    if not !g.lineio->is_data_loaded() then begin
        message,'No line data is attached yet, use filein or dirin.',/info
        return
    endif
                                                                                
    ; set defaults
    if n_elements(ifnum) eq 0 then ifnum = 0
    if n_elements(plnum) eq 0 then plnum = 0
    if n_elements(fdnum) eq 0 then fdnum = 0
    if n_elements(tsys) eq 0 then tsys = 1
    if n_elements(smthoff) eq 0 then smthoff = 1
    if n_elements(units) eq 0 then units = 'Ta'
    if keyword_set(eqweight) then weight = 1.0 ; else undefined and use default weight
    if not(keyword_set(ifile)) then ifile='default'
    if not(keyword_set(calscan)) then calscan=scan+2
    if not(keyword_set(caltype)) then caltype="hi"

    ; Check if scan number is valid
    if (ifile ne 'default') then validscans = get_scan_numbers(file=ifile) $
	else validscans = get_scan_numbers()
    if total(validscans eq scan, /integer) gt 1 then $
      message,"Warning: More than one scan with that scan number is in the data file.",/info
    if total(validscans eq scan, /integer) eq 0 then begin
        message,"That scan is not available.",/info
        return
    end
 
    ; check parameters.  Need to add the ability to have more than 1 files with the same scan number!
    if (ifile eq 'default') then info = scan_info(scan)
    if (ifile ne 'default') then begin
	proc=!g.lineio->get_index_values('PROCEDURE',scan=scan,file=ifile)
	procedure=proc[uniq(proc)]
    endif else procedure=info.procedure
    if procedure[0] ne 'OffOn' and procedure[0] ne 'OnOff' then begin
        message,"Cannot handle this scan: Procedure = " + strcompress(procedure[0],/remove_all), /info
        return
    end
    if (ifile ne 'default') then begin
	seqs=!g.lineio->get_index_values('PROCSEQN',scan=scan,file=ifile) 
	procseqn=seqs[uniq(seqs)]
    endif else procseqn=info.procseqn
    if procseqn[0] ne 1 then begin
        if procseqn[0] ne 2 then begin
            sSub = strcompress(string(procseqn[0]),/remove_all)
            message,"More than two subscans in this procedure, at least :" + sSub, /info
            return
        endif
        scan = scan-1
        if total(validscans eq scan,/integer) gt 1 then $
           message,"Warning: First scan in procedure appears more than once in the data file.",/info
        if total(validscans eq scan,/integer) eq 0 then begin
            message,"First scan in this procedure is missing.",/info
            return
        end
    end
    if (ifile ne 'default') then begin
	ifs=!g.lineio->get_index_values('IFNUM',scan=scan,file=ifile) 
	n_ifs=n_elements(ifs[uniq(ifs)])
    endif else n_ifs=info.n_ifs
    if ifnum lt 0 or ifnum gt (n_ifs-1) then begin
        sifnum = strcompress(string(ifnum),/remove_all)
        snif = strcompress(string(n_ifs),/remove_all)
        message,"Illegal IF identifier: " + sifnum + ".  This scan has " + snif + " IFs, zero-indexed.", /info
        return
    endif
    if (ifile ne 'default') then begin
	feed=!g.lineio->get_index_values('FEED',scan=scan,file=ifile) 
	n_feeds=n_elements(feed[uniq(feed)])
    endif else n_feeds=info.n_feeds
    if fdnum lt 0 or fdnum gt (n_feeds-1) then begin
        message,"Invalid feed: " + strcompress(string(fdnum),/remove_all) + $
           ". This scan has " + strcompress(string(n_feeds),/remove_all) + " feeds, zero-indexed.",/info
        return
    endif
    if (ifile ne 'default') then begin
	pols=!g.lineio->get_index_values('POLARIZATION',scan=scan,file=ifile) 
	n_polarizations=n_elements(pols[uniq(pols)])
    endif else n_polarizations=info.n_polarizations
    if plnum lt 0 or plnum gt (n_polarizations-1) then begin
        spol = strcompress(string(plnum),/remove_all)
        snpol = strcompress(string(n_polarizations),/remove_all)
        message, "Invalid polarization identifier: " + spol + ".  This scan has " + snpol + " polarizations, zero-indexed.", /info
        return
    endif
    if tsys lt 0.0 then begin
        message, 'Invalid tsys value', /info
        return
    endif
    if (ifile ne 'default') then begin
	nchan=!g.lineio->get_index_values('NUMCHN',scan=scan,file=ifile) 
	n_channels=nchan[uniq(nchan)]
    endif else n_channels=info.n_channels
    if smthoff lt 1 or smthoff gt n_channels[0]/4 then begin
        message, 'Invalid smthoff value', /info
        return
    endif

    ; note that this only goes through one polarization at a time.
    if (ifile ne 'default') then begin
	pols=!g.lineio->get_index_values('POLARIZATION',scan=scan,file=ifile) 
	polarizations=pols[uniq(pols)]
    endif else polarizations=info.polarizations
    thispol = polarizations[plnum]
    if (ifile ne 'default') then begin
	fds=!g.lineio->get_index_values('FEED',scan=scan,file=ifile) 
	feeds=fds[uniq(fds)]
    endif else feeds=info.feeds
    thisfeed = feeds[fdnum]

    ; Retrieve all the data necessary to satisfy this request
    ; below is to deal with calscan
    if (calscan gt scan) then begin
    	scn1=scan
    	scn2=scan+1
	scn3=calscan
    endif else begin
	scn1=calscan
	scn2=scan
	scn3=scan+1
    endelse
    ;
    if (ifile ne 'default') then begin
	int=!g.lineio->get_index_values('INT',scan=scan,file=ifile) 
	n_integrations=n_elements(int[uniq(int[sort(int)])])
    endif else n_integrations=info.n_integrations
    singleInt = n_elements(intnum) eq 1
    expectedCount = singleInt ? 1 : n_integrations
    if singleInt then begin
        if intnum ge 0 and intnum le (n_integrations-1) then begin
            if (ifile ne 'default') then $
		data = !g.lineio->get_spectra(count,scan=[scn1,scn2,scn3],feed=thisfeed,ifnum=ifnum,$
			pol=thispol,int=intnum,file=ifile) $
            else data = !g.lineio->get_spectra(count,scan=[scn1,scn2,scn3],feed=thisfeed,ifnum=ifnum,$
			pol=thispol,int=intnum)
        endif else begin
            message,"Integration number out of range", /info
            return
        endelse
    endif else begin
        if (ifile ne 'default') then data = !g.lineio->get_spectra(count,scan=[scn1,scn2,scn3],$
			feed=thisfeed,ifnum=ifnum,pol=thispol,file=ifile) $
	else data = !g.lineio->get_spectra(count,scan=[scn1,scn2,scn3],feed=thisfeed,ifnum=ifnum,pol=thispol)
    endelse

    if (count le 0) then begin
        message,"No data found, this should never happen, can not continue.",/info
        return
    endif

    s1=where(data.scan_number eq scan, counton)
    s2=where(data.scan_number eq (scan+1), countoff)

    if (countoff ne expectedCount or countoff ne counton) then begin 
        message,"Unexpected number of spectra retrieved for some or all of the switching phases, can not continue.",/info
        data_free, data
        return
    endif

    ; copy first element into !g.s[0] as template to hold the result
    old_frozen = !g.frozen
    freeze
    set_data_container,data[0]

    if n_elements(ap_eff) eq 0 then ap_eff = get_ap_eff(!g.s[0].observed_frequency/1.0e9,!g.s[0].elevation)

    if ap_eff lt 0.0 or ap_eff gt 1.0 then begin
        message, 'Invalid ap_eff value - it should be between 0 and 1', /info
        if old_frozen eq 1 then freeze else unfreeze
        data_free, data
        return
    endif

    if n_elements(tau) eq 0 then tau = get_tau(!g.s[0].observed_frequency/1.0e9)

    if tau lt 0.0 or tau gt 1.0 then begin
        message, 'Invalid tau value - it should be between 0 and 1', /info
        if old_frozen eq 1 then freeze else unfreeze
        data_free, data
        return
    endif

    ; Determine the system temperature, assuming it was not given
    if (tsys eq 1) then $
	tsysarr=gbt_tsys(scn3,ifnum=ifnum,intnum=intnum,fdnum=fdnum,caltype=caltype,ifile=ifile,pol=thispol,print='F') $
	else print,"Using a system temparature of ",tsys
    ; I am now removing all frequency information from the system temparature.  I am doing this because I 
    ;	currently do not have gain vs. frequency information.  sigh.
    if (tsys eq 1) then tsys=median(tsysarr[1,*])

    if singleInt then begin
        dops_v2,data[s1],data[s2],tau,tsys,ap_eff,smthoff,units,ret_tsys,ret_tau
    endif else begin
	thisaccum = {accum_struct}
        for n_int = 0,(n_integrations-1) do begin
           dops_v2,data[s1[n_int]],data[s2[n_int]],tau,tsys,ap_eff,smthoff,units,ret_tsys,ret_tau
           dcaccum,thisaccum,!g.s[0],weight=weight
        end
        naccum1 = thisaccum.n
	accumave,thisaccum,thisave,/quiet
        if naccum1 ne n_integrations then begin
           message,'unexpected problems in obtaining the average over integrations, can not continue',/info
           ; clean up
           if old_frozen eq 1 then freeze else unfreeze
           data_free, thisave
           accumclear, thisaccum
           data_free, data
           return
        endif
	set_data_container,thisave
        accumclear, thisaccum
        data_free, thisave
    endelse
    if units eq 'Jy' then $
      print,scan,ret_tau,ap_eff,thispol,ret_tsys,$
      format='("Scan: ",i5,"  units: Jy    tau: ",f5.3,"   ap_eff: ",f5.3,"   Poln: ",a2,"   Tsys: ",f7.2)' $
    else if units eq 'Ta*' then $
      print,scan,ret_tau,thispol,ret_tsys,$
      format='("Scan: ",i5,"  units: Ta* (K)   tau: ",f5.3,"   Poln: ",a2,"   Tsys: ",f7.2, 2x, f7.2)' $
    else print,scan,thispol,ret_tsys,format='("Scan: ",i5,"   units: Ta (K)   Poln: ",a2,"   Tsys: ",f7.2)'

    data_free, data

    	if old_frozen eq 1 then freeze else unfreeze
	if !g.frozen eq 0 then show
end
