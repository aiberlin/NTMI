	// a model of the blippoo box by rob hordijk,
	// with a few liberties taken:
	// saws can be waveshaped,
	// sound is stereo, (shift shifts cycles between left and right)

(
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

q = q ? ();
p = Ndef.dictFor(s);

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
	f = Limiter.ar(f * 0.1, 1, 0.01) * amp;

	f.collect{|si, i|
		PanAz.ar(q.numChans, si, SinOsc.kr(Rand(0.1, 0.2)/2, 0, Rand(1, 2)), amp)
	}.sum;

});

Ndef(\bleepo).supplementNodeMap;
);

// NdefPreset( Ndef(\bleepo) ).loadSettings;

// q.makeBleepoGui = {
// 	var w, m, z, k, sc;
// 	var useScope = false; // (s == Server.internal);
// 	w = Window("< Bleepo >",
// 		Rect(Window.screenBounds.width - 410, 464, 410, 410 + (200 * useScope.binaryValue))
// 	).front;
// 	w.addFlowLayout;
//
// 	"q.dir: %\n\n".postf(q);
//
// 	m = ProxyMonitorGui(p[\bleepo], w, Rect(0, 0, 325, 20));
// 	w.view.decorator.shift(0, 5);
// 	q.bliPreset = NdefPreset(p[\bleepo]);
//
// 	ProxyPresetGui(q.bliPreset, bounds: 350@80, parent: w);
//
// 	k = p[\bleepo].getKeysValues.collect { |list, i|
// 		var name, val, kn; #name, val = list;
// 		kn = EZKnob(w, 56 @ 96, name, name.asSpec, { arg kn; p[\bleepo].set(name, kn.value); }, val);
// 		w.view.decorator.shift(24);
// 		kn
// 	};
//
// 	SkipJack({
// 		p[\bleepo].getKeysValues.do { |list, i| k[i].value_(list[1]) };
// 	}, 0.2, { w.isClosed }, \bleepo);
//
// 	w.view.decorator.shift(0, 5);
//
// 	t = TdefGui(Tdef(\bleepoDrift), parent: w);
// 	t.zone.resize_(2);
// 	// q.bliPreset.storePath = q.dir +/+ "bleepo.pxpreset.scd";
// 	q.bliPreset.loadSettings;
//
// 	if (useScope) {
// 		sc = CompositeView(w, Rect(0,0,330, 200));
// 		sc.addFlowLayout;
// 		Stethoscope(s, 2, ~bleepo.index, zoom: 10, view: sc);
// 	};
// };


// Task {
// 	0.5.wait;
// 	s.sync;
//
// 	0.5.wait;
// 	q.makeBleepoGui;
//
// 	0.5.wait;
// 	//	q.bliPreset.loadSettings;
// 	p[\bleepo].setRates(\dens, 0.0,\rateA, 0.2, \rateB, 0.2,
// 	\fm_b2a, 0.2, \fm_a2b, 0.2, \sh2Filt, 0.2, \sh2RateA, 1.2);
//
// 	0.25.wait;
// 	p[\bleepo].pause;
//
// 	0.5.wait;
// 	//	p[\bleepo].playN((0..q.numChans - 1).scramble.keep(4).clump(2), vol: 0.0);
//
//
// 	Tdef(\bleepoDrift, { inf.do {
// 		exprand(0.2, 10).wait;
// 		q.bliPreset.setRand([0.001, 0.01, 0.1].wchoose([9, 3, 1] / 13));
// 	} });
// }.play(AppClock);
// );
