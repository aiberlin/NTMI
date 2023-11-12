// nonstandard cross FM - Joker Nies style
// hh ca. 2010...
// 2019- made quad/MC

// parameter range Specifications
Ndef(\xFMSH).addSpec(\blend, [0, 1]);
Ndef(\xFMSH).addSpec(\modA_B, [0, 6]);
Ndef(\xFMSH).addSpec(\modB_A, [0, 6]);
Ndef(\xFMSH).addSpec(\freqA, \widefreq);
Ndef(\xFMSH).addSpec(\freqB, \widefreq);
// Ndef(\xFMSH).addSpec(\modAB, \unipolar);
// Ndef(\xFMSH).addSpec(\modBA, \unipolar);
Ndef(\xFMSH).addSpec(\shape, [8, 1/8, \exp]);
Ndef(\xFMSH).addSpec(\lag, [0, 5, 5]);

// basic mapping notes
Ndef(\xFMSH).addHalo(\gamePadMap, (
	joyLX: \freqA,
	joyLY: \shape,
	joyRX: \modA_B,
	joyRY: \amp)
);
(
// sound description in SC JITLib style:
Ndef(\xFMSH, { |amp=0, freqA=440, freqB=44, modA_B=0.1, modB_A=0.9, shape=1, blend=0, lag=0.05|
	var sig, fb = LocalIn.ar(2);
	var sh =  Latch.ar(fb, fb.reverse);
	var freqs =  2.pow([modB_A, modA_B].lag2(lag)).pow(sh) * [freqA, freqB].lag2(lag);
	var oscs = SinOsc.ar(freqs).pow(shape.lag(lag));
	LocalOut.ar(oscs);
	sig = blend(
		oscs.product.dup,
		oscs,
		blend.lag(lag)
	);
	sig.collect{|si, i| // multichannel expansion
		PanAz.ar(2, si, SinOsc.kr(Rand(0.1, 0.2), 0, Rand(1, 2)), amp)
	}.sum;
});
);
