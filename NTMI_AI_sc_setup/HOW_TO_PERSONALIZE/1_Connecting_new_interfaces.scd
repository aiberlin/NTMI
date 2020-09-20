
/* When adapting the app to play with a new interface,
the basic functions of the nUFO can be put on buttons,
sliders of the interface to be used choice.
For longer examples to follow, see the nanoKtl and uc4 files.

*/
/// this file discusses all basic functions:
(q.dir.base +/+ "_Interface_Functions.scd").openOS;

// using Modality-toolkit, make an MKtl for a korg nankontrol:
MKtl('testa', "*kontrol2");
// make a gui for it:
MKtl('testa').gui;

// use the first four R buttons to play the four sound slots
MKtl('testa').elAt(\bt, \R, (0..3)).do { |but, index|
	but.action = { q.slots.playAt(index) };
};
// first four S buttons to stop the sounds
MKtl('testa').elAt(\bt, \S, (0..3)).do { |but, index|
	but.action = { q.slots.stopAt(index) };
};
// first four knobs to et volume the sounds
MKtl('testa').elAt(\kn, (0..3)).do { |knob, index|
	knob.action = {
		q.slots.actives[index].postln.vol_(knob.value.squared.postln)
	};
};

// set all sliders to center value:
MKtl('testa').elAt(\sl).value = 0.5;

// use the last slider for master volume
MKtl('testa').elAt(\sl, 7).action = { |sl|
	MFdef('mainVol').value(sl.value);
};

// attach the first seven sliders the influx:
/// this is how movement and touch influence the running sounds
// switch nUFO off, or leave network ...
// show the influx GUI
Butz.run(\inphlux);

// connect sliders 0-6 to q.inphlux inputs 9-15:
// now every slider introduces a complex change in the sound
// by influencing every parameter to some degree
MKtl('testa').elAt(\sl, (0..6)).do { |knob, index|
	knob.action = {
		q.inphlux.set(
			q.inphlux.inNames[index + 9],
			knob.value.unibi
		);
	};
};

// to be continued ... 