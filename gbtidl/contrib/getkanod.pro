;+
; ph_accum accumulates all integrations for a particular phase;
;
; @param x {in}{required}{type=array of spectrum DCs} The data
; containers to use in the accumulation.
; @param cal {in}{required}{type=integer} The cal_state to select from
; x.
; @param sig {in}{required}{type=integer} The sig_state to select from
; x.
; @param q {in}{required}{type=integer} The first integration to use
; in the accumulation.
; @param tinteg {out}{type=float} The total integration
; time.
; @param s_acc {out}{type=float array} The result, the average of
; the accumulated data.
; @param ncnt {out}{type=integer} The number of integrations in this
; accumulation.
;
; @file_comments A collection of procedures for reducing Ka NOD data.
; The primary procedure here is 'getkanod'.
;
; <p><B>Contributed By: Frank Ghigo, NRAO-GB</B>
;
; @version $Id$
;-
pro ph_accum, x, cal, sig, q, tinteg, s_acc, ncnt
   compile_opt idl2

   ncount = 0
   ncnt = ncount
   s_acc[*] = 0.0
   ss0 = where( (x.cal_state eq cal) and (x.sig_state eq sig) )

  ; if this phase does not exist, just return zero array.
   if (size(ss0))[0] le 0 then return

   nss = (size(ss0))[1]
   for ii = q, nss-1 do begin
     s_acc = s_acc + *(x[ss0[ii]].data_ptr)
     ncount = ncount + 1
   endfor
   s_acc = s_acc/ncount
   tinteg = tinteg + x[ss0[0]].exposure * ncount

   ncnt = ncount
end


;+
; Get the average of all 4 phases of data from !g.lineio at once for
; given ifnum and beam.
;
; @uses<a href="getkanod.html#_ph_accum">ph_accum</a>
;
; @param scan {in}{required}{type=integer} The desired scan number.
; @param ifnum {in}{required}{type=integer} The desired IF number.
; @param bmb {in}{required}{type=integer} The desired feed (beam).
; @param q {in}{required}{type=integer} The first integration to use in
; the averages.
; @param tinteg {out}{type=float} The total integration time for each
; phase.
; @param s_off {out}{type=float array} The average for the cal_off,
; sig phase.
; @param s_on {out}{type=float array} The average for the cal_on, sig
; phase.
; @param r_off {out}{type=float array} The average for the cal_off,
; ref phase.
; @param r_on {out}{type=float array} The average for the cal_on, ref phase.
;-
pro getphases, scan, ifnum, bmb, q, tinteg, s_off,s_on,r_off,r_on

   compile_opt idl2

  ; fetch all 4 phases for this scan, IF, and beam.
   x = !g.lineio->get_spectra( scan=scan, ifnum=ifnum, feed=bmb )

   ncnt = intarr(2)
   ph_accum, x, 0, 1, q, tinteg, s_off, ncnt  ; cal_off and sig phase
   ph_accum, x, 1, 1, q, tinteg, s_on, ncnt   ; cal_on  and sig phase
   ph_accum, x, 0, 0, q, tinteg, r_off, ncnt  ; cal_off and ref phase
   ph_accum, x, 1, 0, q, tinteg, r_on, ncnt   ; cal_on and ref phase

   print, ncnt[0], " ints, scan ", scan, " if", ifnum, " beam",bmb, $
      format='(i3,a,i4,1x,a,i2,1x,a,i2)'
end


;+
; Collect data for two successive scans for one beam.  If ref eq 0
; then assume this is the tracking beam.  If ref eq 1 then this is the
; reference beam.
;
; @uses <a href="getkanod.html#_getphases">getphases</a>
;
; @param scan {in}{required}{type=integer} The first scan number in
; the pair.
; @param ifnum {in}{required}{type=integer} The desired IF number.
; @param bmb {in}{required}{type=integer} Feed (beam).
; @param q {in}{required}{type=integer} The first integration number
; to use.
; @param ref {in}{required}{type=integer} When this is 0, bmb is the
; tracking beam, otherwise bmb is the reference beam.
; @param asig {out}{type=float array}
; @param acal {out}{type=float array}
; @param aref {out}{type=float array}
; @param tinteg {out}{type=float} Total integration time.
;-
pro getkaphases,scan,ifnum,bmb, q, ref, asig, acal, aref, tinteg
   compile_opt idl2

   spmsize = (size(*!g.s[0].data_ptr))[1]
   s1_off = fltarr(spmsize)
   s1_on  = fltarr(spmsize)
   r1_off = fltarr(spmsize)
   r1_on  = fltarr(spmsize)
   getphases, scan, ifnum, bmb, q, tinteg, s1_off,s1_on,r1_off,r1_on

   s2_off = fltarr(spmsize)
   s2_on  = fltarr(spmsize)
   r2_off = fltarr(spmsize)
   r2_on  = fltarr(spmsize)
   getphases, scan+1, ifnum, bmb, q, tinteg, s2_off,s2_on,r2_off,r2_on

   ; get mean of calon and off
   s1_av = 0.5* ( s1_off+s1_on - median(s1_on-s1_off,/even))
   r1_av = 0.5* ( r1_off+r1_on - median(r1_on-r1_off,/even))
   s2_av = 0.5* ( s2_off+s2_on - median(s2_on-s2_off,/even))
   r2_av = 0.5* ( r2_off+r2_on - median(r2_on-r2_off,/even))

   if ref eq 0 then begin
     asig = 0.5 * (s1_av - r1_av - (s2_av - r2_av) )
     aref = 0.5 * ( r1_av + s2_av )
     acal = 0.5* ( (s1_on - r1_on)  - (s1_off-r1_off) $
	   + ( (s2_on - r2_on) - (s2_off - r2_off)) )

   endif else begin
     asig =  0.5 * (r1_av  - s1_av  - (r2_av  - s2_av ) )
     aref =  0.5 * ( s1_av  + r2_av  )
     acal =  0.5* ( (r1_on - s1_on)  - (r1_off-s1_off) $
	    + ( (r2_on - s2_on) - (r2_off - s2_off)) )
   endelse

end


;+
; standard case for KA-band beam-switched dual beam spectra.
; <p>
; this should work for not beam-switching as well!!
;
; @uses <a href="getkanod.html#_getkaphases">getkaphases</a>
;
; @param info {in}{required}{type=scan info structure} Not used here.
; @param scan {in}{required}{type=integer} The first scan number in
; the pair.
; @param ifnum {in}{required}{type=integer} The desired IF number.
; @param bm1 {in}{required}{type=integer} Feed (beam) 1.
; @param bm2 {in}{required}{type=integer} Feed (beam) 2.
; @param tcal {in}{required}{type=float} The Tcal value, used when
; sref eq 0.
; @param q {in}{required}{type=integer} The first integration number
; to use.
; @param sref {in}{required}{type=integer} When eq 0, then normalize
; by cal, else normalize by ref.
; @param noav {in}{required}{type=integer} If ge 1 then don't average
; the two beams.
;-
pro  ka_dual_scp_1cal, info, scan, ifnum, bm1, bm2, tcal, q, sref, noav

   compile_opt idl2

    spmsize = (size(*!g.s[0].data_ptr))[1]

 ;  accums for sig and cal spectra for the two samplers.
      sig1 = fltarr( spmsize)
      cal1 = fltarr( spmsize)
	cal1[*] = 1.0
      ref1 = fltarr( spmsize)
      sig2 = fltarr( spmsize)
      cal2 = fltarr( spmsize)
	cal2[*] = 1.0
      ref2 = fltarr( spmsize)

   ncount=0

 ; sum up the integration time in this array.
   tinteg = fltarr(2)

   getkaphases,scan,ifnum,bm1, q, 0, sig1, cal1, ref1, tinteg
      ncount = ncount + 1

   tint1 = 0.5*tinteg[0]
   tinteg[*]=0

 ; if there is no sampler for beam 2, then skip this step.
   if bm2 gt 0 then begin
    getkaphases,scan,ifnum, bm2, q, 1, sig2, cal2, ref2, tinteg
       ncount = ncount + 1
   endif

    tinteg[*] = tint1

    ; get medians
      medcal = [ median(cal1, /even), median(cal2, /even) ]
      medsig = [ median(sig1, /even), median(sig2, /even) ]
      medref = [ median(ref1, /even), median(ref2, /even) ]
      tsys   = tcal * medref/medcal

    ; print," "
    ; print, "T integration=", tinteg, " , Tcal=", tcal, $
