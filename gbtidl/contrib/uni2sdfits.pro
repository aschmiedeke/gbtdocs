;+
; A procedure to convert a unipops SDD format file to an SDFITS table
; that can be consumed by GBTIDL.
;
; <p> This uses an sdd object to do the conversion, one scan at a
; time.  The converted scan is then copied into the PDC and 
; <a href="../../user/guide/keep.html">keep</a> is used
; to save that scan to the output file.
;
; <p> This also converts recent data from the 12m which uses the
; unipops SDD format except that the byte ordering is reversed.
;
; <p> This could use more error checking and reporting.
;
; <p><B>Contributed By: Bob Garwood, NRAO-CV<g/B>
;
; @param unifile {in}{required}{type=string} The name of the unipops
; SDD file to be converted.
;
; @param sdfitsfile {in}{required}{type=string} The name of the output
; SDFITS file to hold the converted values.  Note that this simply
; appends to the end of sdfitsfile if sdfitsfile already exists.
;
; @examples
; <pre>
; .com sdd__define ; only need to do this the first time
; .com uni2sdfits
; uni2sdfits,'sdd_hc.wbl_001','sdd_hc.wbl_001.fits'
; </pre>
;
; @uses <a href="../../user/toolbox/data_free.html">data_free</a>
; @uses <a href="../../user/guide/fileout.html">fileout</a>
; @uses <a href="../../user/guide/freeze.html">freeze</a>
; @uses <a href="../../user/guide/keep.html">keep</a>
; @uses <a href="sdd__define.html">sdd object</a>
; @uses <a href="../../user/guide/set_data_container.html">set_data_container</a>
; @uses <a href="../../user/guide/unfreeze.html">unfreeze</a>
;
; @version $Id$
;-
pro uni2sdfits, unifile, sdfitsfile
    compile_opt idl2

    ; remember current output file for restoration later
    curFileOut = !g.line_fileout_name
    fileout,sdfitsfile
    uniIn = obj_new('sdd',unifile)

    if uniIn->nscans() le 0 then begin
        message,sdfitsfile + ' appears to have no scans in it, can not continue',/info
        obj_destroy, uniIn
         fileout, curFileOut
        return
    endif

    print,'Begin converting ', uniIn->nscans(), ' scans from ', unifile, ' to ', sdfitsfile

    fstate = !g.frozen
    freeze
    for i=0,(uniIn->nscans()-1) do begin
        if uniIn->indexUsed(i) then begin
            dc = uniIn->getdc(i)
            if data_valid(dc) gt 0 then begin
                set_data_container, dc
                keep
                print,string(i,dc.scan_number,dc.procseqn,format='(i5," : scan ", i5, ".", i2.2," converted")')
                data_free, dc
            endif else begin
                print,' ... skipping'
            endelse                
        endif else begin
            print,'Index ', i,' is empty.'
        endelse
    endfor

    obj_destroy,uniIn
    if not fstate then unfreeze

    fileout, curFileOut

    print,'finished'
end
