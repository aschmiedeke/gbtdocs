.. _mustang2_data:

##############
MUSTANG-2 data
##############

Here are the current options for obtaining and working with MUSTANG-2 data. Unless the PI is well-versed in working with MUSTANG-2 data, most often PIs request one or more of the :ref:`deliverables <mustang2_deliv>` that the MUSTANG-2 team offers. One can also do a quick, simple reduction (see Basic Reduction below). 

----------------

.. grid:: 1 2 2 2

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`archive;3em;green` **Deliverables**

        Description of deliverables.
   
        .. button-link:: data/mustang2_deliverables.html
            :color: primary
            :outline:
            :click-parent:

            See Deliverables

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`archive;3em;green` **M2 GUI**

        How to use the MUSTANG-2 GUI to inspect data during observations.
   
        .. button-link:: data/mustang2_gui.html
            :color: primary
            :outline:
            :click-parent:

            M2 GUI Documentation

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`telescope;3em;green` **find_src**

        How to use the script ``find_src`` to determine if a source has been observed by MUSTANG-2, for how long, make calibrated TODs, and make a MIDAS image of the calibrated data.
   
        .. button-link:: data/mustang2_find_src.html
            :color: primary
            :outline:
            :click-parent:

            find_src Documentation

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`browser;3em;green` **Uncalibrated MIDAS Reduction**

        Wiki page that describes how to make preliminary MIDAS images of uncalibrated MUSTANG-2 data using script ``simple_reduction``. A good way to get a quick look at all the data on a specific target.

        .. button-link:: https://safe.nrao.edu/wiki/bin/view/GB/Pennarray/DataReductionGuide
            :color: primary
            :outline:
            :click-parent:

            See Guide

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`mark-github;3em;green` **Minkasi**

        Github documenation for python package minkasi that can be used to make calibrated maps of MUSTANG-2 data.

        .. button-link:: https://github.com/sievers/minkasi
            :color: primary
            :outline:
            :click-parent:

            Explore Minkasi

    .. grid-item-card::
        :shadow: md
        :margin: 2 2 0 0 

        :octicon:`gear;3em;green` **WITCH**

        Github documenation for python package WITCH (Where Is That Cluster Hiding)which contains tools for modeling and fitting SZ data of galaxy clusters.

        .. button-link:: https://github.com/MUSTANG-SZ/WITCH
            :color: primary
            :outline:
            :click-parent:

            Explore Minkasi

.. toctree::
    :hidden:

    data/mustang2_deliverables
    data/mustang2_gui
    data/mustang2_find_src