.. _mustang2_obs_scripts:

##########################################
How to Prepare MUSTANG-2 Observing Scripts
##########################################
You are expected to have your scripts ready **several hours before** the time of your observation. Ideally at the start of the observing semester. You will likely receive an email from your project friend spurring you to do this.

1. Copy script templates into Astrid
====================================
The M2 instrument team has created template observing scripts which are located in: ``/users/penarray/Public/m2_template_scripts/``. 

If you are creating the scripts for the first time for your project, you will want to copy the following templates into your project directory:
    #. Standard calibration scripts
        * ``1_m2setup``
        * ``2_m2oof``
        * ``3_m2quickDaisyOOF``
        * ``4_m2quickDaisyPC``
    #. Science script. If your science requires a typical observing strategy of a daisy of a certain radius, copy one of the science scripts labeled ``5_XXX`` with the radius listed in the file name (e.g. r3 is a daisy with a radius of 3').
	.. note::

		The radius of the daisy will depend on your science - reach out to the M2 instrument team for guidance.
	           
The scripts ``m2quickDaisy`` and ``skydip`` are extra but can be of use.

To copy these scripts into your project directory in Astrid, first open Astrid and navigate to your project (first go to the observing semester then to your full project code). Then click ``File`` → ``Import from file...``  → ``/users/penarray/Public/m2_template_scripts/`` → ``Open`` at which point the script will appear in the Astrid window. Save this script to your project directory by ``Save to Database`` and enter the name of the script and hit ``Save``. You will have to open each template script this way and save each one.

Read the README (``/users/penarray/Public/m2_template_scripts/README.txt``) for instructions on editing these scripts once you have them in your project directory.

2. Make your science target catalog
===================================
The M2 instrument team is now requesting that all science target catalogs be put in ``/users/penarray/Public/Catalogs/Science_catalogs/Catalogs_YourObservingSemester/``. If your semester does not yet exist please contact the M2 instrument team. You can either make your catalog either directly the appropriate folder in the penarray directory or make it in your home directory and copy it over. 

Example catalogs can be found in any of the folders in ``/users/penarray/Public/Catalogs/Science_catalogs/``. But a basic catalog will look like the following:

.. code::

	format=spherical
	coordmode=j2000
	head= name ra dec
	objectName1 13:22:56.3 -02:28:15
	objectname2 22:07:11.6 +07:57:23

For more information regarding catalogs, see the Catalogs section (section 5.3) of the `Observers guide <http://www.gb.nrao.edu/scienceDocs/GBTog.pdf>`_.

2.1 Naming Conventions
----------------------
We request that you name your catalog in the following way: ``AGBTSemester_ProjectCode.cat``. For example for a catalog for project AGBT23B_005 the catalog would be ``/users/penarray/Public/Catalogs/Science_catalogs/Catalogs_23B/AGBT23B_005.cat``. Note that catalog files should have the ``.cat`` extension in order for CLEO to automatically pick them up.

2.2 Catalog Permissions
-----------------------
At the end of the day, your catalog needs to have the following permissions: ``-rw-rw-r--``. By default it will have ``-rw-r--r--``. You need to add the write permission for the ``observer`` group so that others on the M2 instrument team can edit the catalog if they need to. To do this you can either do this when you copy over your catalog with 

.. code:: bash

	rsync -v /path/to/cats/* ~penarray/Public/Catalogs/Science_catalogs/yourCatalog.cat --chmod=g+w 

or if you copied your catalog over to ``/users/penarray/Public/Catalogs/Science_catalogs/Catalogs_YourObservingSemester/`` just simply change the permissions of the catalog with

.. code:: bash

	chmod g+w yourCatalog.cat

2.3 Update Path for Catalog in Scripts
--------------------------------------
Once you have created your catalog you can update the filepath to the catalog in your science scripts (``5_XXX``) and load them into the Scheduler & Skyview.


3. Choose your calibrators
==========================
You are expected to have your calibrator sources planned out **at least a few hours before** the time of your observation. You can use CLEO's Scheduler and Skyview to do this.

3.1 Flux calibrators
====================
You will need to observe at least one of flux calibrator during your observing session to ensure flux calibration. Preferably you would observe 2-3 flux calibrators, but if you are ok with a 10-20% error in your flux measurement one calibrator is ok. In general, you will want to find the flux calibrators that are closest to your source.

Where can you find flux calibrators? You can use any of the ALMA grid cals listed in the following catalog: ``/users/penarray/Public/Catalogs/alma_gridcal.cat``. You can check the `ALMA Calibrator Source Catalogs <https://almascience.nrao.edu/sc/>`_ for the current flux density levels in Band 3 of the ALMA grid calibrators listed in ``/users/penarray/Public/Catalogs/alma_gridcal.cat`` (the flux density values listed in the CLEO catalog are quite old). Uranus and Neptune, especially Uranus, are also good flux calibrators. 

.. note::

	Note that in February ALMA is shutdown so it isn't as useful to observe ALMA grid cals. Best to observe something else like a planet."

3.2 OOF sources
===============
It is efficient to use the flux calibrators as your first OOF source of the night. For OOF sources, a general guide is that you want a bright source that is > 1 Jy and 25 < elevation < 60. The main quality of a good OOF source is that you it to be a nice point source as seen by M2. Out of the planets Uranus and Neptune are the only planets that work well as an OOF source (especially Uranus). You want to avoid sources that have structure like Saturn or 3C273 (M87).

Additionally, a good general rule to follow for picking your OOF source is that you want to choose an OOF source that is approximately at same elevation as your source. This is because one of the main contributors to the deformations in the dish (what OOF is correcting for) is gravity and at each elevation the dish will deform differently due to gravity. However, a more nuanced way of choosing an OOF source is to consider the average elevation of your science target. If the average observing elevation of your target will be "low" (~35 or less), or "high" (average observing elevation ~60 or higher) then one would prefer to OOF on a source with a similar elevation. But if the science target is in between, then the OOF elevation will be less important.

Once you determine your OOF source, fill in the source name in the ``2_m2oof`` and ``3_m2quickDaisyOOF`` scripts.

3.3 Pointing calibrators
========================
For each science target you will need to determine a pointing calibrator that you will go to roughly every 30 minutes. 

You can find suitable calibrators using CLEO's Scheduler & Skyview
	- Click ``Catalog...`` in the upper right-hand corner
	- Click ``Add/Select/DeSelect Catalogs ...``
	- Select ``mustang_pointing``
	- Click ``Apply`` 
    
The goal is to find a calibrator that is 10-15 deg from your target and > 0.5 Jy (though if have good weather a better choice is something close that is 0.1 Jy). To find a source that is > 0.5 Jy fo the following in CLEO's Scheduler & SkyView:
    - Go to the box in the right-hand corner that says ``Source Intensity Range`` and in the ``Min`` box put 0.5
    - Hit enter
    - Load your science source catalog
    - Enter the time you will be observing in the ``UT Date and Time`` box
    - Find a source that is showing and is 10-15 deg from your target.

It is suggested that you find a few options for each science target. Once you determine your pointing calibrator(s), fill in the source name(s) with the strength in a comment in the ``4_m2quickDaisyPC`` script. It is suggested that you leave the best one uncommented and comment out the other options.
