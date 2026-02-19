.. _cycspec:

############################################
Cyclic Spectroscopy Observations of a Pulsar
############################################

.. admonition:: When to Use This Quick Guide

   This quick guide can be used to obtain the cyclic spectrum of known
   pulsars.  Cyclic spectroscopy (CS) can be used to resolve
   narrow-bandwidth scintles without sacrificing pulse phase
   resolution.  Under certain circumstances it can also be used to
   measure the impulse response function (IRF) of the interstellar
   medium and deconvolve it from a pulsar's intrinsic profile (i.e.,
   to remove scattering).  See `Demorest (2011)
   <https://ui.adsabs.harvard.edu/abs/2011MNRAS.416.2821D/abstract>`_
   for an introduction to CS, and `Walker et al.(2013)
   <https://ui.adsabs.harvard.edu/abs/2013ApJ...779...99W/abstract>`_,
   `Dolch et al. (2021)
   <https://ui.adsabs.harvard.edu/abs/2021ApJ...913...98D/abstract>`_,
   and `Turner et al. (2025)
   <https://ui.adsabs.harvard.edu/abs/2025ApJ...989..228T/abstract>`_
   for guidelines on using CS to deconvolve the IRF.

Overview
========

First, we will define the configurations used for calibration and
pulsar observations, taking advantage of Python syntax to break the
configuration parameters into groups that can be combined when a
:func:`Configure() <astrid_commands.Configure>` command is
issued. This allows us to reduce redundant parameter specifications
and the opportunities for errors.

Next, we provide a complete example of a simple observing script that
will perform flux and polarization calibration observations, as well as a
pulsar observations.

Example Configurations
======================

Configuration Keywords Common to All Pulsar Modes
-------------------------------------------------

The following configuration string is common to all pulsar modes.

.. literalinclude:: scripts/cycspec_obs.py
    :language: python
    :lines: 20-31
    :linenos:

Receiver-Specific Configuration Keywords
----------------------------------------

The following configuration keywords are receiver-specific. In this
example, we will use the ultrawideband receiver (UWBR).

.. literalinclude:: scripts/cycspec_obs.py
    :language: python
    :lines: 33-40
    :linenos: 

.. note:: 

   - We use three frequency windows (indicated by the three rest
     frequencies and `nwin = 3`) to cover the full bandwidth of UWBR.
   - The rest frequencies are chosen such that the frequency windows
     overlap by 187.5 MHz.  This avoids filters near the edge of each
     frequency window and ensures complete coverage of the full UWBR
     frequency range.
   - The bandwidth specified here is that of a single frequency
     window.  When accounting for the overlap mentioned above, the
     total bandwidth is 3375 MHz.

Common VEGAS and Cyclic Spectroscopy Configuration Keywords
-----------------------------------------------------------

Recall that the CS backend operates in parallel with VEGAS, producing
both cyclic spectra and traditional VEGAS data products.  The
following configuration string specifies keywords are common to both
the pulsar fold-mode and calibration scans that we will perform with
VEGAS and CS.  In this example, we will use the most frequently used
parameters for high-precision pulsar timing.

.. literalinclude:: scripts/cycspec_obs.py
    :language: python
    :lines: 42-50
    :linenos: 

.. note:: 

   - The number of channels specified here are those of a single
     frequency window.  
   - This configuration will result in frequency channels that are
     approximately 1.5 MHz wide.
   - The recommended value of ``vegas.scale`` depends on the
     dedispersion mode, bandwidth, and number of channels. See the
     :ref:`VPM Observing Reference <references/backends/vpm:VPM>` for
     recommendations for valid combinations of dedispersion mode /
     bandwidth / number of channels.

Configuration Keywords Specific to Cyclic Spectroscopy
------------------------------------------------------

These keywords enable and define the setup of the CS backend.

.. literalinclude:: scripts/cycspec_obs.py
    :language: python
    :lines: 65-70
    :linenos:

