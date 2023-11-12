/***** Overview of all NTMI functions to put on interfaces ****/

/********** TODO: ************
These funcs should be unified in meaningful ways!
Which ones to put in MFdefs,
which ones as q.funcx,
which are best in q.slots?


MFdef.all.sortedKeysValuesDo {|k, f| f.postln }; "";
q.slots.select(_.isFunction).keys.postcs; "";
q.select(_.isFunction).keys.postcs; "";


q.select(_.isKindOf(Dictionary)).keysValuesDo { |key, dict|
	var funckeys = dict.select(_.isFunction).keys;
	if (funckeys.notEmpty) {
		"\ndict q.% has these functions: \n".postf(key);
		funckeys.postcs;
	};
}; "";

dict q.ro has these functions:
Set[ 'str', 'num' ]

dict q.pre has these functions:
Set[ 'makePreset', 'incrementSeed', 'stepNdefInf' ]

dict q.prefs has these functions:
Set[ 'open', 'readUser' ]

dict q.inph has these functions:
Set[ 'centerToCurrent', 'mode', 'centerToPreset', 'seedRand', 'centerToNewRandSeed', 'centerToRandPreset' ]

dict q.slots has these functions:
Set[ 'chooseNext', 'stopAt', 'nowPlaying', 'stepNext', 'endAt', 'addActive', 'test', 'playAt', 'updateChoices', 'checkIndex', 'toggleAt' ]

*******************/

///////////// GENERAL interface functions: //////
//// Most of these are accessible from the main NTMI window;
//// most of them are also on the nUFO interactor,
//// and should probably be put on other chosen interfaces.
//// Often there are ways to set these absolutely,
//// or change them by steps or jumps.

/***** OVERVIEW *****/
1 - Global controls
1a set or change
1b change main volume stepwise
1c choose mainFX preset
1d choose mainFX preset

2. Influx functions:
2a set current influx weight preset
2b step or jump influx preset
2c set influx zoom
2d step influx zoom
2e set influx inputs
2f change influx inputs


3 - the 4 slots have these controls:
3a - play, stop, end, toggle sound process
3b - set or change volume per slot
3c - choose sound process on each slot
--- sound presets:
3d - choose sound preset on each slot
3e - store current sound settings as presets
3f - couple/decouple sound from influx
... and helper functions to make these possible

4 - nUFO-specific mode switches


////// 1. GLOBAL controls - Volume, MainFX, Influx

////// 1a. mainVol - set absolute volume from a (0-1 linear) range:
MFdef(\mainVol).value(<univalue>);

// test with random values:
MFdef(\mainVol).value([0, 0.25, 0.5, 0.75, 1].choose.postln);
// e.g. on a GUI
EZSlider(nil, nil, \mainVol, \amp, { |sl|
	MFdef(\mainVol).value(sl.value);
});
// this is the function that does it:
MFdef(\mainVol).at(\main).cs;

////// 1b. mainVol - change by relative steps :
// assumes low-number integer steps,intended for encoders or up/down buttons
MFdef(\mainStepVol).value(4.rand2);
MFdef(\mainStepVol).at(\step).cs;

/////////// MainFX: //////////////
// MainFX has a list of prepared presets,
// which is currently not easy to change yet ...

// 1c - MainFX: set preset to a given name directly
MFdef('mainPre').('theology');
// current preset names are here:
q.mfx.preNames.cs;

// 1d - MainFX step or random jump
// mainFX preset: 1 -> up, -1 -> down,   nil -> random.
MFdef('mainPreStep').(1);
MFdef('mainPreStep').(-1);
MFdef('mainPreStep').(); // rand


//// 2. INPHLUX - functions are also global,
//// because influx usually influences all currently playing slots.

// 2a. set inphlux preset directly to an index:
MFdef('setInphWPre').(0); // go to red
MFdef('setInphWPre').(100.rand.postln); // wraps

// 2b. change inphlux preset by step: 1 -> up, -1 is down, nil -> random
MFdef('stepInphWPre').(1);
MFdef('stepInphWPre').(-1);
MFdef('stepInphWPre').();


