/* this is the default ntmi prefs file
- you can modify it as you like!
*/

(
'name': 'raspi', // <- user name here
'numChans': 2,
'serverSetup': "serverBasic2.scd",
'hasGui': false,

// the 4 sounds to load into the slots
'defaultActives': [ 'allArm', 'dog', 'cat', 'revFB' ],

influxPresets: [ 3, 12, 37, 42, 45, 86, \diagL ],
// the preset key/name to set it to
influxPreset: 3,

// these are just filenames with collections of funcs for now
effects: [ "allFX.scd" ],

// the slotNames to put into q.mFX
mfxSlotNames: [
	'00_in', '0OnePolBal', '0_DBComp', '0_comp', '0_gate', '0freqBal',
	'1comby', '1holz', '1ixiDist',
	'3AdCVerb', '3ring', '3thrasher',
	'4ixiVerb', '5HPF', '5LPF',
	'6roto', '7Delay',
	'9endFilt', '9monofy', '9stereofy',
	'ampFin' ]
)
