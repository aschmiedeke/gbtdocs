;+
; Read in the list of all previously detected molecular lines, storing
; them into an array of structures at !g.molecules.  The total number
; of molecules stored there is indicated by !g.nmol.  If !!g.nmol is > 0
; then this procedure returns immediately without modifying
; !g.molecules.  
;
; <p>The molecule_struct has the following fields:
;   <ul><li> <b>freq</b> Rest Frequency (MHz)
;   <li> <b>freqErr</b> Rest Frequency Error (MHz)
;   <li> <b>formula</b> Species Formula
;   <li> <b>name</b> Species Chemical Name
;   <li> <b>qnums</b> Quantum Numbers
;   <li> <b>obsAstInt</b> NIST Observed Astronomical Intensity (where applicable)
;   <li> <b>upperStateE</b> Upper State Energy (K)
;   <li> <b>obsIntRef</b> NIST Observed Intensity Reference (where applicable)
;   <li> <b>lineFreqRef</b> NIST Measured Line Frequency Reference (where applicable)
;   </ul>
;
; <p>Unavailable values are represented in this structure by not-a-number
; (NaN).
; 
; <p><b>Note:</b> IDL variables are case-insensitive.  The case used in
; the structure field names above is done to improve readability.  The
; IDL interpreter ignores case.
;
; <p>See <a href="molecule.html">molecule</a> for
; the code that is intended to use this information and for notes on
; the source of the line information.
;
; @version $Id$
;-
pro moleculeread
    compile_opt idl2

    ; on_error,2

    if !g.nmol gt 0 then return

    fname=file_search('$GBT_IDL_DIR/pro/guide/GBTIDL_RRF_w_Kup.csv',count=count,/expand_environment)
    if count lt 1 then begin
        message,'Line information file could not be found, no line IDs available',/info
        return
    endif

    maxl = n_elements(!g.molecules)

    ;now define for molecules function
    record = {molecule_struct}

    ;- Open input file
    openr, lun, fname, /get_lun

    ;- Read records until end-of-file reached
    recnum = 0L
    while (eof(lun) ne 1 && !g.nmol lt maxl) do begin
        on_ioerror, bad_rec
        error = 1
        ; read one line
        line = ''
        readf, lun, line
        error = 0
        if strmid(line,0,1) ne ';' then begin
            ; only do this for non-comment lines
            parts = strsplit(line,':',/extract)
            ; replace NULL with NaN so they can be converted to doubles
            indx = where(strmatch(parts,'NULL'),count)
            if count gt 0 then begin
               parts[indx] = 'NaN'
            endif
            record.freq = parts[0]
            record.freqErr = parts[1]
            record.formula = parts[2]
            record.name = parts[3]
            record.qnums = parts[4]
            record.obsAstInt = parts[5]
            record.upperStateE = parts[6]
            record.obsIntRef = parts[7]
            record.lineFreqRef = parts[8]
            !g.molecules[!g.nmol] = record
            !g.nmol += 1
        endif
        ;- Silently ignore bad input record - these are always comment lines
        bad_rec:
        recnum = recnum + 1
    endwhile

    if (eof(lun) ne 1) then begin
       message,'moleculread: structure full before end of file seen. Please report this error'
    endif

    close,lun 
    free_lun, lun

    return
end ; end of moleculeread
