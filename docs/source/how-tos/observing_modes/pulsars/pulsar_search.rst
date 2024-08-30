

##########################
Pulsar Search Observations
##########################


.. admonition:: When to Use This Quick Guide

    This quick guide can be used to obtain high time-resolution data when searching for new pulsars, following up on pulsars whose properties are not well known, observing multiple pulsars in the same region of the sky (e.g. globular clusters), or when observing single pulses from pulsars and fast radio bursts (FRBs).

    We will use two different configurations, one with coherent dedispersion, and one without coherent dedispersion. Coherent dedispersion should be used any time the dispersion measure (DM) of a source is known, either from previous observations or from a reliable model estimate.


Overview
========


This quick guide can be used to obtain high time-resolution data when searching for new pulsars, following up on pulsars whose properties are not well known, observing multiple pulsars in the same region of the sky (e.g. globular clusters), or when observing single pulses from pulsars and fast radio bursts (FRBs).

We will use two different configurations, one with coherent dedispersion, and one without coherent dedispersion. Coherent dedispersion should be used any time the dispersion measure (DM) of a source is known, either from previous observations or from a reliable model estimate.



Example Configurations
======================


Configuration Keywords Common to Pulsar Search Modes
----------------------------------------------------


The following configuration string is common to both pulsar modes in this tutorial.




.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 1-15



Receiver-Specific Configuration Keywords
----------------------------------------



The following configuration keywords are receiver-specific. In this example, we will use the L-Band receiver.


.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 19-27


.. note::
    * Not every receiver has a notch filter.
    * The value of nwin must match the number of rest frequencies.
    * You should choose a bandwidth that is well-matched to the frequency range of the receiver.  See the Observer’s Guide for receiver frequency ranges.

.. todo::
    Observers Guide reference


VEGAS Keywords Specific to Search Mode With Coherent Dedispersion
-----------------------------------------------------------------

The following configuration string specifies keywords that will configure for a pulsar search observation that uses coherent dedispersion. Because coherent dedispersion completely removes intra-channel dispersive smearing, we usually use wider frequency channels in order to achieve higher time resolution, compared to when we do not use coherent dedispersion.


.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 30-37


.. note::
    * The value of vegas.dm is specific to each source. Here we use a value of 100 but you must change this for each source you are observing.
    * This configuration will result in frequency channels that are approximately 1.5 MHz wide.  
    * The recommended value of tint depends on the frequency resolution (i.e. the bandwidth and number of channels).  The formula for calculating the recommended tint is tint  = 16 * nchan / BW
    * The recommended value of vegas.scale depends on the dedispersion mode, bandwidth, and number of channels.  See the `VPM Observing Reference <https://gbtdocs.readthedocs.io/en/latest/references/observing_modes/pulsar_reference.html>`_ page for recommendations for valid combinations of dedispersion mode/bandwidth/number of channels.

VEGAS Keywords Specific to Search Mode Without Coherent Dedispersion
--------------------------------------------------------------------

The following configuration string specifies keywords that will configure for a pulsar search observation that does not use coherent dedispersion. To minimize intra-channel dispersive smearing, we use narrow channel bandwidths and longer integration times compared to coherent dedispersion.

.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 40-46


.. note::
    * This configuration will result in frequency channels that are approximately 0.4 MHz wide.  
    * The recommended value of tint depends on the frequency resolution (i.e. the bandwidth and number of channels).  The formula for calculating the recommended tint is tint  = a * nchan / BW where a is the accumulation length, which controls the amount of data that is being written out to disk. Here we use a value of 32. We recommend values of 32 or 64. a should never exceed 128.
    * The recommended value of vegas.scale depends on the dedispersion mode, bandwidth, and number of channels.  See the `VPM Observing Reference <https://gbtdocs.readthedocs.io/en/latest/references/observing_modes/pulsar_reference.html>`_ for recommendations for valid combinations of dedispersion mode/bandwidth/number of channels.




Observing Scripts
=================


This is a complete observing script that will perform a coherent search.

.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 49-147


.. note::
    * We perform the test observation with the same configuration as your search observation to ensure everything is working and nothing changes between the two. Data can be folded as soon as the test pulsar is observed using PRESTO.
    * It is highly recommended to perform an AutoPeakFocus() at the beginning of your session - this will ensure the telescope is set up correctly in addition to checking the pointing solution. Note that the PF800 and PF342 receivers only require an AutoPeak().



Tips and Tricks 
===============

We strongly recommend that all observers check their test pulsar data when observing in incoherent search mode as soon as the scan is completed. This can be done using PRESTO.

``prepfold -psr [pulsar name] <file_name>``


Observing Multiple Sources
--------------------------

This script will automatically observe multiple sources one after another. **Here, we include ONLY the parts of the script that differ from the one above.**

.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 150-194


Advanced Use of Catalogs
------------------------


Here we demonstrate an advanced use of catalogs in which we specify the DM for each source and access this in the script.

First, we define an example catalog:

.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 199-204

Now we define the observing script. The “dm” column from our catalog is read in for each source and substituted into the configuration string. The sources will be observed in the order they appear in the catalog.


.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 207-241


Multiple Bank Configuration
---------------------------

For some receivers a wider bandwidth is available, these receivers allow for observations with a bandwidth greater than 1250 MHz. The following example outlines a C-Band configuration that covers the full bandwidth available from this receiver.


.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 244-313























