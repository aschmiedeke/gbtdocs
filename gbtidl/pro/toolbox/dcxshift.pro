;+ 
; This function returns a value that, when given as the argument to
; shift, will shift the given data container such that it is aligned
; in the current displayed x-axis with the data in the ongoing
; accumulation buffer.  If there is no ongoing accumulation then this
; function returns 0.  The units of the returned value are channels.
; The primary data container must be shifted that many channels in
; order to align in the current x-axis with the data in the
; accumulation buffer.
;
; @param accumbuf {in}{required}{type=accum_struct} The ongoing
; accumulation buffer.
;
; @param dc {in}{required}{type=spectrum} The data container that
; needs to be shifted to align with the data container template in
; accumbuf.
;
; @returns shift, in channels, to be used as argument to
; dcshift. Returns 0.0 on failure.
;
; @examples
; Accumulate several PS scans
; <pre>
; a={accum_struct}
; getps,30
; dcaccum, a, !g.s[0]  ; start an accum, no alignment needed yet
; getps,31
; xs = dcxshift(a,!g.s[0]) ; what is the shift to align 31 with 30?
; ; get a copy of data at !g.s[0]
; data_copy,!g.s[0], d
; dcshift, d, xs  ; actually shift the data
; dcaccum, a, d ; and add it in
; getps, 32
; data_copy,!g.s[0], d
; dcshift, d, dcxshift(a, d)  ; all in one line, shift 32 to align with 30
; dcaccum, a, d
; accumave, a, d ; result is in d now
; </pre>
;
; @version $Id$
;-
function dcxshift, accumbuf, dc
    compile_opt idl2

    on_error, 2

    if n_params() ne 2 then begin
        message,'Usage: dcxshift, accumbuf, dc',/info
        return,0.0
    endif

    if (size(accumbuf,/type) ne 8 or tag_names(accumbuf,/structure_name) ne "ACCUM_STRUCT") then begin
        message,"accumbuf is not an accum_struct structure",/info
        return,0.0
    endif    

    if accumbuf.n eq 0 then return, 0.0

    if (data_valid(dc) le 0) then begin
        message, 'dc is empty or invalid', /info
        return, 0.0
    endif

    accumX = chantox([0,1],dc=accumbuf.template)
    dcX = chantox([0,1],dc=dc)

    deltaAccum = accumX[1]-accumX[0]
    deltaX = dcX[1]-dcX[0]

    if deltaAccum*deltaX lt 0.0 then begin
        message,'The data in dc needs to be inverted first, use DCINVERT',/info
        return, 0.0
    endif

    return, (dcX[0] - accumX[0])/deltaX
end
