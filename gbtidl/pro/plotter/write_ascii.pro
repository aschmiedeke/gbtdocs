; docformat = 'rst'

;+
; This procedure writes the data in the displayed spectrum to an ASCII
; file.  See the documentation in :idl:pro:`dcascii` for an explanation
; of the format of the output.
;
; :Params:
;   filename : in, optional, type=string
;       The filename can be specified using this parameter. If omitted,
;       the file will be called 'gbtidl.ascii' unless /prompt is used.
;
; :Keywords:
;   brange : in, optional, type=integer, default=0
;       The beginning of the range to be written, in units of the current
;       plotter X-axis.
;
;   erange : in, optional, type=integer, default=0
;       The end of the range to be written, in units of the current 
;       plotter X-axis.
;
;   prompt : in, optional, type=boolean
;       When set, a file chooser dialogue is used to set the file name, 
;       even if filename was set as an argument.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       write_ascii,'mydata.txt'
;
; :Uses:
;   :idl:pro:`dcascii`
;
;-
pro write_ascii,filename,brange=brange,erange=erange,prompt=prompt
	common gbtplot_common,mystate,xarray
	if n_elements(filename) eq 0 then thisfilename='gbtidl.ascii' else thisfilename=filename
	if keyword_set(prompt) then thisfilename = dialog_pickfile(file=thisfilename,/write)
        dcascii,file=thisfilename,brange=brange,erange=erange
end
