;+
; make a gif image from the GBTIDL plotter 
;
; <p><B>Contributed by: Jim Braatz</B>
;
; <p>This procedure makes a gif image from the GBTIDL plotter window.
; The procedure depends on the existence of three unix programs:
; xwd, convert, and gifclip.
;
; <p>These programs are available in Green Bank, for example, so makegif
; works on the GB computing systems.
;
; <p>The procedure works only when the user has a single GBTIDL plot window open.
; 
;
; @param filename {in}{optional}{type=string} The GIF fiename to create.
;   If omitted, the gif will be saved to 'mygif.gif'
;
; @keyword notrim {in}{optional}{type=boolean} If set, the GIF image will
;   have a window border from the GBTIDL plotter
; 
; @keyword reverse {in}{optional}{type=boolean} If set, the GIF image will
;   be reversed, with foreground and background colors swapped.
;
; @version $Id$
;-
pro makegif,filename,notrim=notrim,reverse=reverse
 common gbtplot_common,mystate,xarray
 if n_elements(filename) eq 0 then filename = 'mygif.gif'
 print,'Making a GIF image in file ',filename
 widget_control,mystate.main,/show
 reshow
 if n_elements(reverse) ne 0 then begin
   tmp = !g.background
   !g.background = !g.foreground
   !g.foreground = tmp
   reshow
 end
 wait, 1
 spawn,'xwd -name "GBTIDL Plotter" -out temp.xwd'
 spawn,'convert temp.xwd gif:temp.gif'
 spawn,'rm temp.xwd',/sh
 if n_elements(notrim) ne 1 then begin
   jnk = query_gif('temp.gif',gif_info)
   x = gif_info.dimensions[0]-11
   y = gif_info.dimensions[1]-47
   s = "gifclip -q -i 8 52 "+strtrim(string(x),2)+" "+strtrim(string(y),2)+ $
       " temp.gif > "+strtrim(filename,2)
   spawn,s
   spawn,'rm temp.gif',/sh
 end else begin
   spawn,'mv temp.gif '+strtrim(filename,2)
 end
 if n_elements(reverse) ne 0 then begin
   tmp = !g.background
   !g.background = !g.foreground
   !g.foreground = tmp
   reshow
 end
end
