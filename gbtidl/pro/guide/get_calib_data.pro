; docformat = 'rst'

;+
; Used by the calibration routines to actually fetch the necessary
; data.
;
; This is not meant to be called directly by the user.  Error messages
; generated here are displayed using the prefix from the calling
; routine.  It is expected that some argument checking will have
; happened prior to this function being called.  The only checks done
; here are that the requested data (ifnum, plnum, fdnum, and intnum)
; are consistent with the given scan info.
;
; The returned values are the array of data containers found in the
; current line data source that satisfy the request using the provided
; scan info structure to indentify the scan.
;
; If there is a problem, the returned value is -1 and count is 0.
;
; :Params:
;   info : in, required, type=structure
;       The scan_info structure that describes the scan. Use 
;       :idl:pro:`find_scan_info` to get this scan_info.
;   ifnum : in, required, type=integer
;       The IF number to fetch
;   plnum : in, required, type=integer
;       The polarization number to fetch.
;   fdnum : in, required, type=integer
;       The feed number to fetch.  Ignored when twofeeds is set.
;   sampler : in, required, type=string
;       The sampler name, an alternative to ifnum, plnum and fdnum.
;       This is used (and the others are ignored) when it is not empty.
;   count : out, optional, type=integer
;       The number of data containers returned.  This is 0 when there 
;       is a problem.
; 
; :Keywords:
;   intnum : in, optional, type=integer
;       The specific integration to fetch.  If not supplied then fetch 
;       data from all integrations that match the other parameters.
;   useflag : in, optional, type=boolean or string, default=true
;       Apply all or just some of the flag rules?
;   skipflag : in, optional, type=boolean or string
;       Do not apply any or do not apply a few of the flag rules?
;   twofeeds : in, optional, type=boolean
;       When set (1), then this data must contain 2 and only two feeds 
;       and all data from both feeds is returned by this call.  In that 
;       case, fdnum is ignored.
;   sig_state : in, optional, type=integer
;       When -1, this keyword is ignored, when 0 then the reference state
;       is selected, when 1 then the sig state is selected.
;   wcalpos : in, optional, type=string
;       When set, then only data matching this wcalpos string is fetched.
;       Ignored when fetching data from an individual integration.
;   subref : in, optional, type=integer
;       When set, then only data matching this subref value is fetched.  
;       Ignored when fetching data from an individual integration.
; 
;   
; :Returns:
;   returns an array of spectral line data containers that satisfy this
;   request. Returns -1 on error (count will also be 0 in that case).
;
; @private_file
; 
;-
function get_calib_data,info, ifnum, plnum, fdnum, sampler, count, $
                        intnum=intnum, useflag=useflag, skipflag=skipflag, $
                        twofeeds=twofeeds, sig_state=sig_state, wcalpos=wcalpos, $
                        subref=subref
                        
    compile_opt idl2

    count = 0

    thisIF = ifnum
    thisPL = plnum
    thisFD = fdnum

    thisSig = -1
    sigVal = ''
    if n_elements(sig_state) ne 0 then begin
        thisSig = sig_state
        sigVal = 'T'
        if thisSig eq 0 then begin
            sigVal = 'F'
        endif
     endif

    ; info limits the index entries to search, use it

    if (strlen(sampler) gt 0) then begin
        if where(info.samplers eq sampler) lt 0 then begin
            message,'Illegal sampler name: ' + sampler + '.  Choose from : ' + strjoin(info.samplers,' '), level=-1,/info
            return,-1
        endif
        ; samplerinfo is too slow, select on sampler directly
        ; for twofeeds case, ifnum is the tracking if number, 
        ; it will be used eventually even here - check it now.
        if keyword_set(twofeeds) then begin
            if info.n_feeds ne 2 then begin
                message,"Scan "+strtrim(string(info.scan),2)+$
                        " does not have two feeds.  n_feeds = "+strtrim(string(info.n_feeds),2), /info
                return,-1
            endif
            if thisFD lt 0 or thisFD gt 1 then begin
                message,"Invalid feed: " + strcompress(string(thisFD),/remove_all) + ".  fdnum must be 0 or 1",/info
                return,-1
             endif
            if where(info.fdnums[0:(info.n_feeds-1)] eq 0) lt 0 or where(info.fdnums[0:(info.n_feeds-1)] eq 1) lt 0 then begin
               message,"One or both of fdnum 0 and 1 are not present in this data.",/info
               return,-1
            endif
        endif

        if n_elements(intnum) eq 1 then begin
            if intnum le (info.n_integrations-1) then begin
                ; scan and timestamp have already been used when info was retrieved
                ; use retrieve record locations at this point for speed
                if thisSig ge 0 then begin
                    data = !g.lineio->get_spectra(count,$
                                                  srow=info.index_start,nrow=info.nrecords,$
                                                  sampler=sampler,$
                                                  int=intnum,sig=sigVal,$
                                                  useflag=useflag,skipflag=skipflag)
                endif else begin
                    data = !g.lineio->get_spectra(count,$
                                                  srow=info.index_start,nrow=info.nrecords,$
                                                  sampler=sampler,$
                                                  int=intnum, $
                                                  useflag=useflag,skipflag=skipflag)
                endelse
            endif else begin
                message,'Integration number out of range',level=-1,/info
                return,-1
            endelse
        endif else begin
            if thisSig ge 0 then begin
                ; scan and timestamp have already been used when info was retrieved
                ; use retrieve record locations at this point for speed
                data = !g.lineio->get_spectra(count,$
                                              srow=info.index_start,nrow=info.nrecords,$
                                              sampler=sampler,sig=sigVal,$
                                              wcalpos=wcalpos,subref=subref,$
                                              useflag=useflag,skipflag=skipflag)
            endif else begin
                data = !g.lineio->get_spectra(count,$
                                              srow=info.index_start,nrow=info.nrecords,$
                                              sampler=sampler,$
                                              wcalpos=wcalpos,subref=subref,$
                                              useflag=useflag,skipflag=skipflag)
            endelse
        endelse
               
        if keyword_set(twofeeds) then begin
            ; must find the other data and select it as usuall
            thisIF = data[0].if_number
            thisPL = data[0].polarization_num
            thisFD = data[0].feed_num
        
            fdnum2 = (thisFD eq 0) ? 1 : 0

            plIndx = where(info.plnums[0:(info.n_polarizations-1)] eq thisPL)
            ; plIndx must exist because data[0] exists already with that plnum
            thisPlnum = info.plnums[plIndx]

            fdIndx = where(info.fdnums[0:(info.n_feeds-1)] eq fdnum2)
            ; fdIndx must exist because it both fdnums were already tested above
            thisfeed = info.feeds[fdIndx]
        
            if n_elements(intnum) eq 1 then begin
                ; scan and timestamp have already been used when info was retrieved
                ; use retrieve record locations at this point for speed
                if intnum le (info.n_integrations-1) then begin
                    if thisSig ge 0 then begin
                        data2 = !g.lineio->get_spectra(count,$
                                                       srow=info.index_start,nrow=info.nrecords,$
                                                       feed=thisfeed,ifnum=thisIF,plnum=thisPlnum,int=intnum,$
                                                       sig=sigVal,$
                                                       useflag=useflag,skipflag=skipflag)
                    endif else begin
                        data2 = !g.lineio->get_spectra(count,$
                                                       srow=info.index_start,nrow=info.nrecords,$
                                                       feed=thisfeed,ifnum=thisIF,plnum=thisPlnum,int=intnum,$
                                                       useflag=useflag,skipflag=skipflag)

                    endelse
                endif else begin
                    message,'Integration number out of range',level=-1,/info
                    return,-1
                endelse
            endif else begin
                if thisSig ge 0 then begin
                    data2 = !g.lineio->get_spectra(count,$
                                                   srow=info.index_start,nrow=info.nrecords,$
                                                   feed=thisfeed,ifnum=thisIF,plnum=thisPlnum,$
                                                   sig=sigVal,$
                                                   wcalpos=wcalpos,subref=subref,$
                                                   useflag=useflag,skipflag=skipflag)
                endif else begin
                    data2 = !g.lineio->get_spectra(count,$
                                                   srow=info.index_start,nrow=info.nrecords,$
                                                   feed=thisfeed,ifnum=thisIF,plnum=thisPlnum,$
                                                   wcalpos=wcalpos,subref=subref,$
                                                   useflag=useflag,skipflag=skipflag)
                endelse
            endelse

            if thisFD eq fdnum then begin
                data = [data,data2]
            endif else begin
                data = [data2,data]
            endelse
        endif

    endif else begin
        ; regular ifnum, plnum, fdnum selection
        ; This relies on ifnums containing unique values, only 1 possible match
        if where(info.ifnums[0:(info.n_ifs-1)] eq thisIF) lt 0 then begin
            ; no match found
            sifnum = strcompress(string(thisIF),/remove_all)
            sifnumList = strjoin(strcompress(string(info.ifnums[0:(info.n_ifs-1)]),/remove_all),',',/single)
            message,'Illegal IF identifier: ' + sifnum + $
                    '. This scan has the following IFNUMs : ' + sifnumList, $
                    level=-1, /info
            return,-1
        endif
        
        ; and ditto for plnum
        if where(info.plnums[0:(info.n_polarizations-1)] eq thisPL) lt 0 then begin
            spol = strcompress(string(thisPL),/remove_all)
            plnumList = strjoin(strcompress(string(info.plnums[0:(info.n_polarizations-1)]),/remove_all),',',/single)
            message, 'Invalid poliarization identifier: ' + spol + $
                     '. This scan has the following PLNUMs : '+ plnumList, $
                     level=-1,/info
            return,-1
         endif       
        
        if keyword_set(twofeeds) then begin
                                ; scripts that process 2 feeds expect
                                ; them to be always fdnum=0 and 1,
                                ; require both to be here
            if info.n_feeds ne 2 then begin
                message,"Scan "+strtrim(string(info.scan),2)+$
                        " does not have two feeds.  n_feeds = "+strtrim(string(info.n_feeds),2), /info
                return,-1
            endif
            if thisFD lt 0 or thisFD gt 1 then begin
                message,"Invalid feed: " + strcompress(string(thisFD),/remove_all) + ".  fdnum must be 0 or 1",/info
                return,-1
            endif
            if (where(info.fdnums[0:(info.n_feeds-1)] eq 0)) lt 0 or (where(info.fdnums[0:(info.n_feeds-1)] eq 1) lt 0) then begin
               message,"Both fdnum 0 and 1 must exist.  At least one is missing.",/info
               return,-1
            endif
            fdnum2 = (thisFD eq 0) ? 1 : 0
            thisfdnum = [thisFD,fdnum2]
        endif else begin
                                ; look for this specific feed just
                                ; like plnum, ifnum were checked above
            if where(info.fdnums[0:(info.n_feeds-1)] eq thisFD) lt 0 then begin
                fdnumList = strjoin(strcompress(string(info.fdnums[0:(info.n_feeds-1)]),/remove_all),',',/single)
                message,'Invalid feed: ' + strcompress(string(thisFD),/remove_all) + $
                        '. This scan has the following FDNUMs : ' + fdnumList, $
                        level=-1,/info
                return,-1
            endif
            thisfdnum = thisFD
        endelse
        
        plIndx = where(info.plnums[0:(info.n_polarizations-1)] eq thisPL)
        ; must exist because of test above
        thisPlnum = info.plnums[plIndx]

        ; placeholder copy
        thisfeed = thisfdnum
        ; and fill it in
        for ij=0,n_elements(thisfdnum)-1 do begin
           fdIndx = where(info.fdnums[0:(info.n_feeds-1)] eq thisfdnum[ij])
           ; must exist because of previous tests
           thisfeed[ij] = info.feeds[fdIndx]
        endfor
        
        if n_elements(intnum) eq 1 then begin
            ; scan and timestamp have already been used when info was retrieved
            ; use retrieve record locations at this point for speed
            if intnum le (info.n_integrations-1) then begin
                if thisSig ge 0 then begin
                    data = !g.lineio->get_spectra(count,$
                                                  srow=info.index_start,nrow=info.nrecords,$
                                                  feed=thisfeed,ifnum=thisIF,plnum=thisPlnum,int=intnum,$
                                                  sig=sigVal,$
                                                  useflag=useflag,skipflag=skipflag)
                endif else begin
                    data = !g.lineio->get_spectra(count,$
                                                  srow=info.index_start,nrow=info.nrecords,$
                                                  feed=thisfeed,ifnum=thisIF,plnum=thisPlnum,int=intnum,$
                                                  useflag=useflag,skipflag=skipflag)
                endelse
            endif else begin
                message,'Integration number out of range',level=-1,/info
                return,-1
            endelse
        endif else begin
            if thisSig ge 0 then begin
                data = !g.lineio->get_spectra(count,$
                                              srow=info.index_start,nrow=info.nrecords,$
                                              feed=thisfeed,ifnum=thisIF,plnum=thisPlnum,$
                                              sig=sigVal,wcalpos=wcalpos,subref=subref,$
                                              useflag=useflag,skipflag=skipflag)
            endif else begin
                data = !g.lineio->get_spectra(count,$
                                              srow=info.index_start,nrow=info.nrecords,$
                                              feed=thisfeed,ifnum=thisIF,plnum=thisPlnum,$
                                              wcalpos=wcalpos,subref=subref,$
                                              useflag=useflag,skipflag=skipflag)
            endelse
        endelse
    endelse

    return,data
end
    
