; docformat = 'rst' 

;+
; Do an FFT (forward or inverse) of a data container.  For a
; real-to-complex FFT, only one data container is given in the
; arguments.  For a complex-to-complex FFT, the real part comes from
; the first data container and the imaginary part comes from the
; second data container.  The returned value is always a complex array
; containing the results of the FFT.  The input data containers are
; not changed by this function.  It is up to the caller to determine
; what to do with this result (e.g. further calculations, store the
; real part in one data container and the imaginary part in another, etc).
;
; This uses the builtin IDL FFT function.
; 
; For spectral-line data, when inverse is not set (the default)
; the builtin IDL inverse flag **is** used.  This means that when
; dcfft is called with its default arguments and the input data
; container is a spectrum, the IDL FFT will convert properly from the
; frequency domain to the time domain (which is actually an inverse
; FFT).  When inverse is set, the builtin IDL inverse flag is
; **not** set.  This may be confusing to IDL users, but it will
; be familiar to former UniPOPS users.  
; 
; For continuum data, the inverse flag here is exactly the same as
; the inverse flag in the builtin IDL function.
;
; :Params:
;   real : in, required, type=data container
;       The real part of the data to be FFTed.
;   imag : in, optional, type=data container
;       The imaginary part of the data to be FFTed.  When not supplied,
;       it is assumed that the data are pure real (imaginary part is all 
;       zero).
; 
; :Keywords:
;   inverse : in, optional, type=boolean
;       When set, the inverse of the regular FFT is done.  For 
;       spectral-line data, an inverse FFT is done when this is **not**
;       set and a direct FFT is done when this is set so that the 
;       non-inverse transformation as seen by the dcfft user is frequency 
;       to time and the inverse transformation is time to frequency.
;   bdrop : in, optional, type=integer, default=0
;       The number of channels to exclude from the FFT at the beginning.
;   edrop : in, optional, type=integer, default=0
;       The number of channels to exclude from the FFT at the end.
;
; :Returns:
;   A complex array containing the result of the FFT. Returns
;   -1 if no data was found in the real argument.
;
;-
function dcfft, real, imag, inverse=inverse, bdrop=bdrop, edrop=edrop
    compile_opt idl2

    if n_elements(real) eq 0 then begin
        message,'Usage: dcfft(real[, imag, /inverse])',/info
        return,-1
    endif

    nreal = data_valid(real, name=realname)
    if nreal le 0 then begin
        message,'No valid data found in real',/info
        return,-1
    endif

    if n_elements(bdrop) eq 0 then bdrop=0
    if n_elements(edrop) eq 0 then edrop=0
    if (bdrop+edrop ge nreal) then begin
        message,'bdrop and edrop exclude all channels',/info
        return,-1
    endif

    if n_elements(imag) eq 0 then begin
        data = complex(*real.data_ptr)
    endif else begin
        nimag = data_valid(imag, name=imagname)
        if nimag le 0 then begin
            message,'The imag argument does not contain any valid data, assuming pure-real',/info
            data = complex(*real.data_ptr)
        endif else begin
            if nimag ne nreal then begin
                message,'Size of data in real and imag are not the same, assuming pure-real',/info
                data = complex(*real.data_ptr)
            endif else begin
                if realname ne imagname then begin
                    message,'The data containers are not the same type, proceeding as if both were ' + realname,/info
                endif
                data = complex(*real.data_ptr, *imag.data_ptr)
            endelse
        endelse
    endelse
    doinverse=0
    if realname eq 'SPECTRUM_STRUCT' and not keyword_set(inverse) then doinverse=1
    if realname eq 'CONTINUUM_STRUCT' and keyword_set(inverse) then doinverse=1

    if (bdrop ne 0 or edrop ne 0) then begin
        data = data[bdrop:(nreal-edrop-1)]
    endif

    data = fft(data,inverse=inverse,/overwrite)
    return,data
end
