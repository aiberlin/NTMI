// Blip thru Formlet, pseudo-vocal synthesis.
// hh&adc, since beijing 2005
// 2019 made quad/MC

// keywords: vocal, voice, formants

/*
Ndef(\formSing).gui;
Ndef(\formSing).play;
Ndef(\formSing).getHalo(\stepFdev).value;
*/
Ndef(\formSing).addSpec(\root, [20, 500, 6]);
Ndef(\formSing).addSpec(\formfrq, [50, 5000, \exp]);
Ndef(\formSing).addSpec(\harm, [1, 256, \exp]);
Ndef(\formSing).addSpec(\formLag, [0.01, 100, \exp]);
Ndef(\formSing).addSpec(\ndiv, [0.01, 1, \exp]);
Ndef(\formSing).addSpec(\fdev, [0, 24, \amp]);
Ndef(\formSing).addSpec(\round, [0, 3, \amp, 0.05]);

(
// modulating formant frequency
Ndef(\formSing, { arg amp=0, root=150, formfrq=500, harm=20, fdev=2, ndiv = 0.2, formLag=0.1, round = 1.5;
	var freqCompare = 1; // ((formfrq / root).log2).abs.min(1).linexp(0, 1, 0.25, 1);
	var in = Blip.ar(
		root.lag(formLag) * LFNoise0.kr(root * ndiv ! q.numChans, fdev.max(0.01) ).midiratio,
		harm.lag(formLag), // .max(formfrq / root * 0.25),
		0.1
	) * GrayNoise.ar(0.1 ! q.numChans, 1);

	Limiter.ar(Formlet.ar(in, formfrq.lag(formLag), 0.005, 0.02) * (freqCompare * amp.lag(0.1)))
		.softclip;
});
);