.. note::

   - We use 128 cyclic channels per VEGAS channel.  Given the number
     of channels used above, the final frequency resolution of the CS
     data will be approximately 11.44 kHz.
   - See :ref:`Allowable Observing Parameters
     <references/backends/cycspec:Allowable Observing Parameters>` for
     other combinations of `vegas.numchan`, `vegas.ncyc`, and
     `vegas.cycspec_num_bins`


 Keywords Specific to Fold Mode
-------------------------------

These keywords define the setup for observing the known pulsar.  These
keywords will be passed to both VEGAS and the CS backend.

.. literalinclude:: scripts/cycspec_obs.py
    :language: python
    :lines: 52-57
    :linenos:

.. note:: 

    - `vegas.fold_parfile` must specify a valid TEMPO1 formatted file
      specific to your pulsar of interest.
    - See these links for more information about the following parameters: 
      :ref:`swmode <references/observing/configure:\`\`swmode\`\` (str)>` and 
      :ref:`noisecal <references/observing/configure:\`\`noisecal\`\` (str)>`.

Keywords Specific to Calibration Scans
--------------------------------------

These keywords specify the setup for taking data that can be used for
flux and polarization calibration.  These keywords will be passed to
both VEGAS and the CS backend.

.. literalinclude:: scripts/cycspec_obs.py
    :language: python
    :lines: 59-63
    :linenos:

.. note:: 

    - See these links for more information about the following
    parameters: :ref:`swmode
    <references/observing/configure:\`\`swmode\`\` (str)>` and
    :ref:`noisecal <references/observing/configure:\`\`noisecal\`\`
    (str)>`.

Observing Scripts
=================

:numref:`script-cycspec-obs` is a complete observing script that will
perform a flux and polarization calibration scans, followed by an
observation of a single pulsar.

.. literalinclude:: scripts/cycspec_obs.py
    :language: python
    :linenos: 
    :caption: This script will perform flux and polarization
              calibrations scans followed by a CS and VEGAS pulsar
              observation.
    :name: script-cycspec-obs

.. note:: 

   - We use a flux calibration source from the `Perley and
     Butler (2017)
     <https://ui.adsabs.harvard.edu/abs/2017ApJS..230....7P/abstract>`_
     catalog.  Be sure to select a source that is up during your
     observation session.  You should also select a stable source.
     Choosing a built-in source from the PSRCHIVE software package
     will simplify data processing.
   - We do not balance the IF system between the polarization
     calibration scan and the pulsar scan. This ensures that the
     instrument response does not change between the two scans.
   - It is highly recommended to perform an :func:`AutoPeakFocus()
     <astrid_commands.AutoPeakFocus>` at the beginning of your
     session - this will ensure the telescope is set up correctly in
     addition to checking the pointing solution.

Additional Information
======================

.. note::

   Always start your observing session by taking a short (1--2 minute)
   scan of a bright, known pulsar.  This is especially important for
   the CS backend since data will only appear after a scan has ended.
   By taking a short scan on a well-known source, you can check that
   the system is properly configured using fully processed within the
   first few minutes of your observing session.

You should :ref:`Cyclops <references/backends/cycspec:Using Cyclops to
Monitor Your CS Observations>` to monitor data acquisition and
processing during and after your observation.  Specifically:

* Once the CS backend has been configured, check that the observing
  mode and various parameters are set properly using Cyclops.
* Once you have started recording data, check the quality of the
  baseband data using the Cyclops Quality Check pages or that scan.
* Check in on the processing status of your data using Cyclops after
  your session has ended, and contact the GBT operator if processing
  has failed for some reason.

You should also use the VEGAS tools to check input power levels and
the health of the VEGAS backend.

Once a scan ends, unmerged data for each bank should start to appear
in your project area in `/stor/gbtdata`, and processing should finish
within :math:`2\times` the scan duration.