; 	format='(a,1x,f7.3,1x,f7.3,1x,a,f7.2)'
    print,"med Tant = ", tcal*medsig/medcal
    print,"med Tsys = ", tsys

   ; stuff the tint and tcal into the container.
      !g.s[0].mean_tcal = tcal
      !g.s[0].exposure = tinteg[0]

   if sref eq 0 then begin
   ; normalize by cal :
     if noav ge 1 then begin
       *(!g.s[0].data_ptr) = tcal * sig2/cal2 
       copy,0,1
       *(!g.s[0].data_ptr) = tcal * sig1/cal1
     endif else begin
	if bm2 gt 0 then begin       ; average data from both samplers?
          *(!g.s[0].data_ptr) = tcal * (sig1+sig2)/(cal1+cal2) 
          !g.s[0].exposure = 2.0*tinteg[0]
	endif else begin
          *(!g.s[0].data_ptr) = tcal * sig1/cal1
	endelse
     endelse

   endif else begin
   ; normalize by ref :
     if noav ge 1 then begin
       *(!g.s[0].data_ptr) = tsys[1] * sig2/ref2
       copy,0,1
       *(!g.s[0].data_ptr) = tsys[0] * sig1/ref1
     endif else begin
	if bm2 gt 0 then begin       ; average data from both samplers?
          *(!g.s[0].data_ptr) = 0.5*(tsys[0]+tsys[1]) * (sig1+sig2)/(ref1+ref2)
          !g.s[0].exposure = 2.0*tinteg[0]
	endif else begin
          *(!g.s[0].data_ptr) = tsys[0] * sig1/ref1
	endelse
     endelse
   endelse

   !g.s[0].tsys = tsys[0]
   if noav ge 1 then !g.s[1].tsys = tsys[1]

end

;+
; getkanod retrieves and calibrates a "nod" pair for the KA-band receiver.
; <p>
; type getkanod with no parameters to get the help message.
; <p>
; This works only for beamswitched nod pairs with the KA-band receiver,
; and only one polarization channel per beam.
; <p>
;   You must give it the scan number of the first of the two scans.
;   It assumes you have just used a single cal 'R' or 'L'
;   The trk_beam parameter is the on-source beam number for the first scan.
;   Note: there is no "pol" parameter because of the cross-pol switching.
;     in effect, the two polarizations are averaged.
; <p>
;   scal : this is the flux density of a continuum calibrator.
;   If the scal parameter is present, the output spectrum is the noise cal
;   spectrum in flux density units.
; <p> calfile : if you give a calfile name and scal is set, then the 
;    "scal" spectrum is written to the named file.
; <p>
;  After writing a spectrum for the calibrator using scal and calfile,
;  then if you run on a program source with calfile set to the same
;  file that the calibrator spectrum was saved to (but with no scal given),
;  then the calfile is used to scale the spectrum of the program object
;  to flux density units.
; <p>
;   If you do not set the /noav flag, it averages data from the 
;	two samplers and puts the result in container zero.
;     but if /noav is set, then the results from the two samplers
;     are kept separate and are put into containers 0 and 1.
; <p>
;   If the /sref flag is set, then the calibration is (Sig-Ref)/Ref,
;   otherwise its (Sig-Ref)/Cal.
;
; @uses <a href="getkanod.html#_ka_dual_scp_1cal">ka_dual_scp_1cal</a>
;
;
; @param scan {in}{required}{type=integer} scan number
; @param ifnum {in}{required}{type=integer} IF number: 0,1,2,etc, (def:0)
; @keyword tau {in}{optional}{type=float} Zenith absorption coefficient (def:0.05)
; @keyword ap_eff {in}{optional}{type=float} Aperture efficiency in % (def:50)
; @keyword trk_beam {in}{optional}{type=integer} Tracking beam number (def: 1)
; @keyword tcal {in}{optional}{type=float} Average cal temperature (def: 1)
; @keyword scal {in}{optional}{type=float} Calibrator flux density.
; @keyword q {in}{optional}{type=integer} Flag first integration.
; @keyword calfile {in}{optional}{type=string} File for storing SCALs.
; @keyword sref {in}{optional}{type=integer} If =1, normalize by ref.
; @keyword noav {in}{optional}{type=integer} If =1, do not average pols.
;--------------------------------------------------------------
pro getkanod,scan,ifnum,tau=tau,ap_eff=ap_eff, trk_beam=trk_beam, $
	tcal=tcal,scal=scal,q=q,calfile=calfile,sref=sref,noav=noav

   compile_opt idl2

  ; check if help wanted:
  if n_params() le 0 then begin
    print,"getkanod, scanno, ifnum, [tau=...], [ap_eff=...], "
    print,"      [trk_beam=..], [tcal=...], [scal=...],  [q=1], [calfile=...]"
    print,"      "
    print,"   --> ifnum : select IF index (0,1, ..); default : 0"
    print,"   --> tau = zenith absorption; default : 0.05 "
    print,"   --> ap_eff = aperture efficiency; default : 50% "
    print,"   --> trk_beam : track beam number; def: 1 "
    print,"   --> tcal : average tcal for the whole scan."
    print,"   --> scal : compute scal from source flux density."
    print,"   --> q : number of integrations to flag"
    print,"   --> calfile : file to save or retrieve scal data."
    print,"   --> /sref : Normalize by 'ref' spectrum instead of 'cal'"
    print,"   --> /noav : do not average the data from both samplers."
    return
  endif

   ; check that scan is present
   if n_elements(scan) eq 0 then scan = 0
   info = scan_info(scan)

   ; exit the procedure if the scan was not found.
   if (size(info))[0] lt 1 then return

   if info.n_feeds ne 2 then begin
	print," "
	print,"This procedure requires data from 2 beams"
	return
   endif

   ; set defaults
   if n_elements(ifnum) eq 0 then ifnum = 0
   if n_elements(tau) eq 0 then tau = 0.05
   if n_elements(ap_eff) eq 0 then ap_eff = 50.0
   if n_elements(trk_beam) eq 0 then trk_beam = 1    
   if n_elements(tcal) eq 0 then tcal = 1    ; use tcal=1 if no value given
   if n_elements(scal) eq 0 then scal = 0 else scal = float(scal)
   if n_elements(q) eq 0 then q = 1    
   if n_elements(sref) eq 0 then sref=0
   if n_elements(noav) eq 0 then noav=0

