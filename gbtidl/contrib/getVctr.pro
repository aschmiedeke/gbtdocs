
;+
; Performs vector Tcal calibration for a Subreflector Nod observation
; with Ka-band. 
; 
; <p>Combines data from the two beam/pols/phases in the 'correct' way.
;
; <p>Stores results in the PDC
;
; @param scan {in}{required}{type=integer} the scans number for the Track observation.  
; @keyword ifnum {in}{optional}{type=integer} standard ifnum from the
; 'get' commands, defaults to 0.
; @keyword refsmth {in}{optional}{type=refsmth} refsmth
;
; @file_comments getVctr is a collection of routines that use a vector
; Tcal from the database created by the routines in <a href="scal.html">scal.pro</a> 
; to calibrate various observations.  Supports:
; <ul>
; <li> single-beam On-Off and dual beam NOD obs (getVctr),
; <li> dual beam subr nodding Ku, K, Q (getVctrSubrNod)
; <li> Ka-band subr nodding (getKaSubrNod)
; </ul>
;
; <p><B>See also</B> the scal User's Guide found in the
; documentation for <a href="scal.html">scal.pro</a>
;
; <p><B>Contributed By: Ron Maddalena, NRAO-GB</B>
;
; @version $Id$
;-
pro getKaSubrNod,scan,ifnum=ifnum, refsmth=refsmth

     common calCommon, calDatabase

     if (n_elements(ifnum) eq 0) then ifnum = 0
     if (n_elements(refsmth) eq 0) then refsmth = 1

     ; The following accumulators hold the calOn, Off spectra, the sub pos 0 and 1 data
     calOnAccum = {accum_struct}
     calOffAccum =  {accum_struct}
     pos0Accum = {accum_struct}
     pos1Accum =  {accum_struct}

     ; The various beam/pol/phase combinations are averged into...
     resultAccum =  {accum_struct}
     accumclear, resultAccum

     ; Only appropriate for Ka-band
     sampler = [whichsampler(scan,ifnum,1,0), whichsampler(scan,ifnum,0,1)]
     sigRef = ["T", "F"]

     for s = 0, 1 do begin

       for jSigRef = 0,1 do begin

         accumclear, calOnAccum
         accumclear, calOffAccum
         accumclear, pos0Accum
         accumclear, pos1Accum
         
         ; Average records for all 4 combinations of cal on/off, subr pos 0 and 1
         pos0calOn = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='T',subref=1)
	 ; print, 'Pos0 CalOn', count
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos0calOn[i],weight=1
             dcaccum,pos0Accum,pos0calOn[i],weight=1
         end
         pos0calOff = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='F',subref=1)
	 ; print, 'Pos0 CalOff', count
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos0calOff[i],weight=1
             dcaccum,pos0Accum,pos0calOff[i],weight=1
         end
         pos1calOn = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='T',subref=-1)
	 ; print, 'Pos1 CalOn', count
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos1calOn[i],weight=1
             dcaccum,pos1Accum,pos1calOn[i],weight=1
         end
         pos1calOff = getchunk(count=count,scan=scan,sig=sigRef[jSigRef],sampler=sampler[s],cal='F',subref=-1)
	 ; print, 'Pos1 CalOff', count
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos1calOff[i],weight=1
             dcaccum,pos1Accum,pos1calOff[i],weight=1
         end

         ; con/off is the average of the cal on/off data; p0, p1 are the average of the sub position 0 and 1
         accumave,calOnAccum, cOn, /quiet
         accumave,calOffAccum, cOff, /quiet
         accumave,pos0Accum, p0, /quiet
         accumave,pos1Accum, p1, /quiet

         if (refsmth gt 1) then begin
             *p0.data_ptr = doboxcar1d(*p0.data_ptr,refsmth,/nan,/edge_truncate)
             *cOn.data_ptr = doboxcar1d(*cOn.data_ptr,refsmth,/nan,/edge_truncate)
             *cOff.data_ptr = doboxcar1d(*cOff.data_ptr,refsmth,/nan,/edge_truncate)
         endif

        ; idx only works as a way to index Spectrometer/SP data for upto 2 pols and 2 feeds.  
        ; May not work for future backends or receivers
         idx = ifnum + 8*s + 16*jSigRef
         tcal = *calDatabase[idx].tcals

        ; Calculate Ta, update exposure time.  Flip sense for the correct phases
         data_copy,p0,result
         denom = *cOn.data_ptr - *cOff.data_ptr
         if (s eq jSigRef) then begin
            *result.data_ptr = tcal*(*p0.data_ptr - *p1.data_ptr)/denom
            tsys = tcal * *p1.data_ptr/denom
         endif else begin
            *result.data_ptr = tcal*(*p1.data_ptr - *p0.data_ptr)/denom
            tsys = tcal * *p0.data_ptr/denom
         endelse

         result.exposure = p0.exposure*p1.exposure/(p0.exposure+p1.exposure)

        ; Store away mean value for Tsys and Tcal over central 90%
        nchan = n_elements(tcal)
        n1 = floor(0.1*nchan)
        n2 = floor(0.9*nchan)

        result.tsys = mean(tsys[n1:n2],/nan)
        result.mean_tcal = mean(tcal[n1:n2],/nan)

        ; Average in this phase/feed/pol
        dcaccum,resultAccum,result,weight=1./result.tsys^2
       end
     end

    ; Place results into the PDC
     accumave,resultAccum, result, /quiet
     set_data_container,result,buffer=0
     !g.s[0].units = "Ta"

    ; Be a good boy and clean up memory
     data_free,pos0calOn & data_free,pos0calOff
     data_free,pos1calOn & data_free,pos1calOff
     data_free,cOn & data_free,cOff & data_free,p0 & data_free,p1
     data_free,result

