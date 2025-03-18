;+
; This procedure writes a postscript file that reproduces the spectrum
; in the plotter.  To send the postscript directly to a printer, use
; <a href="print_ps.html">print_ps</a>.
;
; @param filename {in}{optional}{type=string} The postscript filename 
; can be specified using this parameter.  If omitted, the file will 
; be called 'gbtidl.ps' unless /prompt is used.
;
; @keyword portrait {in}{optional}{type=boolean} If set then 
; the postscript will be generated in portrait mode instead of the 
; default landscape mode.
;
; @keyword prompt {in}{optional}{type=boolean} When set, a file
; chooser dialogue is used to set the file name, even if filename was
; set as an argument.
;
; @examples
;    write_ps,'myplot.ps'
; 
; @uses <a href="../../devel/plotter/show_support.html">show_support</a>
;
; @version $Id$
;-

pro write_ps,filename, portrait=portrait, prompt=prompt
    if n_elements(filename) eq 0 then thisfilename='gbtidl.ps' else thisfilename=filename
    if keyword_set(prompt) then thisfilename = dialog_pickfile(file=thisfilename,/write)
    show_support, /postscript, filename=thisfilename, /reshow, portrait=portrait
end
