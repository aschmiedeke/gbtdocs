#########################################
Pulsar-Mode Flux Calibration Observations
#########################################

.. admonition:: When to Use This Quick Guide
    
    This quick guide is for observing a flux calibration source. These data can be
    used to create a flux calibration solution with PSRCHIVE, which can then be used
    to calibrate data taken on a pulsar or FRB.

    PSRCHIVE has a built-in list of standard flux calibrators and it is easiest to
    choose a source that is part of this list. We further recommend choosing sources
    that are part of the Perley & Butler (2017) VLA flux calibration catalog and that
    are known to be stable and spatially compact. Some good calibration sources are
    3C196, 3C286, and 3C295.
  
    The PSRCHIVE flux calibration tools are easiest to use when the pulsar and flux 
    calibration data are all taken with the same observing set up (e.g. center 
    frequency, bandwidth, number of frequency channels, polarization state, and 
    dedispersion mode). This quick guide uses the GBT’s L-Band receiver with a center
    frequency of 1500 MHz, bandwidth of 800 MHz, 512 frequency channels, and native 
    linear polarization. It also uses a VEGAS coherent dedispersion mode, even though
    the flux calibration data are not actually dispersed.


Overview
========

First, we will define the configuration. We take advantage of the fact that configuration 
parameters are specified as strings that can be broken up into different groups and 
combined when a :func:`Configure() <astrid_commands.Configure>` command is issued. This 
allows us to reduce redundant parameter specifications and the opportunities for errors.

Next, we provide a complete example of a simple observing script as well as some tips, 
tricks, and use of advanced scripting features.

Example Configuration
=====================

Configuration Keywords Common to All Pulsar Modes
-------------------------------------------------


The following configuration string is common to all pulsar modes.

.. literalinclude:: scripts/pulsar_flux_cal.py
    :language: python
    :lines: 10-21
    :linenos:



Receiver-Specific Configuration Keywords
----------------------------------------

The following configuration keywords are receiver-specific. In this example, we will 
use the L-Band receiver.

.. literalinclude:: scripts/pulsar_flux_cal.py
    :language: python
    :lines: 23-31
    :linenos:


.. note:: 

    - Not every receiver has a notch filter.
    - The value of nwin must match the number of rest frequencies.
    - You should choose a bandwidth that is well-matched to the frequency range of the
      :ref:`receiver <references/receivers:Receivers>` you are using.


VEGAS Configuration
-------------------

Common Keywords
^^^^^^^^^^^^^^^

The following configuration string specifies keywords are common to both the pulsar fold-mode
and calibration scans that we will perform.  In this example, we will use the most frequently 
used parameters for high-precision pulsar timing.


.. literalinclude:: scripts/pulsar_flux_cal.py
    :language: python
    :lines: 33-41
    :linenos:


.. note:: 

    - This configuration will result in frequency channels that are approximately 1.5 MHz wide.  
    - The recommended value of ``tint`` depends on the frequency resolution (i.e. the
      bandwidth, :math:`BW`, and number of channels, :math:`n_{chan}`). The formula
      for calculating the recommended integration time :math:`t_{int}` is 
      :math:`t_{int} = \frac{16 \times n_{chan}}{BW}`.
    - The recommended value of ``vegas.scale`` depends on the dedispersion mode, bandwidth,
      and number of channels. See the :ref:`VPM Observing Reference <references/backends/vpm:VPM>`
      for recommendations for valid combinations of dedispersion mode / bandwidth / 
      number of channels.
      

Keywords Specific to Calibration Scans
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These keywords specify the setup for taking data that can be used for polarization calibration.
Not all science cases will require this, but it is recommended.

.. literalinclude:: scripts/pulsar_flux_cal.py
    :language: python
    :lines: 43-47
    :linenos:


.. note:: 

    - See these links for more information about the following parameters: 
      :ref:`swmode <references/observing/configure:\`\`swmode\`\` (str)>` and 
      :ref:`noisecal <references/observing/configure:\`\`noisecal\`\` (str)>`.

    
    
Observing Scripts
=================

This is a complete observing script that will perform a polarization calibration scan and a timing
observation of a single pulsar.

.. literalinclude:: scripts/pulsar_flux_cal.py
    :language: python
    :linenos:

.. note:: 

    - It is highly recommended to perform an :func:`AutoPeakFocus() <astrid_commands.AutoPeakFocus>`
      at the beginning of your session - this will ensure the telescope is set
      up correctly in addition to checking the pointing solution. 
      
      .. note:: 

        The PF800 and PF342 receivers only require an :func:`AutoPeak() <astrid_commands.AutoPeak>`.

    - We use an :func:`OnOff() <astrid_commands.OnOff>` command to automatically take data at the
      position of the flux calibrator and an offset location 1 degree away in elevation. Both scans 
      are required to create a flux calibration solution using PSRCHIVE.

Tips
====

- A tutorial on how to calibrate pulsar data using PSRCHIVE can be found on the GBO internal computing
  network at ``/home/pulsar_rhel8/tutorials/calibration/instructions.txt``

  .. todo:: Check if that tutorial can be moved to GBTdocs.

- For typical GBT pulsar observing frequencies (300 – 8000 MHz), it is best to choose a calibration 
  source with a flux density of ~1 – 30 Jy.  Choosing a fainter source can lead to low-quality 
  calibration solutions due to low S/N. Choosing brighter sources can make it difficult to optimally
  balance the observing system for both the on- and off-source scans.
- To check the flux density of standard PSRCHIVE calibration sources, use the command 
  ``fluxcal -I [observing frequency in MHz]``

  Here is an example using an observing frequency of 1500 MHz:
    
  .. code-block:: bash

      fluxcal -I 1500

  returning the following output: 

  .. literalinclude:: scripts/fluxcal_output.txt
    :language: text
    :linenos:

