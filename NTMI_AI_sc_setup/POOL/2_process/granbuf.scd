/// load a buffer of files to granulate
/// here, with a set of textfiles

/*
/////////
Ndef(\granbuf).clear;

Ndef(\granbuf).gui(12);

*/
q = q ? ();


// the Ndef specs:
Ndef(\granbuf).addSpec(\sndbuf, \unipolar);        // index into buffer array, 0.0 is first, 1.0 is last
Ndef(\granbuf).addSpec(\sndbufvar, \unipolar);     // how much overlap with next buffer
Ndef(\granbuf).addSpec(\rate, [0.7, 1.4, \exp]);   // buffer playback rate
Ndef(\granbuf).addSpec(\ratevar, [0, 1]);          // how much variation of playback rate between grains
Ndef(\granbuf).addSpec(\dens, [0.5, 200, \exp]);   // density: how many grains per second
Ndef(\granbuf).addSpec(\trigrand, [0, 1]);         // 0 is regular rhythm, 1 is random
Ndef(\granbuf).addSpec(\overlap, [0.1, 40, \exp]); // how much overlap of grains - 2 is smooth continuous
Ndef(\granbuf).addSpec(\scanspeed, [-2, 2]);       // how fast to move thru buffer - 1 is normal, 0 is freeze
Ndef(\granbuf).addSpec(\posvar, [0, 0.1, 4]);      // how much file read pos varies
Ndef(\granbuf).addSpec(\panvar, [0, 1]);           //

// make sound buffer range known so Ndef can access it
Ndef(\granbuf).addHalo(\sndBufRange, [0, 0]);

/*
Ndef(\granbuf).setUni(\posvar, 0.5);
Ndef(\granbuf).set(\scanspeed, 0.25);
Ndef(\granbuf).set(\scanspeed, -0.25);
*/

Ndef(\granbuf, { |
	// don't store amp and sndbuf ...
	amp = 0.1, sndbuf = 0,
	// all of these params are stored in preset
	sndbufvar = 0.1,
	rate = 1, ratevar = 0.1,
	trigrand = 0, dens = 30, overlap = 2,
	scanspeed = 1, posvar = 0.001,
	panvar = 0.25|

	var trig = Impulse.ar(dens * (1-trigrand)) + Dust.ar(dens * trigrand);
	var sndbuf2 = sndbuf.linlin(0, 1, *Ndef(\granbuf).getHalo(\sndBufRange));
	var sndbuf3 = sndbuf2 + Latch.ar(WhiteNoise.kr(sndbufvar), trig).round(1);
	var filepos = Phasor.ar(0, 1 / SampleRate.ir / BufDur.kr(sndbuf2) * scanspeed, 0, 1);
	var filepos2 = filepos + WhiteNoise.ar(posvar);
	var ratekr = 1.25 ** WhiteNoise.kr (ratevar) * rate;
	var panpos = WhiteNoise.kr(panvar);

	var amp2 = amp.lag(0.1) * (overlap.max(1) ** -0.25);

	GrainBuf.ar(4, trig, overlap / dens, sndbuf3, ratekr, filepos2, 2, panpos) * amp2;
});

// // load all soundfiles from example local "soundfiles" folder:
MFdef('reloadBufs').add(\granbufs, {

	MFdef(\bufLoad).(
		// path of dir with samples:
		(q.dir.user +/+ "soundfiles"),
		// function to run when loaded:
		{ |bufs, listname|
			// set the Ndef's buffer range to the new loaded buffers
			MFdef(\setBufRange).(Ndef(\granbuf), bufs, listname);
			Ndef(\granbuf).end;
		},
		// name by which to store loaded buffers under q.bufs.granbufs;
		'granbufs'
	);
});

// and do it once when the file runs
MFdef('reloadBufs').funcDict[\granbufs].value;


// Preset: don't store amp and sndbuf
Ndef(\granbuf).addHalo(\namesToStore, Ndef(\granbuf).controlKeys.drop(2));

Ndef(\granbuf);