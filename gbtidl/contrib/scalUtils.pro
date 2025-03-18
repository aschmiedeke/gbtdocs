;+
; Returns a vector of fluxes for a given vector of frequencies for
; standard calibrators. 
;
; <p>Can also be used to generate fluxes for non-standard calibrators. 
;
; <p><b>Note: </b>If coeffs is given, then src and specindex are ignored.  If
; specindex is given, then src is ignored. src is only used if both
; specindex and coeffs is not used. 
;
; <p>Recognized source names are: 3C48, 3C123, 3C147, 3C161, 3C218, 3C227,
; 3C249.1, VIRA, 3C286, 3C295, 3C309.1, 3C348, 3C353, NGC7027.
;
; <p>Calibrator coefficients are from the Ott et all or Peng list of
; calibrators.
;
; @param src {in}{required}{type=string} source name.  Must be one in
; the enclosed catalog.  This is ignored if coeffs and specindex are
; provided.
; @param freq {in}{required} list of frequencies for which fluxes are
; required.
; @keyword coeffs {in}{optional} For a non standard calibrator,
; polynomial coefficients to use to determine the flux of a source.
; log(S) = coeff[0] + coeff[1]*log(freq) + coeff[2]*log(freq)^2
; @keyword specindex {in}{optional} For a non standard calibrator,
; spectral index coefficients to use to determine the flux of a
; source.  S = specindex[0] * (freq/specindex[1])^(specindex[2]) 
; @returns a vector of fluxes at the given frequencies.
;
; @file_comments scalUtils is a collection of routines that return 
; various quantities needed for calibration.  Users will need to look
; over and maybe modify getTau and getFluxCalib before using any of
; the other scal or getVctr routines.  Contact the contributor for
; additional details.
;
; <p><B>See also</B> the scal User's Guide found in the
; documentation for <a href="scal.html">scal.pro</a>
;
; <p><B>Contributed By: Ron Maddalena, NRAO-GB</B>
;
; @version $Id$
;-
function getFluxCalib, src, freq, coeffs=coeffs, specindex=specindex

    srcNames = ['3C48',  '3C123', '3C147', '3C161', '3C218', '3C227', '3C249.1',  'VIRA', '3C286', '3C295', '3C309.1', '3C348', '3C353', 'NGC7027']
    ; a =        [2.465,     2.525,   2.806,   1.250,   4.729,   6.757,     2.537,   4.484,   0.956,   1.490,     2.617,   3.852,   3.148,     -9.625592]
    ; b =        [-0.004,    0.246,  -0.140,   0.726,  -1.025,  -2.801,    -0.565,  -0.603,   0.584,   0.756,    -0.437,  -0.361,  -0.157,    5.002555]
    ; c =        [-0.1251, -0.1638, -0.1031, -0.2286,  0.0130,  0.2969,   -0.0404, -0.0280, -0.1644, -0.2545,   -0.0373, -0.1053, -0.0911,     -0.6042999  ]
    a =        [2.69116,     2.525,   2.806,   1.250,   4.729,   6.757,     2.537,   4.484,   0.956,   1.490,     2.617,   3.852,   3.148,     -9.625592]
    b =        [-0.124817,    0.246,  -0.140,   0.726,  -1.025,  -2.801,    -0.565,  -0.603,   0.584,   0.756,    -0.437,  -0.361,  -0.157,    5.002555]
    c =        [-0.109415, -0.1638, -0.1031, -0.2286,  0.0130,  0.2969,   -0.0404, -0.0280, -0.1644, -0.2545,   -0.0373, -0.1053, -0.0911,     -0.6042999  ]

    if (n_elements(coeffs) eq 0 and n_elements(specindex) eq 0) then begin
        ; Use the table coeffs
        n = n_elements(freq)
        i = where(srcNames eq strupcase(strtrim(src,2)))
        if i ge 0 then begin
            logfreq = alog10(freq)
            aa = replicate(a(i), n)
            bb = replicate(b(i), n)
            cc = replicate(c(i), n)
	    ; print, 'E',  10^(aa + bb*logfreq + cc*logfreq*logfreq)
            return, 10^(aa + bb*logfreq + cc*logfreq*logfreq)
        endif
        if (n_elements(coeffs) eq 0) then begin
	    print, src, " is not in the calibration table ... Using S = 1.0"
            return, replicate(1.0, n)
        endif
    endif

    if (n_elements(coeffs) ne 0) then begin
        ; Use the user-supplied coeffs
        logfreq = alog10(freq)
        flux = 0
        for i=0, n_elements(coeffs)-1 do begin
            flux = flux + coeffs[i]*logfreq^i
        end
        return, 10^flux
    endif

    if (n_elements(specindex) ne 0) then begin
        ; Use the user-supplied spectral index, flux, and frequency
        return, specindex[0] * (freq/specindex[1])^(specindex[2])
    endif

end

