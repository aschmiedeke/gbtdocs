Scheduling Blocks (SBs)
-----------------------


At the GBT we use Scheduling Blocks (SBs) to perform astronomical observations. The SB can 
contain information for configuring the telescope, balancing the IF system, and other 
commands to "tweak"the telescope system (observing directives) along with the commands 
(scan types) to collect observational data. AstrID interprets SBs via python (currently 
python 2.7.2). Thus SBs should follow python syntax rules (such as indentation for loops)
and can also contain or make use of any python commands. 

Here is an example of a simple SB:

.. code-block:: python

   # load the configuration
   execfile('/mypath/myconfiguration.txt')

   # configure the GBT
   Configure(myconfig)

   # load the catalog file
   Catalog('/mypath/mycatalog.cat')

   # slew to the source
   Slew('B0329+54')

   # balance the IF system
   Balance()

   # observe the source for ten minutes
   Track('B0329+54', None, 600)

* ``execfile()`` loads definitions for configuring the GBT's receivers, IF system and backends for the observations and ``Configure()`` runs the configuration defined in ``myconfiguration.txt`` (see :ref:`Configure the GBT system` for more information).   

* ``Catalog()`` loads a catalog containing information such as positions and radial velocity on the sources to observe (see :ref:`here <Catalog>`)

* ``Slew()`` moves the telescope to the desired source.

* ``Balance()`` balances the power levels in the IF system and backend so that they should be in their linear regime.

* ``Track()`` performs and aquires data for the desired observations. Track and other pre-defined scans are described :ref:`here <Scan Types and other functions - Overview>`.



.. important::

    **Scheduling Blocks must be created well prior to your telescope time. We suggest, that 
    you review SBs with your project friend.**

SBs can be written using AstrID's Observation Management Edit subtab, which contains a
simple text editor reminiscent of Notepad (MS Windows), or you can choose to write your
SB outside of AstrID and use the "Observations Management" import option in AstrID to
upload it into the database. 

Choose a discriptive name for your SB, such as "map_G11.0"or "pointfocus", which will 
remind you of the science you are trying to accomplsh by running that block. Names such
as "test" or "new" are not descriptive and should be avoided. The name you choose can
be up to 96 characters long, and can contain white spaces, so you may have an SB name
that consists of a few words (e.g. "K-band frequency-switched spectroscopy" - 38 characters,
if you were counting). You do not need to add a suffix to your SB name (such as \*.sb or 
\*.py), but you can if you prefer.


.. grid:: 1 2 2 2

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Configuring the IF system** 

        Reference material to write GBT configurations 

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

        Reference material to create source catalogs

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

        Reference material for scheduling block commands

        .. button-link:: observing/sb_commands.html
            :color: primary
            :tooltip: Scheduling block commands
            :outline:
            :click-parent:

            API 

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Example Scheduling Blocks** 

        .. button-link:: observing/sb_examples.html
            :color: primary
            :tooltip: Scheduling block examples
            :outline:
            :click-parent:

            SB examples 


.. toctree::
    :maxdepth: 3
    :hidden:

    observing/sb_commands
    observing/sb_examples


-------------

What Makes a Good Scheduling Block?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Rarely does an observing session exactly follow one's plans. A useful philosophy is 
to consider the work that would be involved in editing an SB if something were to go 
wrong during its execution and you wanted to resume its execution where you left off.
You should break apart any long scripts into smaller individual scripts to reduce the
need for edits.

During your observing, you will make decisions as to how to proceed with the next 
observations. You should break apart large scripts to increase your flexibility in 
being able to react to the circumstances that arise during your observing.

We recommend that the following should be done within a single SB:

* Only use a **single configuration** within an SB.

* Only use a **single receiver** within an SB.

* Only perform a **single map** within any SB.




