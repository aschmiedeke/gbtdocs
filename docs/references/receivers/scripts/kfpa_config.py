#configuration definition for spectral line observations using the KFPA

kfpa_config='''
    receiver  = 'RcvrArray18_26'
    beam      = 'all'
    obstype   = 'Spectroscopy'
    backend   = 'VEGAS'
    restfreq  = {24600:'1,2,3,4', 23900:'5,6,7', 25500 : '-1',
                 'DopplerTrackFreq': 24700} 
    deltafreq = {24600:-100, 23900:0, 25500:0} 
    bandwidth = 187.5  
    nchan     = 32768
    swmode    = 'tp'
    swtype    = 'none'
    swper     = 1.0
    tint      = 30 
    vframe    = 'lsrk'
    vdef      = 'Radio'
    noisecal  = 'lo'
    pol       = 'Circular'
    vegas.vpol= 'cross'
'''
