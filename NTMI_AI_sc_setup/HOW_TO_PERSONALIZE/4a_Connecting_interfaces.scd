// NTMI already supports many interfaces:
NTMI.allInterfaceNames.cs;

// By default, NTMI will connect all supported interfaces it finds.
// You can turn this off by running:
NTMI.connectFoundInterfaces = false;

// You can also tell NTMI which interfaces to load:
NTMI.interfacesToLoad = [\uc4, \nanoKtl];


/*
When adapting NTMI to play with a new interface,
the basic functions of the nUFO can be put on buttons,
sliders, knobs etc of the interface to be used.

For longer examples to follow, see the nanoKtl and uc4 files:

Document.open(NTMI.dir.setup +/+ "3_interfaces/optionals/nanoKtl.scd");
Document.open(NTMI.dir.setup +/+ "3_interfaces/optionals/uc4.scd");

*/

/// This file discusses all basic functions:
Document.open(NTMI.dir.setup +/+ "HOW_TO_PERSONALIZE/All_Interface_Functions.scd");


// using the Modality-toolkit, make an MKtl for a korg nanokontrol:
MKtl('testa', "*kontrol2");
// make a gui for it:
MKtl('testa').gui;

// use the first four R buttons to play the four sound slots
MKtl('testa').elAt(\bt, \R, (0..3)).do { |but, index|
	but.action = { NTMI.slots.playAt(index) };
};
// first four S buttons to stop the sounds
MKtl('testa').elAt(\bt, \S, (0..3)).do { |but, index|
	but.action = { NTMI.slots.stopAt(index) };
};
// first four knobs to set volume of the four sounds
MKtl('testa').elAt(\kn, (0..3)).do { |knob, index|
	knob.action = {
		NTMI.slots.actives[index].postln.vol_(knob.value.squared.postln)
	};
};

// set all sliders to center value initially:
MKtl('testa').elAt(\sl).value = 0.5;

// use the last slider for master volume
MKtl('testa').elAt(\sl, 7).action = { |sl|
	MFdef('mainVol').value(sl.value);
};

// attach the first seven sliders the influx:
/// this is how movement and touch influence the running sounds
// switch nUFO off, or leave the nUFO network!
// show the influx GUI
Butz.run(\inphlux);

// connect sliders 0-6 to NTMI.inphlux inputs 9-15:
// now every slider introduces a complex change in the sound
// by influencing every parameter to some degree
/////// note that this is absolute control mode!
MKtl('testa').elAt(\sl, (0..6)).do { |knob, index|
	knob.action = {
		NTMI.inphlux.set(
			NTMI.inphlux.inNames[index + 9], // which influx input
			knob.value.unibi  // absolute value between -1 and 1
		);
	};
};

// recommended: use relative mode!
MKtl('testa').elAt(\sl, (0..6)).do { |knob, index|
	knob.action = {
		// special function
		MFdef(\setRelInf).value(
			NTMI.inphlux.inNames[index + 9], // which influx input
			// difference between old and new element value/position,
			knob.value - knob.prevValue,
			// can be scaled by a zoom value, here fixed at 1
			1
		);
	};
};


// for more details, see e.g. nanoKtl file.