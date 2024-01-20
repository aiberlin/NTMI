/***** Overview of all NTMI functions to put on interfaces ****/

/********** TODO: ************

*******************/

/*********** GENERAL interface functions: *********
Most of these are accessible from the main NTMI window;
most of them are also given on the nUFO interactor,
and should be put on any other chosen interfaces.
While one can almost always set these absolutely,
there are also many ways change them relatively,
by little steps, or by random jumps.

This makes it possible to play them with multiple
interfacessharing influence over all playing processes.

/***** OVERVIEW *****/

The 4 slots for sound processes have functions to:
- play, stop, end, toggle sound process
- set or change volume per slot
- choose sound process on each slot

Each sound process has presets:
- choose sound preset on each slot
- store current sound settings as presets
- (later) choose to couple/decouple sound from influx


The Influx NTMI uses to play the sound processes has functions to:
- set, step or jump the current influx weight preset
- set or step-change the global influx zoom
- set, step or change the influx inputs
- for each interface, choose absolute or relative influx mode
- for each interface, set individual amount of zoom

Global functions are:
- set or step-change main volume
- set, step-change or jump mainFX preset

Some interfaces may have specific functions:
- nUFO can switch modes between, full, move, touch, binary, binMove and off.

*********/

////// SLOTS Functions: /////////////////


// play, stop, and end a sound at a slot index:
NTMI.slots.playAt(0); // start ndef at slot 0 and listen to its monitor
NTMI.slots.stopAt(0); // stops ndef monitor (ndef itself continues)
NTMI.slots.playAt(1); // play slot 2 ...
NTMI.slots.endAt(1);  // this also stops the ndef itself

// for relative influence, toggle between stop or play
NTMI.slots.toggleAt(0);
NTMI.slots.toggleAt(0);

////// 3b - set or change volume per slot
// set absolute volume on a specific ndef in a slot:
NTMI.slots.actives[2].vol_(0.5);
NTMI.slots.actives[1].vol_(0.1);

// change volume on a specific ndef by small integer steps
// as they usually come from MIDI encoders
// MFdef('ndefVolStep').(<ndef>, <increment>);
// make ndef in slot 1 louder by 2 steps (as in MIDI cc steps)
MFdef('ndefVolStep').(NTMI.slots.actives[1], 2.postln);
// see the function for that:
MFdef('ndefVolStep').funcDict.postcs;

/////////////// SOUND CHOICE and PRESET Functions: /////////////

///// Choose which sound plays in a slot /////
// See the choices of available sounds for each slot:
NTMI.slots.choices[0];
// Since ndefs can only be in one slot at a time,
// the choices always excludes the 4 ndefs currently in use.

// step/jump a slot to a next sound: step 1 for up, -1 for down, nil for random jump
NTMI.slots.stepNext(0, 1);
NTMI.slots.stepNext(0, nil);
NTMI.slots.stepNext(0, -1);
NTMI.slots.stepNext(0, 3); // go 3 sounds up

// switch to a specific sound in one slot - index, ndef
NTMI.slots.addActive(0, Ndef(\bleepo));
// then one cannot use same sound on other slot:
NTMI.slots.addActive(2, Ndef(\bleepo));

// choose random next ndef for slot 0
NTMI.slots.chooseNext(0);


// change the preset on a single sound:
// NTMI.pre.stepNdefInf( ndef, step );
NTMI.pre.stepNdefInf( Ndef(\cat), 1 );   // one step up
NTMI.pre.stepNdefInf( Ndef(\cat), -1 );  // one step down
NTMI.pre.stepNdefInf( Ndef(\cat), nil ); // random jump

// change the presets on all playing sounds:
// NTMI.slots.stepActivePres(step);
NTMI.slots.stepActivePres(1);
NTMI.slots.stepActivePres(-1);
NTMI.slots.stepActivePres; // nil for random jump


/////////// quick-store the current setting of a single sound preset with datestamp:
MFdef('snapshot1').value(NTMI.ndefs.choose);
/////////// quick-store setting of every playing sound:
MFdef('snapshot').value;

// For the curious, see all the functions and objects within NTMI.slots:
NTMI.slots.printInterface("NTMI.slots."); "";



//////////////////// INPHLUX functions:
//// these are global, as influx usually influences all currently playing slots.

// this is the Influx object NTMI uses:
NTMI.inphlux;
// open its gui:
Butz(\NTMI).run(\inphlux);

NTMI.inphlux.resetInvals; // reset inphlux
// setting a single input to an absolute value produces
// a complex change in ALL output values:
NTMI.inphlux.set(\x, 0.5);
NTMI.inphlux.set(\x, 0.25);// half that shift
NTMI.inphlux.set(\x, 0); // return to 0

// setting a different input (by name) produces a different shift:
NTMI.inphlux.set(\y, 0.5);
// these are all the inNames you can set:
NTMI.inphlux.inNames.cs;
-> [ 'x', 'y', 'z', 'w', 'v', 'u', 't', 's', 'r', 'q', 'p', 'o', 'n', 'm', 'l', 'k', 'j' ]

// play a sound and open its preset window to see the influx change it
NTMI.inphlux.resetInvals; // reset inphlux
NTMI.slots.playAt(0);
Butz(\NTMI).run(\presets);

