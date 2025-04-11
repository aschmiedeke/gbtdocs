; docformat = 'rst'

;+
; This procedure clears all data in the plotter and erases the plotter
; screen.
;
; :Examples:
;   
;   ..code-block:: IDL
; 
;       getps,10
;       show
;       clear
;
;-
pro clear
   common gbtplot_common,mystate,xarray
   clearoplotslist
   clearoshowslist
   clearvlines,/noshow
   clearmarks,/noshow
   clearannotations,/noshow

   a = data_new()
   data_copy, a, *mystate.dc_ptr
   data_free, a
   
   if not widget_info(mystate.main,/valid_id) then return

   oldwin=!d.window
   wset,mystate.pix_id
   erase
   wset,mystate.win_id
   erase
   wset,oldwin
end
