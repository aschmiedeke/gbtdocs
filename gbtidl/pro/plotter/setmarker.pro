;+
; This procedure sets a marker on the plot at the given location.
;
; @param x {in}{required}{type=float} X position in current plotter units
; @param y {in}{required}{type=float} Y position in current plotter units
; @keyword text {in}{optional}{type=string} text to be associated with the marker.
;          If omitted, the text will represent the x and y positions.
;
; @examples
;   setmarker,1420.405,1.3
;
; @version $Id$
;-

pro setmarker,x,y,text=text
	common gbtplot_common,mystate,xarray

	if n_params() lt 2 or n_params() gt 3 then begin
	   message,"Error in number of parameters.",/info
	   message,"Usage: setmarker,x,y,[text=text]",/info
	   return
        end

        if n_elements(text) eq 0 then $
	   text = string(x,y, format='(" X: ",g10.5,1x,"Y:",f10.3)')

        mystate.nmarkers = mystate.nmarkers+1
        if mystate.nmarkers gt mystate.maxnmarkers then begin
            ; add another 100
            *mystate.marker_pos = [*mystate.marker_pos, fltarr(100,2)]
            *mystate.marker_txt = [*mystate.marker_txt, strarr(100)]
            mystate.maxnmarkers += 100
        endif
        (*mystate.marker_pos)[mystate.nmarkers-1,0] = x
        (*mystate.marker_pos)[mystate.nmarkers-1,1] = y
        (*mystate.marker_txt)[mystate.nmarkers-1] = text
        if !g.frozen eq 0 then reshow
end
