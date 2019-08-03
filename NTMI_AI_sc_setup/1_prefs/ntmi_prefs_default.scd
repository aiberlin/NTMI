/*
  This is a default ntmi prefs file for macOS users.
  It is copied automatically to Platform.userAppSupportDir,
- and you can modify it there as you like!

  It has lots of explanatory comments so users know
  what to change for what effect.

  filenames of code files to load can be:
* relative, like "serverBasic2.scd", which will be taken from the project folder, or
* absolute, like "~/mycode/ntmi/myServerSetup23.scd", which is a full path.

*/


(
'name': 'default', // <- put your user name here
'numIns': 2,       // number of input channels to use
'numChans': 2,     // number of output channels to use in the slot sounds and MasterFX

// run the gui-related code - true for macOS,
/// false for headless systems, e.g. raspberry
'hasGui': true,


// four stages where personalized extra code can be inserted:

// after first globals are loaded, a script to configure the server
//////// filename for the server setup
'serverSetup': "serverBasic2.scd",

/// ... load all sound processes and their presets ...

// last code file to load before booting
'preBootSetup': "~/Desktop/nufo/preBootSetup.scd",

// first code file to load right after server has booted
'postBootSetup': "~/Desktop/nufo/postBootSetup.scd",

/// ... load all interfaces, postres and GUIs etc ...

// personalize after loadMe file setup is finished
'finalSetup': "~/Desktop/nufo/finalSetup.scd",


//////// specify wich specific processNames to load
//////// if none given or commented out,
//////// all processes found in POOL folders will be loaded.
// processNames: [
// 	'allArm', 'bleepo', 'brushes', 'cat', 'dog',
// 	'etude', 'filterFB', 'formSing', 'frya', 'kiteHi',
// 	'moogSing', 'revFB', 'rjkChaos', 'robTron', 'test',
// 	'varsawFB', 'vowel', 'xFMSH',
// 	// 'xf-bufFun', 'xf-ringMod'
// ],

// THE 4 sounds to load into the slots on startup
'defaultActives': [ 'cat', 'xFMSH', 'robTron', 'revFB' ],

// /// TODO: which Ndef-presets to select for each sound slots
// presetNames: [
// 	'allArm' -> 'allArmistice',
// ],


////// Make six influx presets for different random seed numbers
////// Number 6 is fix, to allow 6 button colors on Interactor buttons!
////// plus diagL preset for simple 1-1 control
// /// TODO: influxPresets from code filenames if not numbers ...
influxPresets: [ 3, 12, 37, 42, 45, 86, \diagL ],
// the preset key/name to set it to
influxPreset: 3,

// code filenames with collections of effects funcs to load
// simple for now
effects: [ "allFX.scd" ],

// the slotNames to put into the MasterFX - q.mFX :
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

// TODO: the first MFX preset to switch to
mfxPreset: \cybernetics
)
