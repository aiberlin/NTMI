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
	LoadMe("3_interfaces/optionals/flatcat/*flatcat*.scd", NTMI.dir.setup);
	1.wait;
	NTMI.flatcat.postln;
	// NTMI.g.main.imuUVMFunc.add(\flatcat, NTMI.flatcat.drawFunc);
	// // NTMI.g.main.imuUVMFunc.disable(\imuPad);
	// NTMI.g.main.imuUV.animate_(true);
};

// now run NTMI setup, then flatcat
NTMI.run;

