
/************* nUFO sensor modes ***

The nUFO has several modes for playing the sounds,
which determine whether and how the motion sensors and pads
influence the sounds:
- move means only use the motion sensor
- touch means use the pads as continuous sensors
- binary means use the pads as a binary clavier
.   to switch between the active sounds presets.
- full is move + touch,
- binmove is move + binary.

NTMI.nUFO.printInterface
// The full choice of these modes is:
NTMI.nUFO.allModes = [
	\full,    // move/imu, touch/pads
	\move,    // only move/imu
	\touch,   // only touch/pads
	\binary,  // pads as binary preset-switching clavier
	\binMove, // pads as binary, plus move/imu best in setRel mode
	\off      // all
];

// The default mode choices are:
NTMI.nUFO.modes
-> [ 'full', 'touch', 'binary' ]
*/
// One choose freely which subset of allModes to use, e.g.:
NTMI.nUFO.modes = [ 'full', 'touch', 'binary', 'binMove', 'off' ];

// To set which mode to go to, use e.g.
NTMI.nUFO.modeIndex = 0;

// to go to specific mode, do:
NTMI.nUFO.setModeIndex(1);

// to step thru the modes, use
NTMI.nUFO.modeStep(1); // up
NTMI.nUFO.modeStep(-1); // down
NTMI.nUFO.modeStep(nil); // rand


/*** NTMI.nUFO.influxModes *****

the nUFO can play the influx in two different modes:
NTMI.nUFO.influxModes.postcs;
[ 'setRel', 'setAbs' ]

- setRel means differences on the nUFO get translated
to differences on the parameters of the playing sounds;
this allows multiple sources to change the sounds
simultaneously, in effect, polyphonic influence.

- setAbs means the full state of the nUFOs sensors,
the current influx weights, and the sounds' last chosen presets
will determine the exact setting of the process parameters.
*/

// this is how to set the initial influxMode:
NTMI.nUFO.influxMode = \setRel;

// and to switch between them when the nUFO is loaded, do:
NTMI.nUFO.setRel; // or
NTMI.nUFO.setAbs; // or

// to set how much influence the nUFO has, use its zoom value:
NTMI.nUFO.zoom = 0.5;

