;+
; Convert from Julian day to local mean sidereal time.  By default the
; longitude of the GBT is used.
;
; <p>If you need local apparent sidereal time, then add the equation of
; the equinox to these values (see nutation_m()).
;
; <p>This code came from 
; <a href="http://www.naic.edu/~phil/">Phil Perillat</a> at Arecibo.
; Local changes:
; <UL>
; <LI> use the position of the GBT as the default position.
; <LI> modify this documentation for use by idldoc.
; <LI> modify to make use of the obslong keyword, which is now east
; longitude in degrees to match contents of gbtidl data container.
; </UL>
;  
; @param juldat {in}{required}{type=double} Array of julian days to
; convert.
;
; @keyword obslong {in}{optional}{type=double}{default=GBT} East longitude of observatory in degrees.
;
; @returns lmst[n]: double local mean sidereal time in radians
;
; @uses <a href="utcinfoinp.html">utcinfoinp</a>
; @uses <a href="utctout1.html">utcToUt1</a>
;
; @version $Id$
;-
function juldaytolmst,juldat,obslong=obslong

    obsWestLongFract = (79.D + 50.D/60.D + 23.3988D/3600.D) / 360.D ; use GBT
    if (keyword_set(obslong)) then begin
        ; flip sign - need west longitude
        obsWestLongFract = -obslong / 360.D
    endif

    if not keyword_set(eqEquinox) then eqEquinox=0.
    JULDAYS_IN_CENTURY=36525.D
    JULDATE_J2000     = 2451545.D
    SOLAR_TO_SIDEREAL_DAY= 1.00273790935D
    istat=utcinfoinp(mean(juldat),utcinfo)

;   julian day starts at noon. get utc frac at midnite
;   we will compute the sidereal time for 0 hours Ut then add 
;   on the fraction of a day utcFrac + utcToUt1
;
    utcFrac  =(juldat - .5D) mod 1.D
    juldat0Ut=long(juldat - .5D) + .5D  ; juldat at 0 hours utc
;
;      go utc fract to ut1 fract
;
        ut1Frac= utcFrac + utcToUt1(julDat,utcInfo)
        ind=where(ut1Frac lt 0.,count)
        if count gt 0 then begin
            ut1Frac[ind]=ut1Frac[ind] +1.
            juldat0Ut[ind]=juldat0Ut[ind] - 1L
        endif
        ind=where(ut1Frac ge 1.,count)
        if count gt 0 then begin
            ut1Frac[ind]=ut1Frac[ind] -1.
            juldat0Ut[ind]=juldat0Ut[ind] + 1L
        endif
;
; fraction of julian centuries till j2000
; TU is measured from 2000 jan 1D12H UT
;
        Tu= (juldat0Ut - JULDATE_J2000)/JULDAYS_IN_CENTURY
;
;     gmst at 0 ut of date in sidereal seconds
;        
        gmstAt0Ut=24110.54841D + Tu*(8640184.812866D + $
                                 Tu*(.093104D        - $
                                 Tu*(6.2d-6)))
;
;  convert to fraction of a day, add on user fract and throw away
;  integer part
;
    dfract=(gmstAt0Ut/86400.D + ut1Frac*SOLAR_TO_SIDEREAL_DAY - $
                     obsWestLongFract) mod 1.d
    ind=where(dfract lt 0.D,count)
    if count gt 0 then dfract[ind]=dfract[ind] + 1.d
    lmstRd=dfract*2.*!dpi    
    return,lmstRd
end
