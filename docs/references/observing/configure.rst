

Configure the GBT system
------------------------


The routing of signals through the GBT system is controlled by many electronic switches which
eliminate the need to physically change cables by hand. The GBT's electronically configurable 
IF system allows many, and more complicated paths for the signals to co-exist at all times.
Configuring the GBT IF system can usually be accomlished in under one minute.


Defining and executing a configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 

Configurations are defined as sets of keyword-value pairs within a single string variable. 
To execute a configuration, this variable is passed as an argument into the 
:func:`Configure() <astrid_commands.Configure>` command in an SB.

Configurations may be defined in two ways:

#. The configuration definition may reside in a text file external to the SB. It can then be 
   loaded into the SB via the :func:`execfile() <astrid_commands.execfile>` command.

   .. code-block:: python

        # An SB to configure only -- Configuration is defined in an external file.

        execfile('mypath/filename.py')
        Configure(myconfiguration)


#. The configuration may be explicitly defined with the SB.


   .. code-block:: python

        # An SB to configure only -- Configuration is defined here.

        myconfiguration = '''
        # This is a comment
        primarykeyword1 = your primarykeyword value
        primarykeyword2 = your primarykeyword value
        ...
        ...
        primarykeywordN = your primarykeyword value
        '''

        Configure(myconfiguration)


We usually recommend that configuration definitions reside in text files external to the SB. 
This allows for configurations to be changed on the file without the need to re-validate and 
re-save the SB. It also allows for simple SBs without clutter.

.. note::

   You should always use execfile rather than import, as import will not reread the file and 
   miss any changes that you may have made.

Explicitely defining configurations within SBs allows you to easily edit and view your 
configuration from AstrID. If you chose this method, you **must** re-validate and re-save
your SB if you make any changes. 

If you use multiple configurations, we recommend that you define them all in one text file 
and load them into the SB via a single :func:`execfile() <astrid_commands.execfile>` command.
You may then use :func:`Configure() <astrid_commands.Configure>` to execute each configuration
as necessary.


Resetting the configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The configuration tool in AstrID remembers all the keyword values defined during a session.
This feature occasionally results in AstrID being unable to validate an otherwise correct
configuration because of previously set values or hardware being configured improperly. To
reset the configuration parameters to their default state, you can issue the :func:`ResetConfig() 
<astrid_commands.ResetConfig>` command in a script before another :func:`Configure() <astrid_commands.
Configure>`.



Configuration keywords
^^^^^^^^^^^^^^^^^^^^^^

