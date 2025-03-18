;+
; Special class whose sole purpose is just to calclulate the if numbers for
; a given scan and its info
; @file_comments
; Special class whose sole purpose is just to calclulate the if numbers for
; a given scan and its info
; @private_file
;-

PRO if_filler__define

    iff = { IF_FILLER, debug:0L }

END


FUNCTION IF_FILLER::init
    compile_opt idl2, hidden

    return, 1

END

PRO IF_FILLER::cleanup
    compile_opt idl2, hidden

END

PRO IF_FILLER::set_debug_on
    compile_opt idl2, hidden
    
    self.debug = 1

END

PRO IF_FILLER::set_debug_off
    compile_opt idl2, hidden
    
    self.debug = 0

END

FUNCTION IF_FILLER::get_if_numbers, scan_rows, names, ints, index_start, index_end
    compile_opt idl2

    catch, error
    if (error ne 0) then begin
        
        print, !error_state.msg
        print, "IF number assigned to -1 for records",index_start,":",index_end," (scan",scan_rows[0].scan,")",format='(a38,i5,a1,i5,a6,i5,a1)'

        return, lonarr( n_elements(scan_rows) ) - 1
    endif

    n_rows = n_elements(scan_rows)
    
    ; create the array to hold the if number for each sdfits row
    ifs = lonarr(n_rows)-1

    ; get basic info about this scan - samplers, polarizations, beams
    frontend = scan_rows[0].frontend
    samplers = scan_rows.sampler
    uniq_samplers = self->get_uniques(samplers,num_samplers)
    pols = scan_rows.crval4
    uniq_pols = self->get_uniques(pols,num_pols)
    beams = scan_rows.feed
    uniq_beams = self->get_uniques(beams,num_beams)

    ; find what the tunnings are for each sampler
    ; only look at the rows from the first integration
    first_int_rows = scan_rows[where(ints[0] eq ints)]
    
    ; see if there is sig column for these rows
    sig = self->get_row_value(scan_rows[0],'SIG',{blank:''},names,'U')
    if (sig eq 'U') then use_sig=0 else use_sig=1
    
    ; if there is a signal column, only use those columns for which we are on signal
    if use_sig then begin
       sigs = first_int_rows.sig
       first_int_rows = first_int_rows[where(sigs eq 'T')]
    endif
    
    ; number of ifs is unique tuples of: (CRVAL1, CTYPE1, CDELT1, and CRPIX1) for only scans
    ; of first integration & sig == 'T'
    n_crval1 = self->get_col_variability(first_int_rows,'CRVAL1',names,1)
    n_type1 = self->get_col_variability(first_int_rows,'CTYPE1',names,1)
    n_cdelt1 = self->get_col_variability(first_int_rows,'CDELT1',names,1)
    n_crpix1 = self->get_col_variability(first_int_rows,'CRPIX1',names,1)
    n_if_tunings_test = n_crval1*n_type1*n_cdelt1*n_crpix1
    
    ; start newest algorithm here:
    ; get arrays of the above mentioned four columns FOR ALL ROWS of this scan
    ctypes = self->get_row_value(scan_rows,'CTYPE1',{blank:''},names,'U')
    crvals = self->get_row_value(scan_rows,'CRVAL1',{blank:''},names,1.0)
    cdelts = self->get_row_value(scan_rows,'CDELT1',{blank:''},names,1.0)
    crpixs = self->get_row_value(scan_rows,'CRPIX1',{blank:''},names,1.0)

    ; translate the ctype string values into integer values
    sorted_ctypes = ctypes[sort(ctypes)]
    unique_ctypes = sorted_ctypes[uniq(sorted_ctypes)]
    ctype_codes = lonarr(n_rows)
    for i=0,n_elements(unique_ctypes)-1 do begin
        ind = where(ctypes eq unique_ctypes[i])
        ctype_codes[ind] = i+1
    endfor

    ; create an array which is the product of all these arrays: this
    ; is equivalent to showing the unique combinations of these values
    all_tunings = ctype_codes * crvals * cdelts * crpixs
    
    ; use only the first integrations
    first_int_tunings = all_tunings[where(ints[0] eq ints)]
    
    if self.debug then print, "first int tunings:", first_int_tunings, format='(a10,2x,e50.26)'
    
    ; collapse the columns where sig == 'T'
    if use_sig then begin
        if_tunings = first_int_tunings[where(sigs eq 'T')]
    endif else begin
        if_tunings = first_int_tunings
    endelse

    ; see how many unique if numbers we should have
    unique_tunings = self->get_uniques(if_tunings, n_if_tunings)
    unsorted_unique_if_tunings = if_tunings[uniq(if_tunings)]

    ; check this number of ifs with the first estimate
    if (n_if_tunings ne n_if_tunings_test) then message, "error in calculating if tunings"

   ; rearrange the unique tunings to be in the right order: 1,2,...
    start_pos = lonarr(n_if_tunings)
    for i=0,n_if_tunings-1 do begin
        ind = where(unique_tunings[i] eq all_tunings)
        start_pos[i] = ind[0]
    endfor
    sorted_start_pos = start_pos[sort(start_pos)]
    tmp = dblarr(n_if_tunings)
    for i=0, n_if_tunings-1 do begin
        ind = where(sorted_start_pos[i] eq start_pos)
        tmp[i] = unique_tunings[ind]
    endfor
    unique_tunings = tmp
    
    if self.debug then begin 
        print, "num tunings: "+string(n_if_tunings)
        print, "unique if tunings: ", unique_tunings
    endif 

    ; move tunings associated with unknown polarization (0) to end of list
    uniqueZeroPols = where(uniq_pols eq 0, count)
    if count gt 0 then begin
        ; some exist
        zeroPolRows = where(pols eq 0)
        allTuningsWithZeroPol = all_tunings[zeroPolRows]
        uniqAllTuningsWithZeroPol = self->get_uniques(allTuningsWithZeroPol,count)
        numDeferred = 0
        numOK = 0
        newUniqueTunings = unique_tunings
        for i=0,n_if_tunings-1 do begin
            thisTuning = unique_tunings[i]
            tmp = where(thisTuning eq uniqAllTuningsWithZeroPol,count)
            if count gt 0 then begin
                numDeferred += 1
                newUniqueTunings[n_if_tunings-numDeferred] = thisTuning
            endif else begin
                numOK += 1
                newUniqueTunings[numOK-1] = thisTuning
            endelse
        endfor
        unique_tunings = newUniqueTunings
    endif
    
    check_for_degeneracy = 1

    ; fill if numbers not worrying about degeneracy
    if check_for_degeneracy eq 0 then begin
    
        for i=0,n_if_tunings-1 do begin
            ind = where(all_tunings eq unique_tunings[i],count)
            if self.debug then print, "unique indicies: ", ind
            if_samplers = self->get_uniques(samplers[ind],nif_samplers)
            for j=0,nif_samplers-1 do begin
                sampler_inds = where(samplers eq if_samplers[j])
                if self.debug then print, "sampler_inds: ", sampler_inds
                ifs[sampler_inds] = i
            endfor ; for each if sampler
        endfor ; for each tuning
        
    endif else begin

        ; the way more complicated case!
        ; apply rules of degeneracy to each row of beams
        for bi=0,num_beams-1 do begin
            current_beam = uniq_beams[bi]
            beam_scan_rows = scan_rows[where(beams eq uniq_beams[bi])] 
            beam_tunings = all_tunings[where(beams eq uniq_beams[bi])] 
            
            if self.debug then print, "beam number:", bi, format='(a13,x,i3)'

            ; for each tuning, check the rules:
            ; no two samplers should have the same polarization
            ; an if should not mix circular and linear polarizations
            if_num = 0
            num_ifs = 0
            for ti=0,n_elements(unique_tunings)-1 do begin
                tuning_inds = where(beam_tunings eq unique_tunings[ti],count)
                if self.debug then print, "unique indicies: ", tuning_inds
                ; get the samplers for this tuning
                ; don't sort the array of sampler names, sdfits already puts them in the right order 
                beam_samplers = beam_scan_rows[tuning_inds].sampler
                beam_samplers = beam_samplers[uniq(beam_samplers)]
                n_beam_samplers = n_elements(beam_samplers)
                ; make sure we didn't screw up
                test_beam_samplers = self->get_uniques(beam_scan_rows[tuning_inds].sampler)
                if n_beam_samplers ne n_elements(test_beam_samplers) then begin
                    beam_samplers = test_beam_samplers
                    n_beam_samplers = n_elements(test_beam_samplers)
                endif
                ; get the polarizations that match up with these samplers
                sampler_pols = lonarr(n_elements(beam_samplers))
                for i=0,n_elements(beam_samplers)-1 do begin
                    pols = beam_scan_rows[where(beam_scan_rows.sampler eq beam_samplers[i])].crval4
                    ; for a given sampler and beam, 
                    ; all rows should have the same polarization
                    sampler_pols[i] = pols[0]
                endfor
                
                if self.debug then begin
                    print, "samplers and their pols: "
                    print, beam_samplers
                    print, sampler_pols
                endif    
                
                ; go through all samplers, splitting if number if need be
                sampler_available = 1
                while sampler_available do begin
                
                    if self.debug then print, "available samplers: ", beam_samplers

                    ; get next available sampler
                    sampler = beam_samplers[0]
                    polarization = sampler_pols[0]

                    if self.debug then print, "match for sampler/pol? ", sampler, polarization, format='(a25,x,a5,x,i5)'
                    if self.debug then print, "among pols: ", sampler_pols

                    ; is there a sampler with a matching polarization
                    matching_pol_index = self->find_matching_polarizations(sampler_pols, polarization,count)

                    if count ne 0 then begin
                        
                        ; use the first appropriate sampler for this if number
                        sampler_match = beam_samplers[matching_pol_index[0]]
                        pol_match = sampler_pols[matching_pol_index[0]]

                        ; assign this if number to the first and matching sampler
                        ; where are the samplers/beam in the scan rows?
                        sampler_beam_inds = where(scan_rows.sampler eq sampler $ 
                            and scan_rows.feed eq current_beam)
                        ifs[sampler_beam_inds] = if_num
                        sampler_beam_inds = where(scan_rows.sampler eq sampler_match $ 
                            and scan_rows.feed eq current_beam)
                        ifs[sampler_beam_inds] = if_num

                        if self.debug then print, "sampler: ", sampler, " pol: ", polarization, " if: ", if_num , $
                            format='(a9,x,a5,x,a6,x,i3,x,a5,x,i3)'
                        if self.debug then print, "sampler: ", sampler_match, " pol: ", pol_match, " if: ", if_num , $
                            format='(a9,x,a5,x,a6,x,i3,x,a5,x,i3)'
                            
                        ; remove these samplers from the availble sampler list
                        si = where(beam_samplers eq sampler)
                        beam_samplers = self->remove_element(beam_samplers, value=sampler)
                        sampler_pols = self->remove_element(sampler_pols, index=si)
                        si = where(beam_samplers eq sampler_match)
                        beam_samplers = self->remove_element(beam_samplers, value=sampler_match, count)
                        sampler_pols = self->remove_element(sampler_pols, index=si)
                        if count eq 0 then sampler_available = 0
                        
                        ; look for the other polarizations - only applicable for cross-pol data
                        other_pols = self->get_other_polarizations(polarization)
                        for i=0,n_elements(other_pols)-1 do begin
                            other_pol = other_pols[i]
                            other_pol_ind = where(other_pol eq sampler_pols,cnt)
                            if cnt ne 0 then begin
                                ; use the first appropriate sampler for this if number
                                sampler_match = beam_samplers[other_pol_ind[0]]
                                pol_match = sampler_pols[other_pol_ind[0]]

                                ; assign this if number to the first and matching sampler
                                ; where are the samplers/beam in the scan rows?
                                sampler_beam_inds = where(scan_rows.sampler eq sampler_match $ 
                                    and scan_rows.feed eq current_beam)
                                ifs[sampler_beam_inds] = if_num
                                if self.debug then print, "sampler: ", sampler_match, " pol: ", pol_match, " if: ", if_num , $
                                    format='(a9,x,a5,x,a6,x,i3,x,a5,x,i3)'
                                si = where(beam_samplers eq sampler_match)
                                beam_samplers = self->remove_element(beam_samplers, value=sampler_match, count)
                                sampler_pols = self->remove_element(sampler_pols, index=si)
                                if count eq 0 then sampler_available = 0
                           
                            endif
                        endfor
                        
                        ; increment the if number
                        if_num += 1
                        num_ifs += 1

                    endif else begin
                    
                        ; none of the samplers can be used in this same if 
                        ; we must split the if degeneracy!
                        ; assign current if just to this sampler, and move on to other samplers
                        ; where are the samplers/beam in the scan rows?
                        sampler_beam_inds = where(scan_rows.sampler eq sampler $ 
                            and scan_rows.feed eq current_beam)
                        ifs[sampler_beam_inds] = if_num
                      
                        if self.debug then print, "sampler: ", sampler, " pol: ", polarization, " if: ", if_num , $
                            format='(a9,x,a5,x,a6,x,i3,x,a5,x,i3)'

                        ; increment the if number
                        if self.debug then print, "splitting if degenerecy!"
                        if_num += 1
                        num_ifs += 1

                        ; remove these samplers from the availble sampler list
                        si = where(beam_samplers eq sampler)
                        sampler_pols = self->remove_element(sampler_pols, index=si)
                        beam_samplers = self->remove_element(beam_samplers, value=sampler, count)
                        if count eq 0 then sampler_available = 0
      
                    endelse ; if no matching samplers-polarizations
                    
                endwhile ; samplers to assign if nums to
                
            endfor ; for each unique tuning   

        endfor ; for each beam name in scan
    
    endelse ; if checking for degeneracies
    
    return, ifs

