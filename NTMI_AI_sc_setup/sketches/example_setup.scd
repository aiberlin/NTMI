/*
 This is an example setup file for discussion.
 It lists two kinds of things:
- which parts of the repertoires to preload, so they are accessible when playing;
- which choices among them to activate / put in front by default.

*/

// (q.dir.base +/+ "2_proc*s/*.scd").pathMatch.collect { |path|
// var name = path.basename;
// if(name[0].isDecDigit) { name = name.drop(1) };
// if(name[0] == $_) { name = name.drop(1) };
// name.splitext[0].asSymbol;
// }.cs;

(
numChans: 6,
// filename = name ++ ".scd";
// -- look first in userdir, then in appbasedir
processesToLoad: [
	'rjkChaos', 'allArm', 'bleepo', 'brushes', 'cat',
	'dog', 'etude', 'filterFB', 'formSing', 'frya',
	'kiteHi', 'moogSing', 'revFB', 'robTron', 'test',
	'varsawFB', 'vowel', 'xFMSH', 'xf-bufFun', 'xf-ringMod'
],
// filename = name ++ "pxpreset.scd";
// allArm can have multiple presets files: allArm_adcFaves.pxpreset.scd;
// -- look first in userdir, then in appbasedir
//
presetsToLoad: [
	'rjkChaos', 'allArm', 'bleepo', 'brushes', 'cat',
	'dog', 'etude', 'filterFB', 'formSing', 'frya',
	'kiteHi', 'moogSing', 'revFB', 'robTron', 'test',
	'varsawFB', 'vowel', 'xFMSH', 'xf-bufFun', 'xf-ringMod'
],
// these are now single files with lots of processes
// make them folders with one process each, named the same?
// -> then they can be composed freely.
// or just load all files into ProxyChain.allSources?
// -> can still only take the ones used in MasterFX
masterFXSlots: [
	'00_in', '0OnePolBal', '0_DBComp', '0_comp', '0_gate', '0freqBal',
	'1holz', '1ixiDist',
	'3AdCVerb', '3ring', '3thrasher',
	'4ixiVerb',
	'5HPF', '5LPF',
	'6roto',
	'7Delay',
	'9endFilt', '9monofy', '9stereofy',
	'ampFin'
],
// stored combinations of masterfx, active slots and their resp. settings
masterFXPresets: [
	\theology, \cybernetics, \psychoanalysis,
],

// must be stored somewhere as generating func or table
influxWeightsToLoad: [ 'diagL', 'diagR', 3, 12, 37, 42, 45, 86, 98, 720 ],
// must be stored as functions somewhere
influxModsToLoad: [ ],

// names of the 4 slots to load by default
slots: [\allArm, \revFB, \robTron, \xFMSH],
// which preset for which slot? - names!
presets: [ 4, 1, 2, 3 ],
// which of the loaded influx weight presets to use
influxWeight: \diagL,
// which  influx outProc to turn on by default
influxMod: \tanh,
// which
masterFXPreset: \cybernetics
)