;+
; Returns a vector of aperture efficiencies.
;
; <p><B>Note: </B>You cannot supply a surface rms without also
; supplying a long wavelength efficiency.
; 
; @param freq {in}{required}{type=vector} list of frequencies in MHz for which an opacity is needed
; @param elev {in}{required}{type=float} elevation in degrees of the observation
; @keyword coeffs {in}{optional}{type=vector} coeffs[0] = the long wavelength efficiency (Default : 0.72) 
; coeffs[1] = Surface rms in microns (Default : 184 microns)
; @returns vector of aperture efficiences at freq
;
; @examples
; <pre>
; a = getApEff(45.0, freqs) ; returns the PTCS  model for ap_eff
; a = getApEff(45.0, freqs, coeffs=[0.69]) ; uses 184 microns but a long-wavelength eff of 69% 
; a = getApEff(45.0, freqs, coeffs=[0.73, 250]) ; uses 250 microns and a long-wavelength eff of 73%
; </pre>
;
;-
function getApEff, elev, freq, coeffs=coeffs

    ; Default is 72% efficiency at long wavelengths, a surface RMS of 184 microns
    eff_long=0.72
    rms = 184
    if (n_elements(coeffs) ge 1) then eff_long = coeffs[0]
    if (n_elements(coeffs) eq 2) then rms = coeffs[1]

    ; print, 'D', eff_long*exp(-(4.189e-8*rms*freq)^2)
    return, eff_long*exp(-(4.189e-8*rms*freq)^2)
end



;+
; Returns a vector of atmospheric zenith opacities.
; @param freqs {in}{required} list of frequencies in MHz for which an opacity is needed
; @keyword coeffs {in}{optional} polynomial coefficients tau = coeff[0] + coeff[1]*freq + coeff[2]*freq^2 + ....
; @returns vector of atmospheric zenith opacities at freqs
;
; @examples
; <pre>
; a = getTau(freqs, coeffs=[0.01]) ; an opacity that is constant with freq
; a = getTau(freqs, coeffs=[0.0234, 0.4567, 0.0045])
; </pre>
;
;-
function getTau, freqs, coeffs=coeffs

    n = n_elements(freqs)
    if (n_elements(coeffs) eq 0) then return, replicate(0.0, n)

    tau = replicate(0.0, n)
    for i=0, n_elements(coeffs)-1 do begin
        tau = tau + coeffs[i]*freqs^i
    end
    ; print, 'C', tau
    return, tau
end

;+
; Estimate the airmass as a function of elevation in degrees.
;
; @param elev{in}{required}{float} elevation in degrees.
; @returns airmass
;-
function AirMass, elev
    if (elev LT 39) then begin
        ; print, 'A', -0.023437  + 1.0140 / sin( (!pi/180.)*(elev + 5.1774 / (elev + 3.3543) ) )
        return, -0.023437  + 1.0140 / sin( (!pi/180.)*(elev + 5.1774 / (elev + 3.3543) ) )
    endif else begin
        ; print, 'B', 1./sin(!pi*elev/180.)
        return, 1./sin(!pi*elev/180.)
    endelse
end

;+
; Converts data in buffer 0 from Ta to Jy.
;
; @keyword tau {in}{required} atmospheric zenith opacity encoded as a
; vector.  See the documentation for getTau for the format of the
; vector.
; @keyword ap_eff {in}{required} aperture efficiency encoded as a
; vector.  See the documentation for getApEff for the format of the
; vector.
;-
pro Ta2Flux, tau=tau, ap_eff=ap_eff

    elev=!g.s[0].elevation
    num_chan = n_elements(getdata(0))
    freqs = chantofreq(!g.s[0],seq(0,num_chan-1))/1.e6
    tauVctr = getTau(freqs, coeffs=tau)
    effVctr = getApEff(elev, freqs, coeffs=ap_eff)
    setdata, getdata(0) * exp(tauVctr*AirMass(elev))/(2.8 * effVctr )
    !g.s[0].units = "Jy"

end

;+
; Calculates an estimate to Tatm from ground air temperature and
; frequencies.
;
; <p>Only appropriate for freqs < 50 GHz.
;
; <p>The results of Maddalena & Johnson (2005, Bulletin of the American Astronomical 
; Society, Vol. 37, p.1438).   The rms uncertainty in my model is 3.5 K
;
; @param freqs {in}{required}{type=float} list of frequencies in MHz
; for which an opacity is needed 
; @param TempK {in}{required}{type=float} ground temperature in K
;
;-
function quickTatm, freqs, TempK
    f = freqs/1000.
    A = 259.691860 - 1.66599001*f + 0.226962192*f^2 - 0.0100909636*f^3 + 0.00018402955*f^4 - 0.00000119516*f^5
    B = 0.42557717 + 0.03393248*f + 0.000257983*f^2 - 0.0000653903*f^3 + 0.00000157104*f^4 - 0.00000001182*f^5
    return, A + B*(TempK-273.15)
end
