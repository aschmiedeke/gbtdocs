Observing Strategies For Strong Continuum Sources
-------------------------------------------------


Spectral line observations of strong continuum sources leads to a great amount 
of structure (i.e. ripples) in the observed spectra. So observations of strong
continuum sources requires careful consideration of the observing setup and the 
techniques used.

If you are trying to observe weak broad spectral lines (wider than ~100 MHz)
toward a source with strong continuum emission (more than 1/10th the system 
temperature), then you should consider using double position switching. This 
technique is discussed in an Arecibo memo :cite:p:`Ghosh2002`.

Another issue is finding a proper IF balance that allows both the "on" and "off"
source positions to remain in the linear range of the backend being used. This
means that one must find the IF balance in both the "on" and "off" position and
then split the difference - assuming that the difference in power levels between
the "on" and "off" do not  exceed the dynamic range of the backend.  The 
:func:`BalanceOnOff() <astrid_commands.BalanceOnOff>` procedure in AstrID can be
used to accomplish this type of balancing.
