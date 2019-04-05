# NTMI 

This repository contains the full setup for the Nontrivial Music Instrument (NTMI) by Airborne Instruments. The code is all in SuperCollider, and can be loaded from the SuperCollider IDE; for better access to users with little interest in coding, it is also packaged in Standalone apps made with SuperCollider.

Instructions to run this setup with SuperCollider:

1. install quarks:

[ "JITLibExtensions", "adclib", "Influx", "Modality-toolkit", "MultiTouchPad", "Standalone", "Vowel" ].do(Quarks.install(_));

2. install SC3-plugins (some sounds require SVF and RLPFD UGens)

3. run the file "00loadMe.scd"
