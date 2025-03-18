;+
; Convert the x quantities in the plotter's state, including xarray,
; to the new xunits, frame, veldef, absrel and voffset values from 
; the current values.  This procedure is not intended to be called 
; by users.
;
; @param tounits {in}{required}{type=string} the desired units.
; @param toframe {in}{required}{type=string} the desired frame.
; @param toveldef {in}{required}{type=string} the desired velocity
; definition.
; @param toabsrel {in}{required}{type=string} the desired absrel
; @param tovoffset {in}{required}{type=double} the desired velocity
; offset (TRUE, m/s) to apply to frequency and velocity values.
; value.
;
; @private_file
;
; @version $Id$
;-
pro convertxstate, tounits, toframe, toveldef, toabsrel, tovoffset
    compile_opt idl2
    common gbtplot_common, mystate, xarray

    ; we might be able to just scale the x values
    needsFullConvert = 1
    parsexunit, tounits, toscale, totype
    parsexunit, mystate.xunit, curscale, curtype

    if (tounits ne mystate.xunit) then begin
        if (curtype eq totype and $
            toframe eq mystate.frame and $
            toveldef eq mystate.veldef and $
            toabsrel eq mystate.absrel and $
            tovoffset eq mystate.voffset) then begin
            ; just rescale the x-values
            rescale = (curscale / toscale)
            mystate.xscale = toscale

            mystate.xrange *= rescale
            if (mystate.nzooms gt 0) then begin
                mystate.zoom1[0:(mystate.nzooms-1),0] *= rescale
                mystate.zoom2[0:(mystate.nzooms-1),0] *= rescale
            endif

            if (mystate.nmarkers gt 0) then (*mystate.marker_pos)[0:(mystate.nmarkers-1),0] *= rescale

            if (mystate.nvlines gt 0) then (*mystate.vline_pos)[0:(mystate.nvlines-1),0] *= rescale

            for i=0,mystate.n_annotations-1 do begin
                if (not (*mystate.ann_normal)[i]) then (*mystate.xyannotation)[i,0] *= rescale
            endfor

            thisptr = mystate.oplots_ptr
            while (ptr_valid(thisptr)) do begin
                if strlen((*thisptr).fnname) eq 0 then begin
                    ; only necessary for non-function overplots
                    (*thisptr).x *= rescale
                endif
                thisptr = (*thisptr).next
            endwhile

            thisptr = mystate.oshows_ptr
            while (ptr_valid(thisptr)) do begin
                (*thisptr).x *= rescale
                thisptr = (*thisptr).next
            endwhile

            xarray = xarray * rescale
            mystate.xoffset *= rescale
            needsFullConvert = 0
            mystate.xunit = tounits
            setxtitle, totype
        endif
    endif


    if (needsFullConvert) then begin

        toxoffset = 0.0d
        if (toabsrel eq 'Rel') then toxoffset = newxoffset(totype, toscale, toframe, toveldef)
            
        mystate.xrange = convertxvalues(*mystate.dc_ptr, mystate.xrange, curscale, curtype, $
                                        mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset, $
                                        toscale, totype, toframe, toveldef, toxoffset, tovoffset)
        thisptr = mystate.oplots_ptr
        while (ptr_valid(thisptr)) do begin
            (*thisptr).x = convertxvalues(*mystate.dc_ptr, (*thisptr).x, curscale, curtype, $
                                          mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset, $
                                          toscale, totype, toframe, toveldef, toxoffset, tovoffset)
            thisptr = (*thisptr).next
        endwhile

        thisptr = mystate.oshows_ptr
        while (ptr_valid(thisptr)) do begin
            (*thisptr).x = convertxvalues(*(*thisptr).dc_ptr, (*thisptr).x, curscale, curtype, $
                                          mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset, $
                                          toscale, totype, toframe, toveldef, toxoffset, tovoffset)
            thisptr = (*thisptr).next
        endwhile

        if (mystate.xrange[0] gt mystate.xrange[1]) then begin
            tmp = mystate.xrange[0]
            mystate.xrange[0] = mystate.xrange[1]
            mystate.xrange[1] = tmp
        endif
        if (mystate.nzooms gt 0) then begin
            mystate.zoom1[0:(mystate.nzooms-1),0] = $
                 convertxvalues(*mystate.dc_ptr, mystate.zoom1[0:(mystate.nzooms-1),0], curscale, curtype, $
                                mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset, $
                                toscale, totype, toframe, toveldef, toxoffset, tovoffset)
            mystate.zoom2[0:(mystate.nzooms-1),0] = $
                 convertxvalues(*mystate.dc_ptr, mystate.zoom2[0:(mystate.nzooms-1),0], curscale, curtype, $
                                mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset, $
                                toscale, totype, toframe, toveldef, toxoffset, tovoffset)
        endif

        if (mystate.nmarkers gt 0) then begin
            (*mystate.marker_pos)[0:(mystate.nmarkers-1),0] = $
                 convertxvalues(*mystate.dc_ptr, (*mystate.marker_pos)[0:(mystate.nmarkers-1),0], curscale, curtype, $
                                mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset, $
                                toscale, totype, toframe, toveldef, toxoffset, tovoffset)
        endif


        if (mystate.nvlines gt 0) then begin
            (*mystate.vline_pos)[0:(mystate.nvlines-1),0] = $
                 convertxvalues(*mystate.dc_ptr, (*mystate.vline_pos)[0:(mystate.nvlines-1),0], curscale, curtype, $
                                mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset, $
                                toscale, totype, toframe, toveldef, toxoffset, tovoffset)
        endif


        if (mystate.n_annotations gt 0) then begin
            normed = where((*mystate.ann_normal)[0:(mystate.n_annotations-1)],normcount,complement=nonnormed)
            if (normcount ne mystate.n_annotations) then begin
                (*mystate.xyannotation)[nonnormed,0] = $
                    convertxvalues(*mystate.dc_ptr, (*mystate.xyannotation)[nonnormed,0], curscale, curtype, $
                                   mystate.frame, mystate.veldef, mystate.xoffset, mystate.voffset, $
                                   toscale, totype, toframe, toveldef, toxoffset, tovoffset)
            endif
        endif


        ; finally set the state values and then xarray
        mystate.xunit = tounits
        mystate.frame = toframe
        mystate.veldef = toveldef
        mystate.absrel = toabsrel
        mystate.xtype = totype
        mystate.xscale = toscale
        mystate.xoffset = toxoffset
        mystate.voffset = tovoffset

        !g.plotter_axis_type = mystate.xtype

        setxarray
    endif
end
