
// test all led elements once:
/*
NTMI.osc.nUFO.mode = \full;
Tdef(\allLEDs).play;
*/

Tdef(\allLEDs).set(\dt, 0.1);
Tdef(\allLEDs, { |ev|
	try { NTMI.osc.nufoSkip.stop };
	2.do {
		"leds back ON".postln;
		MKtl(\nUFO).elAt(\led, \bk).do { |led|
			led.value = 1;
			ev.dt.wait;
		};

		"front on".postln;
		MKtl(\nUFO).elAt(\led, \fr).do { |led|
			led.value = 1;
			ev.dt.wait;
		};

		"back OFF".postln;
		MKtl(\nUFO).elAt(\led, \bk).do { |led|
			led.value = 0;
			ev.dt.wait;
		};

		"front off".postln;
		MKtl(\nUFO).elAt(\led, \fr).do { |led|
			led.value = 0;
			ev.dt.wait;
		};
	};

	// set to correct state now:
	try { NTMI.osc.nufoSkip.stop.play };

	// sync back LEDs state
	0.1.wait;
	NTMI.slots.actives.do { |ndef, i|
		var playVal = ndef.monitor.isPlaying.binaryValue;
		MKtl(\nUFO).elAt(\led, \bk, i).value = playVal;
		0.05.wait;
	};
	NTMI.osc.nUFO.setModeIndex(NTMI.osc.nUFO.modeIndex);
	0.1.wait;
	NTMI.inph.setWPreIndex(NTMI.inph.presIndex);
	0.1.wait;
});

