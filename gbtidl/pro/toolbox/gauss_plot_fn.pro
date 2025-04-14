; docformat = 'rst' 

;+
; Generate x, y pairs to be plotted (x in channels) given a
; structure describing the number of gaussians and the current
; limits and resolution of the plotter.
;
; This is used by :idl:pro:`gshow` to call :idl:pro:`oplotfn` so
; that the function is used to regenerate the gaussian values to
; be plotted as the plotter changes (e.g. zooming) which might 
; otherwise lead to poorly sampled gaussians on unzoomed plots 
; being unnecessarily jagged when zoomed in.
;
; Most users will never use this directly although it could
; be used as a template when generating functions to use with 
; oplotfn.
;
; :Params:
;   params : in, required, type=structure
;       The fields in this structure are the names of the last 
;       3 parameters is :idl:pro:`make_gauss_data`.  See the 
;       documention there for more information (fields are 
;       **a**, **noise** and **offset**).
;
;   minchan : in, required, type=double
;       The minimum channel number of the current plot window's
;       x-axis.
;
;   maxchan : in, required, type=double
;       The maximum channel number of the current plot window's
;       x-axis.
;
;   chanperpix : in, required, type=double
;       The channels per pixel of the current plot window's x-axis.
;       This value is always positive.
;
; :Keywords:
;   count : out, required, type=integer
;       The total number of points in arr to plot.  Should be equal
;       to 0 (do not plot any points) or the number of elements along
;       the second axis of arr.
;
; :Returns:
;   arr - 2D array, arr[0,*] is the x values and arr[1,*] the y.
;
;-
function gauss_plot_fn, params, minchan, maxchan, chanperpix, count=count
    compile_opt idl2

    count = 0

    if (n_params() ne 4) then begin
        usage,'gauss_plot_fn'
        return,0
    endif

    if size(params,/type) ne 8 then begin
        message,'params is not a structure',/info
        return,0
    endif

    ; degenerate case
    if (minchan eq maxchan) then return, 0

    x = seq(minchan, maxchan, chanperpix)
    y = make_gauss_data(x,params.a,params.noise,params.offset);
    ay = abs(y)
    mc = machar()
    indxok = where(ay gt max(ay)*mc.eps,count)

    if count eq 0 then return,0

    arr = dblarr(2,n_elements(indxok))
    arr[0,*] = x[indxok]
    arr[1,*] = y[indxok]
    return,arr
end
