;+
; Converts a string containing an integer list in a special syntax into
; an integer array.  The syntax is comma separated values, with : used
; for ranges.  Example: 3,5,8:12 -> [3,5,8,9,10,11,12]
;-
; <p>Optional upper and lower limits to the integer values can be
; specified.  Values less than the lower limit are set to that limit
; and values greater than the upper limit are set to that limit.
;
; <p> If the unique keyword is set, then the returning array is sorted
; and contains only unique values.
;
; @param strints {in}{required}{type=string} string containing integers
; @returns integer array
;-
FUNCTION decompress_ints, strints, unique=unique, llimit=llimit, ulimit=ulimit
    compile_opt idl2

    ; first, split up the comma separated values
    elements = strsplit(strints,",",count=cnt,/extract)
    
    for i=0,n_elements(elements)-1 do begin
        ; watch for range elements
        range_elements = strsplit(elements[i],":",count=range_cnt,/extract)
        if range_cnt eq 1 then begin
            range = long(range_elements)
        endif else begin
            s= long(range_elements[0])
            e= long(range_elements[1])
            range = lindgen(e-s+1)+s
        endelse
        if i eq 0 then ints=[range] else ints=[ints,range]
    endfor

    ; handle truncation
    if n_elements(llimit) eq 1 then begin
        limited = where(ints lt llimit, count)
        if count gt 0 then ints[limited] = llimit
    endif
    if n_elements(ulimit) eq 1 then begin
        limited = where(ints gt ulimit, count)
        if count gt 0 then ints[limited] = ulimit
    endif

    if keyword_set(unique) then ints = ints[uniq(ints, sort(ints))]

    return, ints

END

