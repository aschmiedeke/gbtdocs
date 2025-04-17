; docformat = 'rst'

;+
; A GUIDE front-end to the standard IDL CONVOL function.
;
; This allows GUIDE users to convolve a data container with an
; arbitrary kernel using the IDL CONVOL function.  All of the
; arguments except the dc keyword have the same meaning and use as
; in the CONVOL function.  Users should consult the IDL documentation
; for CONVOL for a more detailed explanation than is given here.  All
; of the CONVOL keywords are passed in through the _EXTRA keyword are
; so are not shown explicitly here.  These keywords are ``/CENTER``,
; ``/EDGE_WRAP``, ``/EDGE_TRUNCATE``, ``MISSING``, ``/NAN``, and 
; ``/NORMALIZE``
;
; This procedure follows the GUIDE model and the result of the
; convolution replaces the original data values in the indicated data
; container.  
;
; ``NORMALIZE`` was added in IDL 6.2. It is essential when working
; with blanked data (``NAN``).  It is implemented here so that it works
; for earlier version of IDL.  For IDL 6.2 and later, ``/NORMALIZE`` is passed 
; directly to CONVOL.  For earlier versions of IDL, a second 
; convolution is done using a vector of 1.0s having the same length as
; the data and blanked in the same locations as the data.  The
; convolution of the data is then divided by this convolution and the
; result is put back into the data container.  ``BIAS`` was also added in
; IDL 6.2 but that functionality isn't necessary for the rest of
; GBTIDL and so it has not been implemented here apart from what
; CONVOL provides in IDL 6.2 
;
; :Params:
;   kernel : in, required, type=array
;       The kernel to use in the convolution. Must have fewer elements than 
;       the data container being convolved.
;   scale_factor : in, optional, type=real, default=1
;       The scale factor.
; 
; :Keywords:
;   buffer : in, optional, type=integer, default=0
;       The data container buffer to use in the convolution.
;   ok : out, optional, type=boolean
;       Returns 1 if everything went ok, 0 if it did not (empty or invalid 
;       buffer, bad kernel).
;   normalize : in, optional, type=boolean
;       Set this keyword to automatically compute a scale factor and bias
;       and apply it to the result values. If this keyword is set, the 
;       scale_factor argument and the BIAS keyword are ignored. For all 
;       input types, the scale factor is defined as the sum of the absolute
;       values of Kernel. If blanked (NAN) values are present, the scale 
;       factor and bias are calculated without using those values so that 
;       all result values are comparable in magnitude.
;   _extra : in, optional, type=extra keywords
;       Keyword arguments to **CONVOL**.  See the IDL documentation on **CONVOL**
;       for more information.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       ; hanning smoothing kernel
;       kernel = [0.25,0.5,0.25]
;       ; convolve with the data in the primary data container
;       gconvol, kernel
;       ; same kernel, using DC 1, ignore NAN (missing) values, 
;       ; truncate the data at the edges, normalize the result.
;       ; This is how the hanning procedure is implemented.
;       gconvol, kernel, buffer=1, /nan, /edge_truncate, /normalize
; 
; :Uses:
;   :idl:pro:`getdata`
;   :idl:pro:`setdata`
;
;-
pro gconvol, kernel, scale_factor, buffer=buffer, ok=ok, normalize=normalize, $
             _extra=extra_keywords
    compile_opt idl2

    ok = 0
    if n_elements(kernel) eq 0 then begin
        usage,'gconvol'
        return
    endif
    if n_elements(scale_factor) eq 0 then scale_factor = 1.0

    if n_elements(buffer) eq 0 then buffer = 0
    
    theData = getdata(buffer)
    if n_elements(theData) eq 1 then begin
        if theData eq -1 then return
    endif

    if n_elements(kernel) le 0 or n_elements(kernel) ge n_elements(theData) then begin
        message,'kernel must have at least 1 element and < the number of elements in the data',/info
        return
    endif

    idlver=fix(strsplit(!version.release,'.',/extract))
    if idlver[0] gt 6 or (idlver[0] eq 6 and idlver[1] ge 2) then begin
        theData = convol(theData,kernel,scale_factor,normalize=normalize,_extra=extra_keywords)
    endif else begin
        if keyword_set(normalize) then begin
            bindx = where(finite(theData) eq 0)
            ; ignore scale_factor
            theData = convol(theData,kernel,_extra=extra_keywords)
            oneVector = make_array(n_elements(theData),/float,value=1.0)
            if bindx[0] ne -1 then oneVector[bindx] = !values.f_nan
            oneVector = convol(oneVector,kernel,_extra=extra_keywords)
            theData = theData / oneVector
        endif else begin
            theData = convol(theData,kernel,scale_factor,_extra=extra_keywords)
        endelse
    endelse

    setdata,theData,buffer=buffer
    ok = 1
end
