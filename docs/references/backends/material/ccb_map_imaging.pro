; make a map from scans 7-10 using port 11 data 
;  (note the port must be specified; valid ports are
;   9-16)
img=makedcrccbmap([7,8,9,10],/isccb,port=11)

; replot the map
plotmap,img,/int

; make a png copy of it
grabpng,'mymap.png'

; save the map in standard FITS format--
saveimg,img,'mymap.fits'
