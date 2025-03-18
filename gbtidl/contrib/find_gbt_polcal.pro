pro find_gbt_polcal, LSTRANGE=lstrange, SOURCE=source, $
                     TRES=tres, CHARSIZE=charsize, SYMSIZE=symsize, $
                     CONNECT=connect, _REF_EXTRA=_extra
;+
; NAME:
;       FIND_GBT_POLCAL
;
; PURPOSE:
;       To plot the parallactic angle as a function of LST for 
;       polarization calibrators observed at the GBT.
;
; CALLING SEQUENCE:
;       FIND_GBT_POLCAL [, LSTRANGE=[lstmin,lstmax]] [,
;       SOURCE=string array] [, TRES=scalar float] [,
;       CHARSIZE=scalar float] [, SYMSIZE=scalar float] [, /CONNECT]
;
; INPUTS:
;       None.
;
; KEYWORD PARAMETERS:
;       LSTRANGE = two-element array of minimum and maximum LST under 
;                  consideration.
;       SOURCE = string or string array of polarization calibration
;                sources in the Heiles and Fisher catalog.  If no source is
;                specified, all sources are plotted.
;       TRES = time resolution for plot in minutes.  Default is 12min, 
;              about the time for a single polarization calibration 
;              ("spider") scan.
;       CHARSIZE = character size for plot and legend labels.
;       SYMSIZE = symbol size for plotting PA vs LST. Default is 0.75.
;       /CONNECT - set to connect symbols with line segments
;
;       Any keywords for PLOT, OPLOT or LEGEND can be passed in via 
;       _REF_EXTRA.
;
; OUTPUTS:
;       None.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       The parallactic angle is plotted on the current device as a
;       function of LST for standard polarization calibrators.
;
; RESTRICTIONS:
;       This routine produces results for the GBT only.
;
; PROCEDURES CALLED:
;       GODDARD ASTRONOMY LIBRARY: LEGEND, MATCH, HADEC2ALTAZ
;
; EXAMPLE:
;       To find an appropriate polarization calibrator during an LST range
;       from 10h to 17h, you can first plot the position angle of each
;       possible calibrator in this range:
;       IDL> find_gbt_polcal, LSTRANGE=[10,17]
;
;       The legend listing sources shows only the calibrators that are up
;       in this LST range; the source name is preceded by the percentage
;       polarization and the source flux in Jy; sources with an asterisk
;       are stable sources and are prefered.  In order to find sources
;       which change rapidly, it might be desirable to connect the symbols
;       to see gradients more easily:
;       IDL> find_gbt_polcal, LSTRANGE=[10,17], /CONNECT
;
;       It might be desirable to inspect only a subset of preferred
;       calibrators:
;       IDL> find_gbt_polcal, LSTRANGE=[10,17], $
;            SOURCE='3c2'+['73','74','80','86']
;
;       For sources that cross the 0/24h boundaries, one can provide LST
;       ranges <0 or >24.  E.g., between 22h and 03h LST, either of the
;       following calls will work: LSTRANGE = [-2,3] or [22,27]
;
;       I find when outputting to a color printer, it's best to use a 
;       gray background:
;       IDL> psopen, 'paplot.ps', /LANDSCAPE, /COLOR, /TIMES, /ISOLATIN, /BOLD
;       IDL> setcolors, /SYSTEM_VARIABLES, /SILENT
;       IDL> bgfill, !gray
;       IDL> find_gbt_polcal, LST=[10,17], /CONNECT, /NOERASE, $
;       IDL> THICK=3, SYMSIZE=1, CHARSIZE=0.7, FONT=0
;       IDL> psclose
;       IDL> setcolors, /SYSTEM_VARIABLES, /SILENT
;
; NOTES: 
;       An ideal calibrator has a high percentage polarization, a
;       reasonable flux, and covers about 100 degrees in position angle in
;       a reasonable time.  If one has an observing session of about 2-3
;       hours, on can continually observe a strong source like 3C286 whose
;       PA changes rapidly.  If the observing session is long, one can
;       observe a slowly-rotating source in between targets to achieve a
;       uniform sampling of PA in time, as long as a PA swing of about 100
;       degrees is achieved.
;
;       See GBT memo by Heiles and Fisher: Calibrating the GBT For
;       Spectral Polarimetry Using Cross Correlation.  The values of the
;       percent polarization (P) and the flux density in Jy (S) at 4.8 GHz
;       are listed before each source name in the legend.  Sources with an
;       asterisk after them are stable sources.
;
; MODIFICATION HISTORY:
;       03 Dec 2004  Written by Tim Robishaw, Berkeley
;	T. Robishaw  Fixed bug: converted HA from hr to deg. 27 May 2006
;-

