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

///////// 1. UFO /////////
// step main UFO modes
MFdef('inphModeStep').();

// set ZERO offsets position for UFO imu and pads,
/// so sound presets will be heard as stored
// when interactor is at zero position
MFdef('ZERO').();


//////// 2. INPHLUX ////////////
// change inphlux preset:
// by step (1 is up by one, -1 is down, wrapping)
// or nil -> random new choice
MFdef('stepInphWPre').funcDict.cs;
////////// set inphlux preset directly to an index:
// MFdef('setInphWPre').funcDict.cs;

/////// set zoom for inphlux (and globally) directly to a value between 0.0 - 1.0:
q[\setZoom].cs;
// increment zoom by a relative step amount (e.g. 0.1)
q[\incZoom].cs;


////////// 3. SOUNDS / SLOTS //////////////

// turn 4 slots off and on:
q.slots.toggleAt(index);
// or call one or the other explicitly:
q.slots.playAt(index);
q.slots.stopAt(index);


// change the sound at a slot index:
// random choice ...
q.slots.chooseNext(index);
// or step by an increment, usually +1, -1
q.slots.stepNext(index, incr = 1);

// change the presets on all active sounds:
MFdef('stepSlotPres');
// change preset on a single sound:
q.pre.stepNdefInf( nd, step );

// change volume on a specific ndef:
MFdef('stepVol').funcDict.cs


/////////// quick-store a current setting of a single sound preset with datestamp:
MFdef('snapshot1');
/////////// quick-store setting of all active sound presets:
MFdef('snapshot');



/////////// MasterFX: //////////////
// step masterFX preset: 1 -> up, -1 -> down,   nil -> random.
MFdef('mastaPreStep');

// MasterFX: set preset to a given name
MFdef('mastaPre').('theology');


/////////////////// INTERNAL / HELPER FUNCTIONS //////////////

///////// 1. UFO /////////
// set influx from imu
MFdef('imuFunc');
// set influx from pads
MFdef('touchToInph');

// switch xosc mode between simulation and real XOSC
MFdef('switchToSim');
MFdef('switchToXOSC');

// function to set up mode of 3 right buttons group
MFdef('rightMode').funcDict.cs;

//////// 2. INPHLUX ////////////
//////// set inphlux preset directly to an index:
MFdef('setInphWPre').funcDict.cs;


//////////////// 3. SLOTS, helper functions ///////////////

q.slots.actives; // the currently selected sounds
q.slots.nowPlaying; // the currently playing subset of selected sounds

// put a specific sound into a slot index:
q.slots.addActive(index, ndef); //

// list of the open choices for all 4 slots;
// for each slot, these are the names if all loaded sounds,
// minus the ones that currently play,
// plus the name of the sound currently in this slot
q.slots.choices;

// internal settings in slots:
// the volume at which sounds start by default (0.25)
q.slots.defaultVol;
// the fadeoutTime used when sounds are turend off or replaced (1.0)
q.slots.fadeoutTime;

///////////// private methods in slots:
// check that a number is a valid index for slots
q.slots.checkIndex(0);
// check integrity of all slots:
q.slots.test;
// remake available choices for all slots
q.slots.updateChoices;


//////// GUI
// make/remake gui for a given window name

MFdef('makeGui').('xosc', remake: true);
// update guiSlots on NTMI_main
MFdef('guiSlots').();

// all window func names here:
g.makeGui.keys.cs;

