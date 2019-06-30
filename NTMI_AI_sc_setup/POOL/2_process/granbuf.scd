/// load a buffer of files to granulate
/// here, with a set of textfiles
q = q ? ();

// command to load a block of soundfiles
MFdef(\granbufLoad).add(\loadFiles, { |paths|
	forkIfNeeded {
		q.granbufs = paths.collect { |path| Buffer.read(s, path) };
		s.sync;

		// assume bufnums will be in sequential order
		Ndef(\granbuf).addHalo(\sndbufRange, [q.granbufs[0].bufnum, q.granbufs.last.bufnum]);
		// rebuild so we use the latest
		Ndef(\granbuf).rebuild;
		"q.granbufs: % buffers loaded.\n\n".postf(q.granbufs.size);
	}
});

s.doWhenBooted {
	MFdef(\granbufLoad).value("~/Seafile/AI_CC/granulatspeach/textbuffers/*.aif".pathMatch);
};

/*
Ndef(\granbuf).clear;
q.granbufs.collect(_.bufnum);
q.granbufs.choose.play(mul: 0.2)
q.granbufs[0].play;
Ndef(\granbuf).gui(12);
*/

Ndef(\granbuf).addSpec(\sndbuf, \unipolar);
Ndef(\granbuf).addSpec(\sndbufvar, \unipolar);
Ndef(\granbuf).addSpec(\rate, [0.7, 1.4, \exp]);
Ndef(\granbuf).addSpec(\ratevar, [0, 1]);
Ndef(\granbuf).addSpec(\dens, [0.5, 200, \exp]);
Ndef(\granbuf).addSpec(\overlap, [0.1, 40, \exp]);
Ndef(\granbuf).addSpec(\ratevar, [0, 1]);
Ndef(\granbuf).addSpec(\scanspeed, [-2, 2]);
Ndef(\granbuf).addSpec(\posvar, [0, 0.1, 4]);
Ndef(\granbuf).addSpec(\panvar, [0, 1]);
Ndef(\granbuf).addSpec(\trigrand, [0, 1]);

Ndef(\granbuf).addHalo(\sndbufRange, [-1, -1]);

/*
Ndef(\granbuf).setUni(\posvar, 0.5);
Ndef(\granbuf).set(\scanspeed, 0.25);
Ndef(\granbuf).set(\scanspeed, -0.25);
*/

Ndef(\granbuf, { |
	// don't store amp and sndbuf ...
	amp = 0.1, sndbuf = 0,
	sndbufvar = 0.1,
	rate = 1, ratevar = 0.1,
	trigrand = 0, dens = 30, overlap = 2,
	scanspeed = 1, posvar = 0.001,
	panvar = 0.25|

	var trig = Impulse.ar(dens * (1-trigrand)) + Dust.ar(dens * trigrand);
	var sndbuf2 = sndbuf.linlin(0, 1, *Ndef(\granbuf).getHalo(\sndbufRange));
	var sndbuf3 = sndbuf2 + Latch.ar(WhiteNoise.kr(sndbufvar), trig).round(1);
	var filepos = Phasor.ar(0, 1 / SampleRate.ir / BufDur.kr(sndbuf2) * scanspeed, 0, 1);
	var filepos2 = filepos + WhiteNoise.ar(posvar);
	var ratekr = 1.25 ** WhiteNoise.kr (ratevar) * rate;
	var panpos = WhiteNoise.kr(panvar);

	var amp2 = amp.lag(0.1) * (overlap.max(1) ** -0.25);

	GrainBuf.ar(4, trig, overlap / dens, sndbuf3, ratekr, filepos2, 2, panpos) * amp2;
});

// Preset: don't store amp and sndbuf
Ndef(\granbuf).addHalo(\namesToStore, Ndef(\granbuf).controlKeys.drop(2));
