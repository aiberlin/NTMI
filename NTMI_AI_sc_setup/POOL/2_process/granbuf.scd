q = q ? ();
s.doWhenBooted {
	q.granbufs = "~/Seafile/AI_CC/granulatspeach/textbuffers/*.aif".pathMatch.collect { |path|
		Buffer.read(s, path);
	};
	s.sync;
	Ndef(\granbuf).addSpec(\sndbuf, [q.granbufs[0].bufnum, q.granbufs.last.bufnum, \lin, 1]);
	Ndef(\granbuf).set(\sndbuf, q.granbufs.choose.bufnum);
};
/*
q.granbufs.choose.play(mul: 0.2)
q.granbufs[0].play;
Ndef(\granbuf).gui(12);
*/

Ndef(\granbuf).addSpec(\rate, [0.7, 1.4, \exp]);
Ndef(\granbuf).addSpec(\ratevar, [0, 1]);
Ndef(\granbuf).addSpec(\dens, [0.5, 200, \exp]);
Ndef(\granbuf).addSpec(\overlap, [0.1, 40, \exp]);
Ndef(\granbuf).addSpec(\ratevar, [0, 1]);
Ndef(\granbuf).addSpec(\forward, [-2, 2]);
Ndef(\granbuf).addSpec(\posvar, [0, 0.1, 4]);
Ndef(\granbuf).addSpec(\panvar, [0, 1]);


Ndef(\granbuf).setUni(\posvar, 0.5);


Ndef(\granbuf).set(\forward, 0.25);
Ndef(\granbuf).set(\forward, -0.25);

Ndef(\granbuf, { |amp = 0.1,
	sndbuf = 100,
	rate = 1, ratevar = 0.1,
	dens = 30, overlap = 2,
	forward = 1, posvar = 0.001,
	panvar = 0.25|

	var panpos = WhiteNoise.kr(panvar);
	var ratekr = 1.25 ** WhiteNoise.kr (ratevar) * rate;
	var filepos = Phasor.ar(0, 1 / SampleRate.ir / BufDur.kr(sndbuf.round) * forward, 0, 1);
	filepos = filepos + WhiteNoise.ar(posvar);
	GrainBuf.ar(4, Impulse.ar(dens), overlap / dens, sndbuf, ratekr, filepos, 2, panpos) * amp;
}).play;

