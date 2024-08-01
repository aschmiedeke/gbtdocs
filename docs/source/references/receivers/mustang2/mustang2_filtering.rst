###################
MUSTANG-2 Filtering
###################

Like any other ground-based millimeter continuum observations, our default data processing attempts to remove the Earth’s atmosphere with either a common-mode subtraction or something quite similar to it (e.g. PCA).

There is an early :download:`memo </_static/mustang2_documents/Observing_Galaxy_Clusters_With_M2.pdf>` on filtering which compared the results of observing simulated galaxy clusters using two different (Lissajous daisy) scan sizes and two different sets of filtering parameters. There is an :download:`executive summary </_static/mustang2_documents/Observing_with_MUSTANG_2_Executive.pdf>` of that memo.

The following figures show transfer functions for a broad range of (Lissajous) scan sizes (from 2.5′ to 5.0′) with a fairly gentle filtering (3 components subtracted from the timestreams via PCA and a windowed filter, keeping frequencies between 0.06 Hz and 41.0 Hz). 

.. Figure:: images/PCA3_0f06_Xfers.png

	Figure 1. Transfer functions for reduction parameters of PCA=3, and a Fourier window between 0.06 Hz and 41.0 Hz. **Left:** large-scale transmission by scan size (raw binned data). **Right:** fitted curves of the form Transmission = p[0] – (r/p[1])^p[2], by scan size (in arcminutes).

Below are the transfer functions from above with the same scan sizes but instead filtered with 5 components (via PCA) and a window between 0.08 Hz and 41.0 Hz. We note that the units of the wavenumber axes of all the plots on this page are 1/arcseconds.

.. Figure:: images/PCA5_0f08_Xfers.png

	Figure 2. Transfer functions for reduction parameters of PCA=5, and a Fourier window between 0.08 Hz and 41.0 Hz. **Left:** large-scale transmission by scan size (raw binned data). **Right:** fitted curves of the form Transmission = p[0] – (r/p[1])^p[2], by scan size (in arcminutes).

Below we show the differences between these two reductions (PCA=3 with a Fourier window between 0.06 Hz and 41.0 Hz vs PCA=5 with a Fourier window between 0.08 Hz and 41.0 Hz) by splitting the scan sizes used above among two plots:

.. Figure:: images/PCA3_0f06_vs_PCA5_0f08_fitted.png

	Figure 3. Dashed lines indicate the harsher filtering (CA=5 with a Fourier window between 0.08 Hz and 41.0 Hz); solid lines are the gentler filtering (PCA=3 with a Fourier window between 0.06 Hz and 41.0 Hz).

A filtering with a highpass of 0.06 Hz is, unfortunately, a bit more gentler than we find is necessary. Rather, a highpass at 0.07 or 0.08 Hz often results in acceptable noise in our maps. There are still other datasets which require still more aggressive filtering, either a highpass at 0.09 Hz, or even 0.1 Hz.

Transfer Functions for Download
-------------------------------
A repository of transfer functions (ascii files) is available `here <https://astrocloud.nrao.edu/s/RAwkBWecPBc7wK7>`_.

Simulating the Effects of Filtering
-----------------------------------
`M2_ProposalTools <https://m2-tj.readthedocs.io/en/latest/index.html>`_ is a Python library for simulating MUSTANG-2 observations. A specific application of this library is that a proposer can simulate the effect of filtering on the S/N acquired.