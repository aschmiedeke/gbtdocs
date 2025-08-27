

Catalogs
--------

The Source Catalog system in AstrID provides a convenient way for the user to specify
a list of sourcesto be observed, as well as a way to refer to standard catalogs of 
objects. At a minimum for each source there must be a name and a location (RA/Dec or 
Glat/Glon, etc). Other parameters may be set, such as radial velocity. An example of
a simple Catalog is:

.. literalinclude:: scripts/simple_catalog.cat


There are three formats of catalogs:

#. **SPHERICAL**: a fixed position in one of our standard coordinate systems, 
   e.g. RA/Dec, Az/El, Glon/Glat, etc.

#. **EPHEMERIS**: a table of positions for moving sources (comets, asteroids, 
   satellites, etc)

#. **NNTLE NASA/NORAD**: Two-line element sets for Earth satellites.



In addition, the following solar system bodies may be referred to by name, i.e. no 
catalog needs to be invoked for the system to understand these names: ``'Sun'``,
``'Moon'``, ``'Mercury'``, ``'Venus'``, ``'Mars'``, ``'Jupiter'``, ``'Saturn'``, 
``'Uranus'``, ``'Neptune'``, and ``'Pluto'``. These names are case-insensitive and 
may be given to any :ref:`Scan Type function <Scan Types and other functions - Overview`.



Getting a Catalog into AstrID
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

SPHERICAL
^^^^^^^^^

Catalog Format
''''''''''''''

Example Spherical Catalogs
''''''''''''''''''''''''''

Standard Catalogs
'''''''''''''''''

Catalog Functions
'''''''''''''''''

EPHEMERIS
^^^^^^^^^

NNTLE
^^^^^


