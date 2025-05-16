; docformat = 'rst'

;+
; This saves several data containers into the output file
; (keep file).  These must be spectrum data containers.  This is most
; often used in conjuction with :idl:pro:`getchunk`.
;
; :Params:
;   chunk : in, required, type=spectrum data container arry
;       The array of spectrum data containers to save.
;
; :Examples:
;   Copy the input file to the keep file (this is currently only
;   possible in line mode), one scan at a time (in a procedure or function).
;
;   .. code-block:: IDL
; 
;       scans=get_scan_numbers(/unique)
;       for i=0,(n_elements(scan)-1) do begin
;           a = getchunk(scan=scans[i])
;           putchunk, a
;           data_free, a
;       endfor
;
;-
pro putchunk, chunk
    compile_opt idl2

    if n_params() eq 0 then begin
        usage,'putchunk'
        return
    endif

    npts = data_valid(chunk,name=name)
    if name ne 'SPECTRUM_STRUCT' then begin
        message,'Only spectral line data can be saved',/info
        return
    endif

    if npts le 0 then begin
        message,'The first element of chunk is empty or not valid',/info
        return
    endif

    !g.lineoutio->write_spectra,chunk
end
