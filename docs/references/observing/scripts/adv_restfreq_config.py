# Example for the advanced usage of restfreq
adv_restfreq_config='''
receiver = 'Rcvr12_18'
beam = '1,2'
obstype = 'Spectroscopy'
backend = 'VEGAS'
swmode = 'tp' 
swtype = 'none'
swper = 1.0
tint = 10 
vframe = 'lsrk'
vdef = 'Radio'
noisecal = 'lo'
pol = 'Circular'
bandwidth = 23.44
nchan = 32768
dopplertrackfreq = 13500.0
restfreq = [
 {'restfreq':14000,'bank':'A','bandwidth':1500,'nchan':1024,'beam':'1'},
 {'restfreq':14000,'bandwidth':1500,'nchan':1024,'beam':'2'},
 {'restfreq':13000,'bandwidth':187.5,'nchan':32768,'beam':'1'},
 {'restfreq':13100,'bandwidth':187.5,'nchan':32768,'beam':'2',
                    'vpol':'cross','deltafreq':1},
 {'restfreq':13200,'bank':'C','bandwidth':23.44,'res':0.7,'beam':'1',
                    'subband':8},
 {'restfreq':13300,'bank':'C','bandwidth':23.44,'res':0.7,'beam':'1',
                    'subband':8},
 {'restfreq':13400,'bank':'C','bandwidth':23.44,'res':0.7,'beam':'1',
                    'subband':8},
 {'restfreq':13400,'bandwidth':23.44,'res':0.7,'beam':'2',
                    'subband':1},
 {'restfreq':13500,'bandwidth':100,'nchan':32768,'beam':'1'},
 {'restfreq':13500,'bandwidth':100,'nchan':32768,'beam':'2'}]
'''
