; docformat = 'rst' 

;+
; Generates a sequence of numbers in an array
;
; :Params:
;   s_beg : in, required, type=int
;       first value
; 
;   s_end : in, required, type=int
;       last value
; 
;   s_inc : in, optional, type=int
;       increment
; 
; :Returns:
;   long integer array
;
;-
function seq,s_beg,s_end,s_inc
	compile_opt idl2
	if n_elements(s_inc) eq 0 then s_inc = 1
	num = (s_end - s_beg)/s_inc + 1
	a = lindgen(num)*s_inc + s_beg
	return, a
end
