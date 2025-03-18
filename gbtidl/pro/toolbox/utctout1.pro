;+
; utctout1 - convert utc to ut1
;
; <p>Return the offset from utc to ut1 as a fraction of a day. The returned
; value (dut1Frac) is defined as ut1Frac=utcFrac + dut1Frac;
; The fraction of a day can be less then 0. 
;   
; <p>The utc to ut1 conversion info is passed in via the structure
; UTC_INFO.
;
; <p>This code came from 
; <a href="http://www.naic.edu/~phil/">Phil Perillat</a> at Arecibo.
; Local changes:
; <UL>
; <LI> modify this documentation for use by idldoc.
; </UL>
;
; @param juldat {in}{required}{type=double} julian date, may be a
; vector
; @param utcInfo {in}{required}{type=utc_info structure} The utc to ut1
; conversion information.
;
; @returns  ut1FracOffset[n]: double add this to utc based times to get ut1
;
; @version $Id$
;-
function  utcToUt1,juldat,utcInfo

    return,(1d-3*1./86400.D * $
          (utcInfo.offset + ((juldat - utcInfo.juldatAtOff))*utcInfo.rate))
end