Required keywords
'''''''''''''''''

The following keywords do not have default values and must be present in all configuration definitions.


``receiver`` (str)
""""""""""""""""""

Specifies the name of the GBT receiver to be used. The names and frequency ranges of the
receivers can be found in Table XX

.. todo:: Add table reference.



``backend`` (str)
"""""""""""""""""

Specifies the name of the backend (data acquisition system) to be used. Valid backends are 
listed in Table XX

.. todo:: Add table reference.


``obstype`` (str)
"""""""""""""""""

Specifies the type of observing to be performed. The allowed values are one of the following
strings:

* ``'Continuum'``
* ``'Spectroscopy'``
* ``'Pulsar'``
* ``'Radar'``
* ``'VLBI'``


``bandwidth`` (float)
"""""""""""""""""""""

Specifies the bandwidth in MHz to be used by the specified backend. Possible values depend on
the receiver and backend that are chosen. 

.. todo:: Add reference to tables that are in the observer guide labeled 9.2 and 10.1


``restfreq`` (depends)
""""""""""""""""""""""

Specifies the rest frequencies for spectral line observations or the center frequencies for
continuum observations. There are three available syntaxes for ``restfreq``:

#. **Simple:** list of comma separated float values (MHz)

   .. code-block:: python

       restfreq = 1420, 1661, 1667
       deltafreq = 0, 5, 0


   This example sets three rest frequencies and offsets the second window (1661 MHz) by +5 MHz
   in the local (topocentric) frame using the ``deltafreq`` keyword. Rest frequencies may be 
   specified as a list of comma separated float values in MHz. This syntax should be used when
   all beams (including single beam receivers) are configured to observe the same rest frequencies
   and VEGAS does not need to use an advanced configuration.

   .. note::

        * ``deltafreq`` can also be specified using the same syntax as ``restfreq``, a single global
          offset, or omitted to use the default value of zero
        * if ``dopplertrackfreq`` is not set in the main configuration block, then the first rest
          frequency listed using this syntax will be doppler tracked by default

#. **Multi-beam:** python dictionary

   .. code-block:: python

        restfreq = {24000: '1, 2, 3, 4', 
                    23400: '5, 6',
                    25000: '7',
                    'dopplertrackfreq': 24200}

         #deltafreq must be specified with this syntax - even when zero
         deltafreq = {24000: 0, 23400: 0, 25000: 0}

   This example specifies a rest frequency of 24000 MHz for beams 1-4, 23400 MHz for beams 5 and 6,
   and 25000 MHz for beam 7. Different feeds of multi-beam receivers may be tuned to different rest
   frequencies. Rest frequencies and delta frequencies are input as python dictionaries. 

   .. todo:: Check what content of Appendix B of the Observer Guide is needed here.

   .. note::

       * ``deltafreq`` must always be specified as a separate python dictionary, even when zero
       * ``dopplertrackfreq`` must always be specified in the restfreq python dictionary


#. **Advanced:** list of python dictionaries

   .. code-block:: python

        bandwidth = 23.44
        nchan = 32768
        dopplertrackfreq = 1420.0
        restfreq = [{'restfreq': 1420.0},
                    {'restfreq': 1420.0, 'deltafreq': -20.0},
                    {'restfreq': 1667.0, 'bandwidth': 11.72, 'nchan': 65536}]


   This example will configure VEGAS to use 3 rest frequencies. The first two windows are centered o`
   1420 MHz with mode 23 of VEGAS using ``bandwidth=23.44`` and ``nchan=32768`` from the main configuration
   block (8 subbands are selected by default for ``bandwidth=23.44``). However, ``deltafreq`` has been used
   as a dictionary key to offset the second window by -20 MHz in the local topocentric frame. A third window
   is centered on 1667 MHz with mode 16 of VEGAS using the ``bandwidth`` and ``nchan`` dictionary keys to 
   override values from the main configuration block.

   This syntax may be used to more precisely configure VEGAS observations and specifies ``restfreq`` as a 
   list of python dictionaries.

   Available dictionary keys are:

   * ``'restfreq'``: float in MHz

     only required key for each dictionary term

   * ``'res'``: float in kHz

     spectral resolution, can be used as an alternative to the ``nchan`` restfreq dictionary key or the ``nchan``
     keyword in the main configuration block to select the VEGAS mode.
         
     .. todo:: Add reference to table 10.1 (observer guide)

   * ``'bank'``: str (``'A'`` :math:`\rightarrow` ``'H'``)

     specifies which VEGAS bank to use. The default is to let the configuration tool select which bank should
     be used (recommended).

   * ``'bandwidth'``: 
     
     same meaning as the standard configuration keyword   

   * ``'nchan'``

     same meaning as the standard configuration keyword  

   * ``'deltafreq'``

     same meaning as the standard configuration keyword  

   * ``'tint'``

     same meaning as the standard configuration keyword  

   * ``'vpol'``

     same meaning as the standard configuration keyword  

   * ``'beam'``

     same meaning as the standard configuration keyword  

   * ``'subband'``

     same meaning as the standard configuration keyword  


   .. note::

        * Key-value pairs specified in the dictionary override configuration keywords specified
          in the main configuration block which in turn override any default values.
        * ``dopplertrackfreq`` must always be set in the main configuration block

        * ``deltafreq`` may still be specified as a single global offset in the main configuration
          block or ommitted to use the default value of zero.

        * ``nchan`` must always be set in the main configuration block, even if that value is 
          overridden by ``nchan`` in the restfreq dictionary.

            
Optional keywords
'''''''''''''''''


