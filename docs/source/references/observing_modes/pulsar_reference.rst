

Pulsar Observing Reference
==========================


Overview
--------


VEGAS can be used in pulsar observing modes (VEGAS pulsar modes, or VPM) that are similar to those available with the old GUPPI backend (see the GBT Observer's Guide). VEGAS consists of eight CASPER ROACH2 FPGA boards and eight high performance computers (HPCs) equipped with nVidia GTX 780 GPUs, which together comprise a spectrometer **bank** (labeled A--H). VPM offers many combinations of observing modes, dedispersion modes, numbers of spectral channels, bandwidths, and integration times. Data are written in the PSRFITS format using 8-bit values. 



Observing Modes
^^^^^^^^^^^^^^^


VPM can operate in one of three **observing modes**. All three modes can be used with **coherent** or **incoherent** dedispersion.

* **search**: This mode is used to record spectra with very high time resolution (typically < 100 μs) and moderate frequency resolution (> 200 kHz). It is most often used when searching for new pulsars, observing known pulsars when a timing solution is not yet available, observing multiple pulsars simultaneously, or when resolution of individual pulses is required.
* **fold**: This mode is used to phase-fold spectra modulo the instantaneous pulsar period. This requires a user-supplied pulsar timing solution that can be used by TEMPO1 in prediction mode (i.e., to generate "polycos"). Fold-mode is most often used for pulsar timing observations of individual pulsars.
* **cal**: This mode is used for polarization and flux calibration observations of the GBT noise diodes. It is actually a specialized fold-mode in which data are phase-folded at a constant frequency of 25 Hz (or a period of 40 ms). This requires that the GBT noise diodes be turned on and set to a switching period of 0.04 s (see below).


 
Dedispersion Modes
^^^^^^^^^^^^^^^^^^


VPM can operate in **incoherent** or **coherent** dedispersion modes. When using incoherent dedispersion, spectra are written without any removal of intrachannel dispersive smearing, and dedispersion must be performed offline (i.e. incoherently). When using coherent dedispersion, the intrachannel dispersive delay is removed prior to detection, providing higher effective time resolution.

When operating in incoherent dedispersion modes, each FPGA and HPC form an independent spectrometer bank (labeled A--H). The center frequency of each bank can be tuned independently, and each can process a maximum instantaneous bandwidth of up to 1500 MHz, though filters in the IF system limit the *maximum usable bandwidth to 1250 MHz per spectrometer bank.* The center frequencies of each bank can thus be arranged to contiguously cover up to 8 x 1250 Hz = 10 GHz, though, once again, IF limitations generally limit the maximum available bandwidth from any receiver to < 4 GHz (up to 8 GHz is available for certain receivers; see the GBT Observer's Guide).

.. todo:: 

    Remove reference to Observer's guide and replace with link to receiver frequency ranges

When operating in coherent dedispersion modes with 800 or 1500 MHz of sampled bandwidth, one FPGA sends output to all eight HPCs. Since all the HPCs are in use the maximum total bandwidth in coherent dedispersion modes is 1500 MHz, *1250 MHz of which usable.*

When operating in coherent dedispersion modes with 100 or 200 MHz of bandwidth, one FPGA sends output to one or two HPCs, respectively. In these cases, additional HPCs will not be active or write data. The exception is Bank A, which acts as the switching signal master and will always appear as active in CLEO, although it will not always write data.

Generally speaking, incoherent dedispersion is only recommended in the following use cases:

#. Blind searches for new pulsars.
#. Observations at frequencies higher than 4 GHz (i.e., C-Band), when > 1250 Hz of bandwidth is desired.
#. Observations of long-period pulsars in which very high time resolution is not needed (i.e., intrachannel dispersive delays can be tolerated). 

Observations of known pulsars, especially for high-precision timing, observations of multiple pulsars with similar dispersion measures (e.g. globular cluster MSPs), and pulsar searches for which a good estimate of the dispersion measure is available should usually use coherent dedispersion. 




Available VPM Modes
^^^^^^^^^^^^^^^^^^^



All configurations are subject to a maximum data rate of 400 MB/s per bank. The data rate per bank can be calculated as

.. math::

    R = 1 \,\text{byte} \cdot \frac{ n_{\text{pol}} \cdot n_{\text{chan}} }{ t_{\text{int}} }

where n\ :sub:`pol` \ is the number of polarization products (4 for full Stokes parameters, 1 for total intensity), n\ :sub:`chan` \ is the number of spectral channels, and t\ :sub:`int` \ is the integration time (i.e. sampling time). The following tables list all currently supported VPM modes. 

Observers


.. csv-table:: Coherent Modes
    :file: files/coherent_VPM_modes.csv
    :header-rows: 1
    :class: longtable
    :widths: 1 1 1 1 1 1




.. csv-table:: Incoherent Modes
    :file: files/incoherent_VPM_modes.csv
    :header-rows: 1
    :class: longtable
    :widths: 1 1 1 1 1 1









