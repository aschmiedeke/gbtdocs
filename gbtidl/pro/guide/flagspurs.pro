; docformat = 'rst'

;+
; Set the flags for the VEGAS spurs in the currently opened input data
; source (either a single sdfits file or a directory). 
;
; VEGAS produces spurs (spikes) at channels corresponding to
; integer multiples of the ADC sampler frequency divided by 64.  The
; normal behavior of sdfits is to flag these channels when the data
; are filled (use :idl:pro:`listflags` to see the list of
; flags for the currently opened input data set). This routine can be
; used to recreate those flags if the original flag file has been lost
; or corrupted.
;
; A spur is also produced at the center channel (NCHAN/2 when
; counting from 0).  That spur does not arise in the ADC in VEGAS and
; so does not move as the spectral window is tuned across the ADC
; bandpass. This routine does not flag that spur.  Normal
; sdfits use will replace that spur with the average of the two
; adjacent channels and so it generally is not necessary to flag that
; spur.  Since that spur does not move as the spectral window is tuned
; it can be flagged using the standard flag command if necessary.
;
; The routine first unflags all flags with the idstring "VEGAS_SPUR"
;
; This routine expects to encounter uncalibrated VEGAS data filled
; by sdfits.  It checks that there is both an ``SDFITVER`` keyword and an
; ``INSTRUME`` keyword on the primary header of all SDFITS files.  The
; value of the ``INSTRUME`` keyword must be "VEGAS".
;
; This spur locations are determined using the ``VSPDELT``, ``VSPRPIX``,
; and ``VSPRVAL`` columns.  For data filled using older versions of
; sdfits, these values are not present in the SDFITS tables. Such
; older data should be refilled using the most recent version of
; sdfits to make use of this procedure.
; 
; :Keywords:
;   flagcenteradc : in, optional, type=boolean
;       When set, the center ADC spur is also flagged.  Normally that 
;       spur is left unflagged because sdfits usually replaces the value
;       at that location with an average of the two adjacent channels
;       and so that spur does not need to be flagged since it's been
;       interpolated.
;
;-
pro flagspurs, flagcenteradc=flagcenteradc
  compile_opt idl2

  if not !g.line then begin
     message,'This does not work in continuum mode, sorry.', level=-1,/info
     return
  endif

  if not !g.lineio->is_data_loaded() then begin
     message,'No line data is attached yet, use filein, dirin, online, or offline', level=-1, /info
     return
  endif

  !g.lineio->reflag_vegas_spurs, flagcenteradc=flagcenteradc
end
