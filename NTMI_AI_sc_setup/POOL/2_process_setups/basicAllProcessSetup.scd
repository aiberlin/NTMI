/////////// EXAMPLE PROCESS SETUP ////////////

// // post all found processes:
// (q.dir.base +/+ "*processes/*.scd").pathMatch.collect { |path|
// 	path.basename.splitext[0].asSymbol;
// }.postcs;

// [ 'rjkChaos', 'allArm', 'bleepo', 'brushes', 'cat', 'dog', 'etude', 'filterFB', 'formSing', 'frya', 'kiteHi', 'moogSing', 'revFB', 'robTron', 'test', 'varsawFB', 'vowel', 'xFMSH', 'xf-bufFun', 'xf-ringMod' ].collect { |key| key -> key }.cs;


(
/// processes: preload all found processes
processNames: [ 'rjkChaos', 'allArm', 'bleepo', 'brushes', 'cat', 'dog', 'etude', 'filterFB', 'formSing', 'frya', 'kiteHi', 'moogSing', 'revFB', 'robTron', 'test', 'varsawFB', 'vowel', 'xFMSH', 'xf-bufFun', 'xf-ringMod' ],

//// write out the default preset names for each process:
//// replace when people use multiple presets files,
processPresets: [
	// modify like this:
//  ('rjkChaos' -> 'rjkChaosMine')
	('rjkChaos' -> 'rjkChaos'),
	('allArm' -> 'allArm'),
	('bleepo' -> 'bleepo'),
	('brushes' -> 'brushes'),
	('cat' -> 'cat'),
	('dog' -> 'dog'),
	('etude' -> 'etude'),
	('filterFB' -> 'filterFB'),
	('formSing' -> 'formSing'),
	('frya' -> 'frya'),
	('kiteHi' -> 'kiteHi'),
	('moogSing' -> 'moogSing'),
	('revFB' -> 'revFB'),
	('robTron' -> 'robTron'),
	('test' -> 'test'),
	('varsawFB' -> 'varsawFB'),
	('vowel' -> 'vowel'),
	('xFMSH' -> 'xFMSH'),
	('xf-bufFun' -> 'xf-bufFun'),
	('xf-ringMod' -> 'xf-ringMod')
],

//////// start with isak favorites:
slotsNames: [ 'robTron', 'cat', 'revFB', 'xFMSH'],
//////// or with hannes favorites:
// slotNames: [ 'bleepo', 'moogSing', 'revFB', 'xFMSH'],
)

