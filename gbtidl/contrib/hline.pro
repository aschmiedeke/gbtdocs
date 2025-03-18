;+
; hline.pro   draw horizontal line at specific y-axis value
; ---------   
;
; <B>Contributed by: Tom Bania</B>
;
; Note that this is used by bsearch.pro and that it plot's to a
; separate IDL plot window, not the GBTIDL plotter.
;
; @param val {in}{required}{type=float} The y-value to use.
;-
pro hline,val
;
On_error,2  ; returns to calling procedure on error
;
if (n_params() eq 0) then begin
                     print
                     print,'Error: No value input'
                     print,'Syntax: hline,y-axis_value_to_plot'
                     print 
                     return
                     endif
;
;
; get data ranges
;
xmin = !x.crange[0]
xmax = !x.crange[1]
ymin = !y.crange[0]
ymax = !y.crange[1]
xrange = xmax-xmin
yrange = ymax-ymin
xincr=0.025*xrange
;
plots,xmin,val
plots,xmax+xincr,val,/continue,color=!magenta
xyouts,xmax+xincr,val,string(val,'(f5.2)'),/data,color=!magenta
;
;
return
end

