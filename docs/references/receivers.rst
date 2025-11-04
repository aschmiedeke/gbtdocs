.. _receivers:

#########
Receivers
#########

The GBT receivers cover several frequency bands from 0.290 - 50.5 GHz and 67-116 GHz. The properties of the receivers are 
listed below. System temperatures are derived from lab measurements or from exptected receiver performance given reasonable
assumptions about spillover and atmospheric contributions.


Prime Focus Receivers
---------------------

The Prime focus receivers are mounted in a Focus Rotation Mount (FRM) on a retractable boom. The boom is moved to the prime 
focus position when prime focus receivers are to be used, and retracted when using Gregorian receivers. The FRM has three
degrees of freedom: Z-axis radial focus, Y-axis translation (in the direction of the dish plane of symmetry), and rotation.
It can be extended and retracted at any elevation. This usually takes about 10 minutes.

The FRM holds one receiver box at a time. Currently there are two receiver boxes, PF1 and PF2. A change from PF1 to PF2 
receivers requires a box change. Additionally, changing frequency bands within PF1 requires a change in the PF1 feed. 
Changes of or in prime focus receivers take about 4 hours and are done only during routine maintenance time preceding a 
dedicated campaign using that receiver. 

.. include:: /material/tables/receivers_pf.tab


Gregorian Receivers
-------------------

The Gregorian receivers are mounted in a rotating turret in a receiver room located at the Gregorian Focus of the telescope. 
The turret has 8 portals for receiver boxes. All 8 receivers can be kept cold and active at all times. Changing between any 
two Gregorian receivers that are installed in the turret takes about 60-90 seconds.

.. include:: /material/tables/receivers_gregorian.tab


Retired Receivers
-----------------

* RcvrArray1_2
* Rcvr_PAR



.. toctree::
    :maxdepth: 3
    :hidden:

    receivers/pf1
    receivers/pf2
    receivers/uwbr
    receivers/l-band
    receivers/s-band
    receivers/c-band
    receivers/x-band
    receivers/ku-band
    receivers/kfpa
    receivers/ka-band
    receivers/q-band
    receivers/w-band
    receivers/argus
    receivers/mustang2


