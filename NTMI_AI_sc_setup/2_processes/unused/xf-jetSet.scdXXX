Ndef('xf-jetSet').addSpec(\freqMul, [0.75, 8, \exp] );
Ndef('xf-jetSet').addSpec(\dGain, [0, 5, \amp] );
Ndef('xf-jetSet').addSpec(\fFreq, [200, 10000, \exp] );
Ndef('xf-jetSet').addSpec(\filterF, [200, 10000, \exp] );
Ndef('xf-jetSet').addSpec(\wCut, [250, 4000, \lin] );
Ndef('xf-jetSet').addSpec(\cclip, [0.1, 1, \lin] );
Ndef('xf-jetSet').addSpec(\delT, [0.05, 1, 4] );
Ndef('xf-jetSet').addSpec(\delfreq, [5, 50, \lin] );
// Ndef('xf-jetSet').addSpec(\amp,\amp );

Ndef('xf-jetSet', { | amp=0.1, freqMul=1, dGain=1, fFreq=200, wCut=2200, cclip=1, delT=0.2, delfreq = 20 ,filterF=10000|
	// get fed back signal and add a little noise to get things going
	var inChan=0, sig, delay, minfreqs, freqs, combF, hpf, lpf,  filter,wha,  dry, distort;

	var in =  q.liveInput.ar(1);//+ WhiteNoise.ar(0.001!2) + Dust.ar(8!2, 30).lag(0.01);
	// delay due to distance from amp - I chose 0.05s, or 20Hz
	delay = DelayN.ar(in,1/10-ControlDur.ir,1/delfreq-ControlDur.ir.lag(0.1));

	// guitar string frequencies
	// a few octaves to get a good sound.
	// open strings
	//freqs = (84+[0,5,10,15,19,24]).midicps/8;
	// e minor and other chords
	freqs = ((64+
		[	[0,7,12,15,19,24],
			[0,4,12,15,18,24] + 3,
			[0, 3, 6, 8, 10, 22],
			// [0,7,12,15,19,24]
		].choose.postln
	).midicps/4);

	// whammy bar modulates freqs:
	minfreqs = freqs*0.5;
	freqs = freqs* freqMul.lag(0);

	// 6 comb filters emulate the strings' resonances
	combF = Splay.ar(CombN.ar( delay!6, 1/minfreqs, 1/freqs, 8 ));

	// a little filtering...
	lpf = LPF.ar(combF, filterF.lag(0.2));
	hpf = HPF.ar(lpf * dGain.lag(0.2), 70);

	// and some not too harsh distortion
	filter = RLPFD.ar( hpf, fFreq.lag(1) * [1, 1.1], 0.1,0.5 ).flop.sum;
	sig = filter + filter.mean;

	// and spot of reverb
	dry = sig;
	5.do {
		var d = 0.5.rand;
		sig = AllpassN.ar(sig, d, d * delT.lag(0.2), 1);
	};
	sig = (dry + sig) * amp;
	sig = SVF.ar(sig, wCut.lag(0.4));
	sig = sig.clip2(cclip) * cclip.reciprocal;
	sig = SVF.ar(sig, wCut.lag(0.6));
	Limiter.ar(LeakDC.ar(sig, 0.997));
});