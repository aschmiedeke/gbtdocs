source = '2253+1608'                    
freq_argus = 93173.0                    

#Break("Ask the operator to switch to Argus. Click yes when Argus is in place.")

SetValues("ScanCoordinator", {"receiver": "RcvrArray75_115"})
SetValues("LO1", {"restFrequency_A": freq_argus})

AutoPeak(source, frequency=freq_argus, elAzOrder=True)
Break("Check the pointing solution")
Focus(source)
Break("Check the focus solution")
AutoPeak(source, frequency=freq_argus, elAzOrder=True)