;   print,"scan", scan, ", IF", ifnum, ", TAU=", tau, $
;	", apeff=", ap_eff, ", trk_beam", trk_beam, $
;	format='(a,i4,a,i2,a,f6.3,a,f5.2, a,i2)'
;   print, " tcal", tcal, ", scal=",scal, ", q=",q," sref=",sref, $
;	format='(a, f6.2,a,f6.2,a,i2,1x,a,i2)'

   if n_elements(calfile) gt 0 then print, " calfile = ", calfile

   if ifnum lt 0 or ifnum gt info.n_ifs-1 then $
      message,string("Illegal IF identifier: ",ifnum,"  This scan has ",info.n_ifs," IFs.")

   old_frozen = !g.frozen
   freeze

  ; just eliminate all these checks.
  calswitch='F'

  sigswitch='F'
  ; check to see if we are sig/ref switching
  ; ndon = select_data(!g.lineio, int=1, scan=scan, ifnum=ifnum, sig='T*')
  ; ndof = select_data(!g.lineio, int=1, scan=scan, ifnum=ifnum, sig='F*')
  ; if ( (size(ndon))[0] gt 0) and ( (size(ndof))[0] gt 0 )  then sigswitch='T'

  dualbeam='F'
  onlybeam=0
  bm1 = 0
  bm2 = 0
  ndbm1 = select_data(!g.lineio, scan=scan, ifnum=ifnum, $
	feed=trk_beam)
    if (size(ndbm1))[0] lt 1 then begin
	print, "Specified track beam not present"
	return
    endif

  ; what beams do we have?
  ; we assume there are only two beams which are either (1,2) or (3,4)
  ; ndbm1 = select_data(!g.lineio, scan=scan, ifnum=ifnum, feed=1)
  ; if ( (size(ndbm1))[0] gt 0 ) then bm1 = 1
  ; ndbm2 = select_data(!g.lineio, scan=scan, ifnum=ifnum, feed=2)
  ; if ( (size(ndbm2))[0] gt 0 ) then bm2 = 2
  ; ndbm3 = select_data(!g.lineio, scan=scan, ifnum=ifnum, feed=3)
  ; if ( (size(ndbm3))[0] gt 0 ) then begin
  ;      bm1 = 3
  ;      ndbm1 = ndbm3
  ;  endif
  ; ndbm4 = select_data(!g.lineio, scan=scan, ifnum=ifnum, feed=4)
  ; if ( (size(ndbm4))[0] gt 0 ) then begin
  ;      bm2 = 4
  ;      ndbm2 = ndbm4
  ;  endif

;  read first record into data container
   getrec,ndbm1[0]

   elevation = !g.s[0].elevation
   obsfreq   = 1.0e-9 * !g.s[0].observed_frequency  ; in GHz

   ; factors for gain curve and opacity corrections.
    w = 54.0 * 43.0 / obsfreq
    elkw = (elevation - 52.0)/w
    gg = 0.01*ap_eff * exp( - (elkw*elkw)  )

    Tabs_corr = exp( -tau/(sin(elevation* !pi/180.0)) )
    gain_corr = Tabs_corr/gg
    if tau le 0.0001 then gain_corr = 1.0

  ; print info about the scan
  print,"SCAN PROCEDURE N_INTEG N_BEAMS N_IFS N_STATES  TAU  ELEV  GCORR"
  print, info.scan, info.procedure, info.n_integrations, info.n_feeds, $
         info.n_ifs, info.n_switching_states, tau, elevation, gain_corr, $
         format='( i4, a8, i6, 3x, i6, 2x, i6, 2x, i6, 2x, f6.3, 1x, f6.1, 1x, f7.3)'

