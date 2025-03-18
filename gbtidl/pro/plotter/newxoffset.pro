;+
; Returns what the new xoffset needs to be given the current contents
; of the mystate structure.  This is called in the process of
; switching to a relative x-axis.  It does it this way, rather than
; setting mystate.xoffset directly, so that the existing xoffset isn't
; lost.  That value is needed first in the process of converting all
; of the internal values to the new x-axis.  This is used internally
; and is not meant for general use.
;
; @param type {in}{required}{type=integer} The axis type (0 is
; channels, 1 is frequency and 2 is velocity).
;
; @param scale {in}{required}{type=double} The unit scaling to use.
;
; @param frame {in}{required}{type=string} The frame to calculate the
; offset in.  Not used for channels.
;
; @param veldef {in}{required}{type=string} The velocity definition to
; use.  Only used for velocity-type x-axes.
;
; @returns The new xoffset, scaled appropriately.
;
; @private_file
;
; @version $Id$
;-
function newxoffset, type, scale, frame, veldef
    compile_opt idl2
    common gbtplot_common,mystate,xarray

    result = 0.0d
    case type of
        0: begin
            ; chan
            if mystate.line then begin
                result = (*mystate.dc_ptr).reference_channel
            endif else begin
                result = (n_elements(*(*mystate.dc_ptr).data_ptr))/2 - 1.
            endelse
        end
        1: begin
            ; Freq
            result = freqtofreq(*mystate.dc_ptr, $
                                (*mystate.dc_ptr).reference_frequency, frame, $
                                (*mystate.dc_ptr).frequency_type)
            result = shiftfreq(result,mystate.voffset,veldef='TRUE')
        end
        2: begin
            ; Vel
            result = freqtofreq(*mystate.dc_ptr, $
                                (*mystate.dc_ptr).reference_frequency, frame, $
                                (*mystate.dc_ptr).frequency_type)
            result = shiftfreq(result,mystate.voffset,veldef='TRUE')
            result = freqtovel(result, (*mystate.dc_ptr).line_rest_frequency, veldef=veldef)
        end
        else: message,'unrecognized axis type, x-axis values may be wrong',/info
    endcase

    result /= scale

    return, result
end
