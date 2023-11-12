// Ndef(\bufRd).gui

(
// redo \bufnum spec to use specific buffer range!
Ndef(\bufRd).addSpec(\bufnum, \unipolar);
Ndef(\bufRd).addHalo(\sndBufRange, [0, 0]);

try {
	Ndef(\bufRd).addHalo(\sndBufRange, [
		q.bufs.global.first.bufnum,
		q.bufs.global.last.bufnum ].postln
	);
};


Ndef(\bufRd).addSpec(\start, [0, 0.999]);
Ndef(\bufRd).addSpec(\end, [0.001, 1, \exp]);
Ndef(\bufRd).addSpec(\rate, [-2, 2, \lin]);
Ndef(\bufRd).addSpec(\mod, [0, 1]);
Ndef(\bufRd).addSpec(\modResl, [0.25, 160, \exp]);
Ndef(\bufRd).addSpec(\modSpeed, [0.5, 40, \lin]);
Ndef(\bufRd).addSpec(\atk, [0.001, 2, \lin]);
Ndef(\bufRd).addSpec(\sustain, [0.002, 2, \lin]);
Ndef(\bufRd).addSpec(\rel, [0.001, 2, \lin]);
Ndef(\bufRd).addSpec(\ampenv, [0, 1, \amp]);
Ndef(\bufRd).addSpec(\modRateFreq , [0.05, 20, \amp]);
Ndef(\bufRd).addSpec(\pan, [-1,1]);

Ndef(\bufRd, { | amp=1, bufnum = 0, rate=1, start=0, end=1, mod = 0, modSpeed = 1, modResl = 1, atk =0.002, sustain=1, rel=0.002, ampenv = 1, modRateFreq = 1, pan=0|

	var sig, buf = 0, brate, bframes, bStart, bEnd, bdur, trigg, modStart, env, modRate;

	var bufnum2 = bufnum.linlin(0, 1, *Ndef(\bufRd).getHalo(\sndBufRange));

	modRate = { LFNoise0.kr( modRateFreq, 1, -1) * 2 * rate + 1 }!2;
	brate = BufRateScale.kr(bufnum2) * modRate;
	bframes = BufFrames.kr(bufnum2);
	bStart = bframes * start;
	bEnd = bframes * end;
	bdur = BufDur.kr(bufnum2);
	trigg = Impulse.kr(modResl);
	modStart = LFSaw.kr( bdur.reciprocal * modSpeed).range(bframes * start, bframes);
	modStart = Latch.kr( modStart, trigg );
	env = EnvGen.kr( Env( [0,1,1,0],[atk,sustain,rel],[\sin,0,\sin] ),
		trigg,
		timeScale: modResl.reciprocal
	).clip(1 - ampenv, 1);

	sig = BufRd.ar( 1, bufnum2,
		Phasor.ar(0, brate, 0, bframes).wrap( bStart, bEnd ) + (modStart * mod),
		1, 4 );
	Splay.ar(sig * env, 1, amp, pan);
})
);
