;+
; Sets the plotter Autoupdate to "off", i.e. it freezes the plotter.
; 
; <p>When the plotter is frozen, commands that modify the data in
; buffer 0 do not update the plotter with the result.  For example, if
; the plotter is frozen, when the user issues a "hanning" command the
; plotter will not immediately show the result.  Similarly for a
; "getnod", "getrec", "bias",  etc.  The user must explicitly issue a
; "show" to see the latest contents of buffer 0.
;
; <p>This is especially useful before a loop or procedure invocation
; where lots of data is processed and the plotter would otherwise be
; frequently updating.  If only the end result is interesting, then
; freezing the plot will make the loop or procedure happen much
; faster.
;
; @examples
; <pre>
;   ; this might appear in a procedure
;   freeze
;   sclear
;   for i=20,35 do begin
;      getfs,i
;      accum
;   endfor
;   unfreeze
;   ave
; <pre>
;
; @version $Id$
;-
pro freeze
    if not !g.has_display then return

    !g.frozen = 1
    setplotterautoupdate

    return
end
