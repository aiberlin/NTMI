// SOUND 2 // the DubCat example from our Class:
(
// controlspecs
Ndef(\cat).addSpec(\pFreq, [20, 400, \exp]);
Ndef(\cat).addSpec(\pWidth, [0.01, 0.5, \exp]);
Ndef(\cat).addSpec(\filt, [1, 32, \exp]);
Ndef(\cat).addSpec(\q, [1, 1000, \exp]);
Ndef(\cat).addSpec(\modFreq, [0, 200, 7]);
Ndef(\cat).addSpec(\moDepth, [0, 12*8]);

Ndef(\cat).addSpec(\pFreq, [20, 400, \exp]);
Ndef(\cat).addSpec(\pWidth, [0.01, 0.5, \exp]);
Ndef(\cat).addSpec(\filt, [1, 32, \exp]);
Ndef(\cat).addSpec(\q, [1, 1000, \exp]);
Ndef(\cat).addSpec(\modFreq, [0, 200, 7]);
Ndef(\cat).addSpec(\moDepth, [0, 12*8]);

// a Synth with 6 control parameters
(
Ndef(\cat, { |amp=0, pFreq=100, modFreq=0, filt=2, q=1, pWidth=0.5,  moDepth=12|
	var signal;
	var pFreqF = pFreq *
	[
		SinOsc.ar(modFreq * 0.5 + [0, 0.1, 0.213], 0).product,
		SinOsc.ar(modFreq * 0.5 + [0, -0.1, 0.213], 0).product
	].madd(moDepth).midiratio;
	signal = RLPF.ar(
		LFPulse.ar(
			pFreq * [1, 1.01],
			0,
			LFNoise2.kr(1/20).exprange(0.02, 0.9)// pWidth
		),
		(pFreqF * filt).clip(50, 15000),
		q.reciprocal
	)
	* AmpComp.kr(pFreq.lag(1));
	Limiter.ar(signal) * amp;
})
);

Ndef(\cat).vol_(0.25);	// don't play it yet, just prepare
);

fork { s.sync; 0.1.wait; Ndef(\cat).end };
Ndef(\cat);
