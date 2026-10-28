# Reset configuration from prior observations.
ResetConfig()

# Import catalog of flux calibrators and user defined sources.
Catalog(fluxcal) #A catalog of standard flux calibrators known by astrid
Catalog('/home/astro-util/HIsurvey/HI_survey.cat')

# Config for spectral line observations of HI using position switching.
psw_HI_config="""
receiver        = 'Rcvr1_2'      # L-Band receiver for HI
obstype         = 'Spectroscopy' # Spectral line observations
backend         = 'VEGAS'        # Spectral line backend
restfreq        = 1420.4058      # Rest frequency for HI (MHz)
deltafreq       = 0.0            # Offsets for each spectral window (MHz)
bandwidth       = 23.44          # Defined by chosen VEGAS mode (MHz)
nchan           = 32768          # Number of channels in spectral window
vegas.subband   = 1              # Single/multiple spectral windows (1 or 8)
swmode          = 'tp'           # Switching mode: total power with noise diode
swtype          = None           # Type of switching, no switching
swper           = 1.0            # Length of full switching cycle (seconds)
swfreq          = 0, 0           # Frequency offset (MHz)
tint            = 6.0            # Integration time (s; int. mult. of swper)
vframe          = 'lsrk'         # Velocity reference frame
vdef            = 'Optical'      # Doppler-shifted velocity frame
noisecal        = 'lo'           # Level of the noise diode, 'lo' or 'hi'
pol             = 'Linear'       # 'Linear' or 'Circular' polarization
notchfilter     = 'In'           # 'In' to block 1200-1310 MHz RFI signal
"""

#First, lets go to a calibrator source, to check the telescope calibration
#If you are using a prime focus receiver, just use “AutoPeak
AutoPeakFocus('3C286')

# Break, to make sure the AutoPeakFocus looks good;  If not, hit No and restart the script
Break('Everything ok?')

#Slew to your source of interest
Slew('U8503')

# If your flux calibrator was far from your source, then
# Perform position and focus correction on nearby calibrator
# Note that this step is often not necessary at low frequencies 
AutoPeak()

# Break, to make sure the AutoPeakFocus looks good;  If not, hit No and restart the script
Break('Everything ok?')


# Reconfigure after calibrator corrections.
Configure(psw_HI_config)

#Slew back to your source of interest
Slew('U8503')

# Balance the hardware.
Balance()

# Take an ON + OFF scan of the object
# The OFF scan follows the same sky area (Az, El) as the ON
OnOff('U8503', Offset('J2000', '00:05:00', 0.0, cosv=True), 300)