;   if bm1 gt 0 and bm2 gt 0 then dualbeam='T'

;   if trk_beam eq bm2 then begin
;	bbm=bm1
;	bm1=bm2
;	bm2=bbm
;   endif
    bm1 = trk_beam
    if bm1 ge 3 then bm2 = 7-bm1 else bm2=3-bm1

   if info.n_switching_states ge 3 then begin
     print, "Processing dual beam + beamswitching data"
 
    ; process the nod data. 
      ka_dual_scp_1cal, info, scan, ifnum, bm1, bm2, tcal, q, sref, noav

   endif else begin
     print, "Processing dual beam and non-beamswitching data"
     ka_dual_scp_1cal, info, scan, ifnum, bm1, bm2, tcal, q, sref, noav
   endelse

   spmsize = (size(*!g.s[0].data_ptr))[1]
   ; print,"SpmSize=",spmsize
   y1 = fix(0.1*spmsize)
   y2 = fix(0.9*spmsize)

    ; apply gain curve and atmospheric corrections here
    ; if tau=0, apply no corrections
      if tau gt 0.0001 then begin
         tmparr = *(!g.s[0].data_ptr)
          *(!g.s[0].data_ptr) = gain_corr * tmparr
	 if noav ge 1 then begin
           tmparr = *(!g.s[1].data_ptr)
           *(!g.s[1].data_ptr) = gain_corr * tmparr
	 endif

	; also apply correction to tsys
	  !g.s[0].tsys = !g.s[0].tsys * gain_corr
	  if noav ge 1 then $
	    !g.s[1].tsys = !g.s[1].tsys * gain_corr
       endif

     ; convert to scal ??
      if scal gt 0.001 then begin
	  CalFlux = scal
          tmparr = *(!g.s[0].data_ptr)
          *(!g.s[0].data_ptr) = CalFlux/tmparr

	  if noav ge 1 then begin
            tmparr = *(!g.s[1].data_ptr)
            *(!g.s[1].data_ptr) = CalFlux/tmparr
	  endif

	  print,"Calibration SCAL spectrum for Calibrator flux density=", scal
	
	; write cal data to file ??
	if n_elements(calfile) gt 0 then begin
	   dataArr = fltarr( 2, (size(*(!g.s[0].data_ptr)))[1]  )
	   dataArr[0,*] = *(!g.s[0].data_ptr)
	   dataArr[1,*] = *(!g.s[0].data_ptr)
	   if noav ge 1 then dataArr[1,*] = *(!g.s[1].data_ptr)
	   openw,lun, calfile, /get_lun
	   writeu, lun, dataArr
	   free_lun, lun
	   print, "Wrote SCAL data to file ", calfile
	endif

      endif else begin   ; apply cal data??
	if n_elements(calfile) gt 0 then begin
	   dataArr = fltarr( 2, (size(*(!g.s[0].data_ptr)))[1]  )
	   openr,lun,calfile,/get_lun
	   readu,lun,dataArr
	   free_lun, lun
	   print, "Read SCAL data from file ", calfile

	   tmparr = *(!g.s[0].data_ptr)
           *(!g.s[0].data_ptr) = tmparr * dataArr[0,*]
	   ; scale the tsys:
	    !g.s[0].tsys = !g.s[0].tsys * mean(dataArr[0, y1:y2])

	   if noav ge 1 then begin
             tmparr = *(!g.s[1].data_ptr)
             *(!g.s[1].data_ptr) = tmparr * dataArr[1,*]
	     !g.s[1].tsys = !g.s[1].tsys * mean(dataArr[1, y1:y2])
	   endif
	endif
      endelse

   ; summarize the spectrum rms
     if noav le 0 then begin
       std1 = stddev( (*(!g.s[0].data_ptr))[y1:y2] )
       print,"stddev of spectrum =", std1
     endif else begin
       std1 = stddev( (*(!g.s[0].data_ptr))[y1:y2] )
       std2 = stddev( (*(!g.s[1].data_ptr))[y1:y2] )
       print,"stddev of spectra =", std1, " , ", std2
     endelse

   !g.frozen = old_frozen
   if !g.frozen eq 0 then  show 

  return
end
; -------------- end of main getkanod procedure

