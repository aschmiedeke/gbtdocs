
X-Band receiver
---------------

The X-band receiver has one beam, with dual circular polarizations. The feed has a cooled polarizer producing circular polarizations. 
The internal switching modes are frequency switching and polarization switching. The receiver can be used in narrowband or wideband 
modes, for which the maximum instantaneous bandwidths are 1.3 and 4.0 GHz, respectively. Users should note that the narrowband mode
operates with an IF centred at 6 GHz, while the wideband mode operates with an IF centred at 4 GHz. Using the DCR and VEGAS backends
concurrently in wideband mode should be avoided as this would produce conflicts with the DCR filters, which are centred at either
3 or 6 GHz.
  
The frequency range of the X-band receiver is approximately 7.8 – 12.0 GHz. 

.. caution:: 

    Above ~11 GHz, receiver temperatures increase by ~10 K. 
    
.. note:: 

    Licensed LEO and geostationary satellite transmissions are likely to be encountered at the upper end of the band (> 11 GHz).
    It may be possible to minimize these contributions through narrowband observations. However, wideband observations should assume
    that these contributions will be present. 
    
There is a single noise diode which operates at ~5% and ~20% of the system temperature (in 'low-cal' and 'high-cal' modes, respectively)
for flux calibration.

