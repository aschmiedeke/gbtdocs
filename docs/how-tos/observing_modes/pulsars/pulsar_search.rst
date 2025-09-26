

##########################
Pulsar Search Observations
##########################


.. admonition:: When to Use This Quick Guide

    This quick guide can be used to obtain high time-resolution data when searching 
    for new pulsars, following up on pulsars whose properties are not well known,
    observing multiple pulsars in the same region of the sky (e.g. globular clusters),
    or when observing single pulses from pulsars and fast radio bursts (FRBs).

    We will use two different configurations, one with coherent dedispersion, and one 
    without coherent dedispersion. Coherent dedispersion should be used any time the 
    dispersion measure (DM) of a source is known, either from previous observations or
    from a reliable model estimate.


Overview
========


This quick guide can be used to obtain high time-resolution data when searching for 
new pulsars, following up on pulsars whose properties are not well known, observing 
multiple pulsars in the same region of the sky (e.g. globular clusters), or when 
observing single pulses from pulsars and fast radio bursts (FRBs).

We will use two different configurations, one with coherent dedispersion, and one
without coherent dedispersion. Coherent dedispersion should be used any time the 
dispersion measure (DM) of a source is known, either from previous observations or 
from a reliable model estimate.



Example Configurations
======================


Configuration Keywords Common to Pulsar Search Modes
----------------------------------------------------


The following configuration string is common to both pulsar modes in this tutorial.


.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 23-35



Receiver-Specific Configuration Keywords
----------------------------------------



The following configuration keywords are receiver-specific. In this example, we will
use the L-Band receiver.


.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 37-45


.. note::
    * Not every receiver has a notch filter.
    * The value of nwin must match the number of rest frequencies.
    * You should choose a bandwidth that is well-matched to the frequency range of the
      :ref:`receiver <references/receivers:Receivers>` you are using.


VEGAS Keywords
--------------

Search Mode With Coherent Dedispersion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following configuration string specifies keywords that will configure for a pulsar
search observation that uses coherent dedispersion. Because coherent dedispersion 
completely removes intra-channel dispersive smearing, we usually use wider frequency 
channels in order to achieve higher time resolution, compared to when we do not use 
coherent dedispersion.


.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 47-56


.. note::
    * The value of ``vegas.dm`` is specific to each source. Here we use a value of 100
      but you must change this for each source you are observing.
    * This configuration will result in frequency channels that are approximately 
      1.5 MHz wide.  
    * The recommended value of ``tint`` depends on the frequency resolution (i.e. the 
      bandwidth, :math:`BW`, and number of channels, :math:`n_{chan}`). The formula
      for calculating the recommended integration time :math:`t_{int}` is 
      :math:`t_{int} = \frac{16 \times n_{chan}}{BW}`.
    * The recommended value of ``vegas.scale`` depends on the dedispersion mode, bandwidth,
      and number of channels. See the :ref:`VPM Observing Reference <references/backends/vpm:VPM>`
      for recommendations for valid combinations of dedispersion mode / bandwidth / 
      number of channels.


Search Mode Without Coherent Dedispersion
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following configuration string specifies keywords that will configure for a pulsar
search observation that does not use coherent dedispersion. To minimize intra-channel
dispersive smearing, we use narrow channel bandwidths and longer integration times 
compared to coherent dedispersion.

.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 58-64


.. note::
    * This configuration will result in frequency channels that are approximately 0.4 MHz
      wide.  
    * The recommended value of ``tint`` depends on the frequency resolution (i.e. the bandwidth, 
      :math:`BW`, and number of channels, :math:`n_{chan}`). The formula for calculating the 
      recommended integration time :math:`t_{int}` is :math:`t_{int}  = a * n_{chan} / BW`, 
      where :math:`a` is the accumulation length, which controls the amount of data that is 
      being written out to disk. Here we use a value of :math:`a=32`. We recommend values of 
      32 or 64.
  
      .. important: 

         :math:`a` should never exceed 128.

    * The recommended value of ``vegas.scale`` depends on the dedispersion mode, bandwidth, 
      and number of channels. See the :ref:`VPM Observing Reference <references/backends/vpm:VPM>`
      for recommendations for valid combinations of dedispersion mode / bandwidth / 
      number of channels.




Observing Scripts
=================


:numref:`script-pulsar-search` is a complete observing script that will perform a coherent search.

.. literalinclude:: scripts/pulsar_search.py
    :language: python
    :lines: 1-57,66-106
    :linenos:
    :caption: Script performing a coherent search.
    :name: script-pulsar-search


.. note::
    * We perform the test observation with the same configuration as your search observation 
      to ensure everything is working and nothing changes between the two. Data can be folded 
      as soon as the test pulsar is observed using PRESTO.
    * It is highly recommended to perform an :func:`AutoPeakFocus() <astrid_commands.AutoPeakFocus>`
      at the beginning of your session - this will ensure the telescope is set up correctly 
      in addition to checking the pointing solution. 
   
      .. note:: 

        The PF800 and PF342 receivers only require an :func:`AutoPeak() <astrid_commands.AutoPeak>`.



Tips and Tricks 
===============

We strongly recommend that all observers check their test pulsar data when observing in 
incoherent search mode as soon as the scan is completed. This can be done using PRESTO:

``prepfold -psr [pulsar name] <file_name>``


Observing Multiple Sources
--------------------------

:numref:`script-pulsar-search-multiple-src` will automatically observe multiple sources
one after another. We highlight lines of the script that differ from :numref:`script-pulsar-search`.

.. literalinclude:: scripts/pulsar_search_multiple_src.py
    :language: python
    :linenos:
    :emphasize-lines: 5-9, 37-43, 47-68
    :caption: This script will automatically observe multiple sources one after another.
    :name: script-pulsar-search-multiple-src


Advanced Use of Catalogs
------------------------


Here we demonstrate an advanced use of catalogs in which we specify the DM for each source
and access this in the script.

First, we define an example catalog:

.. literalinclude:: scripts/pulsar_search_advCatalog.py
    :language: text
    :lines: 1-6

Now we define the observing script. The ``dm`` column from our catalog is read in for each 
source and substituted into the configuration string. The sources will be observed in the 
order they appear in the catalog.


.. literalinclude:: scripts/pulsar_search_advCatalog.py
    :language: python
    :lines: 10-


Multiple Bank Configuration
---------------------------

For some receivers a wider bandwidth is available, these receivers allow for observations with
a bandwidth greater than 1250 MHz. The following example outlines a C-Band configuration that 
covers the full bandwidth available from this receiver.


.. literalinclude:: scripts/pulsar_search_multiple_bank.py
    :language: python























