// nonstandard synthesis hoelzl style
// hh beijing 2005-
// made quad/MC 2019
q=q?();
q.numChans = q.numChans ? 2;

Ndef(\allArm, { arg amp=0, divefreq=0.2, topfreq= 10000, filtfreq=20;
	var mintime, source;
	mintime = (LFDNoise0.kr(20! q.numChans, 0.5, 1) * topfreq).reciprocal;
	source = LeakDC.ar(
		CombN.ar(
			Decay.ar(
				Dust.ar(0.6 ! q.numChans, 1) + BrownNoise.ar(0.0005),
				0.2,
				WhiteNoise.ar(1 ! q.numChans) * LFDNoise0.kr(0.4, 0.5, 0.5)
			),
			2.2,
			(SinOsc.kr(divefreq, 0.2, 0.7, 0.7)
			+ LFDNoise3.kr(divefreq * 2.6, 0.4, 0.0)).max(mintime).min(2.2),
			1
		)
	);
	Sanitize.ar(
		Limiter.ar(
			OnePole.ar(([ HPF.ar(source, filtfreq), LPF.ar(source, filtfreq, 4) ].sum * amp).distort, 0.2),
			0.7
		)
	);
});

Ndef(\allArm).addSpec(\topfreq, [20, 100000, \exp, 1]);
Ndef(\allArm).addSpec(\filtfreq, [8, 100000, \exp, 1]);
Ndef(\allArm).addSpec(\divefreq, [0.05, 20, \exp, 0.01]);

// basic mapping notes
Ndef(\allArm).addHalo(\gamePadMap, (
	joyLX: \topfreq,
	joyLY: \divefreq,
	joyRX: \filtfreq,
	joyRY: \amp)
);

/* tests
Ndef(\allArm).gui;
Ndef(\allArm).play;

Ndef(\allArm).vol_(0.1);
Ndef(\allArm).set(\filtfreq, 200);
Ndef(\allArm).set(\topfreq, 200);
Ndef(\allArm).set(\divefreq, 1);

Ndef(\allArm).paused
*/

/* old gamepad mapping, for reference
GamePad.putProxy(5, \s5_allArm,
(
joyRY: { arg val; ~s5_allArm.set(\amp, \amp.asSpec.map(val) )  },
joyLX: { arg val; ~s5_allArm.set(\topfreq, \topfreq.asSpec.map(val)) },
joyLY: { arg val; ~s5_allArm.set(\divefreq, \divefreq.asSpec.map(val)) },
joyRX: { arg val; ~s5_allArm.set(\filtfreq,  \filtfreq.asSpec.map(val)) }
)
);
*/