NTMI.inphlux.set(\y, 1.0.rand2);
NTMI.inphlux.set(\x, 1.0.rand2);
NTMI.inphlux.set(\x, 0.25);

// the shifts in the output values come from the matrix of weights
// shown in the top right area of the inphlux window.
// There are 7 weights presets to choose from, with associated colors

NTMI.inph.setWPreIndex(0); // go to 0, red
// jump to a random choice, this wraps
NTMI.inph.setWPreIndex(100.rand.postln);

// 2b. change inphlux preset relative, by step: 1 -> up, -1 is down, nil -> random
NTMI.inph.stepWPre(1);
NTMI.inph.stepWPre(-1);
NTMI.inph.stepWPre();


// 2c. influx Zoom: set zoom for inphlux directly between 0.0 - 1.0:
// post function code:
NTMI.q[\setZoom].cs;
// use function:
NTMI.setZoom(0.62);
// 2d. influx Zoom: step zoom  by small increments (e.g. 0.1)
NTMI.incZoom(0.05);
NTMI.incZoom(-0.1);

// 2e. set influx inputs to bipolar values (-1..1):
// these are the influx input names:
NTMI.inphlux.inNames;

// best view on inphlux window!
Butz(\NTMI).run(\inphlux)
NTMI.inphlux.set(\x, 1.0.rand2);
NTMI.inphlux.set(NTMI.inphlux.inNames.choose.postln, 1.0.rand2.round(0.001).postln);
// flatten to zero:
NTMI.inphlux.resetInvals;

// 2f. do relative sets on the influx inputs
NTMI.inphlux.set(\x, (NTMI.inphlux.get(\x) + 0.3.rand2.postln).clip2(1));

// or use influx preset for shifting the current setting of a given ndef:
(
var ndef = NTMI.ndefs[0];
var whichInfluxIns = (1.. ndef.getKeysValues.size - 1);
var delta = 0.1.rand.postln;
var zoom = 0.3;
NTMI.inphlux.setRel(ndef, deltas: delta, zoom: zoom);
)


////// 1. GLOBAL controls - Volume, MainFX, Influx

////// 1a. mainVol - set absolute volume to value within range 0-4 :
MFdef(\mainVol).value(2.0.rand);  // [0, 4, \amp]
MFdef(\mainVolGet).value.unbubble; // get current mainVol

// test with random values:
MFdef(\mainVol).value([0, 0.25, 0.5, 0.75, 1].choose.postln);
// e.g. on a GUI
EZSlider(nil, nil, \mainVol, [0, 4, \amp], { |sl|
	MFdef(\mainVol).value(sl.value);
});
// this is the function that does it:
MFdef(\mainVol).at(\main).cs;

////// 1b. mainVol - change by relative steps :
// assumes low-number integer steps,intended for encoders or up/down buttons
MFdef(\mainVolStep).value(4.rand2);
MFdef(\mainVolStep).at(\step).cs;

/////////// MainFX: //////////////
// MainFX has a list of prepared presets,
// which is currently hard to change ...
// may become changeable in the future.

// 1c - MainFX: set preset absolutely by name
MFdef('mainPre').('theology');
// current preset names are here:
NTMI.mfx.preNames.cs;

// 1d - Set MainFX preset relatively by steps or random jump
// mainFX preset: 1 -> up, -1 -> down,   nil -> random.
MFdef('mainPreStep').(1);
MFdef('mainPreStep').(-1);
MFdef('mainPreStep').(); // nil is rand



// decouple sound from influx -
// start first two slots
NTMI.slots.playAt(0);
NTMI.slots.playAt(1);

NTMI.inph.decouple(NTMI.ndefs[0]);
NTMI.inph.decouple(NTMI.ndefs[1]);
NTMI.inph.decoupled

NTMI.inph.couple(NTMI.ndefs[0]);
NTMI.inph.couple(NTMI.ndefs[1]);
// toggles coupling/decoupling:
NTMI.clutch(NTMI.ndefs[0]);
NTMI.clutch(NTMI.ndefs[0]);





/////////////// BONUS TRACKS ////////////////////
////----- SLOTS - useful extra functions ---- ////
// which ndefs are currently selected in the slots?
NTMI.slots.actives;
// which ones are currently playing?
NTMI.slots.nowPlaying;

// internal settings in the slots:
// the volume at which sounds start by default (0.25)
NTMI.slots.defaultVol;
NTMI.slots.defaultAmp;
// the fadeoutTime used when sounds are turned off or replaced (1.0)
NTMI.slots.fadeoutTime;


///////// 4. nUFO modes and calibration /////////
// step thru main nUFO modes:
// - full, touch, binary
NTMI.nUFO.modeStep();
// full mode connects and imu, pads to influx
// touch mode only connects pads to influx 9-16
// binary uses only pads to build a "preset piano",
// where pads add up as 1, 2, 4, 8, binary steps
// to access all presets - if not there, random presets are generated

// set ZERO offsets position for nUFO imu and pads,
/// so sound presets will be heard as stored
// when interactor is at zero position
NTMI.nUFO.calibrate;


