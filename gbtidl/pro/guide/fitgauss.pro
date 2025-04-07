; docformat = 'rst'

;+
; An interactive procedure that allows the user to fit gaussians.
;
; The user should first subtract a baseline from the data prior to
; using this procedure.  Next, use the plotter zoom feature to narrow
; in on the region of interest.  Then run fitgauss.  Click the left
; mouse button to mark the regions to be considered in the fit.  Then
; click the middle mouse button, twice for each gaussian to be fit,
; first at the (guessed) peak of the  line, and then at the half-power
; point.  Repeat the middle mouse clicks as  many times as you like to
; fit multiple components.  Finally click the right mouse button to
; actually do the fit and display the results. 
;
; Each guassian (middle mouse clicks) must be found in an already
; set region (left mouse button).  Use the right mouse button to exit
; at any time (will require 2 right clicks to quit the procedure in
; the middle of a step - marking a region or identifying a gaussian).
;
; :Params:
;   fit : out, optional, type=array
;       An output array giving the results of the fit. Also stored in
;       !g.gauss.fit.
;   fitrms : out, optional, type=array
;       An output array giving the uncertainties of the fit.  Also stored
;       in !g.gauss.fitrms.
; 
; :Keywords:
;   modelbuffer : in, optional, type=long, default=-1
;       The buffer number to hold the resulting model. If not set 
;       (the default) then the model is not saved to a global buffer.
;   highlightcolor : in, optional, type=color, default=!g.highlightcolor
;       The color to use after the region of interest has been selected
;       to highlight the data.
;
; :Examples:
; 
;   .. code-block:: IDL
; 
;       fitgauss,modelbuffer=10   ; fit gaussian and store model in buffer 10
;       show
;       subtract,0,10,11          ; store residual in buffer 11
;       oshow, 11                 ; overlay residual
;       oshow, 10, color=!yellow  ; overlay gaussian model
; 
;-
pro fitgauss, fit, fitrms, modelbuffer=modelbuffer, highlightcolor=highlightcolor

    ; init output
    fit = -1
    fitrms = -1

    npts = !g.line ? data_valid(!g.s[0]) : data_valid(!g.c[0])
    if npts le 0 then begin
        message,'No valid data in primary data container',/info
        return
    endif
    data = !g.line ? *!g.s[0].data_ptr : *!g.c[0].data_ptr
    allChans = dindgen(npts)

    if n_elements(highlightcolor) eq 0 then highlightcolor=!g.highlightcolor

    clearovers

    print, "**********************************************************"
    print, "Instructions for fitgauss procedure:"
    print, "Left Mouse Button: to mark regions to be fit."
    print, "Center Mouse Button: to mark initial guesses (center then width)"
    print, "Right Mouse Button: to calculate and show fits"
    print, "**********************************************************"
   
    start_state = 0
    region_state = 1
    ready_state = 2
    gauss_state = 3
    done_state = 4

    state = start_state

    new_region = dblarr(2)
    nregions = 0
    ngauss = 0
    
    new_gauss = dblarr(3)

    clearoplots
    
    while (state ne done_state) do begin
    
        ; wait for mouse press
        c = click(/nocrosshair)
        
        ; there are several places where the nearest channel is useful
        ichan = round(c.chan)
        
;        if (nregions gt 0) then print, "Current regions: ", regions
        
        case state of
            ; just started
            start_state: begin
                case c.button of
                    ; left - mark out left region and transition
                    1: begin
                        new_region[0] = ichan
                        state = region_state
                    end    
                    ; middle - not allowed
                    2: print, 'must select a region first'
                    ; right - let the user quite
                    4: state = done_state
                    else: ; do nothing
                endcase    
            end    
            ; must finish marking region 
            region_state: begin
                case c.button of
                    ; left - finish region and transition
                    1: begin
                        ; new point cant appear in an existing region
                        overlap_check,nregions,regions,ichan,no_overlap
                        if no_overlap then begin
                            if (ichan lt new_region[0]) then begin
                                ; region entered backwards, thats okay
                                new_region[1] = new_region[0]
                                new_region[0] = ichan
                            endif else begin
                                new_region[1] = ichan
                            endelse
                            ; append this new region to the list of regions
                            if (nregions eq 0) then begin
                                regions=[new_region]
                            endif else begin
                                regions=[regions,new_region]
                            endelse    
                            nregions += 1
                            print, "Limits accepted for region ",nregions
                            gbtoplot, seq(new_region[0],new_region[1]), data[new_region[0]:new_region[1]], color=highlightcolor, /chan
                            state = ready_state
                        endif else begin
                            print, 'Ending overlaps with other regions, try again.'
                        endelse
                    end
                    ; middle - not allowed
                    2: print, 'Must finish or quit region first.'
                    ; right - quit region
                    4: begin
                        print, 'Quiting region marking, right click again to quit procedure'
                        state = ready_state
                    end
                    else: ; do nothing
                endcase 
            end
            ; can do anything from here 
            ready_state: begin
                case c.button of
                    ; left - start a new region
                    1: begin
                        ;start of new region cant be within a pre-existing region
                        overlap_check,nregions,regions,ichan,no_overlap
                        if no_overlap then begin
                            new_region[0] = ichan
                            state = region_state
                        endif else begin
                            print, 'Cannot start a new region inside pre-existing one'
                        endelse    
                    end    
                    ; middle - start a new gauss
                    2: begin
                        ; is this inside a region, and which one?
                        find_region,nregions,regions,c.chan,r
                        if (r eq -1) then begin
                            print, "Warning: this Gaussian is not inside any of the regions."
                        endif
                        new_gauss[0] = c.y
                        new_gauss[1] = c.chan
                        state = gauss_state
                    end    
                    ; right - exit
                    4: begin
                       state = done_state
                    end   
                    else: ; do nothing
                endcase 
            end
            ; must finish marking gauss 
            gauss_state: begin
                case c.button of
                    ; left - not allowed
                    1: print, 'Must finish marking gauss width or quit Gauss marking first.'
                    ; middle
                    2: begin
                        ; is this inside the right region?
                        find_region,nregions,regions,c.chan,r
                        if (r eq -1) then begin
                            print, "Warning: this Gaussian is not inside any of the regions."
                        endif  
                         ; trust that the user got it right, work in pixels
                        new_gauss[2] = 2.0*abs(new_gauss[1]-c.chan)
                        ; add a new guass
                        if (ngauss eq 0) then gauss=[new_gauss] else gauss=[gauss,new_gauss]
                        ngauss += 1
                        print, 'Guesses accepted for gaussian ',ngauss
                        state = ready_state
                    end
                    ; right - quit gauss marking
                    4: begin
                        print, 'Quitting Gauss marking, right click again to quit procedure'
                        state = ready_state
                    end
                    else: ; do nothing
                endcase    
            end
            else: ; do nothing
        endcase
        
    endwhile
    
    ; set guide structure using the local variables we just set up
    !g.gauss.nregion = nregions
    !g.gauss.ngauss = ngauss
    if (nregions ne 0) then gregion, regions
    if (ngauss ne 0) then begin
        for i=0,ngauss-1 do begin
            gparamvalues,i, gauss[(i*3):(i*3)+2]
        endfor
    endif 

    if (ngauss gt 0) then begin
        ; fit these gaussians!
        gauss, fit, fitrms, modelbuffer=modelbuffer
        ; plot results
        gshow, modelbuffer=modelbuffer
    endif
    
end
