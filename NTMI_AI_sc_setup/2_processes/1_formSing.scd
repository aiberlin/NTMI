// Blip thru Formlet, pseudo-vocal synthesis.
// hh&adc, since beijing 2005
// 2019 made quad/MC

// keywords: vocal, voice, formants

/*
Ndef(\formSing).gui;
Ndef(\formSing).play;
Ndef(\formSing).getHalo(\stepFdev).value;
*/

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

Ndef(\formSing).addSpec(\root, [20, 500, 6]);
Ndef(\formSing).addSpec(\formfrq, [50, 5000, \exp]);
Ndef(\formSing).addSpec(\harm, [1, 256, \exp]);
Ndef(\formSing).addSpec(\formLag, [0.01, 100, \exp]);
Ndef(\formSing).addSpec(\ndiv, [0.01, 1, \exp]);
Ndef(\formSing).addSpec(\fdev, [0, 24, \amp]);
Ndef(\formSing).addSpec(\round, [0, 3, \amp, 0.05]);

Ndef(\formSing).addSpec(\root, [20, 500, 6]);
Ndef(\formSing).addSpec(\formfrq, [50, 5000, \exp]);
Ndef(\formSing).addSpec(\harm, [1, 256, \exp]);
Ndef(\formSing).addSpec(\formLag, [0.01, 100, \exp]);
Ndef(\formSing).addSpec(\ndiv, [0.01, 1, \exp]);
Ndef(\formSing).addSpec(\fdev, [0, 24, \amp]);
Ndef(\formSing).addSpec(\round, [0, 3, \amp, 0.05]);

Ndef(\formSing).addHalo(\orderedNames, [\amp, \root, \formfrq, \harm, \fdev, \ndiv, \formLag, \round]);

// basic mapping notes
Ndef(\formSing).addHalo(\gamePadMap, (
	joyLX: \formfrq, // was modalized to also set formLag
	joyLY: \root,
	joyRX: \harm,
	joyRY: \amp)
);


// extra funcs to step params up and down:

// was on GamePad rHat
Ndef(\formSing).addHalo(\stepFdev, { arg val; var curr;
	var nd = Ndef(\formSing), halo = nd.getHalo;
	"% - \stepFdev: ".postf(nd);
	halo[\fdefidx] = halo[\fdefidx] ? 0 + 1;
	nd.set(\fdev, [0.03, 0.12, 0.5, 2.5, 7, 12, 24].foldAt(halo[\fdefidx]).postln);
});

/* // for reference, the mappings in the GamePad class (up to SC 3.4.5)
GamePad.putProxy(4,
	\s4_formsing,
	(			// add switch and lag later?
		joyRY: { arg val, modState;
		//	modState.postln;
			if (modState.notNil and: { modState[\midL] }, {
				~s4_formsing.group.set(\formLag, \formLag.asSpec.map(val))
			}, {
				~s4_formsing.set(\amp, \amp.asSpec.map(val) )
			});
		},
		joyLX: { arg val; ~s4_formsing.set(\formfrq, \formfrq.asSpec.map(val)) },
		joyLY: { arg val; ~s4_formsing.set(\root, \root.asSpec.map(val)) },
		joyRX: { arg val; ~s4_formsing.set(\harm, \harm.asSpec.map(val)) },

		rHat: { arg val;
				if (val == 0, {
					q[\formSDev] = (q[\formSDev] ? 0 + 1);
					~s4_formsing.set(\fdev,
						[0.04, 0.5, 7, 12, 24].foldAt(q[\formSDev]).postln)
				});
			},
		lHat: { arg val;
				if (val == 0, {
					q[\formSNDiv] = (q[\formSNDiv] ? 0 + 1);
					~s4_formsing.set(\ndiv,
						[0.01, 0.03, 0.1, 0.3, 1].foldAt(q[\formSNDiv]).postln)
				});
			}
		)
)
*/