end

;+
; Performs vector Tcal calibration on an On-Off, Off-On, or Nod
; observation for all but Ka-band.
;
; <p>Store results in the PDC
;
; <p><B>Note: </B> whether scan2 = scan1 + 1 or scan2 = scan1 -1
; depends upon whether this is an Off-On or On-Off observation, or
; whether this is a fdnum=0 or fdnum=1.  If you get the order
; backwards, Ta will be negative. 
;
; @param scan1 {in}{required}{type=integer} the scan number for the on
; or off observation
; @param scan2 {in}{required}{type=integer} the scans numbers for the
; on or off observation.  
; @keyword ifnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword plnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword fdnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword refsmth {in}{optional}{type=refsmth} refsmth
;
;-
pro getVctr,scan1, scan2, ifnum=ifnum, plnum=plnum, fdnum=fdnum, refsmth=refsmth

     common calCommon, calDatabase

    ; default values for unsupplied arguments
    if (n_elements(ifnum) eq 0) then ifnum = 0
    if (n_elements(plnum) eq 0) then plnum = 0
    if (n_elements(fdnum) eq 0) then fdnum = 0
    if (n_elements(refsmth) eq 0) then refsmth = 1

     ; The following accumulators hold the calOn, Off spectra, the sub pos 0 and 1 data
     calOnAccum = {accum_struct}
     calOffAccum =  {accum_struct}
     pos0Accum = {accum_struct}
     pos1Accum =  {accum_struct}

     sampler = whichsampler(scan1,ifnum,plnum,fdnum)

    accumclear, calOnAccum
    accumclear, calOffAccum
    accumclear, pos0Accum
    accumclear, pos1Accum

    ; Average records for all 4 combinations of scan1/2, cal On/off
     pos0calOn = getchunk(count=count,scan=scan1,sig='T',sampler=sampler,cal='T')
     for i=0, (count-1) do begin
         dcaccum,calOnAccum,pos0calOn[i],weight=1
         dcaccum,pos0Accum,pos0calOn[i],weight=1
     end
     pos0calOff = getchunk(count=count,scan=scan1,sig='T',sampler=sampler,cal='F')
     for i=0, (count-1) do begin
         dcaccum,calOffAccum,pos0calOff[i],weight=1
         dcaccum,pos0Accum,pos0calOff[i],weight=1
     end
     pos1calOn = getchunk(count=count,scan=scan2,sig='T',sampler=sampler,cal='T')
     for i=0, (count-1) do begin
         dcaccum,calOnAccum,pos1calOn[i],weight=1
         dcaccum,pos1Accum,pos1calOn[i],weight=1
     end
     pos1calOff = getchunk(count=count,scan=scan2,sig='T',sampler=sampler,cal='F')
     for i=0, (count-1) do begin
         dcaccum,calOffAccum,pos1calOff[i],weight=1
         dcaccum,pos1Accum,pos1calOff[i],weight=1
     end

    ; con/off is the average of the cal on/off data; p0, p1 are the average of the sub position 0 and 1
    accumave,calOnAccum, cOn, /quiet
    accumave,calOffAccum, cOff, /quiet
    accumave,pos0Accum, p0, /quiet
    accumave,pos1Accum, p1, /quiet

     if (refsmth gt 1) then begin
         *p0.data_ptr = doboxcar1d(*p0.data_ptr,refsmth,/nan,/edge_truncate)
         *cOn.data_ptr = doboxcar1d(*cOn.data_ptr,refsmth,/nan,/edge_truncate)
         *cOff.data_ptr = doboxcar1d(*cOff.data_ptr,refsmth,/nan,/edge_truncate)
     endif

    ; idx only works as a way to index Spectrometer/SP data for upto 2 pols and 2 feeds.  
    ; May not work for future backends or receivers
    idx = ifnum + 8*plnum + 16*fdnum
    tcal = *calDatabase[idx].tcals

    ; Calculate Ta, update exposure time
    data_copy,p0,result
    denom = *cOn.data_ptr - *cOff.data_ptr
    *result.data_ptr = tcal*(*p0.data_ptr - *p1.data_ptr)/denom
    tsys = tcal * *p1.data_ptr/denom

    result.exposure = p0.exposure*p1.exposure/(p0.exposure+p1.exposure)

    ; Store away mean value for Tsys and Tcal over central 90%
    nchan = n_elements(tcal)
    n1 = floor(0.1*nchan)
    n2 = floor(0.9*nchan)

    result.tsys = mean(tsys[n1:n2],/nan)
    result.mean_tcal = mean(tcal[n1:n2],/nan)

    ; Place results into the PDC
    set_data_container,result,buffer=0

    ; Be a good boy and clean up memory
    data_free,pos0calOn & data_free,pos0calOff
    data_free,pos1calOn & data_free,pos1calOff
    data_free,cOn & data_free,cOff & data_free,p0 & data_free,p1
    data_free,result

end

;+
; Performs scalar Tcal calibration for a Subreflector Nod observation
; with Q, Ku, or K-band. 
;
; <p>Combines data from the two beams and polarizations in the 'correct'
; way.
;
; <p>Store results in the PDC
;
; @param scan {in}{required}{type=integer} the scan number for the
; Track observation
; @keyword ifnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword plnum {in}{optional}{type=integer} same usage as in all of
; the standard "get" commands. 
; @keyword refsmth {in}{optional}{type=refsmth} refsmth
;
;-
pro getVctrSubrNod,scan,ifnum=ifnum,plnum=plnum,refsmth=refsmth

     common calCommon, calDatabase

     if (n_elements(ifnum) eq 0) then ifnum = 0
     if (n_elements(plnum) eq 0) then plnum = 0
     if (n_elements(refsmth) eq 0) then refsmth = 1

     ; The following accumulators hold the calOn, Off spectra, the sub pos 0 and 1 data
     calOnAccum = {accum_struct}
     calOffAccum =  {accum_struct}
     pos0Accum = {accum_struct}
     pos1Accum =  {accum_struct}

     ; The various beam/pol/phase combinations are averged into...
     resultAccum =  {accum_struct}
     accumclear, resultAccum

     ; Only appropriate for Ku, K-band, and Q-band
     sampler = [whichsampler(scan,ifnum,plnum,0), whichsampler(scan,ifnum,plnum,1)]

     for s = 0, 1 do begin

         accumclear, calOnAccum
         accumclear, calOffAccum
         accumclear, pos0Accum
         accumclear, pos1Accum
         
         ; Average records for all 4 combinations of cal on/off, subr pos 0 and 1
         pos0calOn = getchunk(count=count,scan=scan,sampler=sampler[s],cal='T',subref=1)
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos0calOn[i],weight=1
             dcaccum,pos0Accum,pos0calOn[i],weight=1
         end
         pos0calOff = getchunk(count=count,scan=scan,sampler=sampler[s],cal='F',subref=1)
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos0calOff[i],weight=1
             dcaccum,pos0Accum,pos0calOff[i],weight=1
         end
         pos1calOn = getchunk(count=count,scan=scan,sampler=sampler[s],cal='T',subref=-1)
         for i=0, (count-1) do begin
             dcaccum,calOnAccum,pos1calOn[i],weight=1
             dcaccum,pos1Accum,pos1calOn[i],weight=1
         end
         pos1calOff = getchunk(count=count,scan=scan,sampler=sampler[s],cal='F',subref=-1)
         for i=0, (count-1) do begin
             dcaccum,calOffAccum,pos1calOff[i],weight=1
             dcaccum,pos1Accum,pos1calOff[i],weight=1
         end

         ; cOn/Off is the average of the cal on/off data
         ; p0, p1 are the average of the sub position 0 and 1

         accumave,calOnAccum, cOn, /quiet
         accumave,calOffAccum, cOff, /quiet
         accumave,pos0Accum, p0, /quiet
         accumave,pos1Accum, p1, /quiet

         if (refsmth gt 1) then begin
             *p0.data_ptr = doboxcar1d(*p0.data_ptr,refsmth,/nan,/edge_truncate)
             *cOn.data_ptr = doboxcar1d(*cOn.data_ptr,refsmth,/nan,/edge_truncate)
             *cOff.data_ptr = doboxcar1d(*cOff.data_ptr,refsmth,/nan,/edge_truncate)
         endif

        ; idx only works as a way to index Spectrometer/SP data for upto 2 pols and 2 feeds.  
        ; May not work for future backends or receivers
         idx = ifnum + 8*plnum + 16*s
         tcal = *calDatabase[idx].tcals

        ; Calculate Ta, update exposure time.  Flip sense for the correct phases
         data_copy,p0,result
         denom = *cOn.data_ptr - *cOff.data_ptr
         if (s eq 0) then begin
             *result.data_ptr = tcal*(*p1.data_ptr - *p0.data_ptr)/denom
             tsys = tcal * *p0.data_ptr/denom
         endif else begin
             *result.data_ptr = tcal*(*p0.data_ptr - *p1.data_ptr)/denom
             tsys = tcal * *p1.data_ptr/denom
         endelse


         result.exposure = p0.exposure*p1.exposure/(p0.exposure+p1.exposure)

        ; Store away mean value for Tsys and Tcal over central 90%
        nchan = n_elements(tcal)
        n1 = floor(0.1*nchan)
        n2 = floor(0.9*nchan)

        result.tsys = mean(tsys[n1:n2],/nan)
        result.mean_tcal = mean(tcal[n1:n2],/nan)
        
        ; Average in this phase/feed/pol
        dcaccum,resultAccum,result,weight=1./result.tsys^2
    end

    ; Place results into the PDC
     accumave,resultAccum, result, /quiet
     set_data_container,result,buffer=0
     !g.s[0].units = "Ta"
     
    ; Be a good boy and clean up memory
     data_free,pos0calOn & data_free,pos0calOff
     data_free,pos1calOn & data_free,pos1calOff
     data_free,cOn & data_free,cOff & data_free,p0 & data_free,p1
     data_free,result

end
