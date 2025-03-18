;+
; Creates a set of vectors which define basic symbos for use in
; scatter plots.
;
; <p>
; These vectors set the shape of the symbols, then USERSYM is called
; prior to plotting. Written by Mike Fanelli; Modified by Ed Murphy .
;
; <p><B>Contributed By: Bob Garwood from Tom Bania's original GBT IDL
; package</B>
;
; @param no {in}{required}{type=integer} The desired symbol,
; 1=circle, 2=triangle, 3=square, 4=diamond, 5=plus, 6=x symbol,
; 7=half circle.
; @param scale {in}{required}{type=float} The scale factor.
; @param ifl {in}{required}{type=integer} The filling factor, 1=filled,
; 0=empty. 
;
; @version $Id$
;-
   Pro syms,no,scale,ifl

 if (no eq 1) then goto,s1
 if (no eq 2) then goto,s2
 if (no eq 3) then goto,s3
 if (no eq 4) then goto,s4
 if (no eq 5) then goto,s5
 if (no eq 6) then goto,s6
 if (no eq 7) then goto,s7

s1:       ; circle
 ang = (360. / 24.) * findgen(25) / !radeg 
 usersym,cos(ang)*scale,sin(ang)*scale,FILL=ifl
 goto,theend

s2:       ; triangle
 ang = (360. / 3.)  * findgen(4) / !radeg
 usersym,sin(ang)*scale,cos(ang)*scale,FILL=ifl
 goto,theend

s3:       ; square
 sqx = [1.,1.,-1.,-1.,1.]  &  sqy = [1.,-1.,-1.,1.,1.]
 usersym,sqx*scale,sqy*scale,FILL=ifl
 goto,theend

s4:       ; diamond
 dix = [0.,1.,0.,-1.,0.]  &  diy = [1.,0.,-1.,0.,1.]
 usersym,dix*scale,diy*scale,FILL=ifl
 goto,theend

s5:       ; plus sign
 plx = [0.,0.,0.,-1.,1.]  &  ply = [1.,-1.,0.,0.,0.]
 usersym,plx*scale,ply*scale,FILL=ifl
 goto,theend

s6:       ; X symbol
 xkx = [0.7071,-0.7071,0.,-0.7071,0.7071]  
 xky = [0.7071,-0.7071,0.,0.7071,-0.7071]
 usersym,xkx*scale,xky*scale,FILL=ifl
 goto,theend  

s7:       ; half-circle
; the following produces a half-circle
; to plot a half-filled circle, plot data once with open circle
; then replot with half circle and ifl=1 
; if lrtp=90 then filled half circle is on left
;         180                         bottom
;         270                         right
;         360                         top
lrtp=90
 ang=fltarr(14) & ang(0) = (15. * findgen(13) + lrtp) / !radeg
 ang(13) = lrtp / !radeg 
 usersym,cos(ang)*scale,sin(ang)*scale,FILL=ifl
 goto,theend

theend:

return
end
 
 


