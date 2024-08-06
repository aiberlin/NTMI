/*** example for NTMI & flatcat setup ***

// To use with StartupFile, do
StartupFile.writeStartupFileToExternalPath(\flatcat_NTMI,
thisProcess.nowExecutingPath;
);
// then to choose it, do
StartupFile.dialog;

// start oscar&xflux
NTMI.oscar.makeServer;
// activate flatcat simulation
defer ({ Tdef(\flatcatSim).stop.play }, 1);

// stop this tdef from unintended self-looping (happens sometimes)
Tdef(\allLEDs).clear;

// NetLib quark has this:
NetAddr.myIP
// nUFO NTMI network address is:
"169.254.1.2"
// close nUFO device when switching to flatcat
MKtl(\nUFO).closeDevice;

*****/

// s.options.device = "UMC404HD 192k";

NTMI.interfacesToLoad = [
	"nUFO",
	"uc4", "mu8",
	"nanoKtl",
	"dual_analog_3.2",
	"dual_analog_4",
	"ferrari"
];

// Schedule loading the flatcat files
// after the full NTMI setup finishes:
NTMI.finalSetup = {

	"\n\n*** NTMI.finalSetup for AbsRel+kraken+flatcat setup: \n".postln;

	// Butz(\NTMI).run(\InfluxMixer);
	// Window.find(\InfluxMixer).moveTo(500, 700).front;

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

	// autostart flatcat sim?
	// defer ({ Tdef(\flatcatSim).stop.play }, 5);
	"*** NTMI.finalSetup DONE.\n\n".postln;
};

// now run NTMI setup, then flatcat
NTMI.run("~/src/aiberlin/NTMI");