``swmode`` (str)
""""""""""""""""

Specifies the switching mode to be used for the observations. The keyword's value is given 
as a string. Te switching schemes are

* 'tp': (Total Power With Cal) - The noise diode is periodically turned on and off for equal 
  amounts of time.

* 'tp_nocal': (Total Power Without Cal) - The noise diode is turned off for the entire scan.

* 'sp': (Switched Power With Cal) - The noise diode is periodically turned on and off for 
  equal amounts of time while another component is in a signal state and then again in a 
  reference state. This is used in frequency switching, where the signal state is one 
  frequency and the reference is another frequency. Similarly beam switching and polarization
  switching change the beams or polarizations so that their signals are sent down two different
  IF paths.

* 'sp_nocal': (Switched Power Without Cal) - The noise diode is turned off while another
  component is switched between a signal and reference state.


.. todo:: Add instructions what to use for receivers that do not use a noise diode.


``swtype`` (str)
""""""""""""""""

Only used when ``swmode='sp'`` or ``swmode='sp_nocal'``. It specifies the type of switching to
be performed. This keyword's values are:

* ``'none'``
* ``'fsw'`` - frequency-switching
* ``'bsw'`` - beam-switching
* ``'psw'`` - polarization-switching

The default value is ``'fsw'`` for all receivers except ``receiver='Rcvr26_40'``, for which the 
default is ``'bsw'``.

``swper`` (float)
"""""""""""""""""
 
Defines the period in seconds over which the full switching cycle occurs. See Table XX  
for recommended minimum switching periods for each VEGAS mode. 

.. todo:: Add reference to table 10.1 from the observer guide.

Default values are 0.2 for ``obstype='continuum'``, 0.04 for ``obstype='pulsar'``, and 1.0 for
any other value for the ``obstype`` keyword. 


``swfreq`` (float, float)
"""""""""""""""""""""""""

Defines the frequency offsets used in frequency switching (``swtype='fsw'``). The value consists
of two comma separated floats which are the pair of frequencies in MHz. The best values for ``swfreq``
are bandwidth/2\ :sup:`n` where n is an integer, so that the frequency switch will be an integer 
number of channels giving less artifacts in data reduction. Default values are 
``swfreq=-0.25*Bandwidth, +0.25*Bandwidth`` for ``swtype='fsw'``, and ``swfreq=0,0``, otherwise.


``tint`` (float)
""""""""""""""""

Specifies the backend's integration (dump) time. The value is a float with units of seconds.
See Table XX for minimum integration times with VEGAS. Default values are

* 10.0 for ``obstype='continuum'``
* tint=swper for ``obstype='spectroscopy'``
* 30.0 for any other value of the ``obstype`` keyword

.. todo:: Add reference to VEGAS table 10.1 in Observer Guide.


``beam`` (str of comma separated int)
"""""""""""""""""""""""""""""""""""""

Specifies which beams are to be used for observations with multi-beam receivers. The keyword value
is a string of comma separated integers. For example ``beam='2'`` would record data for the second
beam and ``beam='3,7'`` would record data for beams 3 and 7. When using the KFPA, ``beam='all'`` 
can be used to record data from all seven beams. This ``beam`` configuration keyword has a different
meaning to the ``beamName`` in observing scans, which usually specifies a tracking beam, not which 
beam to record data for. The default value is ``'1'``.

.. todo:: Add that beam='all' does not only apply to the KFPA but also e.g. Argus.


``nwin`` (int)
""""""""""""""

Specifies the number of frequency windows that will be observed for backends other than VEGAS. The 
value for this keyword is an integer with a maximum value that is backend and receiver dependent.
The number of values given for the ``restfreq`` keyword must be the same as nwin. The default value 
is 1.

.. note:: 

   ``nwin`` does not need to be specified for VEGAS configurations.


``deltafreq`` (depends)
"""""""""""""""""""""""

Specifies offsets in MHz for each spectral window so that ``restfreq`` is not centered in the middle
of the spectral window. ``deltafreq`` can be specified as a single float offset which will be applied
across all windows or in the same manner as ``restfreq``. For example using ``deltafreq`` with 
different types of restfreq syntax as described :ref:`here <\`\`restfreq\`\` (depends)>`. The default 
value is 0.0.


.. todo:: Check what information from Appendix B from Observer Guide should go here.

``vframe`` (str)
""""""""""""""""

Specifies the velocity frame (the inertial reference frame). The keyword value is a string. Allowed
values are

