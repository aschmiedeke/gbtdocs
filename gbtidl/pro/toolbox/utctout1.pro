; docformat = 'rst' 

;+
; utctout1 - convert utc to ut1
;
; Return the offset from utc to ut1 as a fraction of a day. The returned
; value (dut1Frac) is defined as ut1Frac=utcFrac + dut1Frac;
; The fraction of a day can be less then 0. 
;   
; The utc to ut1 conversion info is passed in via the structure
; UTC_INFO.
;
; This code came from `Phil Perillat <http://www.naic.edu/~phil/>`_ at
; Arecibo.
; 
; Local changes:
; 
; * modify this documentation for use by idldoc.
; 
; :Params:
;   juldat : in, required, type=double
;       julian date, may be a vector
;   utcInfo : in, required, type=utc_info structure
;       The utc to ut1 conversion information.
;
; :Returns:
;   ut1FracOffset[n]: double add this to utc based times to get ut1
;
;-
function  utcToUt1,juldat,utcInfo

    return,(1d-3*1./86400.D * $
          (utcInfo.offset + ((juldat - utcInfo.juldatAtOff))*utcInfo.rate))
end
