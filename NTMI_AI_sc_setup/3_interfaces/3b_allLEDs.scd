
// test all led elements once:
/*
q.inph.mode = \full;
Tdef(\allLEDs).play;
*/

Tdef(\allLEDs).set(\dt, 0.1).play;
Tdef(\allLEDs, { |ev|
	try { q.osc.ntmiSkip.stop };
	2.do {
		"leds back ON".postln;
		MKtl(\ntmi).elAt(\led, \bk).do { |led|
			led.value = 1;
			ev.dt.wait;
		};

		"front on".postln;
		MKtl(\ntmi).elAt(\led, \fr).do { |led|
			led.value = 1;
			ev.dt.wait;
		};

		"back OFF".postln;
		MKtl(\ntmi).elAt(\led, \bk).do { |led|
			led.value = 0;
			ev.dt.wait;
		};

		"front off".postln;
		MKtl(\ntmi).elAt(\led, \fr).do { |led|
			led.value = 0;
			ev.dt.wait;
		};
	};

	// set to correct state now:
	try { q.osc.ntmiSkip.stop.play };

	MFdef(\inphModeSetIndex).value(q.inph.modeIndex);
	MFdef(\setInphWPre).value(q.inph.at(\presIndex));

});

