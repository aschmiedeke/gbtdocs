;+
; Extract the scale factor and type (0=Channels, 1=Frequency or 2=Velocity) from an
; xunit string.  This routine is a helper routine for other gbtidl
; plotter procedures and is not intended for end-user use.
;
; @param unit {in}{required}{type='String'} The unit to parse.  The
; recognized strings are the same strings used in the XUnits menu:
; Channels, Hz, kHz, MHz, GHz, m/s, and km/s.
;
; @param scale {out}{required}{type=double} The scale factor implied
; by unit.
;
; @param type {out}{required}{type=string} The type of axis implied by
; unit (Channels, Frequency, or Velocity).
;
; @private_file
;
; @version $Id$
;-
pro parsexunit, unit, scale, type
    compile_opt idl2
    
    type = 1 ; frequency
    case unit of
        'Channels' : begin
            scale = 1.0d
            type = 0
        end
        'Hz' : scale = 1.0d
        'kHz': scale = 1.0d3
        'MHz': scale = 1.0d6
        'GHz': scale = 1.0e9
        'm/s': begin
            scale = 1.0d
            type = 2 ; Velocity
        end
        'km/s': begin
            scale = 1.0d3
            type = 2; Velocity
        end
        else: begin
            print, 'Invalid x-axis unit.  This is a bug that needs to be reported.'
            type = 0 ; default to Channels
            unit = 'Channels'
            scale = 1.0d
        end
    endcase
end
