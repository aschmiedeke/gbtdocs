; docformat = 'rst' 

;+
; Replace data values in the given data containers at the known
; locations of VEGAS spurs with the average of the two adjacent
; channel values. 
;
; VEGAS produces spurs (spikes) at channels corresponding to
; integer multiples of the ADC sampler frequency divided by 64.  The
; normal behavior of sdfits is to flag these channels when the data
; are filled.  When flagged data is retrieved by
; GBTIDL, the flagged channels are replaced with NaNs and will not
; contribute to most operations.  If the skipflag option is used to
; retrieve the data then flagging is not applied and the original data
; values will appear at all channels.  
;
; It is sometimes useful to replace the spur data values (either
; NaNs if the flags have been used or the original data values if the
; flags are ignored) with interpolated values.  This routine replaces
; those values with the average of the two channels on either side of
; the spur (or the adjacent channel if the spur is at the end of the
; spectrum).
; 
; This spur locations are determined using the VSPDELT, VSPRPIX,
; and VSPRVAL header values.  For data filled using older versions of
; sdfits, these values are not present in the SDFITS table and will
; appear as NaN in GBTIDL.  In that case, no spur interpolation is
; possible and a warning message will be printed.  The data should be
; refilled by the most recent version of sdfits to make use of this
; procedure.
;
; :Params:
;   dc : in, out, required, type=spectrum data container(s)
;       The data container(s) to alter.  May be an array of data 
;       containers.
;
; :Uses:
;   :idl:pro:`dcspurchans`
; 
;-
pro dcspurinterp, dc
  ; since the only changes this makes in dc, or any element
  ; in dc if dc is a vector, is in through the data pointer
  ; then this routine will work even if the thing passed in
  ; is a copy and not by reference, i.e.
  ; dcspurinterp,!g.s[0]
  ; will correctly modify !g.s[0]
  compile_opt idl2

  ; only make a specific warning once.
  invalidWarned = 0
  badspursWarned = 0

  for i=0,(n_elements(dc)-1) do begin
     thisdc = dc[i]
     ; skip if the data container is not valid
     nchan = data_valid(thisdc)
     if nchan le 0 then begin
        if not invalidWarned then begin
           message,'One or more data containers is not valid.  No interpolation on that data container.',/info
           invalidWarned = 1
        endif
        continue
     endif

     vspdelt = thisdc.vspdelt
     vsprval = thisdc.vsprval
     vsprpix = thisdc.vsprpix

     if not(finite(vspdelt) and finite(vsprval) and finite(vsprpix)) then begin
        ; Can not proceed, no valid values
        ; just silently continue without warning
        continue
     endif

     spurChans = dcspurchans(vsprval,vsprpix,vspdelt,nchan,count=count)
     if count le 0 then begin
        ; no spurs to interpolate over here, just return
        return
     endif

     surroundChans = lonarr(count*2)
     surroundChans[0:(count*2-2):2] = spurChans-1
     surroundChans[1:(count*2-1):2] = spurChans+1

     ; need separate copy for index purposes because of end channel treatment
     iSurroundChans = surroundChans
     if iSurroundChans[0] lt 0 then begin
        ; duplicate the next value
        iSurroundChans[0] = iSurroundChans[1]
     endif
     if iSurroundChans[count*2-1] gt nchan then begin
        ; duplicate the previous value
        iSurroundChans[count*2-1] = iSurroundChans[count*2-2]
     endif
                                ; default for INTERPOL is linear
                                ; interpolation - so this does the job
     (*thisdc.data_ptr)[spurChans] = $
        interpol((*thisdc.data_ptr)[iSurroundChans],float(surroundChans),float(spurChans))
  endfor
end
