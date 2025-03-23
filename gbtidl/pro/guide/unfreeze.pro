; docformat = 'rst' 

;+
; Sets the plotter Autoupdate to "on", i.e. it unfreezes the plotter.
; When the plotter is unfrozen, commands that modify the data in buffer 0
; automatically update the plotter with the result.  For example, if the 
; plotter is unfrozen (the default), when the user issues a "hanning" command 
; the plotter will immediately show the result.  Similarly for a "getnod",
; "getrec", "bias", etc.  When the plotter is frozen, the user must
; explicitly issue a "show" to see the latest contents of buffer 0.
;
;-
pro unfreeze
    if not !g.has_display then return

    !g.frozen = 0
    setplotterautoupdate

    return
end
