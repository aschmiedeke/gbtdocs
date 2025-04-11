; docformat = 'rst'

;+
; Toolbox front-end to chdoppler.  Get the velocity of a given frame
; relative to another frame.
;
; Recognized frames:
; 
;   * TOPO - topocentric. The observed (sky) frame.
;   * GEO  - geocentric.
;   * HEL  - heliocentric.
;   * BAR  - barycentric.
;   * LSR  - Local standard of rest (kinematic).
;   * LSD  - Dynamic LSR.
;   * GAL  - galactocentric.
; 
; :Params:
;   data : in, required, type=spectrum
;       Data container to get pointing direction, time, and telescope 
;       location from.
;
;   toframe : in, required, type=string
;       The desired frame.
;
;   fromframe : in, optional, type=string
;       The originating frame. Defaults to "TOPO".
;
; :Keywords:
;   bootstrap : in, optional, type=boolean
;       If set, the data.frame_velocity will be used to get to the frame 
;       given in data.velocity_definition. The other data header information
;       will only be used to get to other frames.  Bootstraping is desirable
;       because the sdfits tool may not be getting the correct times and
;       positions for each integration - early versions didn't.  However,
;       the frame_velocity is correct and can be relied on.
;
;   status : out, optional, type=integer
;       This is 1 if there were no problems and is 0 if anything unexpected
;       happened (invalid data container type, velocity definition, or
;       unrecognized data frames).
;
; :Returns:
;   Velocity difference between fromframe and toframe along the line of sight 
;   implied by the data header.
;
; :Uses:
;   :idl:pro:`chdoppler`
;   :idl:pro:`decode_veldef`
;
;-
function frame_velocity, data, toframe, fromframe, bootstrap=bootstrap, status=status
    compile_opt idl2

    if (data_valid(data,name=name) lt 0) then message,'data not a valid data container'
    status = 1

    if name ne "SPECTRUM_STRUCT" then begin
        message,'data must be a spectrum data container',/info
        status = 0
        return,0.0
    endif

    result = 0.0d

    if (n_elements(fromframe) eq 0) then fromframe='TOPO'

    if (toframe eq fromframe) then return, result

    ; frame velocities relative to topo
    radec = getradec(data,/quiet)
    frames = chdoppler(radec[0]/15.D, radec[1], $
                       data.mjd+2400000.5D, obspos=data.site_location[0:1])
    frames *= 1.d3 ; convert km/s to m/s

    ; if bootstraping, try and calibrate the frames values
    boot_velocity = 0.0D
    boot_frame = 'TOPO'
    if (keyword_set(bootstrap)) then begin
        if (not decode_veldef(data.velocity_definition, v_def, v_frame)) then begin
            status = 0
            message,"Problems deciphering data.velocity_definition, velocities may be wrong",/info
        endif
        boot_frame = v_frame
        boot_velocity = data.frame_velocity

        if (fromframe eq "TOPO" and toframe eq boot_frame) then return, boot_velocity

       ; any difference is assumed to come from Earth's rotation
       ;    - common to all frames
        offset=0.0D
        case boot_frame of
            "GEO": offset = shiftvel(frames[0],-boot_velocity,veldef='TRUE')
            "HEL": offset = shiftvel(frames[1],-boot_velocity,veldef='TRUE')
            "BAR": offset = shiftvel(frames[2],-boot_velocity,veldef='TRUE')
            "LSR": offset = shiftvel(frames[3],-boot_velocity,veldef='TRUE')
            "LSD": offset = shiftvel(frames[4],-boot_velocity,veldef='TRUE')
            "GAL": offset = shiftvel(frames[5],-boot_velocity,veldef='TRUE')
           else: offset = 0.0D
        endcase
        ; and add that to all the frame
        ; velocities to get a bootstraped result
        offset = replicate(offset,n_elements(frames))
        frames = shiftvel(frames,-offset,veldef='TRUE')
    endif

    tovel = 0.0D
    if (toframe ne "TOPO") then begin
        ; velocity of toframe relative to TOPO

        case toframe of
            "GEO": tovel=frames[0]
            "HEL": tovel=frames[1]
            "BAR": tovel=frames[2]
            "LSR": tovel=frames[3]
            "LSD": tovel=frames[4]
            "GAL": tovel=frames[5]
            else: begin
                message, "unrecognized toframe, assuming TOPO",/info
                message,"toframe = " + toframe, /info
                toframe = 'TOPO'
                status = 0
                tovel=0.0D
            end
        endcase
    endif

    fromvel = 0.0D
    if (fromframe ne "TOPO") then begin
            ; velocity of fromframe relative to TOPO
        
        case fromframe of
            "GEO": fromvel=frames[0]
            "HEL": fromvel=frames[1]
            "BAR": fromvel=frames[2]
            "LSR": fromvel=frames[3]
            "LSD": fromvel=frames[4]
            "GAL": fromvel=frames[5]
            else: begin
                message, "unrecognized fromframe, assuming TOPO",/info
                message,"fromframe = " + fromframe,/info
                fromframe = 'TOPO'
                status = 0
                fromvel=0.0D
            end
        endcase
    endif

    ; true offset is the full relativistic difference between the two.
    result = shiftvel(tovel,-fromvel,veldef='TRUE')

    return, result
end