// 2c. influx Zoom: set zoom for inphlux directly between 0.0 - 1.0:
// post function code:
q[\setZoom].cs;
// use function:
q.setZoom(0.62);
// 2d. influx Zoom: step zoom  by small increments (e.g. 0.1)
q.incZoom(0.05);
q.incZoom(-0.1);

// 2e. set influx inputs to bipolat values (-1..1):
// these are the input names
q.inphlux.inNames;
// best view on inphlux window!
q.inphlux.set(\x, 1.0.rand2);
q.inphlux.set(q.inphlux.inNames.choose.postln, 1.0.rand2.round(0.001).postln);
// flatten to zero:
q.inphlux.resetInvals;

// 2f. do relative sets on influx inputs
q.inphlux.set(\x, (q.inphlux.get(\x) + 0.1).clip2(1));



///////// 3. FOUR SLOTS have these functions:
3d - choose sound preset on each slot
3e - store current sound settings as presets
3f - couple/decouple sound from influx
... and helper functions to make these possible

q.slots.select(_.isFunction).keys(Array).sort.cs;

// 3.a - play, stop, end a sound at a slot index:
q.slots.playAt(0); // start ndef at slot 0 and listen to its monitor
q.slots.stopAt(0); // stops ndef monitor (ndef itself continues)
q.slots.playAt(1); //
q.slots.endAt(1);  // this also stops the ndef itself

// toggle between stop or play
q.slots.toggleAt(0);
q.slots.toggleAt(0);

////// 3b - set or change volume per slot
// set absolute volume on a specific ndef in a slot:
q.slots.actives[i].vol_(<univalue>)
q.slots.actives[1].vol_(0.5);

// change volume on a specific ndef by small integer steps
// as they often come from MIDI encoders
MFdef('stepVol').(<ndef>, <increment>);
// make ndef in slot 1 louder
MFdef('stepVol').(q.ndefs[0], 4.rand2);
// here is the function
MFdef('stepVol').funcDict.postcs;


// 3c. the choices of available sounds for each slot;
// since ndefs can only be in one slot at a time,
// the choices always excludes the 4 ndefs currently in use.
q.slots.choices;
// step/jump to a next sound: step +1 for up, -1 for down, nil for random jump
q.slots.stepNext(0, 1);

// switch to a specific sound in one slot - index, ndef
q.slots.addActive(0, Ndef(\bleepo));
// cannot use same sound on other slot:
q.slots.addActive(2, Ndef(\bleepo));

// choose random next ndef for slot 0
q.slots.chooseNext(0);

// change the preset on a single sound:
q.pre.stepNdefInf( ndef, step );
q.pre.stepNdefInf( Ndef(\cat), 1 );   // one step up
q.pre.stepNdefInf( Ndef(\cat), -1 );  // one step down
q.pre.stepNdefInf( Ndef(\cat), nil ); // random jump

// change the presets on all active sounds:
MFdef('stepSlotPres').value(step);
MFdef('stepSlotPres').value(1);
MFdef('stepSlotPres').value(-1);
MFdef('stepSlotPres').value; // random jump


/////////// quick-store the current setting of a single sound preset with datestamp:
MFdef('snapshot1').value(ndef);
/////////// quick-store setting of all active sound presets:
MFdef('snapshot').value;


////----- SLOTS - useful extra functions ---- ////
// which ndefs are currently selected in the slots?
q.slots.actives;
// which ones are currently playing?
q.slots.nowPlaying;

// internal settings in the slots:
// the volume at which sounds start by default (0.25)
q.slots.defaultVol;
q.slots.defaultAmp;
// the fadeoutTime used when sounds are turned off or replaced (1.0)
q.slots.fadeoutTime;


///////// 4. nUFO modes and calibration /////////
// step thru main nUFO modes
// - full, touch, binary
MFdef('inphModeStep').();
// full mode connects and imu, pads to influx
// touch mode only connects pads to influx 9-16
// binary uses only pads to build a "preset piano",
// where pads add up as 1, 2, 4, 8, binary steps
// to access all presets - if not there, random presets are generated

// set ZERO offsets position for nUFO imu and pads,
/// so sound presets will be heard as stored
// when interactor is at zero position
MFdef('calibrate').();


