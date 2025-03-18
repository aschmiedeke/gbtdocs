;+
; Return a vector of VEGAS ADC spur channels given the values of VSPDELT,
; VSPRPIX, VSPRVAL, and NCHAN.  
;
; <p>The VSP* values should be taken from a GBTIDL data container,
; where the VSPRPIX value has already had 1 subtracted from the value
; found in the FITS file (FITS counts channels from 1, GBTIDL counts
; channels from 0). 
;
; <p>Spurs are located at the following channels:
; <p>spur_j = (j - VSPRVAL)*VSPDELT + VSPRPIX
; <p>Where j is an integer that goes from 0 through 33.
; <p>The VSP* values are double precision floats but the spur_j is
; assumed to be an integer.  Conversion to an integer is done using
; the IDL round function.
;
; <p>NCHAN is used to determine which spur_j values should be
; returned.  Valid spur_j values are equal to or greater than 0 and
; less than NCHAN.  The count keyword is set to the number of valid
; spur_j values returned.  If there are none, then the returned spur_j
; value is -1 and count is 0.
;
; <p>The value at j=16, the center ADC spur, is not included in the
; returned values unless the docenterspur keyword is set.  Normal
; sdfits use will replace that center ADC spur with the average of the
; two adjacent channels and so it's usually not necessary in
; GBTIDL to know where that center ADC spur is since it does not need
; to be reflagged or interpolated across.
;
; <p>These spurs do not include the center spur.  That spur always
; occurs at  the center channel (NCHAN/2 when counting from 0, as is
; done in IDL) and is replaced with the average of the two adjacent
; channels by sdfits unless the "-nointerp" option to sdfits is used.
; That spur does not arise in the ADC and so does not move as the
; spectral window is tuned across the ADC bandpass.
;
; <p>This routine does not check the validity of the input values.
;
; @param vsprval {in}{required}{type=double} The spur reference value.
; @param vsprpix {in}{required}{type=double} The channel number
; (pixel) corresponding to the spur reference value (vsprval).
; @param vspdelt {in}{required}{type=double} The channel increment
; between adjacent spur numbers (j to j+1).
; @param nchan {in}{required}{type=integer} The number of channels to
; use in determining which spur_j values to return.
; @keyword docenterspur {in}{optional}{type=boolean} When set, the
; center ADC spur will be included in the array of returned channel
; numbers.  The center ADC spur is normally interpolated across by
; sdfits and is typically not needed when reflagging or interpolating
; across the spurs in GBTIDL. The default behavior is to not return
; that channel in the list of spur channel numbers.
; @keyword count {out}{optional}{type=integer} The number of valid
; VEGAS spur channels returned.
;
; @returns an array listing the channel numbers associated with all of
; the VEGAS spurs associated with the input parameters.
;
; @version $Id$
;-
function dcspurchans, vsprval, vsprpix, vspdelt, nchan, docenterspur=docenterspur, count=count
  compile_opt idl2

  spurChans = round((dindgen(33)-vsprval)*vspdelt + vsprpix)
  if not keyword_set(docenterspur) then begin
     ; remove the j=16 spur
     spurChans = [spurChans[0:15],spurChans[17:*]]
  endif
  okSpurs = where(spurChans ge 0 and spurChans lt nchan, count)
  if count le 0 then begin
     ; no valid spurs
     spurChans = -1
  endif else begin
     spurChans = spurChans[okSpurs]
  endelse

  return,spurChans
end
