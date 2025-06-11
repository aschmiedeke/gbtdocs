; docformat = 'rst'

;+
; Overplots a function using oplot on to the GBTIDL plotter's surface.  
; It also remembers the function and parameters so that they can be 
; replotted as needed to the desired screen resolution (e.g. the 
; x-axis changes).  Overplots, if toggled off, are automatically
; toggled on by a call to oplotfn.  Overplots include both
; function calls (set using this function) and simple x,y overplots
; set using :idl:pro:`gbtoplot`.
;
; The syntax of the function call using the fnname parameter 
; is:  
; 
; .. code-block:: IDL
; 
;     arr = fnname(params, minchan, maxchan, chanperpix, count=count)
; 
; where params are exactly as supplied to oplotfn, ``minchan`` and
; ``maxchan`` are the current x-axis limits, in channels, and 
; ``chanperpix`` is the current number of channels per pixel (that
; is a double-precision value).  ``Count`` should be set by ``fnname`` to be
; the total number of points to be plotted.  Use that to signal
; that no points should be plotted for this call (e.g. the x channel
; range is out of the significant range of the function).  
; The returned value is a 2-D array where arr[0,*] is the set of 
; x-axis values, in channels, and arr[1,*] is the set of y-axis 
; value corresponding to those x-axis values.  Typically, the 
; x-axis values would be generated using :idl:pro:`seq` as:
; 
; .. code-block:: IDL
; 
;     x = seq(minchan, maxchan, chanPerPix)
; 
; and then y is generated from x using params and the array
; of [x,y] is then returned.  The returned value (arr) is not
; examined if count is 0.
;
; :Params:
;   fnname : in, required, type=string
;       The name of the function to be invoked to generate the values 
;       to be plotted (see above).
;
;   params : in, required, type=any
;       The parameters passed to fnname. 
;
; :Keywords:
;   color : in, optional, type=long integer, default=!g.oplotcolor
;       The color of the line to be plotted.
;
;   index : out, optional, type=integer
;       Returns the index associated with this oplot. This index can be 
;       used to clear this over plot using clearoplots.  Note that once 
;       an index is cleared, subsequent indexes are renumbered - i.e. 
;       there are never any gaps in index number.
;
;   idstring : in, optional, type=string, default="."
;       A string that can be used to identify this oplot and thereby group 
;       oplots together. This is most useful with clearoplots to remove 
;       just those oplots with the same idstring.  Withing GBTIDL, all 
;       internal id strings begin with two underscores so that they are 
;       less likely to conflict with user-defined idstrings. The default
;       is ''.
;
;   noshow : in, optional, type=boolean, default=unset
;       When this is set, the function is not immediately displayed. This
;       is useful when you have several graphical commands to issue and you 
;       don't want the plotter to have to replot everything each time. 
;       Instead, remember to do a :idl:pro:`reshow` at the end to show
;       everything that has been added. The default behavior is to show the
;       plots immediately.
;
; :Examples:
;   See the source code for :idl:pro:`gauss_plot_fn` for an example function 
;   suitable for use by oplotfn.
;
;-
pro oplotfn, fnname, params, color=color, index=index, idstring=idstring, noshow=noshow
    compile_opt idl2
    common gbtplot_common,mystate, xarray

    ; both params are required
    if n_params() ne 2 then begin
        usage,'oplotfn'
        return
    endif
    ok = gbtplot()
    if not ok then begin
        message,'No plotter!  Check your DISPLAY environment variable setting.',/info
        return
    endif

    if size(fnname,/type) ne 7 or n_elements(fnname) ne 1 then begin
        message,'fnname must be a single string',/info
        return
    endif
    if strlen(fnname) eq 0 then begin
        message,'fnname is an empty string, can not continue!',/info
        return
    endif

    catch,error_status
    if (error_status ne 0) then begin
        message,'There was a problem calling this function, can not continue',/info
        help,/last_message,output=errtext
        print,errtext[0]
        return
    endif
    arr = call_function(fnname,params,mystate.minChan,mystate.maxChan,mystate.chanPerPix,count=count);
    catch,/cancel
    plotme = count ne 0
    if plotme then begin
        if (size(arr,/n_dimensions) ne 2) then begin
            message,'Plot function did not return a 2D array, can not continue',/info
            return
        endif
        x = arr[0,*]
        y = arr[1,*]
    endif

    loccolor = !g.oplotcolor
    if keyword_set(color) then loccolor = color

    ostruct = {x:double(x), y:y, fnname:fnname, params:params, color:loccolor, next:ptr_new(), $
               prev:ptr_new(), plotme:plotme, idstring:''}

    if n_elements(idstring) then ostruct.idstring=idstring

    gbtoplot_support, ostruct, index, /chan, noshow=noshow
end
