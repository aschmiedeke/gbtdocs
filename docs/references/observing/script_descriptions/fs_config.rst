.. literalinclude:: /references/observing/scripts/fs_config.py
    :language: python
    :lines: 4-
    :caption: An example frequency-switched, spectral line configuration.


The above example will configure for the following:

* The single beam L-band receiver [``receiver='Rcvr1_2'``]

  .. note:: Not specifying ``beam`` defaults to ``beam='1'``.

* fsw, spectral line observations [``obstype='Spectroscopy'``, ``swmode='sp'``, ``swtype= 'fsw'``]

* VEGAS as the backend detector using linear polarization without 
  cross-polarization products [``backend='VEGAS'``, ``pol='Linear'``].

* Take data using a single band using VEGAS mode 11 (see :numref:`tab-vegas-modes`) defined by
  23.44 MHz bandwidth, 65536 channels, and one band per spectrometer
  [``bandwidth=23.44``, ``nchan=65536``, ``vegas.subband=1``], 
  centered on 1420 MHz [``restfreq=1420``].
  
* Go through a full switching cycle in 2 seconds [``swper=2.0``]. Over one cycle, 
  the fsw states will be centered on the line, and then be shifted by -5~MHz 
  [``swfreq=0,-5.0``]

* Record data with VEGAS every 10 seconds [``tint=10``]

* Doppler track the spectral line with the rest frequency 1420 MHz in the commonly 
  used Local Standard of Rest velocity with the radio definition of Doppler tracking 
  [``vframe='lsrk'``, ``vdef='Radio'``].

* Use a low-power noise diode [``noisecal='lo'``]

