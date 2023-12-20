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
	LoadMe("SpecialUses/flatcat/flatcat2NTMI_better.scd", NTMI.dir.setup);
	// load flatcat visualisation file
	LoadMe("SpecialUses/flatcat/flatcat_viz.scd", NTMI.dir.setup);
	// and show the flatcat visualisation on the main window
	defer { NTMI.g.main.imuUV.animate_(true).drawFunc = MFdef(\drawFlatcat).postln };
};
// now run NTMI setup, then flatcat
NTMI.run;

