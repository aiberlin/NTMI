
/**** Startup file example for NTMI setup on desktop systems, such as macOS ***
The NTMI quark needs the StartupFile quark, because it uses the LoadMe class.

You can copy this file to your NTMI/POOL folder,
modify it there to your liking, then write a redirection
file with StartupFile:

StartupFile.writeStartupFileToExternalPath(\myNTMI, thisProcess.nowExecutingPath);

StartupFile.dialog;
*****/

// prepare and use my own special hello sound
NTMI.helloSound = {
	// stereo
	{ LFDNoise3.ar(XLine.kr(4000!2, 20, 1, doneAction: 2), 0.05) }.play;
};

// you can test different other configs on macOS for development
// NTMI.isPi = true;       // raspberry - e.g. use smaller gui

// NTMI.hasGui = false;    // test headless
// NTMI.usesMidi = false;  // don't look for MIDI devices (faster and more stable)
// NTMI.usesHid  = false;  // dont look for HID devices   (faster and more stable)


//////// finally, run NTMI for full setup
NTMI.run;
