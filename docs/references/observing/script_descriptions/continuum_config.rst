.. literalinclude:: /references/observing/scripts/continuum_config.py
    :language: python
    :lines: 3-
    :caption: An example continuum configuration.


The above configuration definition has been given the name ``continuum_config``
and can be used for pointing and focusing observations or for continuum mapping.
We have configured for the following:

* The single beam L-band receiver [``receiver='Rcvr1_2'``, ``beam='1'``]

* Total power, continuum observations [``obstype='Continuum'``, ``swmode='tp'``, ``swtype='none'``]

* The DCR as the backend detector [``backend='DCR'``]

* Take data using a single band centered on 1400 MHz with a 80 MHz bandwidth 
  [``nwin=1``, ``restfreq=1400``, ``bandwidth=80``]
  
* Go through a full switching cycle in 0.2 seconds [``swper=0.2``]

* Record data with the DCR every 0.2 seconds [``tint=0.2``]

* Disable dopple tracking for continuum observations [``vframe='topo'``, ``vdef='Radio'``]

* Use a low-power noise diode [``noisecal='lo'``]

* Linear polarization [``pol='Linear'``]
