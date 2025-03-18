;+
; Replace data values at the known locations of VEGAS ADC spurs with
; the average of the two adjacent channel values.
;
; <p>VEGAS produces spurs (spikes) at channels corresponding to
; integer multiples of the ADC sampler frequency divided by 64.  The
; normal behavior of sdfits is to flag these channels when the data
; are filled (use <a href="listflags">listflags</a> to see the list of flags for the
; currently opened input data set).  When flagged data is retrieved by
; GBTIDL, the flagged channels are replaced with NaNs and will not
; contribute to most operations.  If the skipflag option is used to
; retrieve the data then flagging is not applied and the original data
; values will appear at all channels.  
;
; <p>It is sometimes useful to replace the spur data values (either
; NaNs if the flags have been used or the original data values if the
; flags are ignored) with interpolated values.  This routine replaces
; those values with the average of the two channels on either side of
; the spur (or the adjacent channel if the spur is at the end of the
; spectrum).
;
; <p>A spur is also typically present at the center channel (NCHAN/2
; when counting from 0).  That spur does not arise in the ADC in VEGAS
; and does not move as the spectral window is tuned across the ADC
; bandpass. This routine does not interpolate across that channel.
; Normal sdfits usage does that interpolation unless the "-nointerp"
; option is used. 
; 
; <p>If the buffer is not specified then buffer 0 is used.
; <p>If the display is not already frozen and buffer 0 is used then
; the show command is used to redisplay the data.
;
; <p>This spur locations are determined using the VSPDELT, VSPRPIX,
; and VSPRVAL header values.  For data filled using older versions of
; sdfits, these values are not present in the SDFITS table and will
; appear as NaN in GBTIDL.  In that case, no spur interpolation is
; possible and a warning message will be printed.  The data should be
; refilled by the most recent version of sdfits to make use of this
; procedure.
;
; @param buffer {in}{optional}{type=integer}{default=0} Input data
; buffer (0 through 15).
;
; @uses <a href="../toolbox/dcspurinterp.html">dcspurinterp</a>
; 
; @version $Id$
;-
pro spurinterp, buffer
  compile_opt idl2

  if n_elements(buffer) eq 0 then buffer = 0

  if (buffer lt 0 or buffer gt n_elements(!g.s)) then begin
     message, 'requested buffer does not exist',/info
     return
  endif

  if data_valid(!g.s[buffer]) le 0 then begin
     message,'No data found in requested buffer.',/info
     return
  endif

  if not(finite(!g.s[buffer].vspdelt) and finite(!g.s[buffer].vsprval) and finite(!g.s[buffer].vsprpix)) then begin
     message,'No VEGAS spur information found for this buffer, can not interpolate across spur locations',/info
     return
  endif

  dcspurinterp, !g.s[buffer]

  if buffer eq 0 and not !g.frozen then show

end
