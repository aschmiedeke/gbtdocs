; ccb_reduction.pro
;
; set up global variables
;  don't write files or plots to disk...

proj='AGBT06A_049_09'
setccbpipeopts, gbtproj=proj, ccbwritefiles=0, gbtdatapath='/home/archive/science-data/tape-0016/'

; to use postprocessing scripts, set ccbwritefiles=1

; a good color table for the plots:
loadct, 12

; create an array indexing scan numbers
;  to file name
indexscans, si

; summarize the project
summarizeproject

; read a nod observation from scan 12
readccbotfnod, si[12], q

; fit the data, binning integrations to 0.5sec bins
fitccbotfnod, q, qfit, bin=0.5

; the resulting plot shows the differenced
;  data (white) and the fit to the data (green)
;  for each of 16 CCB ports. (the first 8 are blank)

; look at the next nod that just came in
;  this time calibrate to antenna temperature
;  before plotting
; First you need to derive a calibration, which
;  requires a scan with both cals firing independently.
; /dogain tells the code to solve for the calibration;
;  the results are stored in calibdat, which we can
;  pass into subsequent invocations of the calibration.
indexscans, si
readccbotfnod, si[13], q
calibtokelvin, q, /dogain, calibdat=calibdat
fitccbotfnod, q

; the scan index si must be updated to read in scans
;  collected after it was first created
indexscans, si
readccbotfnod, si[14], q

; and calibrate to kelvin using the information
;  we just derived
calibtokelvin, q, calibdat=calibdat

; fit/plot
fitccbotfnod,q

; et cetera...

