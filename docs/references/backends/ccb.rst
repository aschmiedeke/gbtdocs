
CCB
---

The CCB is a sensitive, wideband backend designed exclusively for use with the GBT Ka-band receiver.
It provides carefully optimized radio frequency (not an intermediate frequency) detector circuits
and the capability to beam-switch the receiver rapidly to suppress instrumental gain fluctuations.
There are 16 input ports (only 8 can be used at present with the Ka-band receiver), hard-wired to
the receiver's 2 feeds x 2 polarizations x 4 frequency sub-bands. The CCB allows the left and right
noise-diodes to be controlled individually to allow for differential or total power calibration.
Unlike other GBT backends, the noise-diodes are either on or off for an entire integration (there is 
no concept of phase within an integration). The minimum practical integration period is 5 milliseconds;
integration periods longer than 0.1 seconds are not recommended. The maximum practical beam-switching
rate is about 4 kHz, limited by the needed :math:`250\mu s` beam-switch blanking time. 
Switching slower than 1 kHz is not recommended.


