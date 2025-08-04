Scheduling Blocks (SBs)
-----------------------


At the GBT we use Scheduling Blocks (SBs) to perform astronomical observations. The SB can contain information for configuring the telescope, balancing the IF system, and other commands to "tweak"the telescope system (observing directives) along with the commands (scan types) to collect observational data. AstrID interprets SBs via python (currently python 2.7.2). Thus SBs should follow python syntax rules (such as indentation for loops) and can also contain or make use of any python commands. 


**Scheduling Blocks must be created well prior to your telescope time. We suggest, that you review SBs with your project friend.**

SBs can be written using AstrID's Observation Management Edit subtab, which contains a simple text editor reminiscent of Notepad (MS Windows), or you can choose to write your SB outside of AstrID and use the "Observations Management" import option in AstrID to upload it into the database. 

Choose a discriptive name for your SB, such as "map_G11.0"or "pointfocus", which will remind you o fthe science you are trying to accomplsh by running that block. Names such as "test" or "new" are not descriptive and should be avoided. The name you choose can be up to 96 characters long, and can contain white spaces, so you may have an SB name that consists of a few words (e.g. "K-band frequency-switched spectroscopy"). You do not need to add a suffix to your SB name (\*.sb or \*.py).


.. grid:: 1 2 2 2

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Configuring the system** 

        References to create Scheduling Blocks (SBs)

        .. button-link:: observing/configure.html
            :color: primary
            :tooltip: Configure the GBT system
            :outline:
            :click-parent:

            Configure


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Catalogs** 

        References to create source catalogs

        .. button-link:: observing/catalog.html
            :color: primary
            :tooltip: Source catalogs
            :outline:
            :click-parent:

            Catalog


    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Scan type overview** 

        Scan type overview

        .. button-link:: observing/scan_types.html
            :color: primary
            :tooltip: Scan type overview
            :outline:
            :click-parent:

            Scan Types


.. toctree::
    :maxdepth: 3
    :hidden:

    observing/configure
    observing/catalog
    observing/scan_types


------------

.. grid:: 1 2 2 2

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Scheduling Block Commands** 

        References for scheduling block commands

        .. button-link:: observing/sb_commands.html
            :color: primary
            :tooltip: Scheduling block commands
            :outline:
            :click-parent:

            API 

.. toctree::
    :maxdepth: 3
    :hidden:

    observing/sb_commands



