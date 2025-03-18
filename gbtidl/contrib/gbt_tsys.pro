;+
; <p> 
; This program gets the system temperature, with frequency for a single scan which
; has both cal phases in it.  The program looks at only one if, polarization, feed,
; etc. at time.  It also assume that if the polarization hybrid is placed in the IF
; path the correct polarization ends up in the fits file (e.g. RR instead of XX).
; This idea has not yet been tested, to my knowledge, but it should be true.
; Note that is you do not give a caltype, the program assumes you used the high cal,
; which is preferred for this type of observation.  If you did not fire the high
; cal (that is, the noise diode with high voltage), you must say so, as this information 
; is NOT recorded in the sdfits files.
; <p>
; <p><B>Contributed By: Karen O'Neil, NRAO-GB</B>
;
; @param scan {in}{required}{type=integer} M&C scan number
; @keyword ifnum {in}{optional}{type=integer} IF number (starting with 0)
; @keyword intnum {in}{optional}{type=integer} Integration number (default=all}
; @keyword fdnum {in}{optional}{type=integer} feed number (default 0)
; @keyword caltype {in}{optional}{type=string} 'hi' or 'lo' voltage fired for the cal (default is 'hi')
; @keyword ifile {in}{optional}{type=string} the sdfits file from which the scan is taken.  
; This is needed if there are more than one observations with the same scan number
; (e.g. if the dirin command was used)
; @keyword pol {in}{optional}{type=string}the polarization to use.  Options are 'XX', 
; 'YY', 'XY', 'YX', 'RR', 'LL', 'RL', 'LR' (default is 'XX')
; @keyword print  {in}{optional}{type=string} print the system temperature result? (default is 'T')
;
; @version $Id$
;-
function gbt_tsys,scan,ifnum=ifnum,intnum=intnum,fdnum=fdnum,caltype=caltype,ifile=ifile,pol=pol,print=print
    compile_opt idl2

    if (n_elements(scan) eq 0) then begin
        message, 'The scan number is required', /info
        return,0
    endif

    if not !g.lineio->is_data_loaded() then begin
        message,'No line data is attached yet, use filein or dirin.',/info
        return,0
    endif

    ; set defaults
    if n_elements(ifnum) eq 0 then ifnum = 0
    if n_elements(fdnum) eq 0 then fdnum = 0
    if not(keyword_set(ifile)) then ifile='default'
    if not(keyword_set(caltype)) then caltype='hi'
    if not(keyword_set(pol)) then pol='XX'
    if not(keyword_set(print)) then print='T'

    ; Check if scan number is valid
    if (ifile ne 'default') then validscans = get_scan_numbers(file=ifile) $
        else validscans = get_scan_numbers()
    if total(validscans eq scan, /integer) gt 1 then $
      message,"Warning: More than one scan with that scan number is in the data file.",/info
    if total(validscans eq scan, /integer) eq 0 then begin
        message,"That scan is not available.",/info
        return,0
    end

    ; Check other parameters
    info = scan_info(scan)
    if info.procseqn ne 1 then begin
        if info.procseqn ne 2 then begin
            sSub = strcompress(string(info.procseqn),/remove_all)
            message,"More than two subscans in this procedure, at least :" + sSub, /info
            return,0
        endif
        ;scan = scan-1
        if total(validscans eq scan,/integer) gt 1 then $
           message,"Warning: First scan in procedure appears more than once in the data file.",/info
        if total(validscans eq scan,/integer) eq 0 then begin
            message,"First scan in this procedure is missing.",/info
            return,0
        end
    end
    if ifnum lt 0 or ifnum gt (info.n_ifs-1) then begin
        sifnum = strcompress(string(ifnum),/remove_all)
        snif = strcompress(string(info.n_ifs),/remove_all)
        message,"Illegal IF identifier: " + sifnum + ".  This scan has " + snif + " IFs, zero-indexed.", /info
        return,0
    endif
    if fdnum lt 0 or fdnum gt (info.n_feeds-1) then begin
        message,"Invalid feed: " + strcompress(string(fdnum),/remove_all) + $
           ". This scan has " + strcompress(string(info.n_feeds),/remove_all) + " feeds, zero-indexed.",/info
        return,0
    endif
    int=where(info.polarizations eq pol,count)
    if (count lt 1) then begin
        snpol = strcompress(string(info.polarizations),/remove_all)
        message, "Invalid polarization identifier: " + pol + ".  This scan has only" + snpol + " polarizations.", /info
        return,0
    endif

    thisfeed = info.feeds[fdnum]

    singleInt = n_elements(intnum) eq 1
    expectedCount = singleInt ? 1 : info.n_integrations
    if singleInt then begin
        if intnum ge 0 and intnum le (info.n_integrations-1) then begin
            if (ifile ne 'default') then $
                data = !g.lineio->get_spectra(count,scan=scan,feed=thisfeed,ifnum=ifnum,$
                        pol=pol,int=intnum,file=ifile) $
            else data = !g.lineio->get_spectra(count,scan=scan,feed=thisfeed,ifnum=ifnum,$
                        pol=pol,int=intnum)
        endif else begin
            message,"Integration number out of range", /info
            return,0
        endelse
    endif else begin
        if (ifile ne 'default') then data = !g.lineio->get_spectra(count,scan=scan,feed=thisfeed,ifnum=ifnum,pol=pol,file=ifile) $
        else data = !g.lineio->get_spectra(count,scan=scan,feed=thisfeed,ifnum=ifnum,pol=pol)
    endelse
                                                                                                                          
    if (count le 0) then begin
        message,"No data found, this should never happen, can not continue.",/info
        return,0
    endif
                                                                                                                          
    s1=where(data.scan_number eq scan and data.cal_state eq 0, countcaloff)
    s2=where(data.scan_number eq scan and data.cal_state eq 1, countcalon)
                                                                                                                          
    if (countcaloff ne countcalon) then begin
        message,"Unexpected number of spectra retrieved for some or all of the switching phases, can not continue.",/info
        data_free, data
        return,0
    endif
                                                                                                                          
    ; copy first element into !g.s[0] as template to hold the result
    old_frozen = !g.frozen
    freeze
    set_data_container,data[0]
                                                                                                                          
    if (countcaloff gt 1) then begin
      for i=0,countcaloff-1 do $
        if (i eq 0) then caloff=getdcdata(data[s1[i]]) $
        else caloff=caloff+getdcdata(data[s1[i]])
      for i=0,countcalon-1 do $
        if (i eq 0) then calon=getdcdata(data[s2[i]]) $
        else calon=calon+getdcdata(data[s2[i]])
      caloff=caloff/countcaloff
      calon=calon/countcalon
    endif else begin
      caloff=getdcdata(data[s1])
      calon=getdcdata(data[s2])
   endelse
    result=(calon-caloff)/caloff

    ; get the needed cal values
    chans=make_array(n_elements(calon),value=1)
    for i=0,n_elements(chans)-1 do chans[i]=i
    freq=chantofreq(data[s1[0]],chans)
    rcvr=strtrim(data[s1[0]].frontend,2)

    ; fit function to the result
    coef=chebfit_v2(freq,result,2,yfit=yfit,merr=errors)

    ; convert polarizations to numbers
    ipol=convert_pol(pol)
    calval=getcalval_arr(rcvr=rcvr,cal=caltype,ipol=ipol)

    cal=interpol(calval[1,*],calval[0,*],freq)

   ; make an array with the tsys & frequency results:
    tsys=make_array(2,n_elements(calon),value=0.0)
    tsys[0,*]=freq
    tsys[1,*]=cal/yfit
   
    if (print eq 'T' ) then $ 
    	print,"System Temperature for scan ",strtrim(string(scan),2),", polarization ",$
	strtrim(pol,2),": ",strtrim(string(mean(tsys[1,*])),2)," K."
    data_free, data
    return,tsys
    
end
