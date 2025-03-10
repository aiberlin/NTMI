/// How to add your own control interface to NTMI:

// - see whether it is supported by Modality-toolkit
// does any entry in this list look like it?
MKtlDesc.postLoadable;

// If not, and you would like to add it to modality,
// please start here:
"Tutorials/How_to_create_a_description_file".help;

// You can also use standard MIDI/HID/OSC setup,
// and add NTMI control functions to these.

// If your device is supported in Modality already, great!
// It makes things a lot easier.

// This file has all the NTMI interface functions
// you will want to address with your interface:
Document.open(NTMI.dir.setup +/+ "HOW_TO_PERSONALIZE/All_Interface_Functions.scd");

// for example, these are the four ndefs in the slots
NTMI.ndefs;

// start the ndef at index 0
NTMI.slots.playAt(0);  // this goes on a play button
NTMI.slots.stopAt(0);  // this goes on a separate stop button
NTMI.slots.toggleAt(0);  // or have a single button that toggles play stop

w = Window("test").front; w.addFlowLayout;
~playbuttons = 4.collect { |i| Button(w).states_([["play" + i]]) };
~playbuttons.do { |bt, i| bt.action = { NTMI.slots.playAt(i); } };
//
~playbuttons.do { |bt, i| bt.action = { NTMI.slots.stopAt(i); } };
// signle button toggles between on and off:
~playbuttons.do { |bt, i| bt.action = { NTMI.slots.toggleAt(i); } };

// lets assume you want to use a Logitech extreme pro joystick:
// make a modal kontrol thing for it - an MKtl:

m.free;
m = MKtl(\logi, "*extreme*");
// it knows how to make a gui for the controller!
m.gui.showLabels;

// // for the physical device to register, you may need to do
// Quark("Modality-toolkit").update;
// // to get correct idInfo for 2023 extreme 3d pro


// you can access its elements with elAt:
m.elAt;
// top level has 4 groups, [ 'bt', 'joy', 'hat', 'slider' ]
////// bt > buttons, joy > joystick axes, hat > hat switches, slider

// the button group has 12 elements
m.elAt(\bt);

m.elAt(\bt, 0); // the first button - trigger

// get first four buttons:
m.elAt(\bt, (0..3));

// access four buttons 3..6 on joystick top
// for switching sounds on/off
// lets define these 4 as playbuts:
m.addNamed(\playbuts, m.elAt(\bt, (2..5)));

// lets use the first four buttons to toggle our 4 sounds
m.elAt(\playbuts).do { |bt, i|
	bt.action = { if (bt.isOn) { NTMI.slots.toggleAt(i) } };
	bt.elemDesc.label = "snd" + (i+1);
};

m.gui;

m.elAt(\slider).action = { |sl| MFdef(\mainVol).value(sl.value.postln) };
m.elAt(\slider).elemDesc.label = "VOL";


// next, we want to use the three joystick axes to influence the sounds,
// access the three axes:
m.elAt(\joy);

// set their actions:
m.elAt(\joy).do { |axis, i|
	axis.action = { |ax|
		// choose which influx imput name to set
		// offset of 7 puts y axis on amp articulation:
		var name = NTMI.inphlux.inNames[i + 7];
		// convert val from 0..1 range to -1..1 range
		var newval = ax.value * 2 - 1;
		// now set app playing sounds thru the influx
		NTMI.inphlux.set(name, newval);
	};
};

// what to do with trigger button? articulate sound on/off?
// thumb button 2 on could be a nice shift-key button...
// use hat compass for preset navigation ?
// e.g. left is -1, right is +1, up is +10, down is -10
// how to set volumes for each slot?
// how to switch presets for each slot?

///// example for trig button as mute
m.elAt(\slider).action = { |sl|
	MFdef(\mainVol).value(m.elAt(\slider).value * (1 - m.elAt(\bt, 0).value))
};
m.elAt(\bt, 0).action = { |sl|
	MFdef(\mainVol).value(m.elAt(\slider).value * (1 - m.elAt(\bt, 0).value))
};
m.elAt(\bt, 0).elemDesc.label = "trig";
m.elAt(\slider).elemDesc.label = "VOL";

// add this interface to the interfaces Butz page
WinBounds.addMake(\logi, { m.gui.showLabels.parent });
Butz(\interfaces).add(\logi, {
	WinBounds.showOrMake(\logi);
});

