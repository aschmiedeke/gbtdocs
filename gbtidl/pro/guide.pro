; docformat = 'rst' 

;+
; This procedure adds a data container to an accum buffer, in
; preparation for averaging.  The primary data container (!g.s[0], the
; PDC) is used by default but an alternate data container can be
; specified using the 'dc' keyword.
; 
; The first data container accum'ed in a buffer is used as a
; template for that buffer and subsequent data containers accum'ed to
; that buffer must match in number of channels.  On subsequent uses of
; accum, a warning is printed if the channel spacing
; (frequency_interval) or frequency resolution differs from the values
; already in the buffer.  The accumulation proceeds even when a
; warning is printed.  Use :idl:pro:`resample` to change the frequency_interval 
; and :idl:pro:`gsmooth` to change the frequency_resolution.
;
; There are four accum buffers available to this and related 
; GUIDE-layer procedures.  Users can use these to have several
; averages proceeding simultaneously, but separately, when it is useful
; to do so (e.g. polarizations).  Use the accumnum keyword to specify
; which buffer to use (defaults to 0).
;
; The default weight for each spectrum is exposure*frequency_resolution/Tsys^2. 
; A different weight can be given using the weight keyword.  Alternatively, each 
; channel can be given a separate weight by providing a vector of weights in the
; weight argument.  In that case, the number of elements in weight
; must be the same as in the data.  This can be used to re-start an
; accum from a previous average where the weight was retrieved from
; that average.  See :idl:pro:`ave` for more details.  See :idl:pro:`dcaccum` for 
; additional information on how the header parameters are weighted
; during the accumulation.
;
; Blanked channels (Not a Number data values) are excluded from the
; average. An entirely blanked spectrum (all values are NaNs - e.g. bad
; lags from the GBT spectrometer) is completely ignored by the
; accumulation (the contents of that accum buffer are unchanged).
;
; :Params:
;   accumnum : in, optional, type=integer, default=0
;       accum buffer. Defaults to the primary buffer (accumnum = 0). 
;       There are 4 buffers in all so this value must be between 0 and 3, inclusive.
;
; :Keywords:
;   weight : in, optional, type=float
;       The weight to use for averaging this data. If not set, a weight of
;       exposure*frequency_resolution/Tsys^2 is used. This can also be a
;       vector of weights, one per channel.
;
;   dc : in, optional, type=spectrum or integer
;       The data container to accum.  If not supplied, use the PDC.  If this is an
;       integer, then use the data container at that buffer number in !g.s.
;
; :Examples:
;   A simple averaging operation:
; 
;   .. code-block:: IDL
;
;       sclear
;       getrec,1
;       accum
;       getrec,2
;       accum
;       ave
;
;   Average two polarizations separately for some position switched scans
; 
;   .. code-block:: IDL
;       
;       sclear                  ; clears accum buffer 0;
;       sclear, 1               ; clears accum buffers 1
;       getps,32,plnum=0
;       accum, 0
;       getps,32,plnum=1
;       accum, 1
;       getps,34,plnum=0
;       accum, 0
;       getps,34,plnum=1
;       accum, 1
;       ave,1                   ; Average plnum=1 data and store the result in the PDC
;       copy,0,1                ; Copy the result to DC 1
;       ave, 0                  ; Average plnum=0 data
;       oshow, 1                ; Overplot the plnum=1 average
;
;   Average some data, remember the vector weights at the average, and
;   then average some more data.
;
;   .. code-block:: IDL
;
;       sclear
;       getrec,1
;       accum
;       getrec,2
;       accum
;       ave, wtarray=wtave1_3
;       copy, 0, 10              ; save average for later use
;       sclear                   ; no necessary, but better to be sure
;       getrec,3
;       accum
;       getrec,4
;       accum
;       ave, wtarray=wtave3_4
;       copy, 0, 11              ; save this for later use
;       ; other things could happen here
;       ; average 11 and 10 using appropriate weighting
;       ; they might not be scalars if some part of each was flagged or blanked
;       sclear
;       accum, dc=10, weight=wtave1_3
;       accum, dc=11, weight=wtave3_4
;       ave, wtarray=wtave_all4
; 
; :Uses:   
;
;   :idl:pro:`data_valid`
;   :idl:pro:`dcaccum`
;
;-
pro accum, accumnum, weight=weight, dc=dc
end


; docformat = 'rst'

;+
; This procedure adds the data from two data containers stored in the
; global buffers 0-15.  If no parameters are passed, then the data
; from global buffers 0 and 1 are added and the result is stored in
; global buffer 0.  If two parameters are supplied, those two global
; buffers are added together and the result of the addition is stored
; in global buffer 0.  If three parameters are supplied, then the
; first two are global buffers that are added together and the third
; is the global buffer where the result should be stored.
;
; out = in1 + in2
;
; :Params:
;
;   in1 : in, optional, type=integer
;       Input buffer number, first argument.
;   in2 : in, optional, type=integer
;       Input buffer number, second argument.
;   out : in, optional, type=integer
;       Output buffer number.
;
; :Examples:
; 
;   .. code-block:: IDL
;       
;       getrec,1
;       copy,0,1
;       getrec,2
;       add            ; The two records are added and the result is stored in buffer 0
;
;       getrec,1
;       copy,0,10
;       getrec,2
;       copy,0,11
;       add,10,11,12   ; The data from buffers 10 and 11 are added and the result is stored in buffer 12
; 
; :Uses: 
; 
;   :idl:pro:`dcadd`
;   :idl:pro:`dcpaircheck`
;
;-
pro add,in1,in2,out
end

; docformat = 'rst'

;+
; Add entries to "the stack", which is a list of numbers
; that can be used in batch operations.  The list is stored in
; the variable !g.astack.  The new entries are appended on to
; the existing list.  Use <a href="astack.html">astack</a> to get values from the stack.
;
; :Params:
; 
;   first : in, required, type=integer
;       The first value to be added to the stack.
;
;   last : in, optional, type=integer
;       The last value to be added to the stack.  If this is omitted,
;       only a single entry equal to first will be appended.
;
;   step : in, optional, type=integer
;       The increment between values. If omitted, a step of 1 will be used.
;
; :Examples:
; 
;    add numbers 25, 30 through 39, and the odd indexes from 41
;    through 51 to the stack.
; 
;   .. code-block:: IDL
;    
;       addstack, 25
;       addstack, 30, 39
;       addstack, 41, 51, 2
;
; :Uses:
; 
;   :idl:pro:`appendstack`
;-
pro addstack, first, last, step
end
