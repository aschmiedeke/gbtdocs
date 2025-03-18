;+
; Function to convert a set of xvalues from one frame, veldef, et al
; to another.  This function is not intended to be called by users.
;
; @param dc {in}{required}{type=data container} The data container
; to use in the actual conversion code calls.
; @param xvalues {in}{required}{type=vector of doubles} The values
; to be converted.
; @param scale {in}{required}{type=double} The amount that xvalues
; has been scaled from its base value (channels, Hz, or m/s).
; @param type {in}{required}{type=integer} The type of xvalues to
; convert (0=Channels, 1=Frequency, 2=Velocity).
; @param frame {in}{required}{type=string} The frame that xvalues
; is in.
; @param veldef {in}{required}{type=string} The velocity
; definition used in xvalues.
; @param xoffset {in}{required}{type=double} The amount of linear
; offset in x that must be added to these values before scaling
; to get to the xvalues in the input frame with voffset.
; @param voffset {in}{required}{type=double} The velocity offset
; (TRUE, m/s) that must be accounted for before converting to channels.
; @param newscale {in}{required}{type=double} The amount that the
; converted xvalues
; should been scaled to relative its base value (channels, Hz, or m/s).
; @param newtype {in}{required}{type=integer} The new type of xvalues after
; conversion (0=Channels, 1=Frequency, 2=Velocity).
; @param newframe {in}{required}{type=string} The new frame that
; the converted xvalues are in.
; @param newveldef {in}{required}{type=string} The new velocity
; definition used in the converted xvalues.
; @param newxoffset {in}{required}{type=double} The new xoffset to
; be subtracted from the data after scaling.
; @param newvoffset {in}{required}{type=double} The new velocity
; offset (TRUE, m/s) that frequency and velocities should be shifted
; by before scaling.
;
; @returns The converted xvalues.
;
; @private_file
;
; @version $Id$
;-

function convertxvalues, dc, xvalues, scale, type, frame, veldef, xoffset, voffset, $
            newscale, newtype, newframe, newveldef, newxoffset, newvoffset
    compile_opt idl2

    ; ignore empty data containers
    if data_valid(dc) le 0 then return, xvalues

    newxvalues = xvalues + xoffset
    newxvalues = newxvalues * scale

    ; convert to channels
    switch type of
        2: begin
            ; vel to freq
            newxvalues = veltofreq(newxvalues, dc.line_rest_frequency, veldef=veldef)
        end
        1: begin ; vel falls through and continues from here
            newxvalues = unshiftfreq(newxvalues,voffset,veldef='TRUE')
            newxvalues = freqtochan(dc, newxvalues, frame=frame) ; Freq
        end
        0: break ; Chan, nothing more to be done
       else: message,'unrecognized velocity definition, x-values may be wrong',/info
    endswitch

    ; and convert to desired type
    case newtype of
        0: ; Chan nothing to do
        1: begin ; frequency
            newxvalues = chantofreq(dc, newxvalues, frame=newframe) ; Freq
            newxvalues = shiftfreq(newxvalues, newvoffset, veldef='TRUE')
        end
        2: begin ; velocity
            newxvalues = chantofreq(dc, newxvalues, frame=newframe) ; Freq
            newxvalues = shiftfreq(newxvalues, newvoffset, veldef='TRUE')
            newxvalues = freqtovel(newxvalues, dc.line_rest_frequency, veldef=newveldef)
        end
        else:
    endcase

    ; and scale and offset
    newxvalues /= newscale
    newxvalues = newxvalues - newxoffset

    return, newxvalues
end
