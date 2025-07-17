.. _mustang2_find_src:

#############################################################
How to Get a "Quick Look" of a Source Observed with MUSTANG-2
#############################################################
This is a guide on how to determine if your source has been observed by MUSTANG-2, for how long, and how to make a "quick look" image.

In order to determine if MUSTANG-2 has observed a source and if so, how much time has been spent on that source, you can run a script called ``find_src`` written by Simon Dicker. This script can find MUSTANG-2 observations by source name or position. It can optionally process the observations by making maps via the MIDAS pipeline or produce calibrated timestreams. Note that MIDAS maps produced by ``find_src`` are quick look and should not be used for science. But you *can* use the calibrated timestreams for science.

1. Running Quick Look Script: ``find_src``
==========================================
The script is located on the GBO network at ``/users/penarray/Public/find_src``. To run the script cd to ``/users/penarray/Public/`` then simply execute it with ``find_src`` via the command line or just provide the full path. For example, if you wanted to know about any observations of the galaxy cluster MOO J1142+1527, you would execute ``find_src MOO_1142``. 

We note that if you are searching for an object by name, you will need to know what the name of the object was in the catalog used by the AstrID scripts when the target was observed. Often the name used in the scripts is not the full name. 

If you want to input multiple source names, assuming there are no bugs the source argument can be a comma separated list and each item can contain wildcards. It is easy to get a name wrong (moo1142 is not MOO1142). If you are unsure what names were used in AstrID, the best solution is to search by location.

For full usage instructions use: ``find_src -h``

2. Output of ``find_src``
=========================
``find_src`` prints out the following information:
	- The sessions in which the source was observed. In each session:
		- Total time on source 
		- Total number of scans
		- Number of potentially good scans
		- Time on source from potentially good scans only
		- A list of the scan numbers (with length of scan)
	- The total number of scans on this source that were found (with and without bad scans)
	- The total number of minutes spent observing this source (with and without bad scans)

3. Info about ``find_src``
==========================
What ``find_src`` really does is to generate IDL code and run it.

Every day at 9:30am a script *should* run and updates the following files at GBO: ``sources_current.txt``, ``sources_current.txt.sav``, and ``sources_current.txt.short`` which are located in ``/users/penarray/Public/``. A digital superset of this data is in the IDL save file source.txt.sav. This file also contains information such as elevations and scan centers. Note that  the start of ``sources_current.txt`` contains a list of all MUSTANG2 observations *ever*.

For those that do not use IDL the bash command ``/users/penarray/Public/find_src <options> [src_name|RA_DEC]`` can be used not only to find which projects have observed sources but to make MIDAS maps or calibrated timestreams suitable for use with MINKASI. Full documentation can be found by running this command without arguments. This command is still "beta" (i.e. it works but may have bugs or extra feature requests which you should tell Simon Dicker about).

Note that the existence of a scan in these files does not imply that it is good data, only that it exists. Currently the routine checks for scans known to crash IDL. If any are found (they are rare), they are labeled as "Bad" and are marked with a ``!`` in the output. There is also the ``-b`` flag which is a list of scans not to include. These will then be marked with a ``#`` in the output and excluded from the analysis. Scans that don't crash IDL and the user did not mark as bad, are labeled as "potentially" good in the code output. These "potentially" good scans are labeled as such so that the user knows that no other screening other than above has been applied to the scans.

