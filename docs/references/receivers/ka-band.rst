
Ka-Band receiver
----------------

The Ka-band receiver has two beams, each with a single linear polarization. 
The polarizations of the two beams are orthogonal and are aligned at :math:`\pm45^\circ` 
angles to the elevation (and cross-elevation) direction. The receiver is built 
according to a pseudo-correlation design intended to minimize the effect of 1/f 
gain fluctuations for continuum and broadband spectral line observation.
180 degree waveguide hybrids precede and follow the low noise amplifiers.  
Phase switches between the amplifiers and the second hybrid allow true beam 
switching to be used with this receiver.

The CCB uses the full 26-40 GHz range of the Ka-band receiver. For other backends, 
the receiver is broken into three separate bands: 

* 26.0-31.0 GHz,
* 30.5-37.0 GHz, and
* 36.0-39.5 GHz. 
  
You can only use one of these bands at a time, except for the CCB which can use
the full frequency range of the receiver. For backends other than the CCB, the 
maximum instantaneous bandwidth achievable with this receiver is limited to 4 GHz.

There is a noise diode for each beam (~10% of the system temperature) for flux 
calibration. The feeds are separated by 78" in the cross-elevation direction.


