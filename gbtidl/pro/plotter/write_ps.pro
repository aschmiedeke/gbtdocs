; docformat = 'rst'

;+
; This procedure writes a postscript file that reproduces the spectrum
; in the plotter.  To send the postscript directly to a printer, use
; :idl:pro:`print_ps`.
;
; :Params:
;   filename : in, optional, type=string
;       The postscript filename can be specified using this parameter. 
;       If omitted, the file will be called 'gbtidl.ps' unless /prompt
;       is used.
;
; :Keywords:
;   portrait : in, optional, type=boolean
;       If set then the postscript will be generated in portrait mode 
;       instead of the default landscape mode.
;
;   prompt : in, optional, type=boolean
;       When set, a file chooser dialogue is used to set the file name, 
;       even if filename was set as an argument.
;
; :Examples:
; 
;   .. code-block:: IDL
;   
;       write_ps,'myplot.ps'
; 
;-
pro write_ps,filename, portrait=portrait, prompt=prompt
    if n_elements(filename) eq 0 then thisfilename='gbtidl.ps' else thisfilename=filename
    if keyword_set(prompt) then thisfilename = dialog_pickfile(file=thisfilename,/write)
    show_support, /postscript, filename=thisfilename, /reshow, portrait=portrait
end
