
// test all led elements once:
/*
q.inph.mode = \full;
Tdef(\allLEDs).play;
*/

Tdef(\allLEDs).set(\dt, 0.1);
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

	// sync back LEDs state
	0.1.wait;
	q.slots.actives.do { |ndef, i|
		var playVal = ndef.monitor.isPlaying.binaryValue;
		MKtl(\ntmi).elAt(\led, \bk, i).value = playVal;
		0.05.wait;
	};
	MFdef(\inphModeSetIndex).value(q.inph.modeIndex);
	0.1.wait;
	MFdef(\setInphWPre).value(q.inph.at(\presIndex));
	0.1.wait;
});

