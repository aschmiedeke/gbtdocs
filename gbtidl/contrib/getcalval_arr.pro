;+
; <p>
; This function determines an array of cal values to match the frequencies of
; the data.  The cal values are taken from the astronomical files. 
; This nees to be expanded to cover all receivers, check beam number, check pol, and check date.
;
; <p><B>Contributed By: Karen O'Neil, NRAO-GB</B>
;
; @examples:
; calval=getcalval_arr(cal='hi')
;
; @keyword rcvr {in}{optional}{type=string} Receiver name (default is 'Rcvr1_2')
; @keyword cal {in}{optional}{type=string} 'hi' or 'lo' voltage fired for the cal (default is 'hi')
; @keyword ipol {in}{optional}{type=integer} The polarization to use.  (default is -5)
;
; @version $Id$
;-
;
function getcalval_arr,rcvr=rcvr,cal=cal,ipol=ipol
;
if not(keyword_set(rcvr)) then rcvr='Rcvr1_2'
if not(keyword_set(cal)) then cal='hi'
if not(keyword_set(ipol)) then ipol=-5
;
if (strtrim(rcvr,2) ne 'Rcvr1_2' and (ipol ne -5 or ipol ne -6)) then begin  
	print,'I only handle L-band right with XX and YY polarizations now.  Sorry.' &$
	return,0 &$
endif
;
file='L_Linear.txt'

contribDir = getenv('GBT_IDL_DIR') + '/contrib/'

fullPath = contribDir + file
if not file_test(fullPath,/read) then begin
    print,'The L-band linear data file could not be found or is not readable.'
    return,0
endif
;
openr,lun,fullPath,/get_lun
i=0
j=0
pol=0
done=0
xdone=0
ydone=0
line='s'
tcal=make_array(2,10000,value=0.0)
while ((~EOF(lun)) and (done ne 1)) do begin  
  readf,lun,line 
     if (strmid(line,0,16) eq 'Measurement Date') then begin 
	res=strsplit(line,/extract) 
	month=res[2] 
	date=res[3] 
	yr=res[4] 
     endif 
     if (strmid(line,0,4) eq 'Beam') then begin 
	res=strsplit(line,/extract) 
	beam=fix(res[1]) 
     endif 
     if (strmid(line,0,4) eq 'Pola') then begin 
	res=strsplit(line,/extract) 
	stokes=res[1] 
       ; convert polarization string into numbers
       if (strtrim(stokes,2) eq 'X') then pol=-5
       if (strtrim(stokes,2) eq 'Y') then pol=-6
       if (strtrim(stokes,2) eq 'XL') then pol=-2
       if (strtrim(stokes,2) eq 'YR') then pol=-1
     endif
     if (ipol eq pol) then begin
     if ((strmid(line,0,1) eq '1') or (strmid(line,0,1) eq '2') or $
	(strmid(line,0,1) eq '3') or (strmid(line,0,1) eq '4') or $
	(strmid(line,0,1) eq '5') or (strmid(line,0,1) eq '6') or $
	(strmid(line,0,1) eq '7') or (strmid(line,0,1) eq '8') or $
	(strmid(line,0,1) eq '9') or (strmid(line,0,1) eq '0')) then begin  
	  res=strsplit(line,/extract) 
	  tcal[0,i]=res[0] 
          if (n_elements(res) ge 3) then if (cal eq 'lo') then tcal[1,i]=res[2] 
          if (n_elements(res) ge 4) then if (cal eq 'hi') then tcal[1,i]=res[3] 
	  i=i+1 
     endif 
     endif 
endwhile
close,lun
free_lun,lun
ind=where(tcal[0,*] gt 0,count)
calval=make_array(2,count) 
calval[0:1,*]=tcal[0:1,ind]
;convert frequencies to Hz
calval[0,*]=calval[0,*]*1e9
;
return,calval
end
