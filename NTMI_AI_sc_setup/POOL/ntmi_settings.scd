/*
This file is an example for the using NTMI settings.
It is based on this file:
(NTMI.dir.setup +/+ "0_globals/ntmi_defaults.scd").openOS

*/

// GENERAL: should NTMI use random initial values
// when no initial sounds & presets are set?
// if yes, one gets to know different ones over time
NTMI.usesRandomInit = true;

// headless or regular desktop?
NTMI.hasGui = true;
NTMI.hasSmallScreen = false;

// tell NTMI my username, e.g. for networking
// NTMI.myname = Platform.userHomeDir.basename.asSymbol;
NTMI.myname.postcs;
// NTMI.myname = <desiredNameHere>;

/****** Server Setup *******/
// set audio hardware specifics first, e.g.Ö
s.options.device = "SSL 12";
s.options.sampleRate = 48000;
s.options.numOutputBusChannels = 8;
s.options.numInputBusChannels = 4;

// set number of audio input and output channels,
// for sound processes in the slots and for MainFX
NTMI.numIns = s.options.numInputBusChannels;
NTMI.numChans = s.options.numOutputBusChannels;

NTMI.serverSetupFile = "serverBasic2.scd";

// should server be rebooted on NTMI.run?
// e.g. to set server options before booting?
NTMI.reboot = true;

//// should the MainFX provided with NTMI load?
NTMI.usesMainFX = true;

// function to run right before booting
NTMI.preBoot = nil;

// which sound function to play when starting NTMI:
NTMI.helloSound = { LoadMe("0_helloSound.scd") };

// function to run right after booting
NTMI.postBoot = nil;

//// tell NTMI which soundfile folder to use initially for buffer-using sounds.
//// NTMI quark has some default example files here:
NTMI.globalBufFolder = { NTMI.dir.setup +/+ "/soundfiles/examples/" };


/***** OPTIONAL: Sound Processes and Presets ******/
// // specify by name which specific processes to load,
// // and which preset settings to load initially for each process.

/*
// if none given, all processes found in POOL/2_process/ are loaded.
NTMI.dir.userPOOL.openOS;
// get all available process names with:
NTMI.process.allNames.cs;
*/

// // choose a specific subset of processNames to load:
// NTMI.process_namesToLoad = [
// 	'allArm', 'beatX', 'bleepo', 'brushes',
// 	'dynstosyn', 'envelo', 'filterFB', 'formSing',
// 	'frya', 'gendy1', 'gendy2', 'granbuf'
// ];

// // Define which 4 sounds to load into the slots on startup:
// NTMI.defaultActives = [ 'bleepo', 'xFMSH', 'rjkChaos', 'notThere' ];
// If any of these do not exist as Ndefs, available Ndefs
// will be picked randomly for these slots.

//// Define which Ndef-presets to select for any loaded sound processes,
//// including the four sound slots
NTMI.initialPresetNames = [
	'bleepo' -> 'vocca',
	'xFMSH' -> 'border',
	\revFB -> \slolo,
	'rjkChaos' -> 89, // can also be an index number
	// or a function that generates an index number:
	\robTron -> { |pre| 2000.rand },
];

// function to run after sound processes and presets are loaded
NTMI.postPresets = nil;



//////////// Interfaces ////////////
// //// flags whether to look for MIDI resp. HID interfaces -
// //// turning them off if not needed will speed up loading
NTMI.usesMidi = true;
NTMI.usesHid = false;

//// tell NTMI which interfaces to load by default.
//// turn off unused ones, unless you want to use them by GUI:
NTMI.interfacesToLoad = [ "nanoKtl" ];
NTMI.connectFoundInterfaces = true;

/////////// INFLUX: //////
//// The NTMI influx uses one of weight matrices to translate
//// input from controllers into influences on the processes.
//// these weights can be generated from randomSeeds,
//// or by lookup names.

//// for influxPresets, set random seed numbers:
//// TODO: should also take strings for codefile paths ...

NTMI.inph_randSeeds = [ 7, 13, 23, 42, 86, rrand(0, 1000), \diagL ];
// // the preset key/name to set on startup
NTMI.inph_presIndex = 0;

NTMI.postInterfaces = { "\n NTMI.postInterfaces: any things to do after interfaces?".postln };

////////// MainFX: which preset to use on startup?
NTMI.mfx_domainName = \cybernetics;

// function to run after mainfx, before GUIs are loaded
NTMI.preGui = nil;

// function to run after NTMI setup finishes
NTMI.finalSetup = nil;

// flag whether demo tdefs should be loaded
NTMI.loadDemos = true;
