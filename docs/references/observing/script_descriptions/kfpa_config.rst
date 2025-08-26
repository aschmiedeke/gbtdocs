.. literalinclude:: /references/observing/scripts/kfpa_config.py
    :language: python
    :lines: 2-
    :caption: An example total power, spectral line configuration for the KFPA.


The above example will configure for the following:

* The KFPA receiver using all 7 beams [``receiver='RcvrArray18_26'``, ``beam='all'``] 

* Total power, spectral line observations [``obstype='Spectroscopy'``, ``swmode='tp', ``swtype='none'``]

* VEGAS as the backend detector with circular cross-polarization products 
  [``backend='VEGAS'``, ``vegas.vpol='cross'``, ``pol='Circular'``]

* Mode 4 of VEGAS (see Table XXX).  This mode is defined by a bandwidth of 187.5 MHz with 
  32768 spectral channels [``bandwidth=187.5``, ``nchan=32768``]

  .. todo:: Add reference to VEGAS modes table.


* 3 spectral windows centered on 24600, 23900, and 25500 MHz. Data will be recorded for 
  beams 1 :math:`\rightarrow` 4 using the first window (24600 MHz) while beams 
  5 :math:`\rightarrow` 7 will use the second window (23900 MHz). An additional 
  IF path will be routed from beam 1 to the window centered on 25500 MHz.  
  This is known as the "7+1" mode of the KFPA [``restfreq={24600:'1,2,3,4', 23900:'5,6,7', 25500:'-1', 'DopplerTrackFreq': 24700}``]

  .. note:: 

    Doppler tracking the center (24700 MHz) of the full frequency range (25500 - 23900 + bandwidth)
    is necessary in this example. The maximum frequency separation limitation of the KFPA is 1.8 GHz
    when using multiple beams.  

    .. todo:: Add reference to KFPA section.

* The Radio definition of doppler tracking has been used in the Local Standard of Rest Velocity
  [``vframe='lsrk'``, ``vdef='Radio'``] 

* Shift the window centered on 24600 MHz by -100 MHz in the local (topocentric) frame.
  Thus, this window will now be centered on 24500 MHz [``deltafreq={24600:-100, 23900:0, 25500:0}``].
  ``deltafreq`` should be defined using the same syntax as ``restfreq``: This example uses Python 
  dictionary syntax.

* Go through a full switching cycle in 1~second [swper=1.0] and record data with \gls{VEGAS} every 30~seconds [tint=30]. 

* Use a low-power noise diode [``noisecal='lo'``]
