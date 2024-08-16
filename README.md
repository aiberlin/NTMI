# NTMI 

NTMI is short for Nontrivial Music Instrument, a project by Airborne Instruments: 
http://airborneinstruments.eu/

An NTMI tutorial is at https://s4ntp/ntmi

	Short overview:
NTMI is a performance environment originally designed for playing with
a custom interface, the nUFO, designed by Isak Han for intuitive playing.
It has since been expanded to work with a variety of common interfaces 
such as faderboxes, gamepads, and others. 
This repository contains the full performance environment as a SuperCollider extension library. 

NTMI is intended for an intuitive style of playing with 
multiple complex sound processes, and multiple interfaces. 
You can play up to 4 sound processes in parallel, 
and multiple controllers can influence these at the same time.

The NTMI environment includes: 
- 30+ sound processes to play, and you can add your own
- A general effects section for the main sound output.  
- Several software interfaces to play with
- Several supported hardware interfaces, and you can add your own:
The Airborne Instruments nUFO, 
Korg nanoKontrol2, 
Faderfox UC4, 
several Thrustmaster gamepads, 
and the Music Thing 8mu faderbox + motion sensor.


The code is best installed as a SuperCollider Quark, i.e. an extension package.s

* How to install and run this setup within SuperCollider:

(if needed:) 

-  install SuperCollider from https://supercollider.github.io 

SuperCollider needs git, a software codebase management tool
for loading its libraries. 
To check if you have it already, run this line in SuperCollider:
`Git.checkForGit`
if true, you have git installed
if not, 
- install Git:
	linux: almost always has it
	windows: 
		get from https://git-scm.com, 
		reboot computer
	macOS: 
		get from https://git-scm.com, 
		from brew, 
		or get xcode commandline developer tools.

* install the NTMI Quark with:
`Quarks.install("NTMI");`
This installs all other required quarks.

- update all quarks that NTMI depends on to current versions:
`Quark("NTMI").dependencies.do(_.update);`

NOTE: if you have any local modifications in a quark, 
`Quark("something").update` will fail silently. 
In that case, open Terminal, go to the quark folder, 
and check which files are changed with `git status` etc.

When the required quarks are updated: 
- recompile the class library
- for a first test, try evaluating this line: 
`NTMI.run;`
-> you should see a big red GUI window called ntmi_mainStage.

Now go to the NTMI tutorial at https://s4ntp/ntmi,
or in the Butz window, go to NTMI_Demos and watch them

Recommendations: 
- Also install SC3-plugins 
(some sound processes require UGens from SC3-plugins)
from https://github.com/supercollider/sc3-plugins

For loading NTMI on startup, put this line in your startup file:
NTMI.run;

or use the StartupFile quark:
```
StartupFile.writeStartupFileToExternalPath('ntmi',
 (Quark("NTMI").localPath +/+ "NTMI_AI_sc_setup/00_loadMe.scd")
);
// test that the file is there:
StartupFile.pathsDict.keys.includes('ntmi');
// and write a startup.scd that redirects to NTMI loadMe:
StartupFile.writeRedirectFile('ntmi');
```

For personalizing NTMI to your wishes, 
start reading in (Butz) NTMI_Config ...

For a general tutorial on SC, see Bruno Ruviaro, 
https://ccrma.stanford.edu/~ruviaro/texts/A_Gentle_Introduction_To_SuperCollider.pdf

also in Brazilian: 
https://ccrma.stanford.edu/~ruviaro/texts/Uma_Gentil_Introducao_ao_SuperCollider.pdf