END        

FUNCTION IF_FILLER::remove_element, arr, count, value=value, index=index
    compile_opt idl2, hidden

    if n_elements(arr) eq 1 then begin
        count = 0
        return, -1
    endif
    
    count = 0
    copy = make_array(n_elements(arr)-1,value=arr[0])
    for i=0, n_elements(arr)-1 do begin
        ; value and index keywords are mutually exlusive
        if keyword_set(value) then begin
            if arr[i] ne value then begin
                copy[count] = arr[i]
                count += 1
            endif    
        endif else begin
            if i ne index then begin
                copy[count] = arr[i]
                count += 1
            endif
        endelse
    endfor

    return, copy

END

;+
; Sorts and uniques an array
; @param arr {in}{type=array} array to be sorted and uniqued
; @returns uniqe values of array
; @private
;-
FUNCTION IF_FILLER::get_uniques, arr, count
    compile_opt idl2

    uniques = arr[uniq(arr, sort(arr))]
    count = n_elements(uniques)
    return, uniques

END
    
;+
; Method for attempting to extract a value from an sdfits row.  If the row contains the
; tag name requested, that value is passed back.  If that tag name actually specifies a 
; keyword in the extension-header, and NOT a column, then that value is returned.  Finally,
; if the tag name mathes one of the expected column names that were not found in this
; extension, the default value is returned.
; @param row {in}{type=struct} structure that mirrors a row in an sdfits file
; @param tag_name {in}{type=string} name of the value that we want to retrieve
; @param virtuals {in}{type=struct} struct giving the keyword-values found in the file-extension
; @param names {in}{type=struct} struct contiaining pointers to the names of columns in the row, missing columns, and tag names in the virtuals struct
; @param default_value {in} value to be returned if the tag_name is of a missing column
; @returns either the value of row.tag_name, virtauls.tag_name, or default_value
; @private
;-
FUNCTION IF_FILLER::get_row_value, row, tag_name, virtuals, names, default_value
    compile_opt idl2

    ; look for the tag name inside each member of 'names'
    i = where(tag_name eq *names.row)
    if (i ne -1) then begin
        ; its in the sdfits row
        value = row.(i)
    endif else begin
        i = where(tag_name eq *names.virtuals)
        if (i ne -1) then begin
            ; its a keyword in ext header
            value = virtuals.(i)
        endif else begin
            ; see if there are missing cols to check
            if (size(*names.missing,/dim) ne 0) then begin
                i = where(tag_name eq *names.missing)
            endif else begin
                i = -1
            endelse    
            if (i ne -1) then begin
                ; its a missing column from sdfits row
                value = default_value ;missing.(i)
            endif else begin
                ; use the default value again
                ;print, 'tag_name: '+tag_name+' not found in row, missing, or virtuals'
                value = default_value
            endelse
        endelse
    endelse    
    return, value

