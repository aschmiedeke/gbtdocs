Scheduling Block Examples
-------------------------

For the following SB examples we will use the configuration examples from 
:ref:`references/observing/configure:Example Configurations`. All configurations, catalogs, and scripts 
are available within the Green Bank computing environment at ``/home/astro-util/projects/GBTog``.

.. todo:: Check the folder and ensure all scripts are there.


The following catalog (``sources.cat``) will be used for all examples:

.. literalinclude:: scripts/sources.cat
    

Frequency-switched observations looping through a list of sources
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example we perform frequency-switched observations of the HI 21 cm line towards 
several different sources. This example is available at ``/home/astro-util/projects/GBTog/SBs/example1.py``.

.. literalinclude:: scripts/example1.py


Position-switched observations repeatedly observing the same source
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example we perform position-switched observations of a single source. We observe
the source for two minutes and the off position for two minutes. This is repeated twenty
times. This example is available at ``/home/astro-util/projects/GBTog/SBs/example2.py``.

.. literalinclude:: scripts/example2.py


Position-switched observations of several sources and using the Horizon object
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example we perform position-switched observations of three sources. We observe the 
first source until the second source rises above 20\ :math:`^\circ`  elevation. THen we 
observe the second source until it goes below 20\ `^\circ` elevation at which point we 
observe a third source. This example is available as ``/home/astro-util/projects/GBTog/SBs/example3.py``

.. literalinclude:: scripts/example3.py


Frequency-switched OTF mapping
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this example we perform frequency-switched observations of the HI 21 cm line to map a 
:math:`5^\circ \times 5^\circ` region of the sky. We use pixels that are 3' in size and have an integration time of 2 seconds per pixel. We do not observe the while map in this example. This example is available at ``/home/astro-util/projects/GBTog/SBs/example4.py``

.. literalinclude:: scripts/example4.py
