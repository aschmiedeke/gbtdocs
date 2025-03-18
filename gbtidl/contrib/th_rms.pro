;+
; Calculate theoretical rms expected from current configuration.  Used
; by RADIOM for comparison with empirical radiometer equation.
;
; <p>
; theoretical radiometer equation 
; <pre>
;  rms := k1*tsys/sqrt(k2*teff*npol*df);
;
; </pre>
; where teff is the effective integration time given by
; <pre>
;  teff = ton*toff/(ton + toff) 
; </pre>
; This code assumes ton equals toff hence
; <pre>
;  teff = tint / 2  ; tint is the integration time
; </pre>
;
; <p><B>Contributed By: Bob Garwood from Tom Bania's original GBT IDL
; package</B>
;
;
; @param tsys {in}{required}{type=float} system temperature in milliKelvins
; @param df {in}{required}{type=float} Channel separation in Hz.
; @param npol {in}{required}{type=integer} Number of polarization (or
; independent signals).
; @param k1 {in}{required}{type=float} backend sampling efficiency,
; 1.032 for 9-level autocorrelator, 1.235 for 3-level.
; @param k2 {in}{required}{type=float} Channel weighting function.
; 1.21 for uniform for the GBT spectrometer (sinc(x) channel response)
; and 2.00 for Hanning smoothed GBT spectrometer data.
; @param xmin {in}{required}{type=float} Minimum integration time in minutes.
; @param xmax {in}{required}{type=float} Maximum integration time in minutes.
; @param no_pts {in}{required}{type=integer} Number of unique teff values to
; calculate th_rms between xmin and xmax.
; @param time_x {out}{type=float} The array of integration times used.
; @param rms_y {out}{type=float} The array of theoretical RMS values calculated.
; seconds.
;
; @version $Id$
;-
pro th_rms,tsys,df,npol,k1,k2,xmin,xmax,no_pts,time_x,rms_y
;
on_error,2
;
if n_params() eq 0 then begin
                   print,'Error: Need to specify radiometer equation parameters'
                   print,'Sytax: th_rms,tsys,df,npol,k1,k2,min,xmax,no_pts,time_x,rms_y'
                   return
                   end
;
case k1 of 
          9: k1=1.032d   ; 9-level
          3: ki=1.235d   ; 3-level
       else: begin
             print,'Error: Correlator sampling not specified'
             return
             end
endcase
;
case k2 of
           1: k2=1.21d   ; uniform weighting
           2: k2=2.00    ; Hanning weighting
        else: begin
              print,'Error: Correlator weighting not specified'
              return
              end
endcase
;
; teff = 0.5*t_scan for equal times ON/OFF
; tintg= 2.0*t_scan
; 
; ==>   teff = 0.25*tintg
;
xmin=xmin*60.                     ; time in seconds
xmax=xmax*60. 
dt=(xmax-xmin)/no_pts
for i=0,no_pts-1 do begin
      time_x[i]=xmin+float(i)*dt
      teff=0.25*time_x[i]
      rms_y[i] = k1*tsys/sqrt(k2*teff*npol*df)
endfor
;
time_x=time_x/60.                 ; return time in minutes
;
return
end
