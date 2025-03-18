;+
; Construct the x array for the given data container and the current
; settings in the state variable.  This is used internally and is not
; intended for end users.
;
; @param dc {in}{required}{type=data container} The data container to
; use when constructing the x array.
;
; @keyword type {in}{optional}{type=integer} The type of x-axis
; desired.  0=Channels, 1=Frequency, 2=Velocity.  If not set, then the
; current value of mystate.xtype will be used.
;
; @returns the x-array
;
; @private_file
;
; @version $Id$
;-
function makeplotx, dc, type=type
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    num_chans = data_valid(dc)
    if (num_chans le 0) then return, -1

    x = chantox(dindgen(num_chans),type=type, dc=dc)

    return, x
end
