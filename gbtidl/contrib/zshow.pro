;+
; This procedure displays a zpectrometer data container in the plotter.  
; This is done by first copying the data container to a continuum data
; container and then sending that to the plotter for display. If the
; DATA array is requested instead of the LAGS array using the DATA
; flag then the data are first copied to a spectrum data container and
; that is displayed.
;
; @param zdc {in}{required}{type=zpectrometer data container}
; a zpectrometer data container.
;
; @keyword data {in}{optional}{type=boolean} When set, the DATA array
; is used as the set of values to be plotted.  By default, the LAGS
; array is used.
;
; @keyword color {in}{optional}{type=long integer}{default=!g.showcolor} The
; color for the data to be plotted.
;
; @keyword smallheader {in}{optional}{type=boolean} When set, only a
; small, one line header consisting of RA, DEC, source name, and date
; is placed at the top of the plot.  The footer line is displayed when
; smallheader is set.  By default, the full, multi-line
; header and the single line footer are displayed.
;
; @keyword noheader {in}{optional}{type=boolean} When set, no header
; information is displayed at the top of the plot or below the x-axis
; label of the plot (footer).  This takes precedence over smallheader.
; By default, the full, multi-line header and the single line footer
; are displayed.
;
; @examples
; <pre>
;    ; a simple use of zshow:
;    zio=obj_new('io_sdfits_z')
;    zio->set_file, 'JZTEST.raw.zpec.fits'
;    a = zio->get_rows(index=5)
;    zshow, a, color=!blue
; </pre>
;
; @version $Id$
;-
pro zshow, zdc, data=data, color=color, smallheader=smallheader, noheader=noheader
    compile_opt idl2

    if n_elements(zdc) eq 0 then begin
        usage,'zshow'
        return
    endif

    if keyword_set(data) then begin
        zdc_to_dc, zdc, dc, /data, status=status
    endif else begin
        zdc_to_dc, zdc, dc, status=status
    endelse

   if status eq 0 then begin
        message,'There was a problem converting zdc to a standard data container',/info
        if n_elements(dc) gt 0 then data_free, dc
        return
    endif

    show, dc, color=color, smallheader=smallheader, noheader=noheader

    data_free, dc
end
