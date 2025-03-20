; docformat = 'rst'

;+
; Resample a spectrum data container onto a new frequency axis using
; one of four possible interpolation methods.
;
; Takes the data values in the data container indicated by 
; the parameter 'buffer' and interpolates them onto a new frequency axis 
; derived from the newinterval and keychan arguments.  The 
; reference_frequency is unchanged by this operation.  
; The new frequency_interval is given by the **newinterval** 
; argument.  The new frequency axis is determined by choosing 
; one channel in the original frequency axis and requiring
; that the frequency at that channel be centered on one of the
; channels in the interpolated data (the <b>keychan</b>
; argument).  This sets the new reference frequency. When not
; supplied, **keychan** defaults to the channel nearest to the
; original reference channel.
;
; The data container indicated by the 'buffer' parameter is altered
; by this procedure.  The data values will contain the interpolated
; values and the header will describe the new frequency axis.  The
; number of channels in the resulting interpolated data is just enough
; to use as much of the original data as possible without trying to
; interpolate beyond the ends of that data.
;
; Interpolation is accomplished by using the IDL INTERPOL procedure
; except when 'nearest' is set, in which case it is done by this
; procedure.  Blanked values (NaN) are ignored.  See the documentation
; for INTERPOL for details about the various interpolation methods.
;
; This procedure only works in line mode.
;
; :Params:
;   newinterval : in, required, type=real
;       The new frequency_interval to use in the interpolation. This
;       value must be nonzero. If it has opposite sign from the input
;       frequency interval, :idl:pro:`invert` will be used to first
;       reverse the sense of the frequency axis.
;   keychan : in, optional, type=integer
;       The new frequency axis will have one channel where the frequency
;       value equals the original frequency value at the keychan channel.
;       When keychan is not supplied, it defaults to the channel nearest
;       to the reference_channel.
; 
; :Keywords:
;   buffer : in, optional, type=integer, default=0
;       The data container buffer to use.  Defaults to 0, the primary 
;       data container.
;   nearest : in, optional, type=boolean
;       When set do nearest-neighbor interpolation.
;   linear : in, optional, type=boolean
;       When set (the default), do a linear interpolation.
;   lsquadratic : in, optional, type=boolean
;       When set do a least squares quadratic fit interpolation.
;   quadratic : in, optional, type=boolean
;       When set do a quadratic fit interpolation.
;   spline : in, optional, type=boolean
;       When set do spline interpolation.
;
; :Examples:
; 
;   .. code-block:: 
;
;       ; data container 0 has a spectrum in it
;       ; copy it elsewhere
;       copy,0,10
;       ; do a linear interpolation to 1.5 x the channel spacing
;       resample,!g.s[0].frequency_interval*1.5
;       ; the next line is exactly equivalent to "dcinvert"
;       resample,-!g.s[0].frequency_interval
;       ; Use buffer 10, use channel 0 as the keychan and
;       ; do a spline interpolation, make sure things are ok
;       resample,!g.s[10].frequency_interval*1.5,0,buffer=10,/spline
;
; :Uses:
;   :idl:pro:`dcresample`
;   :idl:pro:`show`
;
;-
pro resample, newinterval, keychan, buffer=buffer, $
              nearest=nearest, linear=linear, lsquadratic=lsquadratic, $
              quadratic=quadratic, spline=spline
    compile_opt idl2

    if n_params() lt 1 then begin
        usage,'resample'
        return
    endif

    if not !g.line then begin
        message,'resample only works on spectral line data',/info
        return
    endif

    if n_elements(buffer) eq 0 then buffer = 0

    if buffer lt 0 or buffer gt n_elements(!g.s) then begin
        message,string(n_elements(!g.s),format='("buffer must be >= 0 and < ",i2)'),/info
        return
    endif

    thisdc = !g.s[buffer] ; get a copy
    dcresample,thisdc,newinterval,keychan,nearest=nearest,linear=linear,$
               lsquadratic=lsquadratic,quadratic=quadratic,spline=spline,ok=ok
    if ok then begin
        !g.s[buffer] = thisdc
        if buffer eq 0 and not !g.frozen then show
    endif
end
