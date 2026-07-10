.. _mustang2_find_src:

#######################
How to Use ``find_src``
#######################
This is a guide on how to use the script ``find_src`` (written by Simon Dicker) to determine if a source has been observed by MUSTANG-2, for how long, make calibrated TODs, and make a MIDAS image of the calibrated data. This script can find MUSTANG-2 observations by source name or position. It can optionally process the observations by making maps via the MIDAS pipeline using calibrated data or produce calibrated timestreams. 

.. attention::

	A reminder that the possible data products are listed :ref:`here <mustang2_deliv>`.

1. General info about ``find_src``
==================================
The script is located on the GBO network at ``/users/penarray/Public/find_src``. For full documentation and usage instructions use: ``/users/penarray/Public/find_src -h``.

Here is an overview of the main applications of ``find_src``: 

.. _tab-receivers-M2-find_src:

.. table:: Main Applications of ``find_src``

	+--------------------------------------------+---------------------------+----------------------------------------------------------------------------------------------+
	| Intention                                  | Command example           | Notes                                                                                        |
	+============================================+===========================+==============================================================================================+
	| Find scans on target (Section 2)           | ``find_src M00_1142*``    | Outputs to screen a list of scans on the target, with flags for bad scans.                   |
	+--------------------------------------------+---------------------------+----------------------------------------------------------------------------------------------+
	| Make (calibrated) MIDAS map(s) (Section 3) | ``find_src -m M00_1142*`` | Makes maps per scan and coadds. If filtering parameters aren't specified, defaults are used. |
	+--------------------------------------------+---------------------------+----------------------------------------------------------------------------------------------+
	| Make (calibrated) TODs (Section 3)         | ``find_src -M M00_1142*`` | Makes calibrated TODs (e.g. for use with WITCH). Data "cleaned", but not filtered.           |
	+--------------------------------------------+---------------------------+----------------------------------------------------------------------------------------------+

.. :ref:`Find scans on target <how-tos/receivers/mustang2/data/mustang2_find_src:2. Use ``find_src`` to get summary of observing info>`

.. note:: 

	Send any requests or bug reports to Simon Dicker. 

Any usage of find_src starts with find_src and *ends* with the target name or location. 

1.1 Background of ``find_src``
------------------------------
What ``find_src`` really does is to generate IDL code and run it.

Every day at 9:30am a script *should* run and updates the following files at GBO: 
``sources_current.txt``, ``sources_current.txt.sav``, and ``sources_current.txt.short`` which are located in ``/users/penarray/Public/``. A digital superset of this data is in the IDL save file source.txt.sav. This file also contains information such as elevations and scan centers. Note that the start of ``sources_current.txt`` contains a list of all MUSTANG2 observations *ever*.

Note that the existence of a scan in these files does not imply that it is good data, only that it *exists*. Currently the routine checks for scans known to crash IDL. If any are found (they are rare), they are labeled as "Bad" and are marked with a ``!`` in the text written to the terminal (stdout). There is also the ``-b`` flag for the ``find_src`` command. The user can manually make a list of scans that they have deemed should not be included in the map making process then input the file path to this list of bad scans after the ``-b`` flag (see ``find_src -h`` for more details). Both of these types of flagged scans (those that crash IDL and those that the user marked as bad) will then be marked with a ``#`` in the output and excluded from the analysis. Scans that don't crash IDL and the user did not mark as bad, are labeled as "potentially" good in the code output. These "potentially" good scans are labeled as such so that the user knows that no other screening other than above has been applied to the scans.

.. attention::

	The user should not expect ``find_src`` to produce an exhaustive list of bad scans. It is recommended that the user inspects each scan in some way to determine what scans shouldn't be included in analysis (as in whether the data is not of good quality or if it crashes IDL).

2. Use ``find_src`` to get summary of observing info
====================================================

2.1 Excute ``find_src``
-----------------------
To run ``find_src`` to get a summary of the observing information, use the full path to ``find_src`` with a source name after it. For example, if you want to know about any observations of the galaxy cluster MOO J1142+1527, you would execute ``/users/penarray/Public/find_src MOO_1142*``

.. note:: 

    Note that when you run ``find_src`` you must be in a directory that you have write permissions (e.g. your home directory). 

.. note:: 

	If you are searching for an object by name, you will need to know what the name of the object was in the catalog used by the AstrID scripts when the target was observed. Further, often suffixes are added to the source name in the script (for example when using the offset script it adds `_off_1p5` to the source name). Thus, you'll typically want to add a star to the end of the name. So its best to just add the star by default when searching by source name. For example, ``find_src MOO_1142*``.

If you want to input multiple source names, assuming there are no bugs the source argument can be a comma separated list and each item can contain wildcards. It is easy to get a name wrong (moo1142 is not MOO1142). If you are unsure what names were used in AstrID, the best solution is to search by location.

