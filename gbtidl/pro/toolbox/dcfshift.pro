;+
; Function to calculate the shift, in channels, necessary to align in 
; frequency a data container with the data container
; template in an ongoing accumulation.  
;
; <p> If the frame is not set, the one implied by the data header is 
; used.  Use <a href="dcxshift.html">dcxshift</a> to align using the
; current settings of the plotter's x-axis.
;
; @param accumbuf {in}{required}{type=accum_struct} The ongoing
; accumulation buffer.
;
; @param dc {in}{required}{type=spectrum} The data container that
; needs to be shifted to align with the data container template in
; accumbuf.
;
; @keyword frame {in}{optional}{type=string}  The reference frame to
; use.  If not supplied, the value implied by the last 4 characters of
; the velocity_definition in the ongoing accumulation will be
; used.  See <a href="frame_velocity.html">frame_velocity</a> for a
; full list of supported reference frames.
;
; @returns shift, in channels, to be used as argument to
; dcshift. Returns 0.0 on error.
;
; @examples
; <pre>
; a={accum_struct}
; getps,30
; dcaccum, a, !g.s[0]  ; start an accum, no alignment needed yet
; getps,31
; fs = dcfshift(a,!g.s[0]) ; what is the shift to align 31 with 30?
; ; get a copy of data at !g.s[0]
; data_copy,!g.s[0], d
; dcshift, d, fs  ; actually shift the data
; dcaccum, a, d ; and add it in
; getps, 32
; data_copy,!g.s[0], d
; dcshift, d, dcfshift(a, d)  ; all in one line, shift 32 to align with 30
; dcaccum, a, d
; accumave, a, d ; result is in d now
; </pre>
;
; @version $Id$
;-
function dcfshift, accumbuf, dc, frame=frame
    compile_opt idl2

    on_error, 2

    if n_params() ne 2 then begin
        message,'Usage: dcfshift, accumbuf, dc[, frame=frame]',/info
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

    if n_elements(frame) eq 0 then begin
        okvdef = decode_veldef(accumbuf.template.velocity_definition, vdef, vframe)
        if not okvdef then begin
            message,'Unrecognized velocity_definition value in ongoing accumulation',/info
            message,'frame must be specified explicitly to continue',/info
            return, 0.0
        endif
        frame = vframe
    endif

    accumF = chantofreq(accumbuf.template, [0.0,1.0], frame=frame)
    dcF = chantofreq(dc, [0.0,1.0], frame=frame)

    deltaAccum = accumF[1]-accumF[0]
    deltaF = dcF[1]-dcF[0]

    if deltaAccum*deltaF lt 0.0 then begin
        message,'The data in dc needs to be inverted first, use DCINVERT',/info
        return, 0.0
    endif

    return, (dcF[0]-accumF[0])/deltaF
end
