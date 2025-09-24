.. _pulsar_time_obs:

#####################################
Timing Observations of a Known Pulsar
#####################################

.. admonition:: When to Use This Quick Guide

    This quick guide can be used to observe known pulsars with well-measured dispersion measures (DMs) and pulsar timing solutions (e.g. as made using TEMPO).  The most common use-case is pulsar timing observations.  It should not be used to observe fast radio bursts (FRBs), to search for pulsars, to observe pulsars without well-determined DMs and timing solutions, or when one needs to observe single pulses.

    This observing setup makes use of coherent dedispersion.  Coherent dedispersion is a technique for completely removing the intrachannel dispersive delay in real time, before data are written to disk.  Coherent dedispersion will improve scientific data quality and should be used whenever the DM of a pulsar is known.

Overview
========

First, we will define some example configurations. We take advantage of the fact that configuration parameters are specified as strings that can be broken up into different groups and combined when a Configure() command is issued. This allows us to reduce redundant parameter specifications and the opportunities for errors.

Next, we provide a complete example of a simple observing script as well as some tips, tricks, and use of advanced scripting features.

Example Configurations
======================

Configuration Keywords Common to All Pulsar Modes
-------------------------------------------------

The following configuration string is common to all pulsar modes.

.. literalinclude:: scripts/pulsar_time_obs.py
    :language: python
    :lines: 16-27
    :linenos:

Receiver-Specific Configuration Keywords
----------------------------------------

The following configuration keywords are receiver-specific. In this example, we will use the L-Band receiver.

.. literalinclude:: scripts/pulsar_time_obs.py
    :language: python
    :lines: 29-37
    :linenos: 


.. note:: 
    
    - Not every receiver has a notch filter.
    - The value of nwin must match the number of rest frequencies.
    - You should choose a bandwidth that is well-matched to the frequency range of the receiver.  See the Observer’s Guide for receiver frequency ranges.

.. todo:: Remove reference to Observer's Guide, add the table with receiver frequency ranges to GBTdocs.


Common VEGAS Configuration Keywords
-----------------------------------

The following configuration string specifies keywords are common to both the pulsar fold-mode and calibration scans that we will perform.  In this example, we will use the most frequently used parameters for high-precision pulsar timing.

.. literalinclude:: scripts/pulsar_time_obs.py
    :language: python
    :lines: 39-47
    :linenos: 


.. note:: 

    - This configuration will result in frequency channels that are approximately 1.5 MHz wide.  
    - The recommended value of tint depends on the frequency resolution (i.e. the bandwidth and number of channels).  The formula for calculating the recommended tint is $t_{int}  = \frac{16 \times n_{chan}}{BW}
    - The recommended value of vegas.scale depends on the dedispersion mode, bandwidth, and number of channels.  See the VPM Observing Instructions page for recommendations for valid combinations of dedispersion mode/bandwidth/number of channels.

    
VEGAS Keywords Specific to Fold Mode
------------------------------------
These keywords define the setup for observing the known pulsar with a specific period and DM value. 

.. literalinclude:: scripts/pulsar_time_obs.py
    :language: python
    :lines: 49-54
    :linenos:



.. note:: 

    - vegas.fold_parfile must specify a valid TEMPO1 formatted file specific to your pulsar of interest.
    - For further information about the use of the swmode and noisecal parameters, refer to the Observer’s Guide.

.. todo:: Move the relevant content from the Observer's Guide to GBTdocs, replace the vague reference above with the specific reference within GBTdocs.


VEGAS Keywords Specific to Calibration Scans
--------------------------------------------
These keywords specify the setup for taking data that can be used for polarization calibration. Not all science cases will require this, but it is recommended.

.. literalinclude:: scripts/pulsar_time_obs.py
    :language: python
    :lines: 56-60
    :linenos:

.. note:: 

    - For further information about the use of the swmode and noisecal parameters, refer to the Observer’s Guide.

.. todo:: Move the relevant content from the Observer's Guide to GBTdocs, replace the vague reference above with the specific reference within GBTdocs.


Observing Scripts
=================

This is a complete observing script that will perform a polarization calibration scan and a timing observation of a single pulsar.

.. literalinclude:: scripts/pulsar_time_obs.py
    :language: python
    :linenos: 



.. note:: 

    - We do not balance the IF system between the polarization calibration scan and the pulsar scan. This ensures that the instrument response does not change between the two scans.
    - It is highly recommended to perform an AutoPeakFocus() at the beginning of your session - this will ensure the telescope is set up correctly in addition to checking the pointing solution. Note that the PF800 and PF342 receivers only require an AutoPeak().

Tips and Tricks 
===============

We strongly recommend that all observers use a par file that they’ve generated themselves using tempo1.
Files generated with tempo1 should work without issue. If you are uncertain about the provenance of your par file, you can validate it with the following steps.

- `tempo -f [your par file] -z -ZPSR=[pulsar name] -ZOBS=1`
- If there are no issues, tempo will exit without messages and a new file called polyco.dat should appear in the working directory
- Depending on which parameters are in the par file, tempo may print “WARNING: TZ mode” - these impact definition of zero pointing phase but will not prevent observations
- If polyco.dat is not generated, this is not a valid par file. Contact your project friend for assistance.
- Contact your project friend for assistance converting par files from tempo2 to tempo1

Observing Multiple Sources
--------------------------

This script will automatically observe multiple sources one after another. **Here, we include ONLY the parts of the script that differ from the one above.**


.. literalinclude:: scripts/pulsar_time_obs_multiple.py
    :language: python
    :linenos:



Advanced Use of Catalogs
------------------------

Here we demonstrate an advanced use of catalogs in which we specify the full path to a parfile for each source and access this in the script.

First, we define an example catalog:

.. literalinclude:: scripts/pulsar_catalog_parfile.cat
    :language: text
    :linenos:


Now we define the observing script. The “parfile” column from our catalog is read in for each source and substituted into the configuration string. The sources will be observed in the order they appear in the catalog.

.. literalinclude:: scripts/pulsar_time_obs_advCatalog.py
    :language: python
    :linenos:

