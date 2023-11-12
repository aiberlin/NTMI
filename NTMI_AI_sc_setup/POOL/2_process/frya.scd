// drone generator,
// pseudo GENDY with shifting envelopes as oscillators
// and modulated filtering
// hh'09; MC version 2019

(
// a Spec for each Sound Parameter. Ranges of possible vals from min to max
Ndef(\frya).addSpec(\baseFreq, [1, 1000, 7]);
Ndef(\frya).addSpec(\driftA, [0.0001, 50, \exp]);
Ndef(\frya).addSpec(\driftT, [0.0001, 50, \exp]);
Ndef(\frya).addSpec(\loopNode, [0,11,  \lin, 1]);
Ndef(\frya).addSpec(\ring, [0.01, 1, 5]);
Ndef(\frya).addSpec(\curve, [-20, 100, \cos]);
Ndef(\frya).addSpec(\fLag, [1, 5000, \exp]);
Ndef(\frya).addSpec(\stereo, [1,0,8]);
Ndef(\frya).addSpec(\oPole, [0.99999, -0.5, 5]);
Ndef(\frya).addSpec(\lag1, [0, 5, 5]);
Ndef(\frya).addSpec(\lag2, [0, 5, 0]);
Ndef(\frya).addSpec(\wEt, [0,1, -2]);
Ndef(\frya).addSpec(\ampRing, [0.01,1, \exp]);
Ndef(\frya).addSpec(\wrap, [0,2]);
Ndef(\frya).addSpec(\minfreq, [20, 19000, \exp, 1]);
Ndef(\frya).addSpec(\maxfreq, [20, 19000, \exp, 1]);
Ndef(\frya).addSpec(\silent, \unipolar);
);

(
// the SynthDef as a Ndef
Ndef(\frya, { |
	amp=0,
	baseFreq=100,

	loopNode=0,
	curve=0,
	//	silent=0.5,
	driftA=0.1,
	driftT=0.1,
	wrap=0,
	wEt=0.5,
	ring=0.03,
	ampRing=0.1,
	oPole=0.9,
	fLag=2000,
	stereo=1,
	minfreq=100,
	maxfreq=5000,
	lag1=0.01,
	lag2=0.3
	|


	var ffreq, ffreq2;
	var n = 22, snd, ffreQ1, ffreQ2, pan;
	var lvlcurvs = (LFDNoise1.kr(driftA * ({Rand(0.6, 1.1)}!n) ).abs ).max(0);
	var timecurvs = LFDNoise1.kr(driftT * ({Rand(0.6, 1.1)}!(n-1)), 0.5, 0.5).normalizeSum;
	var env = (EnvGen.ar(
		Env(
			lvlcurvs,
			timecurvs, curve,
			releaseNode: n-2, loopNode: loopNode
		),
		timeScale: baseFreq.reciprocal
	) );

	// lagging control ins
	wEt = wEt.lag(lag2); 		wrap=wrap.lag(lag2);
	stereo=stereo.lag(lag2); 	baseFreq=baseFreq.lag(lag1);
	maxfreq = maxfreq.lag(lag1); driftT = driftT.lag(lag1);

	env = ( env + wrap).fold(0, 1);
	ffreq = DelayL.ar(env, 0.1, 0.1*[1, stereo.lag(0.01)])
	.linexp(0, 1, minfreq, maxfreq);
	ffreq2 = DelayL.ar((env.neg+0.5).abs, 0.23, 0.23 * [stereo, 1])
	.linexp(0, 0.5, minfreq+30, maxfreq*0.97);
	fLag = fLag.reciprocal;
	ffreQ1 = min(ffreq, ffreq2); // take lower freq louder !
	ffreQ2 = max(ffreq, ffreq2);
	ffreQ1 = Ramp.ar(ffreQ1, fLag);
	ffreQ2 = Ramp.ar(ffreQ2, fLag);
	ffreQ1 = OnePole.ar(ffreQ1, oPole);
	ffreQ2 = OnePole.ar(ffreQ2, oPole*0.95);

	env = env - 0.5;
	snd = Formlet.ar(env, [ffreQ1, ffreQ2], ring/10, ring, 0.025 * [1, 0.3]);
	snd = LeakDC.ar(
		(Limiter.ar(snd.sum * ampRing) * (wEt.sqrt))
		+ ((1-wEt).sqrt * env),
		0.9
	) * amp.lag(0.1);

	pan = snd.collect{|si, i|
		PanAz.ar(q.numChans, si, SinOsc.kr(Rand(0.1, 0.13), i*pi, Rand(0.9, 1.4)), 1, 2.5)
	}.sum.scramble;
	pan + snd.wrapExtend(q.numChans).madd(-12.dbamp);


});
);

