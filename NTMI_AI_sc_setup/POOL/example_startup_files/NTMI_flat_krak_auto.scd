/*** example for NTMI & flatcat setup ***

// To use with StartupFile, do
StartupFile.writeStartupFileToExternalPath(\flatcat_NTMI,
	thisProcess.nowExecutingPath;
);
// then to choose it, do
StartupFile.dialog;

MKtl(\nUFO).closeDevice;
*****/

NTMI.interfacesToLoad = [ /*"nUFO", "uc4", "mu8",*/
	"nanoKtl", "dual_analog_3.2", "dual_analog_4", "ferrari" ];

// Schedule loading the flatcat files
// after the full NTMI setup finishes:
NTMI.finalSetup = {

	"NTMI.finalSetup for installation mode:P".postln;

	NTMI.xflux.verbose = false;
	NTMI.xflux.sends = false;

	Butz(\NTMI).run(\InfluxMixer);
	Window.find(\InfluxMixer).moveTo(500, 700).front;

	LoadMe("SpecialUses/kraken_modal*.scd", NTMI.dir.setup);

	0.5.wait;
	// load flatcat setup/connection file
	LoadMe("SpecialUses/flatcat/*flatcat*.scd", NTMI.dir.setup);
	NTMI.g.main.imuUV.drawFunc.add(\flatcat, NTMI.flatcat.drawFunc);
	// NTMI.g.main.imuUV.drawFunc.disable(\imuPad);
	NTMI.g.main.imuUV.animate_(true);

	NTMI.flatcat.zoom = 0.5;
	NTMI.kraken.zoom = 0.5;

	Window.find(\flatcat).moveTo(500, 200).front;

	defer ({ Tdef(\flatcatSim).stop.play }, 5);

	"NTMI.finalSetup DONE.".postln;


};
// now run NTMI setup, then flatcat
NTMI.run("~/src/aiberlin/NTMI");

