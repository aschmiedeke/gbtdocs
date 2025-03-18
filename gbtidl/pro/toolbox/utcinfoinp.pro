;+ 
; Input parameters to convert utc to ut1
;
; <p>Read the utc to ut1 information from the utcToUt1.dat file.
; The UTC_INFO structure will return the information needed to go from utc to
; UT1. the routine utcToUt1 converts from utc to ut1 using the information
; read in here into the UTC_INFO structure. The conversion algorithm
; is:
; <pre>
;   utcToUt1= ( offset + ((julDay - julDayAtOffset))*rate
; </pre>
;
; The offset, rate, data are input from the utcToUt1.dat file.
; 
; <p>The user passes in the julian date and the
; utcToUt1.dat file will be searched for the greatest julian date that is 
; less than or equal to the date passed in. If all of the values are after the
; requested juliandate,  the earliest value in the file will be used and
; and error will be returned. 
;
; <p><B>Note: \@utc_info must be done before this function is called.</B>
;
; <p>This code came from
;<a href="http://www.naic.edu/~phil/">Phil Perillat</a> at Arecibo.
; Local changes:
; <UL>
; <LI> modify to find the local copy of utcToUt1.dat file.
; <LI> modify this documentation for use by idldoc.
; </UL>
;
; <p>NOTE: The file is updated whenever a leap second occurs or whenever the
;       drift rate changes (usually every 6 months or a year). If you have 
;       downloaded this file from ao, then you need to redownload the
;       newer versions occasionally. Check the file
;       aodefdir()/data/pnt/lastUpdateTmStamp for when your file was 
;      last updated.
;
; @param juliandate {in}{required}{type=double} Julian date
; @param utcInfo {out}{required}{type=utcInfo structure} utcInfo
; structure
; @returns status; 0=problem, 1=ok
;
; @uses <a href="file_exists.html">file_exists</a>
; @uses <a href="dmtodayno.html">dmtodayno</a>
; @uses <a href="daynotodm.html">daynotodm</a>
;
; @returns {utcInfo}
;
;DESCRIPTION
;-
function  utcinfoinp,juliandate,utcInfo


    utcInfo={utc_info}
    caldat,juliandate,mon,day,year,hour,min,sec
    daynum=dmtodayno(day,mon,year)
    
    on_ioerror,endio
    FILE_UTC_TO_UT1=getenv('GBT_IDL_DIR') + "/pro/toolbox/utcToUt1.dat"
    dayNumCur=-1
    yearCur=-1;
    rateCur=0.
    offsetCur=0;
    dayNum0=999999;
    year0=999999;
    offset0=0.
    rate0=0.;
    lun=-1
    istat=file_exists(FILE_UTC_TO_UT1)
    if istat eq 0 then begin
        print,'Unable to open file utcToUt1 file:',FILE_UTC_TO_UT1
        return,0
    endif
;
    openr,lun,FILE_UTC_TO_UT1,/GET_LUN
;
;   loop till we find a the year/daynumber to use
;
    inpline=''
    gotit=0
    while (not gotit) do begin
        readf,lun,inpline 
        if (strmid(inpline,0,1) ne '#') then begin
            reads,inpline,yearInp,daynuminp,offsetinp,rateInp
; 
;            if date <= one passed in
;       
             if  (yearInp le  year) then begin
                if ((yearInp lt year) or (dayNumInp le dayNum)) then begin
;
;                 if date > what we currently have
;
                    if (yearInp ge yearCur) then begin
                        if ((yearInp gt yearCur) or (dayNumInp ge dayNumCur))$
                                then begin
                            yearCur=yearInp;
                            dayNumCur=dayNumInp;
                            rateCur  =rateInp;
                            offsetCur=offsetInp;
                        endif
                    endif
                endif
             endif
             if (yearInp le year0) then begin
                if ((yearInp lt year0) or (dayNumInp lt dayNum0)) then begin
                    year0=yearInp;
                    dayNum0=dayNumInp;
                    offset0=offsetInp;
                    rate0  =rateInp;
                endif
             endif
        endif
     endwhile
endio:
     if lun gt -1 then free_lun,lun
     istat=1
     if (yearCur eq  -1) then begin
;        print,'utcInfoInp:all dates in utcTout1.dat >', year,dayNum
        istat=0
        if (year0 lt 9999) then begin
;
;          use 1st value
;
            yearCur=year0;
            dayNumCur=dayNum0;
            rateCur=rate0;
            offsetCur=offset0;
;            print,' Using 1st date:',year0
        endif else begin
             print,'no dates in utcToUt1.dat file'
        endelse
    endif
    dm=daynotodm(dayNumCur,yearCur)
    jd=julday(dm[1],dm[0],yearCur,0.,0.,0.)
    utcInfo.julDatAtOff=julday(dm[1],dm[0],yearCur,0.,0.,0.)
    utcInfo.offset=offsetCur;
    utcInfo.rate  =rateCur;
    return,istat
end
