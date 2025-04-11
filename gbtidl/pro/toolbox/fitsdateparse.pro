; docformat = 'rst'

;+
; Convert a FITS date string into its component parts.
; 
; :Params:
;   dateobs : in, required, type=string
;       A FITS date string following the pattern: 
;       YYYY-MM-DD[Thh:mm:ss[.sss...]] or DD/MM/YY.
;
; :Returns:
;   double precision vector containing [year,month,day,hour,minute,second].
;   If the time fields are not present, 0s are returned.  If the string is
;   invalid, -1 is returned.
;
;-
function fitsdateparse,dateobs
    compile_opt idl2
    ;
    ; Determine type of input supplied
    ;
    s = size(dateobs) & ndim = s[0] & datatype = s[ndim+1]
    if (ndim ne 0) or (datatype ne 7) then begin
        ; invalid input date error section

        message,'FITSDATEPARSE - invalid dateobs specified - wrong dimension or type',/info
        return, -1
    end
   
    year = 0
    month = 0
    day = 0
    hour = 0
    minute = 0
    seconds = 0.0

    ; check for normal FITS date string: YYYY-MM-DD[Thh:mm:ss[.sss...]]
    if strmatch(dateobs,'????-??-??*') then begin
        year = fix(strmid(dateobs,0,4))
        month = fix(strmid(dateobs,5,2))
        day = fix(strmid(dateobs,8,2))
        if strlen(dateobs) gt 10 then begin
            if strmatch(strmid(dateobs,10),'T??:??:??*') then begin
                hour = fix(strmid(dateobs,11,2))
                minute = fix(strmid(dateobs,14,2))
                seconds = double(strmid(dateobs,17))
            endif else begin
                message, 'FITSDATEPARSE - invalide time format after valid date will be ignored',/info
            endelse
        endif
    endif else begin
    ;
    ; check for old FITS date format:  DD/MM/YY
    ;
        if strmatch(dateobs,'??/??/??') then begin
            day = fix(strmid(dateobs,0,2))
            month = fix(strmid(dateobs,3,2))
            year = 1900 + fix(strmid(dateobs,6,2))
        endif else begin
            message, 'FITSDATEPARSE - invalide FITS date string', /info
            return, -1
        endelse
    endelse

    out = dblarr(6)
    out[0] = year
    out[1] = month
    out[2] = day
    out[3] = hour
    out[4] = minute
    out[5] = seconds

    return,out

end
