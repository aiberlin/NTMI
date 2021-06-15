
/**** Startup file example for NTMI setup on raspberry / patchbox OS ***
We recommend using the StartupFile quark to switch between
startupfiles for multiple projects, and copying the example files
most relevant to your setup in StartupFile.dir,
and modifying them as you see fit.

Quarks.install("StartupFile");
// recompile ...
StartupFile.help


// See the ntmi_prefs file for further adjustments:
(Platform.userAppSupportDir +/+ "ntmi_prefs.scd").openOS;

*****/

"*** NTMI on patchbox ***".postln;

// prepare and use my own hello sound
q = q ? ();
q.helloSnd = {
	// stereo
	{ LFDNoise3.ar(XLine.kr(4000!2, 20, 1, doneAction: 2), 0.05) }.play;
};

// setup for patchbox
q.isPi = true;       // raspberry - use smaller gui if desktop

q.hasGui = false;    // set flag for headless
// q.usesMidi = false;  // don't look for MIDI devices (faster and more stable)
// q.usesHid  = false;  // dont look for HID devices   (faster and more stable)

//////// finally, run NTMI loadMe file for full setup
"~/src/aiberlin/NTMI/NTMI_AI_sc_setup/00_loadMe.scd".loadPaths;

