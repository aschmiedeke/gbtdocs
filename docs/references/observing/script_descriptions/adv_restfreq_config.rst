.. literalinclude:: /references/observing/scripts/adv_restfreq_config.py
    :language: python
    :lines: 3-
    :caption: An example showing advanced use of the ``restfreq`` keyword.


The above example uses the advanced restfreq syntax (an array of Python dictionary
terms) to more precisely configure the GBT system. 

.. caution::

    Note that this is an example of usage only and it is not recommended that users 
    attempt to manually route beams to specific VEGAS banks.

When using the advanced restfreq syntax, it is important to be aware of the following 
details in the main configuration block:

* Key values specified in the restfreq dictionary term override key-values pairs in
  the main configuration. If no values for a key have been specified, a default value
  will be used if available.
    
* ``bandwidth`` and ``nchan`` must always be specified in the main configuration block
  outside of restfreq. This is required for the configuration to pass validation, even 
  if such values are redundant [``bandwidth=23.44``, ``nchan=32768``]

* ``dopplertrackfreq`` must be set by the user [``dopplertrackfreq=13500.0``] since
  there is no default doppler tracking frequency for the advanced restfreq syntax.


The following points give details on the usage of the advanced restfreq syntax in this example:

* Multiple rest frequencies (or windows centered on a rest frequency) are input as an array of 
  Python dictionary terms. The ``restfreq`` dictionary key is the minimum required entry for
  each dictionary term and specifies the center of each window. Each bank may also be configured
  with different resolution, bandwidth, and number of spectral windows. However, the integration 
  time, switching period and frequency switch must be the same for all banks.

* Each window may be routed to a specific bank (VEGAS spectrometer) with the ``bank`` dictionary
  key (see the first window of this example). By omitting ``bank``, the system will attempt to 
  route windows to available banks automatically (recommended). Note that certain restrictions
  exist when routing multi-beam receivers to VEGAS banks. 
  
  .. todo:: Add reference to VEGAS IF section and KFPA (also Argus?) for further information.
    
* The ``beam`` dictionary key specifies which beam is used for the window. Omitting ``beam``
  defaults to beam 1 [``'beam': '1'``]

* VEGAS modes are set for a window by defining valid combinations of bandwidth and resolution,
  and the number of sub-bands if using a 23.44~MHz bandwidth (see Table XXX). If these values
  are not defined as dictionary keys, then values defined in the main configuration block or 
  default values will be used. It is worth noting the following points in this example:

  .. todo:: Add reference to VEGAS modes table.

  * Bank C has been split into 3 subbands and uses VEGAS mode 23 defined by 23.44 MHz bandwidth,
    8 subbands, and 0.7 kHz resolution [``'bank': 'C', 'bandwidth': 23.44, 'res': 0.7, 'subband': 8``].
    The 3 windows are centered on 13200, 13300, and 13400 MHz. 
    
    .. note:: 
    
        All sub-bands within a single bank must use identical VEGAS settings apart from
        the center frequency and offset.
        
  * A second window has been centered around 13400 MHz using a bandwidth of 23.44 MHz with 0.7 kHz
    resolution. However, this window is configured to use beam 2 and mode 10 of VEGAS with a 
    single sub-bank [``'restfreq': 13400, 'bandwidth': 23.44, 'res':0.7, 'beam': '2', 'subband':1``]

  * The window centered at 13100 MHz gives an example of the other dictionary keys available. 
    This window has been shifted +1 MHz in the local frame [``'deltafreq': 1``] to be centered 
    on 13101 MHz. Data will be recorded with full Stokes polarization products [``'vpol': 'cross'``].
    All other windows will record data with total intensity polarization products [``vegas.vpol='self'``
    (the default setting)]