END

;+
; Given rows from an sdfits file, how much does the value of a given column vary?
; Used when translating contents of an sdfits file into contents of the index file.
; @param rows {in}{type=array} array of structures mirroring sdfits rows
; @param tag_name {in}{type=string} column in the sdfits rows we are querying
; @param names {in}{type=struct} structure containing pointers to the list of row columns, missing cols, and header keywords
; @param default_value {in} if the tag_name is not found in the rows or as a keyword, use this as the variability
; @returns the variablity of this column in the fits file
; @private
;-
FUNCTION IF_FILLER::get_col_variability, rows, tag_name, names, default_value
    compile_opt idl2

    variability = 1
    i = where(tag_name eq *names.row)
    if (i ne -1) then begin
        ; its in the sdfits row
        values = rows.(i)
        sorted = values[sort(values)]
        uniques = sorted[uniq(sorted)]
        variability = n_elements(uniques)
    endif else begin
        i = where(tag_name eq *names.virtuals)
        if (i ne -1) then begin
            ; its a keyword in ext header
            variability = 1
        endif else begin
            ; see if there are missing cols to check
            if (size(*names.missing,/dim) ne 0) then begin
                i = where(tag_name eq *names.missing)
            endif else begin
                i = -1
            endelse    
            if (i ne -1) then begin
                ; its a missing column from sdfits row; ex: CAL
                variability = default_value 
            endif else begin
                ; fits no case
                variability = 1
            endelse
        endelse
        
    endelse    
    return, variability 

