;+
; Fit a polynomial baseline to the contents of the primary data
; container (the PDC, buffer 0) and  optionally overplot that fit on
; to the current plot. 
;
; <p>This fits a set of orthogonal polynomials with a maximum order
; given by the !g.nfit value to the data values in the primary data
; container.  The range of channels to use is given by !g.regions and
; !g.nregion. The parameters of the fit are placed in to !g.polyfit
; and the polynomial is evaluated over all channels.  That evaluation
; is placed into the data container at modelbuffer (see the comments
; for that keyword for more details), which is otherwise  a copy of
; the header information in global buffer 0.
;
; @keyword nfit {in}{optional}{type=integer} The order of polynomial
; to fit.  Defaults to !g.nfit.  If set, then this also sets the value
; of !g.nfit.  
;
; @keyword noshow {in}{optional}{type=boolean} If set, the result is
; not shown (overplotted).  If the plotter is frozen, then nothing is
; overplotted even if this keyword is not set.
;
; @keyword modelbuffer {in}{optional}{type=integer} The buffer number
; to hold the fit evaluated at all channels (the model).  If not set  
; then no global buffer will hold the model after this procedure is
; used.
;
; @keyword ok {out}{optional}{type=boolean} This is set to 1 on
; success and 0 on failure.  
;
; @keyword color {in}{optional}{type=color} The color to use when
; overplotting the baseline fit.  This defaults to the same default
; used by <a href="../plotter/gbtoplot.html">gbtoplot</a>
;
; @examples
; <pre>
; ; fit, using the value of !g.nfit, set using nfit
; nfit,3
; bshape
; ; Or specify an nfit here, keeping the fit in buffer 10
; bshape,nfit=3, modelbuffer=10
; </pre>
;
; @uses <a href="../toolbox/dcbaseline.html">dcbaseline</a>
; @uses <a href="getbasemodel.html">getbasemodel</a>
; @uses <a href="../toolbox/data_valid.html">data_valid</a>
; @uses <a href="bmodel.html">bmodel</a>
;
; @version $Id$
;-
pro bshape, nfit=nfit, noshow=noshow, modelbuffer=modelbuffer, ok=ok, color=color
   compile_opt idl2

   ok = 0

   npts = !g.line ? data_valid(!g.s[0]) : data_valid(!g.c[0])
   if (npts lt 1) then begin
       message, 'no data in the primary data container', /info
       return
   endif

   if (n_elements(modelbuffer) eq 0) then modelbuffer=-1

   maxbuffer = !g.line ? n_elements(!g.s) : n_elements(!g.c)
   if (modelbuffer gt maxbuffer) then begin
       message, 'requested model buffer does not exist', /info
       return
   endif

   if (n_elements(nfit) eq 0) then nfit = !g.nfit
   if ((nfit+1) gt n_elements(!g.polyfitrms)) then begin
       message, 'nfit is too large', /info
       return
   endif
   !g.nfit = nfit

   if (!g.line) then begin
       ok =  dcbaseline(!g.s[0], nfit, !g.regions, !g.nregion, polyfit, polyrms)
   endif else begin
       ok =  dcbaseline(!g.c[0], nfit, !g.regions, !g.nregion, polyfit, polyrms)
   endelse
   if (not ok) then begin
       message, 'there was a problem with the fit',/info
       return
   endif
   !g.polyfit[*,0:nfit] = polyfit
   !g.polyfitrms[0:nfit] = polyrms
   !g.nfit = nfit
   if (modelbuffer ge 0) then begin
       bmodel,modelbuffer=modelbuffer,nfit=nfit
       modelfit = getdata(modelbuffer)
   endif else begin
       modelfit = getbasemodel(nfit=nfit)
   endelse 

   if not keyword_set(noshow) then gbtoplot, modelfit, /chan, color=color

   ok = 1
end
