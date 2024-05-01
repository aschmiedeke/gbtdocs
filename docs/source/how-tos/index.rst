.. _howtos:

###########################################
:octicon:`terminal;2em;green` How-To Guides
###########################################

Practical step-by-step guides to help you achieve a specific goal. Most useful when you're trying to get something done.


----------------


Infrastructure
==============

These guides provide information on how to use GBO infrastructure.


.. grid:: 1 2 2 2

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`globe;3em;green` **Remote Connection** 

        How to connect remotely to the GBO network?

        .. button-link:: infrastructure/remote-connection.html
            :color: primary
            :tooltip: Practical steps on how to connect remotely to the GBO network.
            :outline:
            :click-parent:

            Remote connections




Observing Mode Guides
======================

These guides contain end-to-end instructions, i.e. how to set up specific observations and how to calibrate and post-process the obtained data.


.. grid:: 1 2 2 2

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Polarization** 

        How to derive a Mueller matrix?

        .. button-link:: quick_guides/C-band_Mueller_matrix.html
            :color: primary
            :tooltip: Practical steps to obtain a Mueller matric using spider scans.
            :outline:
            :click-parent:

            Mueller matrix



.. button-link:: quick_guides/HI_single-pointing.html
    :color: primary
    :tooltip: Practical steps to obtain a single-pointing HI spectrum using either position-switching or frequency-switching.

    How to observe an HI spectrum and process it?

.. button-link:: quick_guides/C-band_Mueller_matrix.html
    :color: primary
    :tooltip: Practical steps to obtain a Mueller matrix using spider scans.

    How to derive a Mueller matrix?



----------------



Receiver specific Guides
========================

These guides provide receiver specific information on how to achieve a specific goal.


.. grid:: 1 2 3 3

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **Argus** 

        How-to observe with Argus (75-115 GHz)

        .. button-link:: receivers/argus/argus_obs.html
            :color: primary
            :tooltip: How-to use Argus (75-115 GHz receiver).
            :outline:
            :click-parent:

            Argus

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0

        **MUSTANG-2**

        Guides for MUSTANG-2 (bolometer camera)

        .. button-link:: receivers/mustang2.html
            :color: primary
            :tooltip: How-to use MUSTANG-2 (bolometer camera).
            :outline:
            :click-parent:

            MUSTANG-2



----------------


Software
========



.. grid:: 1 2 3 3

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        **GBTIDL** 

        How-to process spectra using GBTIDL (examples)

        .. button-link:: data_reduction/gbtidl.html
            :color: primary
            :tooltip: Shows practical steps to calibrate and process gbt data using gbtidl
            :outline:
            :click-parent:

            GBTIDL





.. toctree::
    :hidden:
    :maxdepth: 3

    infrastructure/remote-connection
    quick_guides/HI_single-pointing
    quick_guides/C-band_Mueller_matrix
    receivers/argus/argus_obs
    receivers/mustang2
    data_reduction/gbtidl

