.. literalinclude:: /references/observing/scripts/tp_config_multi_beam.py
    :language: python
    :lines: 3-
    :caption: An example total power, spectral line configuration for a multi-beam receiver.


The above example will configure for the following:

* The dual beam Q-band receiver using both beams [``receiver='Rcvr40_52'``, 
  ``beam='1,2'``]

* Total power, spectral line observations [``obstype='Spectroscopy'``, 
  ``swmode='tp'``, ``swtype='none'``]

* VEGAS as the backend detector using circular polarization without 
  cross-polarization products [``backend='VEGAS'``, ``pol='Circular'``]

* Mode 2 of VEGAS (see :numref:`tab-vegas-modes`).  This mode is defined by a bandwidth
  of 1500 MHz with 16384 spectral channels [``bandwidth=1500``, ``nchan=16384``]

* 4 spectral windows, each of which centered on one of the 4 frequencies (in MHz)
  listed under restfreq [``restfreq=44580, 43751, 45410, 46250``]

* Shift the window centered on 43751 MHz by 100 MHz in the local (topocentric) frame. 
  Thus, this window will now be centered on 43851 MHz [``deltafreq=0,100,0,0``]. 
  ``deltafreq`` should be defined in the same manner as ``restfreq``: This example 
  uses 4 comma separated values.

* Go through a full switching cycle in 1 second [``swper=1.0``] and record data with
  VEGAS every 10 seconds [``tint=10``].

* Doppler track the spectral line with the rest frequency 44580 MHz (default is the
  first specified rest frequency) in the commonly used Local Standard of Rest velocity
  [``vframe='lsrk'``] with the radio definition of Doppler tracking [``vdef='Radio'``].

* Use a low-power noise diode [``noisecal='lo'``]
