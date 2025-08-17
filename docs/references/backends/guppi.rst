
GUPPI
-----

The Green Bank Ultimate Pulsar Processing Instrument (GUPPI) was previously the main pulsar backend for the GBT.
It is retired as of January 2021 and has been replaced by :ref:`VEGAS Pulsar Modes (VPM) <VPM>`.


Transitioning from GUPPI to VPM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Experienced pulsar observers will recognize that GUPPI and VPM observing are very similar, especially the 
parameters used in scheduling blocks. The following table summarizes the similarities and some differences
between GUPPI and VPM.

**Astrid**: Most ``"guppi."`` parameters can be replaced with ``"vegas."``. The exceptions are ``guppi.datadisk``,
which has no VPM equivalent.

**File names:** VPM output file names include a new element, the number of seconds after midnight UTC.
``vegas_<MJD>_<secUTC>_<sourceName>_<scanNumber>_<fileNumber>.fits``
``vegas_<MJD>_<secUTC>_<sourceName>_cal_<scanNumber>_<fileNumber>.fits``

The table below can be used a cheat-sheet for navigating between some common GUPPI and VPM tasks. 

.. csv-table:: Quick Reference for Transitioning from GUPPI to VPM
    :file: material/guppi2vpm.csv
    :header-rows: 1
    :class: longtable
    :widths: 1 1 1

.. note::

    The asterisk denotes a shortcut for ``/lustre/gbtdata``.




