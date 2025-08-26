.. literalinclude:: /references/observing/scripts/tp_config.py
    :language: python
    :lines: 3-
    :caption: An example total power, spectral line configuration.

The above example will configure for the following:

* The single beam X-band receiver [``receiver='Rcvr8_10``]
  
  .. note:: Not specifying ``beam`` defaults to ``beam='1'``.

* Total power, spectral line observations [``obstype='Spectroscopy'``, ``swmode='tp',
  ``swtype='none'``]

* VEGAS as the backend detector using circular polarization without cross-polarization 
  products [``backend='VEGAS', ``pol='Circular'``]

* Mode 21 of VEGAS (see Table XXX). This mode is defined by a bandwidth of 23.44 MHz,
  8192 spectral channels in the eight subband mode of VEGAS [``bandwidth=23.44``,
  ``nchan=8192``]
  
  .. note:: 

      Not specifying ``vegas.subband`` for a bandwidth of 23.44~MHz will 
      default to ``vegas.subband=8``.

  .. todo:: Add reference to VEGAS modes table.

* 9 spectral windows, each of which centered on one of the 9 frequencies (in MHz) listed
  under restfreq [``restfreq=9816.867, 9487.824, 9173.323, ....``]
   
* Go through a full switching cycle in 1 second [``swper=1.0``] and record data with
  VEGAS every 30 seconds [``tint=30``].
  
* Doppler track the spectral line with the rest frequency 8873.1 MHz [``dopplertrackfreq=8873.1``]
  in the commonly used Local Standard of Rest velocity [``vframe='lsrk'``] with the radio definition 
  of Doppler tracking [``vdef='Radio'``]

* Use a low-power noise diode [``noisecal='lo'``]


