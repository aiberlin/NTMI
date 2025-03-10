/*
This file sets the default values for many preferences in NTMI;
If they are not defined somewhere in a startup script,
the values in here will be looked up and used as defaults.
*/

// GENERAL: should NTMI use random initial values
// when no initial sounds & presets are set?
// if yes, one gets to know different ones over time
NTMI.defaults.usesRandomInit = true;

// headless or regular desktop?
NTMI.defaults.hasGui = \View.asClass.notNil;
NTMI.defaults.hasSmallScreen = false;

// tell NTMI my username, e.g. for networking
NTMI.defaults.myname = Platform.userHomeDir.basename.asSymbol;

/****** Server Setup *******/
// set number of audio input and output channels,
// for sound processes in the slots and for MainFX
NTMI.defaults.numIns = 2;
NTMI.defaults.numChans = 2;

NTMI.defaults.serverSetupFile = "serverBasic2.scd";

// should server be rebooted on NTMI.run,
// e.g. to set server options before booting?
NTMI.defaults.reboot = true;

//// should the MainFX provided with NTMI load?
NTMI.defaults.usesMainFX = true;

// function to run right before booting
NTMI.defaults.preBoot = nil;

// which sound function to play when starting NTMI:
NTMI.defaults.helloSound = { LoadMe("0_helloSound.scd") };

// function to run right after booting
NTMI.defaults.postBoot = nil;

//// tell NTMI which soundfile folder to use initially for buffer-using sounds.
//// NTMI quark has some default example files here:
NTMI.defaults.globalBufFolder = { NTMI.dir.setup +/+ "/soundfiles/" };


/***** OPTIONAL: Sound Processes and Presets ******/
// // specify by name which specific processes to load,
// // and which preset settings to load initially for each process.

/*
// if none given, all processes found in POOL/2_process/ are loaded.
NTMI.dir.userPOOL.openOS;
// get all available process names with:
NTMI.process.allNames.cs;
*/

// // choose a specific subset of processNames to load
///// no default needed, nil defaults to all found processNames
NTMI.defaults.namesToLoad;

// // Define which 4 sounds to load into the slots on startup:
// NTMI.defaults.defaultActives = [ 'bleepo', 'xFMSH', 'rjkChaos', 'notThere' ];
// If any of these do not exist as Ndefs, available Ndefs
// will be picked randomly for these slots.

//// Define which Ndef-presets to select for which loaded sound processes,
//// often including the four defaultActives
//// when not set, this defaults to random sounds and presets.
NTMI.defaults.initialPresetNames = nil;
// NTMI.defaults.initialPresetNames = [
// 	'bleepo' -> 'vocca',
// 	'xFMSH' -> 'border',
// 	\revFB -> \slolo,
// 	'rjkChaos' -> 89, // can also be an index number
// 	// or a function that generates an index number:
// 	\robTron -> { |pre| 2000.rand },
// ];

// function to run after sound processes and presets are loaded
NTMI.defaults.postPresets = nil;

//////////// Interfaces ////////////
// //// flags whether to look for MIDI resp. HID interfaces -
// //// turning them off if not needed will speed up loading
NTMI.defaults.usesMidi = true;
NTMI.defaults.usesHid = false;

//// tell NTMI which interfaces to load by default.
//// turn off unused ones, unless you want to use them by GUI:
NTMI.defaults.interfacesToLoad = [ "nanoKtl" ];
NTMI.defaults.connectFoundInterfaces = true;

/////////// INFLUX: //////
//// The NTMI influx uses one of weight matrices to translate
//// input from controllers into influences on the processes.
//// these weights can be generated from randomSeeds,
//// or by lookup names.

//// for influxPresets, set random seed numbers:
//// TODO: should also take strings for codefile paths ...

NTMI.defaults.inph_randSeeds = [ 7, 13, 23, 42, 86, rrand(0, 1000), \diagL ];
// // the preset key/name to set on startup
NTMI.defaults.inph_presIndex = 0;

NTMI.defaults.postInterfaces = { "\n NTMI.defaults.postInterfaces: any things to do after interfaces are loaded?".postln };

////////// MainFX: which preset to use on startup?
// usually nil, so it defaults to random choice
// NTMI.mfx.domainName = nil;

// function to run after mainfx, before GUIs are loaded
NTMI.defaults.preGui;

// function to run after NTMI setup finishes
NTMI.defaults.finalSetup;

// flag whether demo tdefs should be loaded
NTMI.defaults.loadDemos = true;