END

FUNCTION IF_FILLER::find_matching_polarizations, pols, pol, count
    compile_opt idl2, hidden

    count = 0
    match = self->get_matching_polarization(pol)
    if match ne pol then begin
        ; only count matches that don't match itself
        for i=0,n_elements(pols)-1 do begin
            if pols[i] eq match then begin
                if count eq 0 then matches=[i] else matches=[matches,i]
                count += 1
            endif
        endfor
    endif

    if count eq 0 then return, -1 else return, matches
        
END

FUNCTION IF_FILLER::get_matching_polarization, polarization
    compile_opt idl2, hidden

    ; this is a kludge for IQUV

    case polarization of
        -2: p = -1
        -1: p = -2
        -4: p = -3
        -3: p = -4
        -5: p = -6
        -6: p = -5
        -7: p = -8
        -8: p = -7
         1: p = 2
         2: p = 1
         3: p = 4
         4: p = 3
        else: p = 0
    endcase

    return, p
        
END

FUNCTION IF_FILLER::get_other_polarizations, polarization
    compile_opt idl2, hidden

    ; this is a kludge for IQUV

    case polarization of
        -2: p = [-3,-4]
        -1: p = [-3,-4]
        -4: p = [-1,-2]
        -3: p = [-1,-2]
        -5: p = [-7,-8]
        -6: p = [-7,-8]
        -7: p = [-5,-6]
        -8: p = [-5,-6]
         1: p = [3,4]
         2: p = [3,4]
         3: p = [1,2]
         4: p = [1,2]
        else: p = 0
    endcase

    return, p
        
END

    