* ``'topo'`` - topocentric, i.e. Earth's surface
* ``'bary'`` - barycenter of solar system
* ``'lsrk'`` - Local Standard of Rest kinematical definition, i.e. typical LSR definition
* ``'lsrd'`` - Local Standard of Rest dynamical definition; rarely used
* ``'galac'`` - center of galaxy
* ``'cmb'``  - relative to Cosmic Microwave Background

The default value is ``'topo'``.


``vdef`` (str)
""""""""""""""

Specifies which mathematical equation (i.e. definition) is used to convert between frequency and velocity.
The keyword value is a string. Allowed values are 

* ``'Optical'`` - :math:`v_{\text{optical}} = c \left(\frac{\nu_0}{\nu} - 1\right)`
* ``'Radio'`` - :math:`v_{\text{radio}} = c \left(1 - \frac{\nu}{\nu_0}\right)`
* ``'Relativistic'`` - :math:`v_{\text{relativistic}} = c \left(\frac{\nu_0^2 - \nu^2}{\nu_0^2 + \nu^2}\right)`


The default value is ``'Radio'``.


Hardware dependent keywords
'''''''''''''''''''''''''''
(in alphabetical order)

Some configuration keywords depend on which backends and receivers are being used. Some 
observations may require one of these keywords while for other observations none may be needed.


``broadband`` (int)
"""""""""""""""""""

This keyword is used to activate the "broadband" 7.5 GHz maximum instantaneous mode of the KFPA by
setting ``broadband=1``. This may only be used with single beam configurations using either beam 1
or beam 2 of the KFPA. 

.. admonition:: Default

   The default value is ``broadband=0``, i.e. broadband mode is turned off.


``dopplertrackfreq`` (float)
""""""""""""""""""""""""""""

Specifies the rest frequency in MHz used to compute the velocity for doppler tracking. When using the 
simple restfreq syntax, the default is the first listed restfreq value.


``nchan`` (int)
"""""""""""""""

Used to determine the number of spectral channels that VEGAS will provide. Available values are listed in 
Table XXX

.. todo:: Add reference to Table 10.1 from observer guide.


.. note:: 

   The following string values designed for use with the now obsolete GBT spectrometer
   may still be used:

   * ``'low'``
   * ``'medium-low'``
   * ``'medium'``
   * ``'medium-high'``
   * ``'high'``

   These string values may be used to distinguish between up to 5 levels of resolution for a given bandwidth. 
   For example, mode 18 of VEGAS could be set by setting ``bandwidth=11.72`` and ``nchan=262144`` or ``nchan='medium-high'``



``noisecal`` (str)
""""""""""""""""""

All receivers below 12 GHz have two noise diodes for calibration signals -- one with an
equivalent brightness temperature at roughly one tenth the system temperature (``'lo'`` 
value). and one nearly equal to the system temperature (``'hi'`` value). This keyword
specifies which noise diode is to be used. Allowed values are ``'low'``, ``'hi'``, and 
``'off'``.

.. admonition:: Default

   The default value is ``'lo'`` except for the Radar backend, for which the default value
   is ``'off'``.


``notchfilter`` (str)
"""""""""""""""""""""

There is a notch filter covering roughly 1200-1310 MHz in the L-band receiver that filters
out an Federal Aviation Administration (FAA) radar signal. This keyword determines if this
notch filter is in place and used by the system or is removed from the receiver's RF path.
Allowed values are ``'In'`` or ``'Out'``.

.. admonition:: Default

   The default value is ``'In'``.


``pol`` (str)
"""""""""""""

Each of the prime focus, L-band, S-band, and C-band receivers have a hybrid that can output
either linear or circular polarization. Additionally the W-band receiver is linear when using 
two beams and circular when using one beam. The ``pol`` keyword specifies whether linear or 
circular polarization is desired for these receivers. Allowed values are ``'Linear'`` and 
``'Circular'``.

.. admonition:: Default

   The default is ``'Circular'`` for the VLBI and Radar backends and ``'Linear'`` otherwise.


``vegas.dm``
""""""""""""


``vegas.fold_bins``
"""""""""""""""""""


``vegas.fold_dumptime``
"""""""""""""""""""""""


``vegas.fold_parfile``
""""""""""""""""""""""


``vegas.numchan``
"""""""""""""""""


``vegas.obsmode``
"""""""""""""""""


``vegas.outbits``
"""""""""""""""""


``vegas.polnmode``
""""""""""""""""""


``vegas.scale``
"""""""""""""""


``vegas.subband`` (int)
"""""""""""""""""""""""

Used by the config tool to select between 23.44 MHz VEGAS modes with single and multiple spectral
windows (see Table XX). Is assumed values ``1`` or ``8``. 

.. todo:: Add reference to table 10.1 from observer guide.

.. admonition:: Default

   The default value is ``8``.



``vegas.vpol`` (str)
""""""""""""""""""""

Specifies which spectral product to record in the FITS file. It assumes the following values:

* ``'self'``: Record the total intensity polarization products.
* ``'cross'``: Record the full Stokes polarization products.
* ``'self1'``: Record the polarization from the first Analog to Digital Converter (ADC) card only.
  There are two ADCs per VEGAS bank, one for each polarization.
* ``'self2'``: Record the polarization from the second ADC only.

.. admonition:: Default

   The default value is ``'self'``



``vlbi.phasecal`` (str)
"""""""""""""""""""""""

This expert keyword turns the VLBI phase cals on or off. The phase cals can run at 1 MHz 
(``'M1'``) or 5 MHz (``'M5'``). Allowed values are ``'off'``, ``'M1'`` or ``'M5'``.



.. todo:: Add CCB configuration keywords to this list.



Expert keywords
'''''''''''''''
(in alphabetical order)

