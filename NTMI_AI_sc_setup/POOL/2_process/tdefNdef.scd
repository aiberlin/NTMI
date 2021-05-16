/* uncomment top and bottom comment to try this ...

/*** EXAMPLE FOR TDEF-NDEF-COMBO THAT WORKS IN NTMI SETUP ****/

/***
// TESTS:
// Ndef starts tdef, tdef sounds
Ndef('tdefNdef').play;
// Tdef sounds controlled by Ndef vol
Ndef('tdefNdef').vol = 0.5;
// end ends Ndef and stops Tdef fully
Ndef('tdefNdef').end; // end sound and tdef

// set params by hand:
// note center of random range:
Ndef('tdefNdef').set(\note, 24.rand2);
// amount of random deviation
Ndef('tdefNdef').set(\notedev, 24.rand);

Ndef('tdefNdef').set(\pan, 1.0);
Ndef('tdefNdef').set(\amp, 0.3);

***/

//////// SETUP CODE: //////

// Ndef has all the params

Ndef('tdefNdef').set(\rate, 8);
Ndef('tdefNdef').set(\note, 0);
Ndef('tdefNdef').set(\notedev, 8);
Ndef('tdefNdef').set(\pan, 0.5);
Ndef('tdefNdef').set(\amp, 0.2);

Ndef('tdefNdef').addSpec(\rate, [1, 64, \exp]);
Ndef('tdefNdef').addSpec(\note, [-36, 36]);
Ndef('tdefNdef').addSpec(\notedev, [0, 24]);

// ndef plays on q.numChans audio chans
Ndef('tdefNdef').ar(q.numChans);
// source is the same-named Tdef
Ndef('tdefNdef', Tdef('tdefNdef'));

// this second object sets the params to use for ntmi/influx:
// silent sound output for now,
// could also be post-processing of sounds from tdef?
Ndef('tdefNdef').put(5, { |amp, note = 0, notedev = 12, rate = 4, pan |
	Silent.ar(2);
});


///// Tdef plays the sounds (events) onto the Ndef bus;
//// reads its params from the Ndef;
//// and gets started/ended from the Ndef;

Tdef('tdefNdef', {
	var myndef = Ndef('tdefNdef');
	var mymap = myndef.nodeMap;
	inf.do { |i|
		(
			note: mymap.at(\note) + mymap.at(\notedev).rand2,
			amp: mymap.get(\amp),
			pan: mymap.get(\pan).rand2.round(0.01),
			dur: (1/mymap.at(\rate)),

			out: myndef.index,
		).play;
		(1/mymap.at(\rate)).wait;
	}
});

// setup as in all NTMI processes:
// init once, then end process again
fork { s.sync; 0.1.wait; Ndef(\tdefNdef).end };

// ... and return the Ndef
Ndef(\tdefNdef);

*/
