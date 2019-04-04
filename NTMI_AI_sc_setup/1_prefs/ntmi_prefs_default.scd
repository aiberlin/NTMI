(
'name': 'adc',
'numChans': 2,
'serverSetup': "serverBasic2.scd",

processNames: [
	'allArm', 'bleepo', 'brushes', 'cat', 'dog',
	'etude', 'filterFB', 'formSing', 'frya', 'kiteHi',
	'moogSing', 'revFB', 'rjkChaos', 'robTron', 'test',
	'varsawFB', 'vowel', 'xFMSH',
	// 'xf-bufFun', 'xf-ringMod'
],
'defaultActives': [ 'allArm', 'dog', 'cat', 'revFB' ],

// /// TODO: preset names different from ndef names ...
// presetNames: [
// 	'allArm' -> 'allArmistice',
// ],

// /// TODO: influxPresets from files if not numbers ...
influxPresets: [ 3, 12, 37, 42, 45, 86, 666, 1000.rand ],
// the one to set it to
influxPreset: 3,

// just filenames with collections for now
effects: [ "allFX.scd" ],

// all slotNames in q.mFX
mfxSlotNames: [
	'00_in', '0OnePolBal', '0_DBComp', '0_comp', '0_gate', '0freqBal',
	'1holz', '1ixiDist',
	'3AdCVerb', '3ring', '3thrasher',
	'4ixiVerb', '5HPF', '5LPF',
	'6roto', '7Delay',
	'9endFilt', '9monofy', '9stereofy',
	'ampFin' ],
// all stored presets , theology etc
mfxPresets: [ ],

// the first MFX preset to switch to
mfxPreset: \cybernetics
)
