What is Cyclic Spectroscopy?
----------------------------

Cyclic spectroscopy (CS) is an advanced signal processing technique
that takes advantage of the period nature of pulsars to simultaneously
achieve high radio frequency and pulse phase resolution.  The
application of CS to pulsars is described in :cite:t:`Demorest2011`.

Traditional signal processing techniques measure radio-frequency power
spectra via a Fourier transform.  There are different approaches for
doing so (e.g. autocorrelation spectroscopy and polyphase filterbanks)
but they are all subject to the Fourier transform uncertainty
principle.  Specifically, the frequency resolution one can achieve is
inversely proportional to the temporal resolution.  In other words, to
resolve narrowband frequency structure, one has to sacrifice time
resolution.

Pulsars, in particular millisecond pulsars (MSPs), frequently exhibit
temporal structure on the order of 0.1 - 0.01 milliseconds, and
resolving this temporal structure is critical for high-precision
pulsar timing.  As such, pulsar observers typically prioritize high
time resolution at the expense of frequency resolution.  A common
observing setup obtains frequency resolution of about 1 MHz and time
resolution of about 1 ms.

The Fourier transform uncertainty principle specifically applies to
wide-sense stationary processes.  However, the periodic nature of
pulsars makes them cyclostationary, i.e. their statistical properties
are periodic in nature.  This property allows one to use advanced
signal processing techniques to break the degeneracy between time and
frequency resolution and simultaneously achieve very high radio
frequency and pulse phase resolution.  The resulting *cyclic spectrum*
measures amplitude and phase as a function of radio frequency
(:math:`\nu`) and cycle frequency (:math:`\alpha`), with a frequency
resolution limited only by :math:`1/P`, where :math:`P` is the pulsar
period.

When to Use Cyclic Spectroscopy
-------------------------------

CS is useful when observing pulsars that are highly scattered by the
ionized interstellar medium (IISM).  Density variations in the IISM
diffract pulsar signals at radio frequencies, scattering rays into an
observer’s line of sight that would not otherwise intersect with the
Earth.  The differing path lengths upon which these signals travel
causes them to arrive at Earth with different phases, leading to
constructive and destructive interference known as scintillation.  The
resulting interference pattern varies with time and frequency leading
to increases in flux density that are localized over a characteristic
scintillation bandwidth, :math:`\Delta \nu_{\rm scint}`, and
timescale, :math:`t_{\rm scint}`.  Multi-path propagation also causes
pulsed emission to arrive at the Earth with varying time delays that
are functionally described as a one-sided exponential that decays by
:math:`1/e` over a scattering timescale, :math:`\tau_{\rm s}`.  The
relationship between the scattering timescale and scintillation
bandwidth is given by

.. math::
   \Delta \nu_{\rm scint} \tau_{\rm s} = 2 \pi C_1

where C1 is a constant of proportionality related to the geometry of
density variations in the IISM.  For a uniform electron density model
with a Kolmogorov turbulence spectrum :math:`C_1` = 1.16, while for a
thin-screen density model and Kolmogorov spectrum :math:`C_1` = 0.957.

Within pulsar astronomy a measurement of pulse flux density as a
function of time and frequency (i.e. an observation of the diffractive
interference pattern) is known as a dynamic spectrum, and such a
measurement encodes a wealth of information about the IISM.
Specifically, measurement of the scintillation bandwidth can be used
to estimate the scattering delay up to the value of :math:`C_1`.
Furthermore, a 2-D Fourier transform of the dynamic spectrum, known as
a secondary spectrum, often reveals parabolic arcs and inverted
parabolic arclets which are related to the distance to the scattering
screens.  The secondary spectrum is thus a valuable probe of the
geometry of the IISM.

While scattering is useful for studying the IISM, it serves as a
nuisance term for high-precision pulsar timing.  Scattering delays
bias measurements of pulse times of arrival (TOAs), and epoch-to-epoch
changes in ts are a source of stochastic red noise in pulsar timing
models.  The influence of nanohertz-frequency gravitational waves
(GWs) also manifests as a stochastic red noise process, so unmodeled
scattering delays decrease pulsar timing array sensitivity to GWs.

Scattering delays can be estimated by measuring :math:`\Delta \nu_{\rm
scint}` from dynamic spectra (which, as previously mentioned, are also
useful for studying the IISM).  However, very highly scatted pulsars
may have :math:`\Delta \nu_{\rm scint}` that are too narrow to resolve
with traditional techniques.  Thus CS may be useful for resolving
scintles in highly scattered pulsars.

This has several benefits.  First, it may be possible to measure
:math:`\Delta \nu_{\rm scint}`, and thus estimate :math:`\tau_{\rm
s}`, while maintaining adequate pulse phase resolution for
high-precision pulsar timing.  Second, measuring the average phase
slope of the cyclic spectrum provides another measure of the total
time delay that a pulsar signal experiences.  Finally, under certain
conditions it may be possible to measure the impulse response function
(IRF) of the IISM, and to thus measure ts directly.

The GBT Cyclic Spectroscopy Backend
-----------------------------------

CS is computationally demanding and its use was historically limited
to special instruments.  GBO now offers an observatory-supported CS
backend that operates in close-to-real time and that is controlled
using the standard GBT observing interface (Astrid).  It operates in
parallel with VEGAS, producing traditional data products and *periodic
spectra* (which are related to the cylclic spectrum via a Fourier
transform).  

The :ref:`Cyclic Spectroscopy reference <references/backends/cycspec:Cyclic Spectroscopy>`
section contains detailed technical information on the CS backend.


The How-to guide on :ref:`how-tos/observing_modes/pulsars/cycspec:Cyclic Spectroscopy Observations of a Pulsar` contains detailed instructions on how to obtain the cyclic spectrum of known pulsars.
