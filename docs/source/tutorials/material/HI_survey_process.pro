; Step 3.2.2
dirin,'/home/astro-util/HIsurvey/Session02'

jnk='jnk'   ; this is used later, to pause the observations
freeze      ; keep from plotting on the screen, to speed up the processing

; skipping steps 3.2.3, and 3.2.4 since you are running a script you should already understand your dataset.

; Steps 3.2.5  here we are running the commands quietly, and then 
; getting the tsys values from the !g structure.

gettp,299,plnum=0, /quiet
tsys0=!g.s.tsys

gettp,299,plnum=1, /quiet
tsys1=!g.s.tsys

;Step 3.2.6 - clear the buffer
sclear

;Step 3.2.7; Here wer are going to loop over the scans of interest.
;Because this is a text file, we are using the $& at the end, to continue the lines
;appropriately.  Again this is being run quietly

for i=295,297,2 do begin &$  ; scan numbers
  for p=0,1 do begin &$      ; polarizzation numbers
    if (p eq 0) then tsys=tsys0[0] else tsys=tsys1[0] &$
    getsigref,i+1,i,plnum=p,tsys=tsys,unit='Jy', /quiet &$
    accum &$
  endfor &$
endfor

ave

; Step 3.2.8 - fix the x-axis
setxunit,'GHz' ; make sure we have the expected units in the x-axis.
setx,1.401,1.412

; Step 3.2.9 - smooth the data to the desired resolution
gsmooth,100,/decimate

show
unfreeze
; Step 3.2.10 - Remove baseline
; set region - Here we are going to avoid clicking on the screen and set the regions for the
; baseline fitting 
region=[1.402, 1.4045, 1.40506, 1.4054, 1.4072, 1.4115]
reg1=xtochan(region)
Nregion,reg1
nfit,1
bshape

; this pauses the observations, to see the baseline shape
; this is only needed if this script is being read into gbtidl as a whole.
read,jnk,prompt='Push return to continue: '  

;remove the baseline
baseline ; removes the baseline

; Step 3.2.11.1: determine (and print) the rms noise
velo
stats,2000,2500, ret=mystats
rms1 = mystats.rms
stats,3500,4000, ret=mystats
rms2 = mystats.rms

rms = (rms1 + rms2) / 2

; Step 3.2.11.2: determine the galaxy's mean intensity using method 1, and calculating the 20% and 50% velocity widths
gmeasure,1, 0.5,brange=2815,erange=3142,rms=rms                       
gmeasure,1, 0.2,brange=2815,erange=3142,rms=rms


