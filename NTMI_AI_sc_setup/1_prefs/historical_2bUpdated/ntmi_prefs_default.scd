/*
  This is a default ntmi prefs file tested for macOS users.
  It is copied automatically to Platform.userAppSupportDir,
- and you can modify it there as you like!

  It has lots of explanatory comments so users know
  what to change for what effect.

  filenames of code files to load can be:
* relative, like "serverBasic2.scd", which will be taken from the project folder, or
* absolute, like "~/mycode/ntmi/myServerSetup23.scd", which is a full path.

*/


(
'name': '???', // <- put your user name here
'numIns': 2,       // number of input channels to use
'numChans': 2,     // number of output channels to use in the slot sounds and MainFX

//// a flag whether to run gui-related code or not
//// - usually true for desktop systems, macOS, windows, linux,
/// and false for headless systems, e.g. raspberry lite or bela
'hasGui': true,
//// a flag whether NTMI should reboot the server if already running,
//// so it can set server options as needed:
reboot: true,

//// a flag whether to load the MainFX collection provided with NTMI:
usesMainFX: true,

//// flags whether to look for MIDI resp. HID interfaces -
//// turning them off if you dont need them will speed up loading
usesMidi: true,
usesHid: true,
//// tell NTMI which default interfaces to load.
//// turn off the ones you do not need,
//// unless you want to use them from their GUIs:
interfacesToLoad: [ "ferrari", "uc4", "nanoKtl" ],

//// folder with soundfiles to use for buffer-using sound processes
//// NTMI quark has some default example files here:
bufferFolder: { NTMI.dir.setup +/+ "/soundfiles/" },

// There are four stages where personalizing code can be inserted:

// After the first globals are loaded, a script to configure the server
//////// filename for the server setup
'serverSetup': "serverBasic2.scd",

// last code file to load before booting
'preBootSetup': NTMI.dir.user +/+ "preBootSetup.scd",

// first code file to load right after server has booted
'postBootSetup': NTMI.dir.user +/+ "postBootSetup.scd",

/// ... load all sound processes and their presets ...
/// ... load all interfaces, postres and GUIs etc ...

// personalize after loadMe file setup is finished
'finalSetup': NTMI.dir.user +/+ "finalSetup.scd",

///////////// OPTIONAL: ////////////////
//////// specify wich specific processNames to load
//////// if none given or commented out,
//////// all processes found in POOL folders will be loaded.
// processNames: [
// 	// 'allArm', 'bleepo', 'brushes',
// 	'cat', 'dog',
// 	//'etude', 'filterFB', 'formSing', 'frya', 'kiteHi',
// 	// 'moogSing',
// 	'revFB', 'rjkChaos',
// 	'robTron', 'testMissing',
// 	'varsawFB', 'vowel', 'xFMSH',
// 	// 'xf-bufFun', 'xf-ringMod'
// ],

// THE 4 sounds to load into the slots on startup:
'defaultActives': [ 'bleepo', 'xFMSH', 'rjkChaos', 'revFB' ],
// if any of these dont exist as Ndefs, available Ndefs
// will be picked randomly for these slots.

//// Define which Ndef-presets to select for all sound processes,
//// including the four sound slots
presetNames: [
	'bleepo' -> 'vocca',
	'xFMSH' -> 'border',
	\revFB -> \slolo,
	'rjkChaos' -> 89, // can also be an index number
	// or a function that generates an index number:
	\robTron -> { |pre| 2000.rand },
],


/////////// INFLUX: //////
//// The NTMI influx uses one of weight matrices to translate
//// input from controllers into influences on the processes.
//// these weights can be generated from randomSeeds,
//// or by lookup names.


//// for influxPresets, set random seed numbers:
//// TODO: should also take strings for codefile paths ...
// influxPresets: [ 15, 12, 37, 42, 45, 86, \diagL ],
influxPresets: [ 7, 13, 23, 37, 42, 86, rrand(0, 1000), \diagL ],

// the preset key/name to set on startup
influxPreset: 23,

///////////// NOT ACTIVE YET : //////
// code filenames with collections of effects funcs to load
// load everything in basic collection allFX for now
effects: [ "allFX.scd" ],

// the slotNames to put into the MainFX - NTMI.mFX :
mfxSlotNames: [
	'00_in', '0OnePolBal', '0_DBComp', '0_comp', '0_gate', '0freqBal',
	'1comby', '1holz', '1ixiDist',
	'3AdCVerb', '3ring', '3thrasher',
	'4ixiVerb', '5HPF', '5LPF',
	'6roto', '7Delay',
	'9endFilt', '9monofy', '9stereofy',
	'ampFin' ],

// TODO: put all stored presets here, theology etc
mfxPresets: [ ],

// this works already - the first MFX preset to switch to
mfxPreset: \cybernetics
)
