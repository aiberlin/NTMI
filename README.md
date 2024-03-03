# NTMI 

This repository contains the full setup for the Nontrivial Music Instrument (NTMI) by Airborne Instruments: http://airborneinstruments.eu/

The code is all in SuperCollider, and is best installed as a SuperCollider Quark, i.e. an extension package. (For better access to users with little interest in coding, it can also be packaged into Standalone apps made with SuperCollider).

Instructions to run this setup within SuperCollider:

- install the NTMI Quark with:
`Quarks.install("NTMI");`
This installs all other required quarks.

- update all quarks that NTMI depends on to their current versions:
`Quark("NTMI").dependencies.do(_.update);`

NOTE: if you have any local modifications in a quark, 
`Quark("something").update` will fail silently. 
In that case, open Terminal, go to the quark folder, 
and check which files are changed with `git status` etc.

When the quarks are updated: 
- recompile the class library
- for a first test, run the file "00loadMe.scd"
-> you should see a big red GUI window called ntmi_mainStage.

Recommendation: 
Also install SC3-plugins 
(some sound processes require UGens from SC3-plugins)
https://github.com/supercollider/sc3-plugins

For auto-loading NTMI (or other projects) on startup, 
use the StartupFile quark:
```
StartupFile.writeStartupFileToExternalPath('ntmi',
 (Quark("NTMI").localPath +/+ "NTMI_AI_sc_setup/00_loadMe.scd")
);
// test that the file is there:
StartupFile.pathsDict.keys.includes('ntmi');
// and write a startup.scd that redirects to NTMI loadMe:
StartupFile.writeRedirectFile('ntmi');
```

Then start reading in NTMI_Config ...
