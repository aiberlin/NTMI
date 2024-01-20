/*
This file sets the default values for many preferences in NTMI;
If not defined, the values will be looked up in here.
*/

// when no initial sounds, presets are set,
// should NTMI use random initial values,
// so you get different ones every time?
NTMI.defaults.usesRandomInit = false;

NTMI.defaults.hasGui = true;


// in case it is useful, tell NTMI my username:
NTMI.defaults.myname = Platform.userHomeDir.basename.asSymbol;

/****** server setup *******/
// set number of audio input and output channels,
// for sound processes in the slots and for MainFX
NTMI.defaults.numIns = 2;
NTMI.defaults.numChans = 4;

NTMI.defaults.serverSetupFile = "serverBasic2.scd";

// should server be rebooted on NTMI.run,
// e.g. to set server options before booting?
NTMI.defaults.reboot = true;

//// a flag whether to load the MainFX  provided with NTMI:
NTMI.defaults.usesMainFX = true;


NTMI.defaults.preBoot = nil;

// write a custom sound function to play when starting NTMI:

NTMI.defaults.helloSound = {
	{ Impulse.ar(XLine.kr([1, 100], [100, 1], 1, doneAction: 2), 0, 0.5) }.play
};

NTMI.defaults.postBoot = nil;

//// tell NTMI which soundfile folder to use initially for buffer-using sounds.
//// NTMI quark has some default example files here:
NTMI.defaults.globalBufFolder = { NTMI.dir.setup +/+ "/soundfiles/examples/" };


/***** OPTIONAL: Sound Processes and Presets ******/
// // specify by name which specific processes to load,
// // and which preset settings to load initially for each process.

/*
// if none given, all processes found in POOL/2_process/ are loaded.
NTMI.dir.userPOOL.openOS;
// get all available process names with:
NTMI.process.allNames.cs;
*/

// choose a specific subset of processNames to load:
NTMI.defaults.process_namesToLoad = [
	'allArm', 'beatX', 'bleepo', 'blippoo', 'brushes',
	'dynstosyn', 'envelo', 'filterFB', 'formSing',
	'frya', 'gendy1', 'gendy2', 'granbuf'
];

// THE 4 sounds to load into the slots on startup:
// NTMI.defaults.defaultActives = [ 'bleepo', 'xFMSH', 'rjkChaos', 'notThere' ];
// if any of these dont exist as Ndefs, available Ndefs
// will be picked randomly for these slots.

//// Define which Ndef-presets to select for all sound processes,
//// including the four sound slots
NTMI.defaults.pre_initialPresetNames = [
	'bleepo' -> 'vocca',
	'xFMSH' -> 'border',
	\revFB -> \slolo,
	'rjkChaos' -> 89, // can also be an index number
	// or a function that generates an index number:
	\robTron -> { |pre| 2000.rand },
];

NTMI.defaults.postPresets = nil;

//////////// Interfaces ////////////
// //// flags whether to look for MIDI resp. HID interfaces -
// //// turning them off if not needed will speed up loading
NTMI.defaults.usesMidi = true;
NTMI.defaults.usesHid = false;

//// tell NTMI which interfaces to load by default.
//// turn off unused ones, unless you want to use them by GUI:
NTMI.defaults.interfacesToLoad = [ "nanoKtl" ];

/////////// INFLUX: //////
//// The NTMI influx uses one of weight matrices to translate
//// input from controllers into influences on the processes.
//// these weights can be generated from randomSeeds,
//// or by lookup names.

//// for influxPresets, set random seed numbers:
//// TODO: should also take strings for codefile paths ...

NTMI.defaults.inph_randSeeds = [ 7, 13, 23, 42, 86, rrand(0, 1000), \diagL ];
// // the preset key/name to set on startup
NTMI.defaults.inph_presIndex = 2;

NTMI.defaults.postInterfaces = { "\n NTMI.defaults.postInterfaces: any things to do after interfaces?".postln };

////////// MainFX: which preset to use on startup?
NTMI.defaults.mfx_domainName = \cybernetics;

/// and two more functions
NTMI.defaults.preGui = nil;

NTMI.defaults.finalSetup = nil;