on_error, 2

; LATITUDE OF GREEN BANK...
latitude = 38.42d0

; HERE IS A LIST OF POLARIZATION CALIBRATION SOURCES FROM HEILES & FISHER...
polcals = [$
;           SOURCE      RAJ2000 [deg]  DECJ2000 [deg]   FLUX     POLN
           ['NRAO5',      '1.5578870',   '-6.3931484',  '2.2',   '3.5'],$
            ['3C10',      '6.2836251',    '64.165474', '15.5',   '0.5'],$
            ['3C48',      '24.422081',    '33.159760', '5.40',  '4.02'],$
            ['3C58',      '31.408333',    '64.828331', '29.3',   '5.6'],$
           ['3C66B',      '35.799084',    '42.991779', '3.26',  '3.63'],$
  ['MITGJ0221+3555',      '35.272793',    '35.937145',  '1.3',   '2.5'],$
          ['3C83.1',      '49.565575',    '41.857605',  '1.8',   '5.5'],$
            ['3C84',      '49.950668',    '41.511696',   '22',  '0.05'],$
         ['NRAO140',      '54.125450',    '32.308151',  '1.6',   '4.0'],$
            ['3C93',      '55.875042',    '4.9635000', '0.87',   '7.5'],$
         ['4C76.03',      '62.690044',    '76.945923',  '2.8',   '0.5'],$
           ['3C138',      '80.291191',    '16.639458',  '3.8',  '10.5'],$
     ['PKS0521-365',      '80.741600',   '-36.458569',  '8.0',   '3.5'],$
           ['3C144',      '83.633209',    '22.014473',  '596',   '5.0'],$
           ['3C147',      '85.650574',    '49.852009',  '7.5',   '0.3'],$
           ['3C153',      '92.385628',    '48.070999', '1.32',  '3.94'],$
           ['3C196',      '123.40014',    '48.217377',  '4.3',   '2.3'],$
        ['4C 71.07',      '130.35152',    '70.895050',  '2.3',   '7.0'],$
           ['3C207',      '130.19829',    '13.206546',  '1.3',   '3.0'],$
           ['3C216',      '137.38957',    '42.896244',  '1.6',   '1.5'],$
           ['3C219',      '140.28604',    '45.649445',  '2.4',   '3.0'],$
           ['3C245',      '160.68585',    '12.058684', '1.61',  '8.38'],$
     ['PKS1127-145',      '172.52939',   '-14.824274',  '3.8',   '3.5'],$
           ['3C273',      '187.27791',    '2.0523882',   '37',   '3.3'],$
           ['3C274',      '187.70593',    '12.391124',   '71',  '0.48'],$
           ['3C280',      '194.23979',    '47.338806', '1.66',  '7.64'],$
           ['3C286',      '202.78453',    '30.509155', '7.37', '11.09'],$
           ['3C330',      '242.40396',    '65.945915', '2.24',  '3.59'],$
  ['MITGJ1653+3945',      '253.46292',    '39.765278',  '1.6',   '2.7'],$
           ['3C353',      '260.11734',  '-0.97961110', '22.2',   '5.2'],$
         ['3C390.3',      '280.53745',    '79.771423',  '4.4',   '6.0'],$
           ['3C395',      '285.73309',    '31.994917',  '1.5',   '4.0'],$
  ['MITGJ2005+4029',      '301.49249',    '40.487221',  '2.7',   '4.5'],$
  ['MITGJ2016+3714',      '304.10959',    '37.239445',  '3.5',   '7.0'],$
           ['3C452',      '341.45322',    '39.687805', '3.14',  '7.14']]

; CHECK INPUT KEYWORDS...
if (N_elements(lstrange) eq 0) then lstrange = [-12,36]
if (N_elements(lstrange) ne 2) $
   then message, 'LSTRANGE must be 2-element array.'
if (lstrange[1] le lstrange[0]) $
   then message, 'LSTRANGE[0] must be < LSTRANGE[1]'
if (N_elements(charsize) eq 0) then charsize = !p.charsize + (!p.charsize eq 0)
if (N_elements(symsize) eq 0) then symsize=0.75

; DEFINE THE ABSCISSA, THE LST...
; TIME RESOLUTION IS TIME IN HOURS FOR A SPIDER SCAN, WHICH IS ROUGHLY 12M...
if (N_elements(tres) eq 0) then tres = 12.0
nscans = round((lstrange[1]-lstrange[0])/(tres/60.0)) + 1L
lst = findgen(nscans)*(tres/60.0) + lstrange[0]

nsources = (size(polcals))[2]
sources = lindgen(nsources)

