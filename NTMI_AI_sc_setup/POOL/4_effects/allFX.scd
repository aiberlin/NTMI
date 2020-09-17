(
// add your own fx stuff here!

// global specs first
ProxyChain.addSpec(
	\freqscale, [0.3, 3, \exp, 0.001],
	\rtscale, [0.3, 3, \exp, 0.001],

	\thresh, \amp,
	\threshG, \amp,
	\gain, [0.01, 5, \amp, 0, 1],

);


ProxyChain.add3( '1comby',
	\filterIn -> { |in, freqscale = 1, rtscale = 1|
		CombletC.ar(in, 0.2,
			(1/( (0, 7 .. 28) + 12)).collect { |del|
				del * LFDNoise3.kr(0.2, 0.003, 1) },
			3,
			0.3,
			[0.5, 0.4, 0.32, 0.25, 0.2]
		).mean;
}, 0.25);

// .add3: name, func, level, [specs]
ProxyChain.add3( '1klanky',
	\filterIn -> { |in, freqscale = 1, rtscale = 1|
		Ringz.ar(in,
			[400, 700, 1300] * freqscale,
			[0.2, 0.1, 0.05] * rtscale,
			0.1).mean;
	},
	0.25
);

ProxyChain.add3( '1comby',
	\filterIn -> { |in, freqscale = 1, rtscale = 1|
		CombletC.ar(in, 0.2,
			(1/( (0, 7 .. 28) + 12)).collect { |del|
				del * LFDNoise3.kr(0.2, 0.003, 1) },
			3,
			0.3,
			[0.5, 0.4, 0.32, 0.25, 0.2]
		).mean;
	},
	0.1
);

ProxyChain.add3( '1ring',
	\filterIn -> { arg in, ringfr=100; in * SinOsc.ar(ringfr) },
	1,
	[
		\ringfr, [5, 2000, \exp, 0.1]
	]
);

ProxyChain.add3( '00_in',
	\filterIn -> { arg in, level=1, llag=0.2, noisefloor=0.01;
		LeakDC.ar( in * level.lag(llag) )
		+ BrownNoise.ar(0.0001).madd(noisefloor ! q.numChans);
	},
	1,
	[
		\level, [0, 20, 5],
		\llag, [0, 600, 8],
		\noisefloor, \amp
	]
);

ProxyChain.add3( '0_DBComp',
	\filterIn -> {	 arg in, mainVol = 1, xFreq=400, thresh=0.5, loGain=2, hiGain=0.5, compRatio=2;

		DualBandComp.ar(
			in * mainVol.lag(0.2),
			xFreq, loGain,  hiGain, thresh, compRatio
		)
	},
	1,
	[
		\xFreq, [100, 1000, \exp],
		\mainVol, [0, 4, \amp],
		\loGain, [0, 10, \amp, 0, 1],
		\hiGain, [0, 10, \amp, 0, 1],
		\compRatio, [1, 10, \exp]
	]
);

ProxyChain.add3( '0_comp',
	\filterIn -> { arg in, thresh=0.5, slopLo=0.9, slopHi=0.5;
		Compander.ar(
			in, in,
			thresh, slopLo, slopHi,
			0.03, 0.05
		)
	},
	1,
	[ 	\slopLo, [1/10, 10, \exp, 0.0],
		\slopHi, [1/10, 10, \exp, 0.0]
	]
);

ProxyChain.add3( '0_gate',
	\filterIn -> {|in, threshG = 0.03, attG=0.01, decG=1|
		Compander.ar(
			in, in,
			threshG, 10, 1,
			attG, decG
		)
	},
	1,
	[
		\attG, [0.0001, 0.03, \exp],
		\decG, [0.01, 0.3, \exp],
	]
);

ProxyChain.add3( '0freqBal',
	\filterIn -> { arg in, bFreq=200, pan=0;
		var split, lo;
		pan = LinExp.kr(pan, -1,1, 1/20,20);
		lo = LPF.ar(in, bFreq);
		split = [lo, in-lo] * [ pan.reciprocal, pan ];
		split.sum;
	},
	1,
	[
		\bFreq, \freq
	]
);

ProxyChain.add3( '0OnePolBal',
	\filterIn -> { arg in, coeff= 0.6, balnZ = 0.5;
		var split, lo;
		lo = OnePole.ar(in, coeff);
		split = [lo, in-lo] * [ balnZ.reciprocal, balnZ ];
		split.sum;
	},
	1,
	[
		\coeff, [0, 0.99999, -7.5, 0.00001],
		\balnZ, [1/12, 12, \exp, 0, 0],
	]
);

ProxyChain.add3( '1holz',
	\filterIn -> {|in, reson=0.1, levelH=1.2|
		var n = 8;
		var freqs = {exprand(150, 6000).floor }.dup(n).sort;
		var res = {exprand( 0.05, 0.1 )}.dup(n).sort.reverse;
		var tone = Klank.ar(`[
			freqs.postln,
			0.03 ! n,
			res.round(0.001).postln
		],
		in, decayscale: reson
		);
		(tone * levelH).tanh
	},
	1,
	[
		\reson, [0.01, 2, \exp],
		\levelH, \ampx4,
	]
);

ProxyChain.add3( '7Delay',
	\filterIn -> { arg in, delayTime1 = 1, delayTime2 = 0.76, mod=0.66, feedback=3;
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
	},
	1,
	[
		\feedback, [1, 100, \exp, 0.1],
		\delayTime1, [0.05, 1, \exp],
		\delayTime2, [0.05, 1, \exp],
		\mod, [0, 1, \lin],
	]
);

ProxyChain.add3( '5HPF',
	\filterIn -> { arg in, bpm=80, freqH = 400, modH =0.5, rqH =0.75;
		var fr, seq, tempo;
		tempo = bpm / 60;   // quarter tempo..
		fr = SinOsc.kr((modH * tempo), [0, 0.4]).exprange(0.5, 3).madd(freqH).fold(20, 19000);
		RHPF.ar(in, fr, rqH)
	},
	1,
	[
		\bpm, [20, 360, \exp],
		\rqH, \rq,
		\modH, [0, 32, 5, 1/1000],
		\freqH, \freq,
	]
);

ProxyChain.add3( '5LPF',
	\filterIn -> { arg in, freqL = 4000, modL = 0.6, rqL = 1;
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
	1,
	[
		\freqL, \freq,
		\modL, \unipolar,
		\rqL, [0.1, 2, \exp],
	]
);

ProxyChain.add3( '3AdCVerb',
	\filterIn -> { |in, revTime=3, animRate = 0.4, animDepth = 0.1, predelay = 0.02, combScale = 1|
		AdCVerb2.ar(in.sum * 0.2,
			revTime,
			animRate, animDepth,
			hfDamping: 0.5,
			nOuts: q.numChans,
			predelay: predelay,
			leakCoeff: 0.99,
			combScale: combScale
		);
	},
	0.05,
	[
		\predelay, [0.0, 0.2, \amp],
		\revTime, [0.3, 30, \exp],
		\animRate, [0.01, 10, \exp],
		\animDepth, [0, 1, \amp],
		\combScale, [0.05, 2, \exp]
	]
);

ProxyChain.add3( '3thrasher',
	\filterIn -> { arg in, bit = 7, downsample= 6000, downsmod=0.75;
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
	},
	1,
	[
		\bit, [16, 2, \lin, 1],
		\downsmod, [0, 1, \lin],
		\downsample, [s.sampleRate ? 44100 /2, 100, \lin],
	]
);

ProxyChain.add3( '1ixiDist',
	\filterIn -> { |in, pregain=2, dFreq= 4000, postgain=1, loSlop=0.6 |
		var sig, sigtocomp, fx, y, z;
		sig = in;
		sigtocomp = LPF.ar((sig * pregain).distort, dFreq, postgain).distort;
		fx = Compander.ar(sigtocomp, sigtocomp, 1, loSlop, 1 );
		LeakDC.ar(fx, mul: 0.5 );
	},
	1,
	[
		\dFreq, \freq,
		\pregain, [0.01, 20, \linear],
		\postgain, [0.01, 20, \linear],
		\loSlop, [1, 0.0, \linear, 0, 1],

	]
);
ProxyChain.add3( '4ixiVerb',
	\filterIn -> {| in, predelay=0.048, combdecay=5, apDecay=1, ixivAmp=0.1 |
		var sig, y, z;
		sig = in.madd(ixivAmp).rotate(-1);
		z = DelayN.ar(sig, 1, predelay);
		y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.05, rrand(0.03, 0.05), combdecay) }).scramble);
		6.do({ y = AllpassN.ar(y.rotate(1), 0.050, rrand(0.03, 0.05), apDecay) });
		y+in;
	},
	1,
	[
		\predelay, [0.0001, 1, \linear],
		\apDecay, [0.01, 12, \linear, 0, 1],
		\combdecay, [0.1, 15, \linear, 0, 15],
		\ixivAmp, \amp,
	]
);

ProxyChain.add3( '6roto',
	\filterIn -> { arg in, speed = 0.02;
		var sins, n = in.size;
		sins = LFSaw.ar(speed, 0, 1, (1..n)-1*2/n * 0.67 );
		(({ arg i; PanAz.ar(n, in[i], sins[i], 1, 1.9) } ! n)).sum;
	},
	1,
	[
		\speed, [0.01, 2, \exp, 0.0],
	]
);

ProxyChain.add3( '9endFilt',
	\filterIn -> { arg in, higCut=15000, lowCut=40;
		var l, h;
		l = LPF.ar( in, lowCut);
		h = LPF.ar( in, higCut);
		h-l;
	},
	1,
	[	\lowCut, \freq,
		\higCut, \freq,
	]
);

ProxyChain.add3( '9stereofy',
	\filterIn -> { arg in;
		// overwrite channels past 2 with Silence
		Splay.ar(in) ++ Silent.ar(in.size - 2)
	},
	1
);

ProxyChain.add3( '9monofy', \filterIn -> { arg in; (in).mean.dup(q.numChans) }, 1);

ProxyChain.add3( 'ampFin',
	\filterIn -> { |in, limDrive=1, ampLimit=0.9, postAmp=1 |
		var st = Limiter.ar(in * limDrive, ampLimit) * postAmp;
		LeakDC.ar(st)
	},
	1,
	[
		\limDrive, \ampx4,
		\ampLimit, \amp,
		\postAmp, \ampx4
	]
);

)

