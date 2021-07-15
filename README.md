# NTMI 

This repository contains the full setup for the Nontrivial Music Instrument (NTMI) by Airborne Instruments: http://airborneinstruments.eu/

The code is all in SuperCollider, and is best installed as a SuperCollider Quark, i.e. an extension package. (For better access to users with little interest in coding, it can also be packaged into Standalone apps made with SuperCollider).

Instructions to run this setup within SuperCollider:

- install as Quark (which installs all other required quarks)
`Quarks.install("NTMI");` or if this doesn't work: `Quarks.install("https://github.com/aiberlin/NTMI")`

- update all installed Quarks to their current versions:
`Quarks.installed.do(_.update);`

- recompile the class library

- run the file "00loadMe.scd"

You can personalize this setup later with
- a startup file so NTMI loads automatically
- a personalized ntmi preferences file for your settings
- inserting your own code in the loading process, for adding your own sound processes, presets, interfaces, or other modifications.

Recommended: also install SC3-plugins 
(some sound processes may require UGens from SC3-plugins)
https://github.com/supercollider/sc3-plugins
and if you switch between projects in SuperCollider, try 
Quarks.install("StartupFile");
