; docformat = 'rst'

;+
; Add a data container into an ongoing accumulation in a given
; accum_struct structure.
;
; If this is the first item to be "accum"ed, it will also be used as a template,
; stored in accumbuf.template, to be used by :idl:pro:`accumave`.
;
; If the polarization of any items being accumed does not match
; that of template, the polarization of the template is changed to 'I'.
;
; This combines the UniPOPS functionality of ACCUM and SUM.  The SUM
; name is already in use in IDL.
;
; This is primarily for use inside procedures and functions where
; it is useful to average several data containers without disturbing
; the public data containers in the guide structure.  Most users will
; find using :idl:pro:`accum` preferable to using dcaccum.
;
;   * The data are  : sum(weight*data)
;   * The times are : sum(duration), sum(exposure)
;   * The weight is : sum(weight) one weight sum per channel.
;   * The tsys is   : sqrt(sum(max(weight)*Tsys^2))
;   * The frequency resolution is the maximum of all f_res values used
;     during the accumulation.
;
; A warning message is shown if either the frequency_resolution or
; the frequency_interval do not match that in an already on-going
; accumulation.  If the quiet flag is on, then this message is
; suppressed.  In either case, the accumulation proceeds.
;
; If a weight is not supplied, it will be exposure*frequency_resolution/tsys^2
;
; <p>weight can either be a scalar or it can be a vector having the same
; number of elements as the data in dc.
;
; If all of data is blanked (not a number) then it is completely
; ignored and the accumulated weight, times, and system temperatures
; are unchanged.  If individual regions are blanked then the weight at
; those channels is 0.  When an average is requested (accumave) this
; weight array is used to rescale the data.  That weight array is also
; available when the average is requested.  If that weight array is
; used as input in a future average, the averaging can continue from
; the same point as before.
;
; If all of the weight values (supplied or the default value as
; described above) are not finite (not a number) this routine behaves
; as if the data are blanked and the data are ignored and the
; accumulated values are unchanged.
;
; If the Tsys value is not finite (not a number) but the
; weights and data are at least partially finite, then the Tsys value
; is ignored in the ongoing weighted Tsys^2 accumulation.  The
; weights used in the Tsys^2 accumulation are kept separate from the
; data weights.
;
; :Params:
;   accumbuf : in, out, required, type=accum_struct
;       The structure containing the accumulation that you want to add to.
;
;   dc : in, required, type=spectrum
;       The data container to accum.
;
; :Keywords:
;   quiet : in, optional, type=boolean
;       If set, suppress warning messages about frequency resolution and 
;       interval not matching values in accumbuf.
;
;   weight : in, optional, type=float
;       The weight to use for this data.  If this is not set, a weight of
;       exposure*frequency_resolution/tsys^2 will be used.  Weight can 
;       either be a scalar (uniform weight across at all channels) or it 
;       can be an array having the same number of elements as the data in dc.
;
; :Examples:
; 
; average some data
; 
;   .. code-block:: IDL
; 
;       a = {accum_struct}
;       accumclear,a  ; not necessary here, but a good habit to follow
;       ; get several records at once
;       s = !g.lineoutio->get_spectra(index=0)
;       dcaccum,a,s
;       data_free,s ; be sure to clean up, else leaks memory
;       s = !g.lineoutio->get_spectra(index=1)
;       dv = dcvshift, a, s ; align in velocity
;       dcshift, a, dv ; actually do the shift to align
;       dcaccum,a,s
;       data_free, s
;       accumave,a,s
;       show, s
;       data_free, s  
;
; See :idl:pro:`ave` for additional examples.
;
; :Uses:
;   :idl:pro:`accumulate`
;   :idl:pro:`data_valid`
;   :idl:pro:`data_free`
;
;-
pro dcaccum, accumbuf, dc, weight=weight, quiet=quiet
    compile_opt idl2

    on_error, 2

    if n_params() ne 2 then begin
        usage,'dcaccum'
        return
    endif

    if (size(accumbuf,/type) ne 8 or tag_names(accumbuf,/structure_name) ne "ACCUM_STRUCT") then begin
        message,"accumbuf is not an accum_struct structure",/info
        return
    endif

    dataOk = data_valid(dc,name=name)
    if dataOk le 0 then begin
        message,'dc is empty or invalid, can not continue.',/info
        return
    endif
    if name ne 'SPECTRUM_STRUCT' then begin
        message,'data container is not a SPECTRUM_STRUCT, only spectral line data can be accumed, sorry.',/info
        return
    endif

    if (accumbuf.n eq 0) then begin
        data_free, accumbuf.template
        accumbuf.template = dc
        ; now copy the pointer values, making new pointers here
        accumbuf.template.data_ptr = ptr_new(*dc.data_ptr)
    endif else begin
        if dc.polarization ne accumbuf.template.polarization then accumbuf.template.polarization = 'I'
    endelse

    ; watch for duration of 0.0, early data has that
    tdur = dc.duration
    if dc.duration le 0.0 then tdur = dc.exposure

    accumulate, accumbuf, *dc.data_ptr, dc.exposure, dc.tsys, dc.frequency_resolution,$
                tdur, dc.frequency_interval, wt=weight, quiet=quiet
end
