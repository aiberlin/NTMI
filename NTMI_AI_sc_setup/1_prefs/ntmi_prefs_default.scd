/*
  This is a default ntmi prefs file tested for macOS users.
  It is copied automatically to Platform.userAppSupportDir,
- and you can modify it there as you like!

  It has lots of explanatory comments so users know
  what to change for what effect.

  filenames of code files to load can be:
* relative to q.dir.ntmi (i.e. in the project folder), like "serverBasic2.scd";
* or absolute, like "~/mycode/ntmi/myServerSetup23.scd", which is a full path.

*/

q = q ? ();
q.hostName = Platform.userHomeDir.basename.asSymbol;
// q.hostName = \patch; // test raspi/patchbox

// use the same prefs file fo different users
q.startNdefs = (
	// specific person's laptop
	adc: [  'bleepo', 'pulselet', 'rjkChaos', 'revFB' ],
	// all raspberries with patchbox OS, user 'patch',
	// use gendyn synthesis patches
	patch: [ 'gendhy', 'gendy2', 'gendyfyre', 'rjkChaos' ]
);

(
'name': q.myname ? q.hostName, // <- if not hostname, put your user name here
'numIns': q.numMics ? 4,       // number of input channels to use
'numChans': q.numChans ? 2,     // number of output channels to use in the slot sounds and MainFX

// flag whether to run gui-related code or not - true for macOS,
/// false for headless systems, e.g. raspberry or bela
'hasGui': \Window.asClass.isNil,
// //// or set to false for testing?
// 'hasGui': true,

'rebootServer': false,

// there are four stages where personalized extra code can be inserted:

// after first globals are loaded,
// a script to try to configure the server
//////// filename for the server setup
'serverSetup': "serverBasic2.scd",

// last code file to load before booting
'preBootSetup': "~/Desktop/ntmi/preBootSetup.scd",

// first code file to load right after server has booted
'postBootSetup': "~/Desktop/ntmi/postBootSetup.scd",

/// ... load all sound processes and their presets ...
/// ... load all interfaces, postres and GUIs etc ...

// personalize after loadMe file setup is finished
'finalSetup': "~/Desktop/ntmi/finalSetup.scd",

///////////// OPTIONAL: ////////////////
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
'defaultActives': q.startNdefs[q.hostName] ? [ 'cat', 'xFMSH', 'robTron', 'revFB' ],

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
// load everything in basic collection allFX for now
effects: [ "allFX.scd" ],

// the slotNames to put into the MainFX - q.mFX :
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
