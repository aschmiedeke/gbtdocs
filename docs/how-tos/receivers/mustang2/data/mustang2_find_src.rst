.. _mustang2_find_src:

#######################
How to Use ``find_src``
#######################
This is a guide on how to use the script ``find_src`` (written by Simon Dicker) to determine if a source has been observed by MUSTANG-2, for how long, make calibrated TODs, and make a MIDAS image of the calibrated data. This script can find MUSTANG-2 observations by source name or position. It can optionally process the observations by making maps via the MIDAS pipeline using calibrated data or produce calibrated timestreams. 

1. General info about ``find_src``
==================================
The script is located on the GBO network at ``/users/penarray/Public/find_src``. For full documentation and usage instructions use: ``/users/penarray/Public/find_src -h``.

Send any requests or bug reports to Simon Dicker. 

1.1 Nitty gritty details of ``find_src``
----------------------------------------
What ``find_src`` really does is to generate IDL code and run it.

Every day at 9:30am a script *should* run and updates the following files at GBO: 
``sources_current.txt``, ``sources_current.txt.sav``, and ``sources_current.txt.short`` which are located in ``/users/penarray/Public/``. A digital superset of this data is in the IDL save file source.txt.sav. This file also contains information such as elevations and scan centers. Note that the start of ``sources_current.txt`` contains a list of all MUSTANG2 observations *ever*.

Note that the existence of a scan in these files does not imply that it is good data, only that it exists. Currently the routine checks for scans known to crash IDL. If any are found (they are rare), they are labeled as "Bad" and are marked with a ``!`` in the output. There is also the ``-b`` flag which is a list of scans not to include. These will then be marked with a ``#`` in the output and excluded from the analysis. Scans that don't crash IDL and the user did not mark as bad, are labeled as "potentially" good in the code output. These "potentially" good scans are labeled as such so that the user knows that no other screening other than above has been applied to the scans.

2. Use ``find_src`` to get summary of observing info
====================================================

2.1 Excute ``find_src``
-----------------------
To run ``find_src`` to get a summary of the observing information, use the full path to ``find_src`` with a source name after it. For example, if you want to know about any observations of the galaxy cluster MOO J1142+1527, you would execute ``/users/penarray/Public/find_src MOO_1142*``

.. note:: 

    Note that when you run ``find_src`` you must be in a directory that you have write permissions (e.g. your home directory). 

.. note:: 

	If you are searching for an object by name, you will need to know what the name of the object was in the catalog used by the AstrID scripts when the target was observed. Further, often suffixes are added to the source name in the script (for example when using the offset script it adds `_off_1p5` to the source name). Thus, you'll typically want to add a star to the end of the name. So its best to just add the star by default when searching by source name. For example, ``find_src MOO_1142*``.

If you want to input multiple source names, assuming there are no bugs the source argument can be a comma separated list and each item can contain wildcards. It is easy to get a name  wrong (moo1142 is not MOO1142). If you are unsure what names were used in AstrID, the best solution is to search by location.

2.2 Info Provided by ``find_src`` 
---------------------------------
When running ``find_src`` to get a summary about the observing statistics associated with a science target, it will print out the following information:
	- The sessions in which the source was observed. In each session:
		- Total time on source 
		- Total number of scans
		- Number of potentially good scans
		- Time on source from potentially good scans only
		- A list of the scan numbers (with length of scan)
	- The total number of scans on this source that were found (with and without bad scans)
	- The total number of minutes spent observing this source (with and without bad scans)


3. Use ``find_src`` to produce calibrated data products
=======================================================
You can also use ``find_src`` to produce a calibrated MIDAS map of your science source and to produce calibrated TODs (which can be used as input into minkasi).

In order to make a MIDAS calibrated map (and SNR map) of a source the call to find_src looks like this ``/users/penarray/Public/find_src -m MOO_1142*``.

.. note::

	If you are using any flags with find_src the target name needs to come at the end of the command. For example, ``/users/penarray/Public/find_src -p TGBT25B_608_12 -P /path/to/put/maps/ -m MACS0647*``

.. attention::
	
	It is not guaranteed that the default parameters for MIDAS used by ``find_src`` are optimal (and/or will produce a good map). A manual check on the filtering parameters and the resulting map is warranted.

.. note::

	``find_src`` will only include calibrated data in the maps that it makes. So for ``find_src`` to include a session in the map it makes, calibration has to have been done on that session. 

.. note::

	``find_src`` will by default include ALL scans that have been calibrated and  match the source name given. So if you want specific scans and/or sessions to be excluded you need to explicitly tell ``find_src`` that.
