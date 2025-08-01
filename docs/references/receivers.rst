.. _receivers:

#########
Receivers
#########

The GBT receivers cover several frequency bands from 0.290 - 50.5 GHz and 67-116 GHz. The properties of the receivers are listed below. System temperatures are derived from lab measurements or from exptected receiver performance given reasonable assumptions about spillover and atmospheric contributions.


Prime Focus Receivers
---------------------

The Prime focus receivers are mounted in a Focus Rotation Mount (FRM) on a retractable boom. The boom is moved to the prime focus position when prime focus receivers are to be used, and retracted when using Gregorian receivers. The FRM has three degrees of freedom: Z-axis radial focus, Y-axis translation (in the direction of the dish plane of symmetry), and rotation. It can be extended and retracted at any elevation. This usually takes about 10 minutes.

The FRM holds one receiver box at a time. Currently there are two receiver boxes, PF1 and PF2. A change from PF1 to PF2 receivers requires a box change. Additionally, changing frequency bands within PF1 requires a change in the PF1 feed. Changes of or in prime focus receivers take about 4 hours and are done only during routine maintenance time preceding a dedicated campaign using that receiver. 

+-------------------------------------------+-------------+---------+---------------+--------------+----------+---------------+-----------------+-----------------+-------------+--------+------------+--------------------+
| Receiver                                  | Astrid name | Band    | Frequency     | Polarization | Number   | Polarizations | :math:`T_{rec}` | :math:`T_{sys}` | FWHM        | Gain   | Aperture   | Max. Instantaneous | 
|                                           |             |         | Range [GHz]   |              | of beams | per beam      | [K]             | [K]             |             | (K/Jy) | Efficiency | Bandwidth (MHz)    |
+===========================================+=============+=========+===============+==============+==========+===============+=================+=================+=============+========+============+====================+
|                                           | Rcvr_342    | 342 MHz | 0.290 - 0.395 | Lin/Circ     | 1        | 2             | 12              | 46              | 36'         |        |            |                    |
|                                           +-------------+---------+---------------+--------------+----------+---------------+-----------------+-----------------+-------------+        +            +                    +
|                                           | Rcvr_450    | 450 MHz | 0.385 - 0.520 | Lin/Circ     | 1        | 2             | 22              | 43              | 27'         |        |            |                    |
| :ref:`PF1 <Prime Focus 1 (PF1) receiver>` +-------------+---------+---------------+--------------+----------+---------------+-----------------+-----------------+-------------+ 2.0    + 72%        + 240                +
|                                           | Rcvr_600    | 600 MHz | 0.510 - 0.690 | Lin/Circ     | 1        | 2             | 12              | 22              | 21          |        |            |                    |
|                                           +-------------+---------+---------------+--------------+----------+---------------+-----------------+-----------------+-------------+        +            +                    +
|                                           | Rcvr_800    | 800 MHz | 0.680 - 0.920 | Lin/Circ     | 1        | 2             | 21              | 35              | 15          |        |            |                    |
+-------------------------------------------+-------------+---------+---------------+--------------+----------+---------------+-----------------+-----------------+-------------+--------+------------+--------------------+
| :ref:`PF2 <Prime Focus 2 (PF2) receiver>` | Rcvr_1070   |         | 0.910 - 1.230 | Lin/Circ     | 1        | 2             | 10              | 17              | 12          | 2.0    | 72%        | 240                |           
+-------------------------------------------+-------------+---------+---------------+--------------+----------+---------------+-----------------+-----------------+-------------+--------+------------+--------------------+
| :ref:`UWBR <Ultra-wideband receiver>`     |             |         | 0.700 - 4     | Lin          | 1        | 2             | TBD             | TBD             | 17.7'- 3.1' | TBD    | TBD        | 3420               |
+-------------------------------------------+-------------+---------+---------------+--------------+----------+---------------+-----------------+-----------------+-------------+--------+------------+--------------------+


Gregorian Receivers
-------------------

The Gregorian receivers are mounted in a rotating turret in a receiver room located at the Gregorian Focus of the telescope. The turret has 8 portals for receiver boxes. All 8 receivers can be kept cold and active at all times. Changing between any two Gregorian receivers that are installed in the turret takes about 60-90 seconds.

