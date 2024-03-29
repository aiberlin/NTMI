	// a model of the blippoo box by rob hordijk,
	// with a few liberties taken:
	// saws can be waveshaped,
	// sound is stereo, (shift shifts cycles between left and right)

(
q = q ? ();

Ndef(\bleepo).ar(q.numChans);

Ndef(\bleepo).addSpec(\rateB, [0.01, 5000, \exp]);
Ndef(\bleepo).addSpec(\rateA, [0.01, 5000, \exp]);
Ndef(\bleepo).addSpec(\peak1, \freq);
Ndef(\bleepo).addSpec(\peak2, \freq);
Ndef(\bleepo).addSpec(\fm_b2a, \amp);
Ndef(\bleepo).addSpec(\fm_a2b, \amp);
Ndef(\bleepo).addSpec(\sh2Filt, \pan);
Ndef(\bleepo).addSpec(\sh2RateA, \pan);

Ndef(\bleepo).addSpec(\rezo,  [1, 100, \exp, 0.1]);
Ndef(\bleepo).addSpec(\dens,  [0.00001, 1, \exp, 0.00001]);
Ndef(\bleepo).addSpec(\ramp,  [100, 30000, \exp, 1]);

Ndef(\bleepo).addSpec(\wshape, [0.001, 0.999]);
Ndef(\bleepo).addSpec(\shift, [0, 1]);


Ndef(\bleepo, { arg amp = 0,
	rateA=0.0216, rateB=0.3, peak1=1114, peak2=77,
	fm_b2a=0.43, fm_a2b=0.8, sh2Filt=0.694, rezo = 29.2,
	dens = 0.11, wshape=0.025, sh2RateA=0.68, shift = 0.0647;

	var ramp = 30000;	// should be lower, ca 5-7000 or so ... hmm!

	var waves, sha, u, o, f, r, trig, filtfreqs2, sh, shf, rungler1, rungler2;
	var midfreq, maxfreq;
	var in = LocalIn.ar(3);
	var oscfreqs2 = ([in[2] * rateA, rateB]
		* in.keep(2).reverse.madd([fm_b2a,fm_a2b])
			.linexp(-1,1, 1/18, 18)
	).fold(0.01, 19000);

	rezo = rezo.reciprocal;

	waves = VarSaw.ar(oscfreqs2, 0, [wshape, 1 - wshape]);

	maxfreq = oscfreqs2[0].max(oscfreqs2[1]);

	trig = waves[0].absdif((waves[1] + [0, shift]).wrap(-1, 1)) < dens;
	trig = Trig.ar(trig, 0.0);

	u = Decay2.ar(trig, 0/maxfreq, 0.1/maxfreq);
	u = ToggleFF.ar(trig);

	sh = Latch.ar(waves, trig); // -1, 1
	shf = ( 10 ** (sh.abs * sh2Filt.squared  * sh2Filt.sign));
	sha = ( 10 ** (sh.abs * sh2RateA.cubed.abs  * sh2RateA.sign));

	filtfreqs2 = Fold.ar(( [ peak1 * shf, peak2 * (shf ** -1)]), 20, 19000);
	f = RHPF.ar(u, Slew.ar(filtfreqs2[0], ramp, ramp), rezo)
	  - RHPF.ar(u, Slew.ar(filtfreqs2[1], ramp, ramp), rezo);

	LocalOut.ar(waves ++ [sha] );
	f = Limiter.ar(f * 0.4, 1, 0.01) * amp;

	f.collect{|si, i|
		PanAz.ar(q.numChans, si, SinOsc.kr(Rand(0.1, 0.2)/2, 0, Rand(1, 2)), amp)
	}.sum;

});
);
