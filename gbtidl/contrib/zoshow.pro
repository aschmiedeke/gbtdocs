;+
; Plot a zpectrometer data container on top of (over) the current plot.
; The x-axis will be automatically constructed to match that of the
; current plot.  If the plot is not zoomed, the x and y range will be
; adjusted to accomodate this data along with all previously plotted
; data. If overlays are turned off, calling this automatically turns
; it on.
;
; <p>The type of zpectrometer plot (data or lags) will match that
; already displayed in the plotter.
;
; @param zdc {in}{required}{type=data container}
; The zpectrometer data container to over plot.  
;
; @keyword color {in}{optional}{type=color}{default=!g.oshowcolor} A color to use when
; drawing the line.
;
; @examples
; <pre>
;    ; a simple use of zshow:
;    zio=obj_new('io_sdfits_z')
;    zio->set_file, 'JZTEST.raw.zpec.fits'
;    a = zio->get_rows(index=5)
;    zshow, a, color=!blue
;    b = zio->get_rows(index=6)
;    zoshow, b, color=!red
; </pre>
;
; @version $Id$
;-
pro zoshow, zdc, color=color
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    if mystate.line eq 1 then begin
        zdc_to_dc, zdc, dc, /data, status=status
    endif else begin
        zdc_to_dc, zdc, dc, status=status
    endelse
    if status eq 0 then begin
        message,'There was a problem converting zdc to a standard data container',/info
        if n_elements(dc) gt 0 then data_free, dc
        return
    endif

    oshow, dc, color=color

    data_free, dc
end
