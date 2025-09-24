High Frequency Observing Strategies
-----------------------------------


When observing at frequencies above 10 GHz you should be aware that additional calibration
measurements may be necessary.  The telescope efficiency can become elevation dependent, 
atmospheric opacities are important and the opacities can be time variable. You should 
contact your GBT project friend to discuss these issues.

All the GBT high frequency receivers have at least two beams (pixels) on the sky. You
should make use of both of these during your observations if possible. For example, if you
are doing position switched observations and your source is not extended then you can use 
the :func:`Nod() <astrid_commands.Nod>` procedure to observe.
