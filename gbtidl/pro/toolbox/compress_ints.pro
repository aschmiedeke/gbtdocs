;+
; Take an integer array, sort it, and convert it to a comma separated
; string where consecutive values of integers are 'compressed' into a
; range, using the syntax 'begining:end'. 
;
; <p>The returned string is collection of individual integers and
; ranges separated by commas.
; 
; <p>Two consecutive values are left as individual integers, only
; sequences longer than 3 integers are compressed to a range (there's
; no savings in space for 2 consecutive integers. 
;
; <p>Optional upper and lower limits to the integer values can be
; specified.  Values less than the lower limit are set to that limit
; and values greater than the upper limit are set to that limit.
;
; <p>Duplicate values are removed before the array is compressed to
; the string.
;
; @param ints {in}{required}{type=long} Integer array to convert
; @keyword llimit {in}{optional}{type=long} Optional lower limit to
; use.
; @keyword ulimit {in}{optional}{type=long} Optional upper limit to
; use.
; @returns a string represent all of the unique values in the array
; passed in, optionally truncated to fall withing llimit to ulimit,
; inclusive.
;-
function compress_ints, ints, llimit=llimit, ulimit=ulimit
    compile_opt idl2
    
    ; local copy
    lints = ints
    ; first, limit the values
    if n_elements(llimit) eq 1 then begin
        limited = where(lints lt llimit,count)
        if count gt 0 then lints[limited] = llimit
    endif
    if n_elements(ulimit) eq 1 then begin
        limited = where(lints gt ulimit,count)
        if count gt 0 then lints[limited] = ulimit
    endif

    ; get rid of duplicates and sort it
    lints = lints[uniq(lints,sort(lints))]

    nInts = n_elements(lints)

    if nInts eq 1 then return, strtrim(string(lints),2)
    if nInts eq 2 then return, strtrim(string(lints[0]),2)+","+strtrim(string(lints[1]),2)

    diffInts = lints[1:(nInts-1)] - lints[0:(nInts-2)]

    jumps = where(diffInts gt 1,count)
    str = ""
    if count eq 0 then begin
        ; single jump
        str = strtrim(string(lints[0]),2)+":"+strtrim(string(lints[nInts-1]),2)
    endif else begin
        lastEnd = -1
        for i = 0,count do begin
            first = lastEnd + 1
            if i lt count then begin
                last = jumps[i]
            endif else begin
                last = n_elements(lints)-1
            endelse
            if (last - first) lt 2 then begin
                for j = first, last do begin
                    str = str + strtrim(string(lints[j]),2) + ","
                endfor
            endif else begin
                str = str + strtrim(string(lints[first]),2) + ":" + strtrim(string(lints[last]),2) + ","
            endelse
            lastEnd = last
        endfor
        
        ; strip off inevitable trailing comma
        str = strmid(str,0,strlen(str)-1)
    endelse
    return, str
end
