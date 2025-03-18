;+
;
; A brute force method for setting the printer name.  This 
; procedure will need to be modified if the printer names
; or locations change.  Also it will need to be modified
; to make it work for sites other than NRAO-GB and NRAO-CV.
; 
; <p><B>Contributed By: Jim Braatz, NRAO-CV</B>
;
; @param printer {in}{optional}{type=string} printer name
; @keyword domain {in}{optional}{type=string} domain
;
; @examples
; <pre>
;   setprinter               ; attempts to determine the domain name
;                            ;    and then gives the user a choice from
;                            ;    a harcoded list of printers
;   setprinter,'lp'          ; sets the printer name directly
;   setprinter,domain='cv'   ; sets the domain name and then gives
;                            ;    the user a choice of printers
; </pre>
;
; version $Id$
;
;-
pro setprinter, printer, domain=domain

   compile_opt idl2

   if n_elements(printer) ne 0 then begin
      if size(printer, /type) ne 7 then begin
         message,"Usage: setprinter [,printer, domain=domain]",/info
         message," ",/info
         message,"       printer and domain are string variables",/info
         message,"       Use one or the other, not both.",/info
         message,"       example 1: setprinter, 'ops4050'",/info
         message,"       example 2: setprinter, domain='gb'",/info
         return
      endif else begin
         !g.printer = printer
         print,'!g.printer set to ',printer
         return
      endelse
   endif
      
   if n_elements(domain) ne 0 then begin
      if size(domain, /type) ne 7 then begin
         message,"Usage: setprinter [,printer, domain=domain]",/info
         message," ",/info
         message,"       printer and domain are string variables",/info
         message,"       Use one or the other, not both.",/info
         message,"       example 1: setprinter, 'ops4050'",/info
         message,"       example 2: setprinter, domain='gb'",/info
         return
      end
   endif else begin
      spawn,"domainname",domain
   end
   print,'domain = ',domain

   printer = 'none'
   domain = strtrim(domain,2)
   domain = strlowcase(domain)
   if domain eq 'gbt' then domain = 'gb'

   ; Only a few printers in CV and GB are handled in the following code.
   ; Add your own printers and your own site if you like.
   ; Also check for updates, as these names change often.

   if domain eq 'gb' then begin
      pr_name = ['net','lp','pslaser','coltran','ops4050','telops','basement']
      pr_desc = ['Room 234 (BW)', $
                 'Room 105 (BW)', $
                 'Room 105 (color)', $
                 'Room 105 (color)', $
                 'Control room (BW)', $
                 'Control room (color)', $
                 'Basement terminal room (BW)' ]
   end

   if domain eq 'cv' then begin
      pr_name = ['ps1','ps1color','ps2','ps3e','ps3f']
      pr_desc = ['Room ER-114 (BW)', $
                 'Room ER-114 (color)', $
                 'Room ER-210 (BW)', $
                 'Room ER-333 (BW)', $
                 'Room ER-349 (BW)' ]
   end

   ; Define your own site printers and descriptions here, using the
   ; above code as a template

   if n_elements(pr_name) gt 0 then begin
      print,' '
      print,' ID  Name       Location'
      print,'--------------------------------------------------'
      for i=0,n_elements(pr_name)-1 do $
         print,i,pr_name[i],pr_desc[i],format='("  ",I-3,A-10," : ",A-30)'
      print,''
      read,'Choose a printer ID (integer) -> ',pr
      pr = round(pr)
      if pr lt 0 or pr ge n_elements(pr_name) then begin
         message,"Illegal entry.",/info
      endif else begin
         printer=pr_name[pr]
      end
   endif else begin
      print, "No printers found.  Modify the setprinter.pro code or use !g.printer = 'printer_name'"
   endelse

   !g.printer = printer
   print,'Printer set to ',printer

end
