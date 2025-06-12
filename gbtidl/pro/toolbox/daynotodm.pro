; docformat = 'rst'

;+
; Convert daynumber and year to day of month (1..31) and  month
; of year (1.l12).
;
; This code came from `Phil Perillat <http://www.naic.edu/~phil/>`__ at Arecibo.
; 
; Local changes:
; 
; * modify this documentation for use by idldoc.
;
; :Params:
;   dayno : in, required, type=long integer
;       daynumber of year 1..365 or 366
;   year : in, required, type=long integer
;       4 digit year
;
; :Returns:
;   [day,month] as a vector. 
;
;-
function daynotodm,dayno,year
    dayNoDat=[[0,31,59,90,120,151,181,212,243,273,304,334,365],$
              [0,31,60,91,121,152,182,213,244,274,305,335,366]]

    if isleapyear(year) then begin
       indyr=1
       daysInYear=366
    endif else begin
       indyr=0
       daysInYear=365
    endelse
    if dayno lt 1 then dayno = 1
    if dayno gt daysInYear then dayno = daysInYear
    ind=where(daynodat[*,indyr] ge dayno,count)
    mon=ind[0]
    return,[dayno-dayNoDat[ind[0]-1,indyr],mon]
end

