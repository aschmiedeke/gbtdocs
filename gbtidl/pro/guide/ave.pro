; docformat = 'rst'

;+
; Get the average from an ongoing accumulation.
;
; The result is put into the primary data container (buffer 0).  
; The contents of the accum buffer are cleared as a consequence of
; calling ave, unless the noclear keyword is set. 
;
; *Note*: It is a good idea to use :idl:pro:`sclear` to clear the accum buffer 
; before using it the first time so that you can be certain it is
; starting from a cleared (empty) state. 
;
; :Params:
; 
;   accumnum : in, type=integer, default=0
;       Use this accum buffer. Defaults to the primary buffer, 0. There are
;       4 buffers total so this value must be between 0 and 3, inclusive.
;
; :Keywords:
;
;   noclear : in, optional, type=boolean, default=F
;       When set, the contents of the accum buffer are not cleared.  This is
;       useful when you want to see what the current average is but also plan
;       on continuing to add data to that average.  If this is not set, you
;       would need to restart the accumulation to average more data.
;
;   quiet : in, optional, type=boolean, default=F
;       Normally, ave announces how many spectra were averaged.  Setting this
;       turns that announcement off.  This is especially useful when multiple
;       accum buffers are used within a procedure.
;
;   wtarray : out, optional, type=float array
;       This is the contents of the weight array at the time of the average
;       - one value per channel. If no blanked data went into accumulation, 
;       then all values in wtarray will be the same.  If an entire spectrum
;       was blanked (e.g. bad data from the GBT Spectrometer) then that 
;       spectrum was ignored during the accumulation and again, all of the 
;       wtarray values will be the same.  This quantity is only important if 
;       some channels were blanked in at least one spectrum in the accumulation
;       and you expect to use the result of this accumulation at a later
;       time in part of another accumulation.  If you keep the wtarray
;       around in an IDL variable, then you can use it again to weight this
;       result in that new accumulation.
;
;   count : out, optional, type=integer
;       The number of spectra that have been averaged.  Returns -1 on an error.
;       If count=0 then the the PDC and wtarray are unchanged by this procedure.
;
; :Examples:
; 
;   Average some data
;   
;   .. code-block:: IDL
;
;       sclear
;       get,index=1
;       accum
;       get,index=2
;       accum
;       ave 
; 
;
;   Average some data using another accum buffer
; 
;   .. code-block:: IDL
; 
;       sclear, 2 
;       get,index=1
;       accum, 2
;       get,index=2
;       accum, 2
;       ave, 2
; 
;
;   Average some data, look at an intermediate result
;
;   .. code-block:: IDL
;
;       sclear
;       get,index=1
;       accum
;       get,index=2
;       accum
;       ave,/noclear  ; accum buffer is NOT clear here
;       get,index=3
;       accum
;       ave     ; accum buffer IS clear here
; 
; :Uses:
; 
;   :idl:pro:`accumave`
;   :idl:pro:`accumclear`
;   :idl:pro:`set_data_container`
;   :idl:pro:`data_free`
;
;-
pro ave, accumnum, noclear=noclear, quiet=quiet, wtarray=wtarray, count=count
    compile_opt idl2

    on_error, 2

    count = 0

    if not !g.line then begin
        message,'Ave only works in line mode, sorry.',/info
        return
    endif

    if n_elements(accumnum) eq 0 then accumnum = 0

    if (accumnum lt 0 or accumnum gt 3) then begin
        message,'accumnum must be in the range 0 to 3',/info
        return
    endif

    if !g.accumbuf[accumnum].n gt 0 then begin
        accumbuf = !g.accumbuf[accumnum]
        accumave, accumbuf, thisavg, quiet=quiet, noclear=noclear, wtarray=wtarray, count=count
        if count gt 0 then begin
            set_data_container, thisavg
            data_free, thisavg
            !g.accumbuf[accumnum] = accumbuf
        endif
    endif else begin
        message, 'Nothing in the accum buffer, no change in data 0',/info
    endelse
end
