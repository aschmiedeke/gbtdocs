###################
GBTIDL Introduction
###################


GBTIDL is an interactive package for the reduction and analysis of spectral line data taken with the
Robert C. Byrd Green Bank Telescope (GBT). GBTIDL is written entirely in IDL. There is limited
support in GBTIDL for GBT continuum data, but it is mainly intended for spectral line data from the
spectrometer or spectral processor.


Main Features of GBTIDL
-----------------------

* **GBTIDL is easy and effective** The GBTIDL package consists of a set of straightforward, yet flexible, calibration, averaging, and analysis procedures modeled after the
UniPOPs and CLASS data reduction philosophies.
* **Plotter** GBTIDL features a customized plotter with many built-in visualization features.
* **Support for advanced users** GBTIDL has Data I/O and toolbox functionality that can
be used for more advanced tasks.
* **Data structures** GBTIDL makes use of data structures for storing spectra along with
their headers.
* **Online feature** GBTIDL can be run in ``online`` mode while observing with the GBT to
give users rapid access to the most recent data.


Where can I run GBTIDL?
-----------------------

GBTIDL is installed on the Linux computing systems at NRAO-Green Bank and NRAO-Charlottesville.
It is also available for installation at other sites. An IDL license and installation with IDL 6.0 or later are
required to run GBTIDL. GBTIDL has been tested on both Linux and Apple Mac installations. If you
do not have an IDL license, it is possible to connect to a Green Bank computer from your remote site or
sign up for time on a machine in Charlottesville that is dedicated to supporting remote users. Contact
Jim Braatz or Bob Garwood for further information. In Green Bank and Charlottesville, GBTIDL is
installed in ``/home/gbtidl/release/gbtidl``. The NRAO developed IDL code is found starting in the pro
subdirectory.

Obtaining GBTIDL
----------------

GBTIDL is available as a tar file from the GBTIDL home page at
http://gbtidl.nrao.edu. Simply click on `Download GBTIDL Now <https://gbtidl.nrao.edu/downloads.shtml>`_ and follow the instructions.


User Documentation
------------------

The following documents are available from links on the http://gbtidl.nrao.edu homepage:

* The GBTIDL Quick Reference Guide gives a topical summary of the IDL procedures and functions.
* The User Reference provides a list of GBTIDL procedures with detailed descriptions of parameters
and usage examples.
* The Contributed Code Reference describes user contributed procedures.
* Calibration of GBT Spectral Line Data in GBTIDL describes how you can optimize calibration of
your data.

Other documents that may be useful to GBTIDL users include:

* The text Practical IDL Programming by :cite:`Gumley2002` is a useful resource for beginning
and expert IDL users.




.. bibliography:: references.bib
   
