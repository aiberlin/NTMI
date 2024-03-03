
/**** Startup file example for NTMI setup on raspberry/patchbox systems ***
The NTMI quark needs the StartupFile quark, because it uses the LoadMe class.

You can copy this file to your ~/NTMI/POOL folder,
modify it there to your liking, then write a redirection
file with StartupFile:

StartupFile.writeStartupFileToExternalPath(\myNTMI, thisProcess.nowExecutingPath);

StartupFile.dialog;
*****/

"*** NTMI on patchbox ***".postln;

// prepare and use my own special hello sound
NTMI.helloSound = {
	// stereo
	{ LFDNoise3.ar(XLine.kr(4000!2, 20, 1, doneAction: 2), 0.05) }.play;
};

// typical setup for patchbox
NTMI.isPi = true;       // raspberry - use smaller gui if desktop

NTMI.hasGui = false;    // set flag for headless

// skipping some interface types will make loading faster and more stable:
// NTMI.usesMidi = false; // skip MIDI
NTMI.usesHid  = false;  // skip HID devices

NTMI.interfacesToLoad = ["mu8"];
// For further personalization, see here:
/*
Document.open(NTMI.dir.setup +/+ "HOW_TO_PERSONALIZE/1_Configure_setup.scd");
*/

// for example, post which MKtls were loaded after setup:
NTMI.finalSetup = {
	"MKtls loaded: %\n".postf(MKtl.all);
};

//////// finally, run NTMI for full setup
NTMI.run;

