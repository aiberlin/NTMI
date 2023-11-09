/***** Overview of interface functions in NTMI ***/


/********** TODO: ************
Some functions are MFdefs,
some in q.slots,
some also in q directly:
MFdef.all.sortedKeysValuesDo {|k, f| f.postln }; "";
q.slots.select(_.isFunction).keys.postcs; "";
q.select(_.isFunction).keys.postcs; "";


****************************************/

///////////// GENERAL interface functions: //////
//// most of these are accessible on the interactor,
//// and also on the main UFO window,
//// and can and should be put on substitute interfaces as well.


////// 0. first GLOBAL controls:

// set main volume from a unipolar (0-1 linear) element:
MFdef(\mainVol).value(univalue);

// test with random values:
MFdef(\mainVol).value([0, 0.25, 0.5, 0.75, 1].choose.postln);


///////// 1. FOUR SLOTS have these functions:

q.slots.keys(Array).sort.cs;

// play and stop a sound at a slot index:
q.slots.playAt(0);
q.slots.stopAt(0);
// toggle between stop or play
q.slots.toggleAt(0);
q.slots.toggleAt(0);

// which ones are currently selected in the slots?
q.slots.actives;
// which ones are actually playing now
q.slots.nowPlaying;

// internal settings in slots:
// the volume at which sounds start by default (0.25)
q.slots.defaultVol;
q.slots.defaultAmp;
// the fadeoutTime used when sounds are turned off or replaced (1.0)
q.slots.fadeoutTime;

// the choices of available sounds for each slot
q.slots.choices;
// step/jump to a next sound: step +1 for up, -1 for down, nil for random jump
q.slots.stepNext(0, 1);

// switch to a specific sound in one slot
q.slots.addActive(0, Ndef(\bleepo));
// cannot use same sound on other slot:
q.slots.addActive(2, Ndef(\bleepo));

q.slots.chooseNext(0);

// change the presets on all active sounds:
MFdef('stepSlotPres').value(step);
// change preset on a single sound:
q.pre.stepNdefInf( ndef, step );
q.pre.stepNdefInf( Ndef(\cat, 1 ));

// change volume on a specific ndef:
MFdef('stepVol').(ndef, increment);

// make ndef in slot 1 louder by 0.1
MFdef('stepVol').(q.ndefs[0], 0.1);


/////////// quick-store the current setting of a single sound preset with datestamp:
MFdef('snapshot1').value(ndef);
/////////// quick-store setting of all active sound presets:
MFdef('snapshot').value;


//////// 3. INPHLUX ////////////
// change inphlux preset:
// by step (1 is up by one, -1 is down, wrapping)
// or nil -> random new choice
MFdef('stepInphWPre').(1);
MFdef('stepInphWPre').(-1);
MFdef('stepInphWPre').();

////////// set inphlux preset directly to an index:
MFdef('setInphWPre').(0); // go to red

/////// set zoom for inphlux (and globally) directly to a value between 0.0 - 1.0:
// post function code:
q[\setZoom].cs;
// use function:
q.setZoom(0.62);
// increment zoom by a relative step amount (e.g. 0.1)
q.incZoom(0.05);
q.incZoom(-0.1);

/////////// MainFX: //////////////
// step mainFX preset: 1 -> up, -1 -> down,   nil -> random.
MFdef('mainPreStep').(1);
MFdef('mainPreStep').(-1);
MFdef('mainPreStep').(); // rand

// MainFX: set preset to a given name
MFdef('mainPre').('theology');



///////// 2. nUFO modes and calibration /////////
// step thru main nUFO modes
// - full, touch, binary
MFdef('inphModeStep').();

// set ZERO offsets position for nUFO imu and pads,
/// so sound presets will be heard as stored
// when interactor is at zero position
MFdef('calibrate').();



/////////////////// INTERNAL / HELPER FUNCTIONS //////////////

///////// 1. UFO /////////
// set influx from imu
MFdef('imuFunc');
// set influx from pads
MFdef('touchToInph');

//// obsolete by now
// switch xosc mode between simulation and real XOSC
MFdef('switchToSim');
MFdef('switchToXOSC');



//////////////// 1. SLOTS, helper functions ///////////////

q.slots.actives; // the currently selected sounds
q.slots.nowPlaying; // the currently playing subset of selected sounds

// put a new Ndef into a slot index:
q.slots.addActive(index, ndef); //

// list of the open choices for all 4 slots;
// for each slot, these are the names if all loaded sounds,
// minus the ones that currently play,
// plus the name of the sound currently in this slot
q.slots.choices;
q.slots.choices[0]; // choices for slot 0

///////////// private internal methods in slots:
// check that a number is a valid index for slots
q.slots.checkIndex(0);
// check integrity of all slots:
q.slots.test;
// remake available choices for all slots
q.slots.updateChoices;


//////// GUI
// make/remake gui for a given window name
// all Butz actions:
Butz.actions.names;
// use one of the window makefuncs:
Butz.run(\liveInput);

