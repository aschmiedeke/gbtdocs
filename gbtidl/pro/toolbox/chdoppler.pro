; docformat = 'rst'

;+
; Computes the projected velocity of the telescope wrt
; six coordinate systems: geo, helio, bary, lsrk, lsrd, gal
; negative velocities mean approach
;
; The standard LSR is defined as follows: the sun moves at 20.0 km/s
; toward ra=18.0h, dec=30.0 deg in 1900 epoch coords
;
; Fully vectorized.  All three arguments must have the same dimensions.
;
; This code came via e-mail from Carl Heiles via Tom Bania on 11/04/2004.
; Updated using code found via google from same source on 11/30/2009.
; Local changes:
; 
; * modify this documentation for use by idldoc.
; * removed path argument and related code, replaced by obspos argument.
; * default position is the GBT.
; * Observatory longitude was not being passed to juldaytolmst.
; * LSRD added 
; * Galactocentric added
; * Checked against aips++ Measures.  Differences were less then 20 m/s in
;   one test case (less then 10m/s for geo, bary, and lsrk).
; * Double precision throughout.
; * Relativistic addition of velocities.
; 
;
; Previous revision history: carlh 29oct04
; 
; * from idpppler_chl; changed calculation epoch to 2000.
; * 19nov04: correct bad earth spin calculation
; * 07 Jun 2005: vectorize to make faster for quantity calculations
; * 20 Mar 2007: CH updated documentation
; * 08 Feb 2015: CH fixed doppler additions for array inputs. See
;                  annotated statements at end of program.
;
; :Params:
;   ra {in}{required} The source ra in decimal hours, equinox 2000
;   dec {in}{required} The source dec in decimal hours, equinox 2000
;   julday {in}{required} The julian day
;
; :Keywords:
;   obspos {in}{optional}{type=double [2]} 
;       observatory position [East longitude, latitude] in degrees.  
;       Uses the GBT position if not specified.
; 
;   light : in, optional, type=boolean
;       When set, returns the velocity as a fraction of c
;
; :Returns:
;   The velocity in km/s, or as a faction of c if the keyword /light is specified.
;   the result is a 6-element vector whose elements are [geo, helio, bary, lsrk, 
;   lsrd, gal].
;
; :Uses:
;   `baryvel <https://asd.gsfc.nasa.gov/archive/idlastro/ftp/pro/astro/baryvel.pro>`_
;   `precess <https://asd.gsfc.nasa.gov/archive/idlastro/ftp/pro/astro/precess.pro>`_
;   :idl:pro:`juldaytolmst`
;
;-
function chdoppler, ra, dec, julday, $
        obspos=obspos, light=light
;
; Default to GBT if obspos not provided.
if (not keyword_set(obspos)) then begin
    obspos=dblarr(2);
    obspos[0]=[-(79.D + 50.D/60.D + 23.3988D/3600.D)]
    obspos[1]=[(38.D + 25.D/60.D + 59.2284D/3600.D)]
endif

;------------------ORBITAL SECTION-------------------------
nin = n_elements( ra)

;GET THE COMPONENTS OF RA AND DEC, 2000u EPOCH
rasource=ra*15.d*!dtor
decsource=dec*!dtor

xxsource = dblarr( 3, nin)
xxsource[0, *] = cos(decsource) * cos(rasource)
xxsource[1, *] = cos(decsource) * sin(rasource)
xxsource[2, *] = sin(decsource)
pvorbit_helio = dblarr( nin)
pvorbit_bary = dblarr( nin)
pvlsrk = dblarr( nin)
pvlsrd = dblarr( nin)
pvgal = dblarr( nin)

;GET THE EARTH VELOCITY WRT THE SUN CENTER
;THEM MULTIPLY BY SSSOURCE TO GET $
;       PROJECTED VELOCITY OF EARTH CENTER WRT SUN TO THE SOURCE
FOR NR=0, NIN-1 DO BEGIN
baryvel, julday[nr], 2000.,vvorbit,velb
pvorbit_helio[ nr]= total(vvorbit*xxsource[*, nr])
pvorbit_bary[ nr]= total(velb* xxsource[ *,nr])
ENDFOR

;stop

;-----------------------LSRK SECTION-------------------------
;THE STANDARD LSRK IS DEFINED AS FOLLOWS: THE SUN MOVES AT 20.0 KM/S
;TOWARD RA=18.0H, DEC=30.0 DEG IN 1900 EPOCH COORDS
;using PRECESS, this works out to ra=18.063955 dec=30.004661 in 2000
;coords.
ralsrk_rad= 2.d*!pi*18.d/24.d
declsrk_rad= !dtor*30.d
precess, ralsrk_rad, declsrk_rad, 1900.d, 2000.d,/radian

