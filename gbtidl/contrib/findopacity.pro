;+
; The procedure that uses the fitted values to calculate f.
; use.
; 
; @param x {in}{required}{type=float} elevations
; @param a {in}{required}{type=float} 2-element array used in setting f.
; @param f {out}{required}{type=float} f
;
; @hidden
;-
pro opacityfit, x, a, f

   common opacityparams, tatm

   numelev = n_elements(x)
   atmospheres = fltarr(numelev)

   for i=0,numelev-1,1 do begin
       if (x(i) lt 39.0) then begin
           atmospheres(i) = -0.023437  + 1.0140 / $
                            sin( (!pi/180.)*(x(i) + 5.1774 / $
                                             (x(i) + 3.3543) ) )
       endif else begin
           atmospheres(i) = 1./sin(!pi*x(i)/180.)
       endelse
   endfor

   f=a[0]+tatm*a[1]*atmospheres

end

;+
; Procedure to fit data to determine opacity.
;
; <p><b>Note:</b> this procedure works only on position switched and
; nodding data.
;
; Contact the contributor for additional details.
;
; <p><B>Contributed By: Toney Minter, NRAO-GB</B>
;
; @param scans {in}{required}{type=integer array} The scan numbers
; to calibrated (using getps) to determine system temperatures and
; ultimately opacity.
; @param opacity {in}{out}{required}{type=float} The initial guess on input and
; the fitted value on output for the opacity.
; @keyword ifnum {in}{optional}{type=integer} The standard GBTIDL
; ifnum argument.  This defaults to 0 if not supplied.
; @keyword plnum {in}{optional}{type=integer} The standard GBTIDL
; plnum argument.  This defaults to 0 if not supplied.
; @keyword fdnum {in}{optional}{type=integer} The standard GBTIDL
; fdnum argument.  This defaults to 0 if not supplied.
; @keyword tatmos {in}{optional}{type=float} The atmospheric
; temperature, in K, to use in the fit. This defaults to 270.0 if not
; supplied.
;
; @examples
;     opacity=0.35
;     findopacity,[6,8,10,12,14,16,18],3,1,opacity
;     print,opacity
;       0.05345
;
; @version $Id$
;-
pro findopacity,scans,opacity,ifnum=ifnum,plnum=plnum,fdnum=fdnum,$
                tatmos=tatmos
    ; suggestions were made by Ron Maddalena on the functional 
    ; form of the number of atomosphers along the line of sight
    ; and the calculation of the atompsheric temperature
    ; The reference for Ron's suggestions is
    ; http://www.gb.nrao.edu/~rmaddale/GBT/HighPrecisionCalibrationFromSingleDishTelescopes.pdf 
    ; and the corresponding abstract from the Bulletin of
    ; the AAS for the January 2006 meeting.
    ; the errors for the coefficients are given by
    ; A0=    259.69185966 +/- 0.117749542
    ; A1=     -1.66599001 +/- 0.0313805607
    ; A2=     0.226962192 +/- 0.00289457549
    ; A3=   -0.0100909636 +/- 0.00011905765
    ; A4=   0.00018402955 +/- 0.00000223708
    ; A5=  -0.00000119516 +/- 0.00000001564
    ; B0=      0.42557717 +/- 0.0078863791
    ; B1=     0.033932476 +/- 0.00210078949
    ; B2=    0.0002579834 +/- 0.00019368682
    ; B3=  -0.00006539032 +/- 0.00000796362
    ; B4=   0.00000157104 +/- 0.00000014959
    ; B5=  -0.00000001182 +/- 0.00000000105

    ; here is how we share the atmospheric temperature with the
    ; fitting function
    common opacityparams, tatm

    ; have values been set
    if n_elements(ifnum) eq 0 then ifnum=0
    if n_elements(plnum) eq 0 then plnum=0
    if n_elements(fdnum) eq 0 then fdnum=0

    ; how many scans to process and make needed arrays
    numscans=n_elements(scans)
    elevations=fltarr(numscans)
    tsys=fltarr(numscans)

    ; get the tsys from each on/off scan using getps
    for i=0,numscans-1,1 do begin
        getps,scans[i],ifnum=ifnum,plnum=plnum,fdnum=fdnum
        elevations(i)=!g.s[0].elevation
        tsys(i)=!g.s[0].tsys
    endfor

    ; set tatm to be tatmos
    a=[259.69185966, -1.66599001, 0.226962192, -0.0100909636, $
       0.00018402955, -0.00000119516]
    b=[0.42557717, 0.033932476, 0.0002579834, -0.00006539032, $
       0.00000157104, -0.00000001182]
    freq=!g.s[0].center_frequency/1.d9 ; in GHz
    tground=!g.s[0].tambient-273.15 ; temp in C
    calctatm = ( a(0) + a(1) * freq + a(2) * freq^2 + a(3) * freq^3 + $
             a(4) * freq^4 + a(5)*freq^5 ) + $
           ( b(0) + b(1) * freq + b(2) * freq^2 + b(3) * freq^3 + $
             b(4) * freq^4 + b(5) * freq^5) * tground
    if n_elements(tatmos) eq 0 then tatmos=calctatm
    tatm=tatmos

    ; now plot the tsys values vs elevations
    tmax=max(tsys)
    tmin=min(tsys)
    tdiff=tmax-tmin
    emax=max(elevations)
    emin=min(elevations)
    ediff=emax-emin
    plot,elevations,tsys,psym=1,yrange=[tmin-0.1*tdiff,tmax+0.1*tdiff],$
         xrange=[emin-0.1*ediff,emax+0.1*ediff],xstyle=1,ystyle=1,$
         xtitle='Elevation (degrees)',ytitle='Tsys (K)'

    ; now fit a curve to the data
    y=tsys(sort(elevations))
    x=elevations(sort(elevations))
    a=[tmin,opacity]
    w=y/y
    sigmaa=[0.,0.]
    Result = CURVEFIT(x, y, w, a, sigmaa, $
                          function_name ="opacityfit", /NODERIVATIVE,$
                     ITMAX=1000)
    
    ; print and plot the results
    print,'Trx+Tcmb+Tspill =',a[0],' +/-',sigmaa[0],' K'
    print,'        Opacity =',a[1],' +/-',sigmaa[1],' nepers'
    oplot,x,Result

    ;return the fitted opacity
    opacity=a[1]
end
