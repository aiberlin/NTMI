# NTMI 

This repository contains the full setup for the Nontrivial Music Instrument (NTMI) by Airborne Instruments: http://airborneinstruments.eu/

The NTMI is intended for an intuitive style of playing complex sound processes, 
with multiple interfaces. The setup includes: 
- 30+ sound processes to play, and you can add your own
- several software interfaces to play with
- Several supported hardware interfaces, and you can add your own:
The Airborne Instruments nUFO, 
Korg nanoKontrol2, 
Faderfox UC4, 
Thrustmaster gamepads, 
and Music Thing 8mu faderbox + motion sensor. 

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
- for a first test, try evaluating this line: 
`NTMI.run;`
-> you should see a big red GUI window called ntmi_mainStage.

Recommendation: 
Also install SC3-plugins 
(some sound processes require UGens from SC3-plugins)
https://github.com/supercollider/sc3-plugins

For loading NTMI on startup, put this line in your startup file:

NTMI.run;

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