;FIND THE COMPONENTS OF THE VELOCITY OF THE SUN WRT THE LSRK FRAME
xxlsrk = dblarr( 3, nin)
xxlsrk[ 0, *] = cos(declsrk_rad) * cos(ralsrk_rad)
xxlsrk[ 1, *] = cos(declsrk_rad) * sin(ralsrk_rad)
xxlsrk[ 2, *] = sin(declsrk_rad)
vvlsrk = 20.d*xxlsrk

;PROJECTED VELOCITY OF THE SUN WRT LSRK TO THE SOURCE
for nr=0, nin-1 do pvlsrk[ nr]=total(vvlsrk*xxsource[ *, nr])


;-----------------------LSRD SECTION-------------------------
;THE LSRD IS DEFINED AS FOLLOWS: THE SUN MOVES AT 16.6 KM/S
;TOWARD RA=17:49:58.7 hours, DEC=28.07.04 DEG IN 2000 EPOCH COORDS

ralsrd_rad= 2.d*!dpi*(17.D + 49.D/60.D + 58.7D/3600.D)/24.d
declsrd_rad= !dtor*(28.D + 07.D/60.D + 04.0D/3600.D)

;FIND THE COMPONENTS OF THE VELOCITY OF THE SUN WRT THE LSRD FRAME
xxlsrd = dblarr( 3, nin)
xxlsrd[ 0, *] = cos(declsrd_rad) * cos(ralsrd_rad)
xxlsrd[ 1, *] = cos(declsrd_rad) * sin(ralsrd_rad)
xxlsrd[ 2, *] = sin(declsrd_rad)
vvlsrd = 16.6D*xxlsrd

;PROJECTED VELOCITY OF THE SUN WRT LSRD TO THE SOURCE
for nr=0, nin-1 do pvlsrd[ nr]=total(vvlsrd*xxsource[ *, nr])

;-----------------------GALACTOCENTRIC SECTION------------------
; LSRD + 220 km/s towards RA=21:12:01.1 DEC=48.19.47 in J2000 Epoch

ragal_rad = 2.d*!dpi*(21.D + 12.D/60.D + 01.1D/3600.D)/24.d
decgal_rad = !dtor*(48.D + 19.D/60.D + 47.D/3600.D)

; Find the components of the velocity of the sun wrt this frame
xxgal = dblarr( 3, nin)
xxgal[ 0, *] = cos(decgal_rad) * cos(ragal_rad)
xxgal[ 1, *] = cos(decgal_rad) * sin(ragal_rad)
xxgal[ 2, *] = sin(decgal_rad)
vvgal = 220.D*xxgal

;PROJECTED VELOCITY OF THE SUN WRT GAL TO THE SOURCE
for nr=0, nin-1 do pvgal[ nr]=total(vvgal*xxsource[ *, nr])

;---------------------EARTH SPIN SECTION------------------------
lat= obspos[1]

lst_mean= 24.d/(2.d*!pi)*juldaytolmst( julday,obslong=obspos[0])

;MODIFIED EARTH SPIN FROM GREEN PAGE 270
pvspin= -0.465* cos( !dtor*lat) * cos( decsource) * $
        sin(( lst_mean- ra)* 15.* !dtor)

;---------------------NOW PUT IT ALL TOGETHER------------------

vtotal= dblarr( 6, nin)
vtotal[ 0,*]= -pvspin
vtotal[ 1,*]= shiftvel(-pvspin,-pvorbit_helio)
vtotal[ 2,*]= shiftvel(-pvspin,-pvorbit_bary)
vtotal[ 3,*]= shiftvel(vtotal[2,*],-pvlsrk)
vtotal[ 4,*]= shiftvel(vtotal[2,*],-pvlsrd)
vtotal[ 5,*]= shiftvel(vtotal[4,*],-pvgal)

;the statements below are wrong (CH 8 feb 2015)
;vtotal[ 3,*]= -shiftvel(-vtotal[2],pvlsrk)
;vtotal[ 4,*]= -shiftvel(-vtotal[2],pvlsrd)
;vtotal[ 5,*]= -shiftvel(-vtotal[4],pvgal)

if keyword_set(light) then vtotal=vtotal/(!gc.light_speed*1.d3)

;stop

return,vtotal
end
