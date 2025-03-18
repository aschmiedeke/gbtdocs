;+
; Lists the values contained in the stack.
;
; @examples
; <pre>
;    addstack,30,50,2
;    tellstack
; </pre>
; @version $Id$
;-
pro tellstack
    compile_opt idl2

    if !g.acount eq 0 then begin
       print, 'The Stack is empty.'
       return
    end
    print,'[',format='(A,$)'
    for i=0,!g.acount-2 do $
        print,astack(i),', ',format='(1x,I0,A,$)'
    print,astack(!g.acount-1),']',format='(I0,A)'
end
