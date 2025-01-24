The modules in `optics` are forward engineered for both understanding dual-beam SLM configurations 
& potential future use. The code quality is highly variable. Minor portions are copy/pasted from
`neurobeam`. Anything good will eventually get polished, tested, & merged into `neurobeam`'s optics 
module and the rest will be left to rot.


The initial `spatial_light_modulator` module was from when I was reverse engineering 
slm stuff to understand things before `slmsuite`. These are completely untested and I don't 
plan to ever test them. They don't have a backend for meadowlark PCIe-connected SLMs, 
so I wrote my own and will get around to push/testing it. Assuming that that feature 
will be pushed expediently, we can use `slmsuite` as an interface to make any SLM operations 
hardware-agnostic. 


**warning**: This repo is not intended for use by anyone other than me. It 
might contains bugs, errors, and other issues. It is not guaranteed to work. It is not
guaranteed to be safe. It is not guaranteed to be correct--some of the code might 
have been hastily scribbled down from memory and never actually run a single time. 
It is not guaranteed to be
anything other than a scratchpad.