These keywords should only be used by very experienced observers who have expert knowledge of how 
a given backend works or in how the GBT IF system works.



``if0freq`` (float)
"""""""""""""""""""

Used to set the center frequency of the IF after the mixing of the RF signal with the first LO. 
The keyword value is a float with units of MHz.



``if3freq`` (comma-separated list of floats)
""""""""""""""""""""""""""""""""""""""""""""

Used to set the IF input frequency of the backend. The keyword value is a comma separated list
of floats with units of MHz.


 
``ifbw`` (float)
""""""""""""""""

Sets the minimum IF bandwidth to be used in filters within the receiver and in the IF rack. 
The keyword value is a float with units of MHz.



``iftarget`` (float)
""""""""""""""""""""

Specifies the target voltage level to use when balancing the IF rack. The nominal range of the 
IF rack is 0.0 - 10.0 and the linear range is 0.1-5.0.



``lo1bfreq`` (float)
""""""""""""""""""""

Used to set the center frequency of synthesizer used for the alternative first LO, LO1B in MHz.
This keyword is only to be used with the Ka-band receiver. 


``lo2freq`` (comma-separated list of floats)
""""""""""""""""""""""""""""""""""""""""""""

Used to set the frequency values of the eight LO2 synthesizers within the Converter Rack in 
units of MHz.

``polswitch`` (str)
"""""""""""""""""""

Sets the polarization switch for the L-band and X-band receivers. Allowed values are ``'ext'``, 
``'thru'``, and ``'cross'``. 

.. admonition:: Default

   The default value is ``'ext'`` if ``swtype='psw'`` and ``'thru'`` otherwise.


``vhigh`` (float)
"""""""""""""""""

Specifies the maximum velocity to be observed from a group of sources in units of km/s. The use 
of ``vhigh`` is not recommended for frequencies where there can be large amounts of RFI.

.. admonition:: Default

   The default value is ``0.0``

.. todo:: Add context from Appendix C from observer guide.



``vlow`` (float)
""""""""""""""""

Specifies the minimum velocity to be observed from a group of sources in units of km/s. The use 
of ``vlow`` is not recommended for frequencies where there can be large amounts of RFI.

.. admonition:: Default

   The default value is ``0.0``

.. todo:: Add context from Appendix C from observer guide.



``xfer`` (str)
""""""""""""""

Sets the beam switch for the Ku-band, K-band and Ka-band receivers. Allowed values are ``'ext'``, 
``'thru'``, or ``'cross'``. 

.. admonition:: Default

   The default value is ``'ext'`` when ``swtype='bsw'`` and ``'thru'`` otherwise.





