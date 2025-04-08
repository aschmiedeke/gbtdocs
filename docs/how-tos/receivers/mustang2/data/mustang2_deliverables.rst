.. _mustang2_deliv:

######################
MUSTANG-2 Deliverables
######################

The MUSTANG-2 team is able to produce the following data products for all MUSTANG-2 projects:
	* A calibrated map either in Jy/beam or Kelvin (main beam).
		* Each scan is gridded individually. Maps are stacked via weighted averaging.
	* An associated noise map
		* The default noise map, for a single scan, flips every other detector. The combined noise map is the stack of all individual scans.
	* An associated SNR map
		* The above map and noise map are smoothed by some amount (generally 9″). The weight map is scaled according to the RMS in the noise map 

Additionally, the following products will help in using the above data products:
	* A transfer function
		This accounts for the filtering we perform on the data. The calibrated map referenced above does not preserve signals on all scales; a transfer function (along with convolution of the beam shape) must be taken into account when modelling the intrinsic astronomical signal. More information on how this is calculated and can be used can be found at https://safe.nrao.edu/wiki/bin/view/GB/Pennarray/MUSTANG_CLASH. A repository of transfer functions (ascii files) is available :ref:`here <Transfer Functions for Download>`.
	* A stacked beam map
		From the calibrators, observed every ~30 minutes, we can compute an average beam for a given science target. The stacked beam is normalized to have a peak of 1. Double Gaussian (azimuthally symmetric) fits are included in the header (among the last cards in the header). The user can also produce their own fits to the stacked beam, if they so choose.