; ARE WE ASKING FOR SPECIFIC SOURCES...
if (N_elements(source) gt 0) then begin
    ; DO WE HAVE ANY MATCHES...
    match, reform(polcals[0,sources]), strupcase(source), indx, COUNT=nsources
    if (nsources eq 0) $
       then message, 'None of these sources are polarization calibrators.'
    sources = sources[indx[sort(indx)]]
endif

; DEFINE OUTPUT STRING FOR THE LEGEND...
legend_string = ['(   P,  S) Source',$
                 reform('('+string(float(polcals[4,sources]),FORM='(F4.1)')$
                        +','+$
                        string(round(float(polcals[3,sources])),FORM='(I3)')+$
                        ') '+polcals[0,sources])]

; ADD ASTERISK NEXT TO STABLE SOURCES...
match, reform(polcals[0,sources]), $
       '3C'+['48','66B','93','153','245','280','286','330','452'], $
       stable_indx, COUNT=nstable
if (nstable gt 0) then $
   legend_string[stable_indx+1] = legend_string[stable_indx+1]+' *'

; ESTABLISH PLOT...
plot, [0], /NODATA, $
      XSTYLE=1, XRANGE=lstrange, XTITLE='LST (hr)', $
      YSTYLE=1, YRANGE=[-90,90], YTITLE='PA (deg)', $
      XMARGIN=[23+max(strlen(polcals[0,sources]))$
               +(charsize lt 1)*(2.5)*(1.2/charsize)$
               +keyword_set(CONNECT)*(4.0/(charsize<1.2)),3], $
      CHARSIZE=charsize, _EXTRA=_extra

; ESTABLISH UNIQUE PLOT SYMBOLS AND COLORS...
pa_psym = [1,2,4,5,6,7]
pa_colr = [!red,!orange,!yellow,!green,!blue,!magenta,!p.color]
pa_psym = (reform(rebin(pa_psym,6,8),6*8))[0:nsources-1]
pa_colr = (reform(rebin(pa_colr,7,8),7*8))[0:nsources-1]

; GO THROUGH EACH POLARIZATION CALIBRATION SOURCE AND OVERPLOT THE PA
; SWING...
r2d = 180d0/!dpi
d2r = !dpi/180d0
nup = 0
for j = 0, nsources-1 do begin

    i = sources[j]

    ; GET THE POISITON OF THIS SOURCE...
    ra  = float(polcals[1,i])     ; deg
    ha  = lst*15d0 - ra           ; deg
    dec = float(polcals[2,i])     ; deg

    ; TRANSFORM THE EQUATORIAL COORDINATES TO ALT-AZ...
    hadec2altaz, ha, dec+fltarr(nscans), latitude, el, az

    ; WHEN IS THIS SOURCE UP...
    up = where(el ge 15, n_up)

    ; IF SOURCE IS NOT UP IN THIS LST RANGE, MOVE ON...
    if (n_up eq 0) then begin
       if (N_elements(SOURCE) gt 0) then $
          message, /INFO, polcals[0,i]+' is not up in this LST range.'
       continue
    endif

    ; PARALLACTIC ANGLE IS DEFINED IN RANGE [-180,+180]...
    parangle = -r2d*atan(-sin(d2r*ha[up]),$
                         cos(d2r*dec)*tan(d2r*latitude)-$
                         sin(d2r*dec)*cos(d2r*ha[up]))

    ; FOR EASE OF VIEWING, DISPLAY RESULTS IN RANGE [-90,+90]...
    pa = ((((parangle-90) mod 180) + 180) mod 180) - 90

    ; OVERPLOT THE PA SWING FOR THIS SOURCE...
    oplot, lst[up], pa, SYMSIZE=symsize,$
           PSYM=(1-2*keyword_set(CONNECT))*pa_psym[nup], COLOR=pa_colr[nup], $
           _EXTRA=_extra

    nup = nup+1
    up_index = (nup gt 1) ? [up_index,j] : j
endfor

nsources = N_elements(up_index)
if (nsources eq 0) then return

; PLACE A LEGEND ON THE PLOT TO DETERMINE BEST SOURCES...
legend, legend_string[[0,up_index+1]], /NORMAL, $
        POSITION=[2*float(!d.x_ch_size)/!d.x_vsize*charsize,$
                  1-2*float(!d.y_ch_size)/!d.y_vsize],$
        COLORS=[!p.color,pa_colr[0:nsources-1]], $
        PSYM=(1-2*keyword_set(CONNECT))*[3,pa_psym[0:nsources-1]], $
        CHARSIZE=charsize, PSPACING=2, _EXTRA=_extra

end; find_gbt_polcal