``find_src`` can also search by RA,Dec which avoids requiring knowing the naming nomenclature used by PI/Scheduling Block.

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

.. note::

	You can find a rubric for determining which analysis pipeline to use `here <https://safe.nrao.edu/wiki/bin/view/GB/Pennarray/DataReductionGuide>`_.

3.1 Making calibrated maps via MIDAS
------------------------------------

3.1.1 Default usage
-------------------
The base command to make calibrated maps via MIDAS is ``/users/penarray/Public/find_src -m <source_name>``.

Notes on using ``find_src`` to make calibrated maps via MIDAS:
	- it uses ``quickm2map.pro``, which is our legacy MIDAS mapmaker
	- the most impactful parameter(s) are given by the variable ``ffilt``, whose default value is [0.07,49.0]. The principle concern is the first value, which represents the frequency at which the data (TODs) are high-pass filtered. 0.07 Hz is moderate value. You can try to recover larger scale signal by pushing this down to 0.06 or 0.05, but the maps will tend to also have larger noise (and less white noise) by doing this. It is exceedingly rare that below 0.05 is advantageous. To change the default high-pass value to, say, 0.06, you can run ``find_src -m MOO_1142* -f 0.06``.
	- another impactful parameter can be ``PCA``, whose default value is 3. This indicates the number of principle components which are removed from the TODs. A higher number indicates greater filtering, though the changes are usually not that substantial. There is not a single option that allows the user to change this (easily, directly).
	- You may also want to run ``find_src -m -N <source_name>``, where the ``N`` will produce additional figures (added to a ``Figures/`` subfolder of the output path) and an ascii (txt) output with a name similar to ``NoisePerScan_MIDAS_0f070-to-49f0Hz_.txt``.  The figures and output may help the user assess data quality beyond what may be previously noted (e.g. regarding scans that crash IDL or that have otherwise been flagged by the MUSTANG-2 team). The user can compile a list of bad scans and supply them with ``find_src -b <file_of_bad_scans>``.

.. attention::
	
	It is not guaranteed that the default parameters for MIDAS used by ``find_src`` are optimal (and/or will produce a good map). A manual check on the filtering parameters and the resulting map is warranted.

.. note::

	``find_src`` will only include calibrated data in the maps that it makes. So for ``find_src`` to include a session in the map it makes, calibration has to have been done on that session. 

.. note::

	``find_src`` will by default include ALL scans that have been calibrated and match the source name or location (within search radius). So if you want specific scans and/or sessions to be excluded you need to explicitly tell ``find_src`` that.

3.1.2 Editing MIDAS parameters
------------------------------
To change the defaults more broadly, you may wish to make a copy of ``/users/penarray/Public/m2/reduction_scripts/shell_integration/MIDAS_conf.pro`` to an appropriate directory (where you have write permission), and perhaps alter the name as you see fit. For this example, suppose user emoravec copies the configuration module to ``/users/emoravec/MIDAS_emoravec_conf.pro``. After editing parameter values in the copied file, this can be run with find_src as 
``/users/penarray/Public/m2/reduction_scripts/shell_integration/find_src -m MOO_1142* -C /users/emoravec/MIDAS_emoravec_conf.pro``

What changes might one make to the configuration file (module)? As above, you could change the values of ``PCA``. Anything 2 or higher is fine. ``PCA=1`` will actually revert to PCA=3 inside quickm2map.pro. This is done largely because PCA=1 should be equivalent to subtracting a common-mode, which is done by setting the input keyword cmsub to anything non-zero (generally just 1). That is, if using ``cmsub``, it’s best to set ``PCA=0`` and ``cmsub=1``. You also have the option to set a polynomial timescale with the variable poltime. By setting ``poltime`` (which only works with cmsub), the polynomial order will be calculated such that variations on the timescale of ``poltime`` should roughly be fitted. It’s suggest that you keep ``poltime`` above the scan period (e.g. ``poltime=30`` corresponds to 30 seconds, and is generally fine. Larger values will correspond to fewer modes being fit and subtracted, i.e. less filtering.)

.. note::

	The ability for a typical user to making ancillary MIDAS data products is under development. In lieu of a user producing ancillary data products, you can download a repository with the standard transfer function for various scan sizes :download:`here </_static/mustang2_documents/transfer_functions.zip>` and if an average beam is sufficient for your science, you can :download:`a python script </_static/mustang2_documents/AverageM2Beam.py>` that creates an average M2 beam.

3.2 Making calibrated timestreams
---------------------------------
You can produce the calibrated timestreams (a.k.a. time ordered data = TODs) by executing ``/users/penarray/Public/find_src -M <source_name>``. You can then use these calibrated TODs as input to `minkasi <https://github.com/sievers/minkasi>`_ or `witch <https://github.com/MUSTANG-SZ/WITCH>`_.



