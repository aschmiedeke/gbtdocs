;+
; avkanods calibrates and averages a series of "nod" pairs 
; for the KA-band receiver.
; <p>
; type avkanods with no parameters to get the help message.
; <p>
; This works only for beamswitched nod pairs with the KA-band receiver,
; and only one polarization channel per beam.
; <p>
; The first parameters "scans" is an array with a series of scan numbers;
; each scan number is the first of a nod pair.
; <br> For example:  avkanods,[16,18,20,22],0
; <p>
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
; @uses <a href="getkanod.html">getkanod</a>
;
; <p><B>Contributed By: Frank Ghigo, NRAO-GB</B>
;
; @param scans {in}{required}{type=integer} scan number
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
;
; @version $Id$
;-
pro avkanods,scans,ifnum,tau=tau,ap_eff=ap_eff, trk_beam=trk_beam, $
	tcal=tcal,scal=scal,q=q,calfile=calfile,sref=sref, noav=noav

   compile_opt idl2

; "scans" is an array with a series of scan numbers;
; each scan number is the first of a nod pair.

  ; check if help wanted:
  if n_params() le 0 then begin
    print,"avkanods, scanlist, ifnum, [tau=...], [ap_eff=...], "
    print,"      [trk_beam=..], [tcal=...], [scal=...],  [q=1], [calfile=...]"
    print,"      "
    print,"   --> scanlist : array of scan numbers, e.g. [23,25,27]"
    print,"   --> ifnum : select IF index (0,1, ..); default : 0"
    print,"   --> tau = zenith absorption; default : 0.05 "
    print,"   --> ap_eff = aperture efficiency; default : 50% "
    print,"   --> trk_beam : track beam number; def: 1 "
    print,"   --> tcal : average tcal for the whole scan."
    print,"   --> scal : compute scal from source flux density."
    print,"   --> q : number of integrations to flag"
    print,"   --> calfile : file to save or retrieve scal data."
    print,"   --> /sref: Scale by 'ref' spectrum instead of 'cal'."
    return
  endif

  if n_elements(noav) eq 0 then noav=0

  ncount = 1

   ss = size(scans)
   ; print,"avkanods", ss

   old_frozen = !g.frozen
   freeze

   if ss[0] gt 0 then begin
      if ss[1] gt 0 then begin

	; get the first scan
	getkanod,scans[0],ifnum,tau=tau,ap_eff=ap_eff, trk_beam=trk_beam, $
           tcal=tcal,scal=scal,q=q,calfile=calfile,sref=sref,noav=noav

        tint = [ !g.s[0].exposure, !g.s[1].exposure ]
        ttss = [ !g.s[0].tsys    , !g.s[1].tsys     ]

	acc1 = *(!g.s[0].data_ptr)
	if noav ge 1 then acc2 = *(!g.s[1].data_ptr)

	if ss[1] gt 1 then begin
	 for ii = 1, ss[1]-1 do begin
	  getkanod,scans[ii],ifnum,tau=tau,ap_eff=ap_eff, trk_beam=trk_beam, $
             tcal=tcal,scal=scal,q=q,calfile=calfile,sref=sref,noav=noav

	  acc1 = acc1 + *(!g.s[0].data_ptr)
	  if noav ge 1 then acc2 = acc2 + *(!g.s[1].data_ptr)
	  ncount = ncount + 1
            ; total up the exposure time
            tint = tint + [ !g.s[0].exposure, !g.s[1].exposure ] 
            ttss = ttss + [ !g.s[0].tsys    , !g.s[1].tsys     ] 
          endfor

       *(!g.s[0].data_ptr) = acc1/ncount
        !g.s[0].exposure = tint[0]
        !g.s[0].tsys     = ttss[0]/ncount

	if noav ge 1 then begin
          *(!g.s[1].data_ptr) = acc2/ncount
          !g.s[1].exposure = tint[1]
          !g.s[1].tsys     = ttss[1]/ncount
	endif
       endif
      endif
   endif
   ; summarize the spectrum rms for the averaged scans
     spmsize = (size(*!g.s[0].data_ptr))[1]
     y1 = fix(0.1*spmsize)
     y2 = fix(0.9*spmsize)
     std1 = stddev( (*(!g.s[0].data_ptr))[y1:y2] )
     std2 = 0.0
     if noav ge 1 then std2 = stddev( (*(!g.s[1].data_ptr))[y1:y2] )
     print,"stddev of ",ncount, " averaged spectra =", std1, " , ", std2

   !g.frozen = old_frozen
   if !g.frozen eq 0 then  show 
end
;-------------------------------------------------------------

