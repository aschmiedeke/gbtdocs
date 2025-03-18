;+
; Given a string containing a comma separated list with optional range
; strings, turn that into two strings giving the start and end points
; that would be used to turn that string into integers.
;
; <p>Examples: extract_edges(["1,2,4:8"]) returns ["1,2,4","1,2,8"]
;
; @param strlist {in}{required}{type=string} Comma separated list
; @returns 2-element string array
;-
    function extract_edges, strlist
    compile_opt idl2, hidden

    ; first, split up the comma separated values
    elements = strsplit(strlist,",",count=cnt,/extract)
    
    b = ""
    e = ""
    count = 0

    for i=0,n_elements(elements)-1 do begin
        ; watch for range elements
        range_elements = strsplit(elements[i],":",count=range_cnt,/extract)
        if range_cnt eq 1 then begin
            newB = range_elements
            newE = range_elements
        endif else begin
            newB = range_elements[0]
            newE = range_elements[1]
        endelse
        ; add commas when necessary
        if count gt 0 then begin
            b = b+","
            e = e+","
        endif
        b = b + newB
        e = e + newE
        count++
    endfor
    return,[b,e]
end