+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
| Receiver                                      | Astrid name     | Band  | Frequency   | Polari-  | Number   | Polarizations | :math:`T_{rec}` | :math:`T_{sys}` | Beam       | FWHM   | Gain   | Aperture   | Max. Instantaneous | Calibration |
|                                               |                 |       | Range [GHz] | zation   | of beams | per beam      | [K]             | [K]             | Separation |        | (K/Jy) | Efficiency | Bandwidth (MHz)    | Method      |
+===============================================+=================+=======+=============+==========+==========+===============+=================+=================+============+========+========+============+====================+=============+
| :ref:`L-Band <L-Band receiver>`               | Rcvr1_2         |       | 1.15 - 1.73 | Lin/Circ | 1        | 2             | 6               | 20              | -          | 9.0'   | 2.0    | 72%        | 650                | noise diode |
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
| :ref:`S-Band <S-Band receiver>`               | Rcvr2_3         |       | 1.73 - 2.60 | Lin/Circ | 1        | 2             | 8-12            | 22              | -          | 5.8'   | 2.0    | 72%        | 970                | noise diode |
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
| :ref:`C-Band <C-Band receiver>`               | Rcvr4_6         |       | 3.95 - 7.80 | Lin/Circ | 1        | 2             | 5               | 18              | -          | 2.5'   | 2.0    | 72%        | 3800               | noise diode |
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
| :ref:`X-Band <X-Band receiver>`               | Rcvr8_10        |       |  7.8 - 12.0 | Circ     | 1        | 2             | 17              | 27              | -          | 1.4'   | 2.0    | 71%        | 1300, 4000         | noise diode |
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
| :ref:`Ku-Band <Ku-Band receiver>`             | Rcvr12_18       |       | 12.0 - 15.4 | Circ     | 2        | 2             | 14              | 30              | 330"       | 54"    | 1.9    | 70%        | 3000               | noise diode |
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
| :ref:`KFPA <K-Band Focal Plane Array (KFPA)>` | RcvrArray18_26  |       | 18.0 - 27.5 | Circ     | 7        | 2             | 15-25           | 30-45           | 96"        | 32"    | 1.9    | 68%        | 1800, 7200         | noise diode |
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
|                                               |                 | MM-F1 | 26.0 - 31.0 |          |          |               | 20              | 35              |            | 26.8"  |        |            |                    |             |
+                                               +                 +-------+-------------+          +          +               +-----------------+-----------------+            +--------+        +            +                    +             +
| :ref:`Ka-Band <Ka-Band receiver>`             | Rcvr26_40       | MM-F2 | 30.5 - 37.0 | Lin      | 2        | 1             | 20              | 30              | 78"        | 22.6"  | 1.8    | 63-67%     | 4000               | noise diode |
+                                               +                 +-------+-------------+          +          +               +-----------------+-----------------+            +--------+        +            +                    +             +
|                                               |                 | MM-F3 | 36.0 - 39.5 |          |          |               | 20              | 45              |            | 19.5"  |        |            |                    |             |
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
| :ref:`Q-Band <Q-Band receiver>`               | Rcvr40_52       |       | 39.2 - 50.5 | Circ     | 2        | 2             | 40-70           | 67-134          | 58"        | 16.0"  | 1.7    | 58-64%     | 4000               | noise diode
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
|                                               |                 | FL1   | 67-74       |          |          |               | 50              | 160             |            | 10.0"  |        |            | 6000               |             |
|                                               +                 +-------+-------------+          +          +               +-----------------+-----------------+            +--------+        +            +--------------------+             +
|                                               |                 | FL2   | 73-80       |          |          |               | 50              | 120             |            | ??     |        |            |                    |             |
| :ref:`W-Band <W-Band receiver>`               + Rcvr68_92       +-------+-------------+ Lin/Circ + 2        + 2             +-----------------+-----------------+ 286"       +--------+ 1.0    + 30-48%     +                    + ambient/    +
|                                               |                 | FL3   | 79-86       |          |          |               | 50              | 100             |            | ??     |        |            | 4000               | cold load   |
|                                               +                 +-------+-------------+          +          +               +-----------------+-----------------+            +--------+        +            +                    +             +
|                                               |                 | FL4   | 85-93       |          |          |               | 60              | 110             |            | ??     |        |            |                    |             |
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
| :ref:`Argus <Argus>`                          | RcvrArray75_115 |       | 74 - 116    | Lin      | 16       | 1             | 50              | 110             | 30.4"      | 10"    | -      | 20-35%     | 1250               | vane cal    |
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+
| :ref:`MUSTANG-2 <MUSTANG-2>`                  | Rcvr_MBA1_5     |       | 75 - 105    | -        | 223      | -             |                 |                 | -          | 8.0"   | -      | 35%        | 20000              | --          |
+-----------------------------------------------+-----------------+-------+-------------+----------+----------+---------------+-----------------+-----------------+------------+--------+--------+------------+--------------------+-------------+

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


