; docformat ='rst' 

;+
; Only applicable if the loaded index file has had new rows written to it.
; This method need not be used (is called internally) when working in online
; mode: filein, 'filename', /online
;
; If line mode is on (!g.line is 1) then this updates the global 
; line io object, otherwise, it sets the
; global continuum object.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       ; note that we are NOT in online mode
;       >filein, 'filename'
;       ; immediatly display contents before online index file has changed
;       >list
;       ; call update before anything has changed
;       > update
;       >'Online index file has not changed'
;       >list
;       ; here you see the original contents of 'filename'
;       ; now wait for end of next scan
;       >update
;       >"Online index file has 96 new lines."
;       >list
;       ; followed by all the contents, including last scan, of 'filename'
;       ; NOTE: the same can be done using online mode:
;       >filein, 'filename', /online
;       ; display before end of next scan
;       >list
;       >'Online index file has not changed'
;       ; followed by original contents
;       ; wait for end of next scan
;       >list
;       >'Online index file has 96 new lines."
;       ; followed by original + last scan contents
; 
; @private_file
;-
pro update
    if (!g.line) then begin
        !g.lineio->update
    endif else begin
        !g.contio->update
    endelse
end
