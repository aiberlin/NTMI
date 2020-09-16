/////////// EXAMPLE PROCESS SETUP ////////////

// // post all found processes:
// (q.dir.base +/+ "*processes/*.scd").pathMatch.collect { |path|
// 	path.basename.splitext[0].asSymbol;
// }.postcs;


(
/// processes: preload all found processes
processNames: (q.dir.base +/+ "*processes/*.scd").pathMatch.collect { |path|
	path.basename.splitext[0].asSymbol;
},
//////// start with isak favorites:
slotsNames: [ 'robTron', 'cat', 'revFB', 'xFMSH'],
//////// or with hannes favorites:
// slotNames: [ 'bleepo', 'moogSing', 'revFB', 'xFMSH'],

// influx weight presets to load or create - usually 8
// string or symbol is filename, number is randseed:
influxPresets: [ 3, 12, 37, 42, 45, 86, 98, 875 ],
// key of influxPreset to put into starting weights:
influxWeights: 42,

////// not yet implemented, just sketched here:
influxTerrains: [\none, \tanh, \env7, \env13],
currTerrain: [\tanh],

// preload these effects files for MainFX
effectsFiles: [ "basic" ],
mfxSlotNames: [ '00_in', '0OnePolBal', '0_DBComp', '0_comp', '0_gate', '0freqBal', '1holz', '1ixiDist', '3AdCVerb', '3ring', '3thrasher', '4ixiVerb', '5HPF', '5LPF', '6roto', '7Delay', '9endFilt', '9monofy', '9stereofy', 'ampFin' ],

/////////// not implemented yet, just sketched here -
// preload these combinations of MainFX presets:
mfxPresetNames: [ \theology, \cybernetics, \psychoanalysis ],
// and call up this one to start
mfxPreset: \psychoanalysis
)

