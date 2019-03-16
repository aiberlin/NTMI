// add all global filter functions to use - these are then available by name.
q=q?();
q.numChans = q.numChans ? 2;
1000.do{|i| var sy = ("wet"++i).asSymbol; Spec.add(sy, \unipolar) };
1000.do{|i| var sy = ("mix"++i).asSymbol; Spec.add(sy, \unipolar) };
(
// add your own fx stuff here!
q.fx = IdentityDictionary
[

	'3ring' -> { arg in, ringfr=100;
		in * SinOsc.ar(ringfr)
	},

	'00_in' -> { arg in, level=1, llag=0.2, noisefloor=0.01;
		LeakDC.ar( in * level.lag(llag) )
		+ BrownNoise.ar(0.0001).madd(noisefloor ! q.numChans);
	}
	,
	'0_DBComp' -> {	 arg in, xFreq=400, thresh=0.5, loGain=2, hiGain=0.5, compRatio=2;
		DualBandComp.ar(
			in,
			xFreq, loGain,  hiGain, thresh, compRatio
		)
	}
	,
	'0_comp' -> { arg in, thresh=0.5, slopLo=0.9, slopHi=0.5;
		Compander.ar(
			in, in,
			thresh, slopLo, slopHi,
			0.03, 0.05
		)
	}
	,
	'0_gate' -> {|in, threshG = 0.03, attG=0.01, decG=1|
		Compander.ar(
			in, in,
			threshG, 10, 1,
			attG, decG
		)
	}
	,
	'0freqBal' -> { arg in, bFreq=200, pan=0;
		var split, lo;
		pan = LinExp.kr(pan, -1,1, 1/20,20);
		lo = LPF.ar(in, bFreq);
		split = [lo, in-lo] * [ pan.reciprocal, pan ];
		split.sum;
	}
	,
	'0OnePolBal' -> { arg in, coeff= 0.6, balnZ = 0.5;
		var split, lo;
		lo = OnePole.ar(in, coeff);
		split = [lo, in-lo] * [ balnZ.reciprocal, balnZ ];
		split.sum;
	}
	,
	'1holz' -> {|in, reson=0.1, levelH=1.2|
		var n = 8;
		var freqs = {exprand(150, 6000).floor }.dup(n).sort;
		var res = {exprand( 0.05, 0.1 )}.dup(n).sort.reverse;
		var tone = Klank.ar(`[
			freqs.postln,
			0.1!n,
			res.round(0.001).postln
		],
		in, decayscale: reson
		);
		(tone * levelH).tanh
	}
	,

	'7Delay'	-> { arg in, delayTime1 = 1, delayTime2 = 0.76, mod=0.66, feedback=3;
		var dtKr, comb, tempo;
		tempo = 1;   // quarter tempo..
		dtKr = [delayTime1, delayTime2 ].lag(1.0);
		comb = CombL.ar(
			HPF.ar(in, 200),
			6,
			dtKr * ( 1 - LFDNoise3.kr(mod.sqrt!2 * 4, 0.8 * mod).cubed ),
			dtKr * feedback,
			0.8
		);

		Rotate2.ar(comb[0], comb[1], SinOsc.kr(0.025)) + in;
	}
	,
	'5HPF'	-> { arg in, bpm=80, freqH = 400, modH =0.5, rqH =0.75;
		var fr, seq, tempo;
		tempo = bpm / 60;   // quarter tempo..
		fr = SinOsc.kr((modH * tempo), [0, 0.4]).exprange(0.5, 3).madd(freqH).fold(20, 19000);
		RHPF.ar(in, fr, rqH)
	}
	,

	'5LPF'	-> { arg in, freqL = 4000, modL = 0.6, rqL = 1;
		var fr = (freqL
			+ LFDNoise3.kr(
				Amplitude.kr(in).sqrt
				* modL.cubed
				* 20
				! q.numChans
			).exprange(1/3, 3)
			.madd(freqL * modL)
		).cpsmidi.round(2).fold(15, 133).midicps;

		RLPF.ar(in, fr, rqL )
	},
	'3AdCVerb' -> {| in, predelay=0.048, revTime=3, combScale=1, apScale=1, mod=0.05 |
		var sig, y, z;
		AdCVerb.ar( in, revTime, LFNoise1.kr(0.2!2,0.1*mod, 0.11),  2, predelay,
			8, 4, 0.6, combScale = 1, apScale = 1);

	}
	,
	'3thrasher' -> { arg in, bit = 7, downsample= 6000, downsmod=0.75;
		var zin, zout;
		zin = in;
		zout = zin.round(2.pow(bit).reciprocal);
		zout = downsample<22050 *
		Latch.ar(
			zout,
			Impulse.ar(
				downsample
				* LFDNoise1.kr(
					downsmod.cubed * 75 ! 2,
					0.25, 0.75
				).abs
			)
		)
		+ (downsample >= 22050 * zout)
	}
	,
	'1ixiDist' -> { |in, pregain=2, dFreq= 4000, postgain=1, loSlop=0.6 |
		var sig, sigtocomp, fx, y, z;
		sig = in;
		sigtocomp = LPF.ar((sig * pregain).distort, dFreq, postgain).distort;
		fx = Compander.ar(sigtocomp, sigtocomp, 1, loSlop, 1 );
		LeakDC.ar(fx, mul: 0.5 );
	}
	,
	'4ixiVerb' -> {| in, predelay=0.048, combdecay=5, apDecay=1, ixivAmp=0.1 |
		var sig, y, z;
		sig = in.madd(ixivAmp).rotate(-1);
		z = DelayN.ar(sig, 1, predelay);
		y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.05, rrand(0.03, 0.05), combdecay) }).scramble);
		6.do({ y = AllpassN.ar(y.rotate(1), 0.050, rrand(0.03, 0.05), apDecay) });
		y+in;
	}
	,
	'6roto' -> { arg in, speed = 0.02;
		var sins, n = q.numChans;
		sins = LFSaw.ar(speed, 0, 1, (1..n)-1*2/n * 0.67 );
		(({ arg i; PanAz.ar(n, in[i], sins[i], 1, 1.9) } ! n)).sum;
	}
	,

	'9endFilt' -> { arg in, higCut=15000, lowCut=40; var l, h;
		l = LPF.ar( in, lowCut);
		h = LPF.ar( in, higCut);
		h-l;
	},
	'9stereofy' -> { arg in;
		Splay.ar(in)
	},
	'9monofy' -> { arg in;
		(in).mean.dup(q.numChans)
	},

	'ampFin' -> { |in, limDrive=1, ampLimit=0.9, postAmp=1 |
		var st = Limiter.ar(in * limDrive, ampLimit) * postAmp;
		LeakDC.ar(st)
	}

];
);

// add them to da Chain
q.fx.keysValuesDo({ |key,val| // key.postcln;
	ProxyChain.add(key.asSymbol, \filterIn -> val)
});

// and specs for them fof gui control.
Spec.add( \level, [0, 20, 5]);
Spec.add( \llag, [0, 600, 8]);

Spec.add( \coeff, [0, 0.99999, -7.5, 0.00001]);
Spec.add( \balnZ, [1/12, 12, \exp, 0, 0]);
Spec.add( \inGain, [0, 25, 6]);
Spec.add( \thresh, [0.000001, 1, \exp]);
Spec.add( \mmGain, [0, 10, \lin]);
Spec.add( \ampFIN, [0, 10, \amp, 0, 1]);
Spec.add( \gain, [1/100, 5, \amp, 0, 1]);

Spec.add(\noisefloor, \amp);
Spec.add(\limDrive, \ampx4);
Spec.add(\ampLimit, \amp);
Spec.add(\postAmp, \ampx4);

Spec.add( \inAmp, \gain.asSpec);
Spec.add( \thresh, \amp.asSpec);
Spec.add( \threshG, \amp.asSpec);
Spec.add( \slopLo, [1/10, 10, \exp, 0.0]);
Spec.add( \slopHi, [1/10, 10, \exp, 0.0]);
Spec.add( \loCut, \freq.asSpec);
Spec.add( \lowCut, \freq.asSpec);
Spec.add( \higCut, \freq.asSpec);

Spec.add( \gainL, [0.1, 10, \exp]);
Spec.add( \gainR, [0.1, 10, \exp]);
Spec.add( \hifreq, [600, 19000, \exp]);
Spec.add( \lowfreq, [10, 500, \exp]);
Spec.add( \freqSpan, [10, 7000, \exp]);
Spec.add( \octSpan, [-8, 8, \lin]);
Spec.add( \ffFrq, [10, 19000, \exp]);

Spec.add( \wetRev, [0, 1, \lin]);
Spec.add( \feedback, [1, 100, \exp, 0.1]);
Spec.add( \delayTime1, [0.005, 6, \exp]);
Spec.add( \delayTime2, [0.005, 6, \exp]);
Spec.add( \mod, [0, 1, \lin]);

Spec.add( \revTime, [0.05, 1, \exp]);
Spec.add( \revDecay, [0.001, 10, \exp]);
Spec.add( \modulation, [0, 1, \lin]);
Spec.add( \modulatie, [0, 1, \lin]);
Spec.add( \modulaNon, [0, 1, \lin]);

Spec.add( \bit, [16, 2, \lin, 1]);
Spec.add( \downsmod, [0, 1, \lin]);
Spec.add( \downsample, [s.sampleRate ? 44100 /2, 100, \lin]);

Spec.add( \dAmp, \amp.asSpec);
Spec.add( \dFreq, \freq.asSpec);
Spec.add( \pregain, [0.01, 20, \linear]);
Spec.add( \postgain, [0.01, 20, \linear]);

Spec.add( \combScale, \amp.asSpec);
Spec.add( \apScale, \amp.asSpec);
Spec.add( \predelay, [0.0001, 1, \linear]);

Spec.add( \revDcy, [0.01, 12, \linear, 0, 1]);
Spec.add( \apDecay, [0.01, 12, \linear, 0, 1]);
Spec.add( \combdecay, [0.1, 15, \linear, 0, 15]);
Spec.add( \ixivAmp, \amp.asSpec);
Spec.add( \bFreq, \freq.asSpec);

Spec.add( \pFreq, \freq.asSpec);
Spec.add( \pDb, [-60, 32, \linear, 0, 1]);
Spec.add( \pRq, \rq.asSpec);

Spec.add( \loSlop, [1, 0.0, \linear, 0, 1]);
Spec.add( \rqL, \rq.asSpec);
Spec.add( \rqH, \rq.asSpec);
Spec.add( \modL, \unipolar.asSpec);
Spec.add( \modH, [0, 32, 5, 1/1000]);
Spec.add( \freqL, \freq.asSpec);
Spec.add( \freqH, \freq.asSpec);

Spec.add( \ampC, \gain.asSpec);
Spec.add( \op, [0.95, 0.5, 1].asSpec);
Spec.add( \lpfreq, \freq.asSpec);

Spec.add( \lagW, [0.01, 30, \exp, 0.0]);
Spec.add( \speedW, [0.0001, 4, \exp, 0.0]);
Spec.add( \widthW, [0.0, 0.5, \lin, 0.0]);

Spec.add( \spreadX, [1.01, 5.0, \exp, 0.0]);
Spec.add(\gainX, \gain.asSpec);

Spec.add( \rotWh, [-10, 100, \lin, 0.0]);
Spec.add( \ampWh, [0.01, 100, \exp, 0.0]);
Spec.add( \ampExp, [0.1, 10, \exp, 0.0]);
Spec.add( \lagWheel, [0.01, 120, \exp, 0.0]);
Spec.add( \dimension, [0.01, 120, \exp, 0.0]);
Spec.add( \slewU, [0, 24000, 4]);
Spec.add( \slewD, [0, 24000, 4]);
Spec.add( \miX, \pan.asSpec);
Spec.add( \fftGain, \amp.asSpec);
Spec.add( \levelH, \gein.asSpec);
Spec.add( \reson, [0.01, 2, \exp] );

Spec.specs.put(\xFreq, \freq.asSpec);
Spec.specs.put(\loGain, ControlSpec(0, 10, \amp, 0, 1));
Spec.specs.put(\hiGain, ControlSpec(0, 10, \amp, 0, 1));
Spec.specs.put(\compRatio, [1, 10, \exp, 0.1, 3].asSpec);


/////make MAster FX

(
q.mFX = MasterFX.new(server: s,
	numChannels: q.numChans,
	slotNames: q.fx.keys.asArray.sort,
	busIndex: 0
);

// pre-set ons:
q.mFX.pxChain.add('00_in', 1);
q.mFX.pxChain.add('0_DBComp', 1);

// q.mFX.pxChain.add('3AdCVerb', 0.1);
// q.mFX.pxChain.add('3ring', 0.1);
// q.mFX.pxChain.add('5LPF', 0.1);
q.mFX.pxChain.add('ampFin', 1);

);

// tweak
q.mFX.pxChain.proxy.fadeTime = 2;
// add Panic Button?
/*
q.mFX .pxChain . dump
q.mFX .pxChain . proxy.dump

MasterFX.clear('localhost')
q.mFX.pxChain.proxy.controlKeys
*/