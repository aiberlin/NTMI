/*** example for NTMI & flatcat setup ***

// To use with StartupFile, do
StartupFile.writeStartupFileToExternalPath(\flatcat_NTMI,
	thisProcess.nowExecutingPath;
);
// then to choose it, do
StartupFile.dialog;
*****/

// Schedule loading the flatcat files
// after the full NTMI setup finishes:
NTMI.finalSetup = {
	// load flatcat setup/connection file
	LoadMe("SpecialUses/flatcat/flatcat*.scd", NTMI.dir.setup);
	// show the flatcat visualisation on the main window
	NTMI.g.main.imuUV.drawFunc.add(\flatcat, NTMI.flatcat.drawFunc);
	// and turn off showing the imu and pads
	NTMI.g.main.imuUV.drawFunc.disable(\imu);
};
// now run NTMI setup, then flatcat
NTMI.run;

