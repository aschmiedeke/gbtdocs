; docformat = 'rst'

;+
; Fit a baseline to the contents of the dc argument with various options.
;
; This fits a set of orthogonal polynomials with a maximum order given by 
; the ``nfit`` argument to the data values in dc.  The range of channels to use
; is given by the ``regions`` and ``nregion`` arguments. The parameters of the fit
; are placed in the value of the polyfit argument and the rms values of the
; fits are placed in the polyrms argument.  If there is a problem, the return
; value is 0, otherwise the return value is 1.
;
; :Params:
;   dc : in, required, type=data container
;       The data container to use.  The values to fit come from ``*dc.data_ptr``.
;   nfit : in, required, type=integer
;       The order of polynomial to fit.
;   regions : in, required, type=2D array
;       Array describing the regions to use in the fit, along with nregion. 
;       This has the same properties as the !g.region field in the guide 
;       structure.
;   nregion : in, required, type=integer
;       The number of regions in regions to actually use.
;   polyfit : out, type=double array
;       Parameters describing the polynomials.  Array with (nfit+1) elements.
;       See :idl:pro:`ortho_fit` for more details.
;   polyrms : out, type=double array
;       RMS values, one for each polynomial (nfit+1).
;
; :Returns:
;   1 on success, 0 on failure.
;
; :Examples:
;
;   .. code-block:: IDL
; 
;       ok = dcbaseline(!g.s[0], 2, !g.regions, !g.nregion, polyfit, polyrms)
; 
; :Uses:
;   :idl:pro:`DATA_VALID`
;   :idl:pro:`get_chans`
;   :idl:pro:`ortho_fit`
; 
;-
function dcbaseline, dc, nfit, regions, nregion, polyfit, polyrms
   compile_opt idl2

   if (data_valid(dc) lt 1) then begin
       message, 'The data container to be fit has no valid data in it.', /info
       return, 0
   endif

   if (nfit < 0) then begin
       message, 'nfit must be >= 0', /info
       return, 0
   endif

   chans = get_chans(dc, nregion, regions)
   if (chans[0] < 0) then begin
       message, 'The nregions are invalid',/info
       return, 0
   endif
   indx = where(finite((*dc.data_ptr)[chans]))
   if indx[0] lt 0 then begin
       message,'No unblanked data in those regions, nothing to fit',/info
       return, 0
   endif
   chans = chans[indx]
   polyfit = ortho_fit(chans,(*dc.data_ptr)[chans], nfit, cfit, polyrms)
   return, 1
end
