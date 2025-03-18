;+
; This procedure is used to specify how many channels at the beginning of
; the spectrum should be ignored, when plotting.  You then avoid the
; bad autoscaling that can result when the edge of the spectrum contains
; bad values.
;
; Note that the values are applied in channel space, so depending on whether the
; plot is shown in channels, frequency, or velocity, a bdrop value may
; affect the left or right side of the plotted spectrum.
;
; @param nchan {in}{required}{type=int} number of channels to drop from the
;  beginning of the plot
;
; @examples
; <pre>
;   show       ; show some spectrum with bad channels 
;   bdrop,10   ; the spectrum is replotted with better scaling
;   bdrop,0    ; unset the bdrop value
; </pre>
;
; @version $Id$
;-

pro bdrop,nchan
	compile_opt idl2
	common gbtplot_common,mystate,xarray
	if n_params() ne 1 then begin
	  message,"Usage: bdrop, nchans",/info
	  return
	end

	datalen = data_valid(!g.s[0])
        if datalen le 0 then begin
             message,'No data has been plotted yet.',/info
             return
        endif
	if ((nchan lt 0) or (nchan ge datalen)) then $
		message, 'Bad value. Must be between 0 and '+string(datalen),/info
	mystate.bdrop = nchan
	if !g.frozen eq 0 then reshow
end
