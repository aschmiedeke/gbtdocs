;+
; This procedure is used to specify how many channels at the end of
; the spectrum should be ignored, when plotting.  You then avoid
; the bad autoscaling that can result when the edge of the spectrum contains
; bad values.
;
; Note that the values are applied in channel space, so depending on whether
; the plot is shown in channels, frequency, or velocity, an edrop value may
; affect the left or right side of the plotted spectrum
;
; @param nchan {in}{required}{type=int} number of channels to drop from the
;  end of the plot
;
; @examples
; <pre>
;   show       ; show some spectrum with bad channels 
;   bdrop,10   ;
;   edrop,10   ; the spectrum is replotted with better scaling
;   edrop,0    ; unset the edrop value.  bdrop is still in effect.
; </pre>
;
; @version $Id$
;-

pro edrop,nchan
	compile_opt idl2
	common gbtplot_common,mystate,xarray
	if n_params() ne 1 then begin
	  message,"Usage: edrop, nchans",/info
	  return
	end

        datalen = data_valid(!g.s[0])
        if datalen le 0 then begin
             message,'No data has been plotted yet.',/info
             return
        endif
 
	if ((nchan lt 0) or (nchan ge datalen)) then $
		message, 'Bad value. Must be between 0 and '+datalen,/info
	mystate.edrop = nchan
	if !g.frozen eq 0 then reshow
end
