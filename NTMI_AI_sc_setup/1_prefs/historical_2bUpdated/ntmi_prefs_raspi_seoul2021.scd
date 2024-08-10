/*
This is the  prefs file for the korea exhibition 2021:
- different raspis known by name load different ndefs on startup.

*/



q.userName = unixCmdGetStdOut("whoami").select(_.isAlphaNum).asSymbol;
q.hostName = {
	Platform.case(\osx, {
		unixCmdGetStdOut("hostname").split($-).first.select(_.isAlphaNum).asSymbol;
	},
	// works on raspi, hope on linux and windows too?
	{
		unixCmdGetStdOut("hostname").select(_.isAlphaNum).asSymbol;
	});
};

q.startNdefs = (
	adcpi64: [  'bleepo', 'pulselet', 'rjkChaos', 'revFB', ],
	adc: [  'bleepo', 'pulselet', 'rjkChaos', 'revFB', ],
	ntmpi_01: [  'allArm', 'granbuf', 'moogSing', 'xFMSH', ],
	ntmpi_02: [ 'bleepo', 'pulselet', 'robTron', 'xf-bufFun' ],
	ntmpi_03:   [ 'cat',  'filterFB', 'varsawFB', 'pulselet', ],
	ntmpi_04: [  'dog', 'formSing', 'revFB',  'xf-ringMod' ],
	ntmpi_05: [ 'envelo', 'kiteHi',  'rjkChaos', 'frya' ],
);

(
'name': 'raspi', // <- user name here
'numChans': 2,
'serverSetup': "serverBasic2.scd",
'hasGui': false,

// the 4 sounds to load into the slots
//	'defaultActives': [ 'allArm', 'dog', 'cat', 'revFB' ],

'defaultActives': q.startNdefs[q.hostName],

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
	'ampFin' ],
'finalSetup': "~/ntmi/finalSetup.scd",

)
