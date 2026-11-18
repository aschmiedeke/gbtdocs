"""
Author: Charles Romero (2025)
"""
import numpy as np
import astropy.units as u
from scipy.ndimage import filters

def m2_params(instrument):
    """
    Returns
    -------
    output : tuple
       A tuple containing fwhm1,norm1,fwhm2,norm2,fwhm,smfw,freq,FoV
    """

        fwhm1 = 8.9*u.arcsec  # arcseconds
        norm1 = 0.97          # normalization
        fwhm2 = 25.0*u.arcsec # arcseconds
        norm2 = 0.03          # normalization
        
    return fwhm1,norm1,fwhm2,norm2

def smooth_by_M2_beam(image,pixsize=2.0):
    """
    Smooths an image by a double Gaussian that is representative for MUSTANG-2.

    Parameters
    ----------
    image: float 2D numpy array
         2D array for which we compute the power spectrum
    pixsize: float
         Pixel size, in arcseconds

    Returns
    -------
    bcmap : float 2D numpy array
       beam-convolved map
    
    """

    fwhm1,norm1,fwhm2,norm2 = m2_params()

    sig2fwhm   = np.sqrt(8.0*np.log(2.0)) 
    pix_sigq1  = fwhm1/(pixsize*sig2fwhm*u.arcsec)
    pix_sigq2  = fwhm2/(pixsize*sig2fwhm*u.arcsec)
    pix_sig1   = pix_sigq1.decompose().value
    pix_sig2   = pix_sigq2.decompose().value
    map1       = filters.gaussian_filter(image, pix_sig1)
    map2       = filters.gaussian_filter(image, pix_sig2)

    bcmap      = map1*norm1 + map2*norm2

    return bcmap

