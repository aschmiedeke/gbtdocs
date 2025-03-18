; docformat = 'rst'

;+
; Smooth the data with a GAUSSIAN such that the spectrum in the given
; buffer with an original resolution of frequency_resolution now has a 
; resolution of NEWRES, where NEWRES is expressed in channels.  
; 
; Optionally also decimate the spectrum by keeping only every 
; NEWRES channels.
;
; The frequency_resolution field is set to newres *
; abs(frequency_interval) after this procedure is used.
;
; The width of the smoothing Gaussian is sqrt(newres^2-oldres^2).
;
; :Params:
;
;   newres : in, required, type=real
;       The desired new resolution in units of channels.  This must be
;       >= the frequency_resolution also expressed in channels.  If it 
;       is equal to the frequency_resolution then this procedure does 
;       not change the data.
; 
; :Keywords:
; 
;   buffer : in, optional, type=integer, default=0
;       The data container to smooth to the new resolution.  This
;       defaults to the primary data container (0).
; 
;   decimate : in, optional, type=boolean
;       When set, only every NEWRES channels are kept, starting from 
;       the original 0 channel.  If NEWRES is not an integer, this may
;       not be a wise thing to do (the decimation rounds to the nearest
;       integer).
; 
; :Examples:
;
;   .. code-block:: IDL
;   
;       ; smooth to 2 channels wide
;       gsmooth, 2
;       ; copy that to buffer 1 and smooth it to 4 channels wide
;       copy,0,1
;       gsmooth, 4, buffer=1
;       show, 1
;       ; same operation on buffer 0, but decimate
;       gsmooth, 4, /decimate
;
; :Uses:
;   
;   :idl:pro:`dcsmooth`
;
;-
pro gsmooth, newres, buffer=buffer, decimate=decimate
    compile_opt idl2

    if n_elements(newres) eq 0 then begin
        usage,'gsmooth'
        return
    endif

    if n_elements(buffer) eq 0 then buffer = 0

    if buffer lt 0 or buffer gt n_elements(!g.s) then begin
        message,string((n_elements(!g.s)-1),format='("buffer must be >= 0 and <= ",i2)'),/info
        return
    endif

    thisdc = !g.s[buffer] ; this only copies the pointers, not values
    dcsmooth, thisdc, newres, decimate=decimate, ok=ok
    if not ok then return

    !g.s[buffer] = thisdc ; copy it back
        
    if not !g.frozen then show
end

