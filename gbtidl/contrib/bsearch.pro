;+
;   bsearch.pro   Fit baselines with polynomials of order 0 to 100
;   -----------   Pop up graphics window and plot RMS of fit vs
;                 polynomial order
;                 nmax is maximum order to plot -- nmax=100 is default
;
; @param nmax {in}{optional}{type=integer} The maximum order to
; plot, defaults to 100.
;
; <B>Contributed by: Tom Bania</B>
;
; Note: that this plots to a separate GBTIDL plot window and not the
; GBTIDL plotter.  The baseline fitting uses the data in buffer 0 (the
; primary data container) and the baseline regions (e.g. as set by
; setregion).
;-
pro bsearch,nmax

    on_error,2

    window,1,title='Baseline Search Plot',xsize=1050,ysize=600

    nfit=100                    ; Search for best baseline up to nfit=100   !!

    if (n_params() eq 0) then nmax=nfit

    index=get_chans(!g.s[0], !g.nregion, !g.regions)
    dsig = stddev((*!g.s[0].data_ptr)[index])
    xnfit=dindgen(nfit)

    bshape,nfit=nfit,/noshow

    print
    print,'RMS in NREGIONs before any fit = ', dsig,$
          ' for ',n_elements(index),' channels',$
           format='(a,f12.6,a,i5,a)'
    print

    xmin=0.  & xmax=float(nmax)-1 &
    ymin=min(!g.polyfitrms[0:nmax-1])  &  ymax=1.1*dsig  &

    plot,xnfit,!g.polyfitrms,/xstyle,/ystyle,title='RMS of Fit vs Order of Fit',$
         xtitle='Order of Fit',yrange=[ymin,ymax],$
         ytitle='RMS of Fit',  xrange=[xmin,xmax]

    hline,dsig

    for i=0,nmax-1 do print,i,!g.polyfitrms[i],format='(i4,1x,d12.6)'

    ; this serves to reset the GBTIDL plotter state 
    ;   - eventually this should be unnecessary    
    reshow 

    return
end
