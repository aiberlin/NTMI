# NTMI_AI_sc - A project folder for SuperCollider

This repository contains the full setup for the Nontrivial Music Instrument (NTMI) by Airborne Instruments. You can  code is all in SuperCollider, and can be loaded from the SuperCollider IDE; for better access to users with little interest in coding, it is also packaged in Standalone apps made with SuperCollider. It is hosted at github here:
https://github.com/aiberlin/NTMI


Instructions to run this setup with SuperCollider:

1. install NTMI as a quark:
```
Quarks.install("https://github.com/aiberlin/NTMI");
```
NTMI requires several quarks - in case the loadscript fails,
please make sure you have the latest versions of these quarks:
```
[ "JITLibExtensions", "adclib", "Influx", "Modality-toolkit", "Vowel", "PaneView" ].do(Quark(_).update);
```
2. optional: install SC3-plugins (some additional sound patches use the UGens SVF and RLPFD)

3. run the file "00loadMe.scd" (or load it from a startup file etc)


---
The project folder is organised as follows:

__README_NTMI_projdir.md - this textfile

_Interface_Functions.scd - Overview of all functions that controllers should access to play with the NTMI app.

********* the code base: ************

- 0_globals/				- self-tests, server & network setup
- 00_loadMe.scd				- the sc script that loads the project
- 1_prefs/					- user and default preferences for the app

- 2_liveInput.scd			- support for live sound input
- 2a_preset_func.scd		- make presets for the sound  

- 3_interfaces/				- OSC, MIDI devices, the 4 slots, presets,
- 5_postres/				- MainOut Effects, NTMI-osc simulator, etc.
- 8_GUIs/					- all Graphical User Interfaces

- 9_optionals/				- code files that are NOT loaded automatically
- macos_binaries/		    - binaries for macOS commandline programs: 
	tongsengmod for MTP, OSCGroupClient, etc

- POOL/	- a pool of all sound and fx processes and settings; users can copy this to their user home dir and modify it as desired (e.g. add sounds and FX) there.

**************** EXTRAS ****************

Sketches				- sketches and tests for developing next features

Tests					- A test suite for verifying that all is well, plus utilities, e.g. for multichannel speakers
