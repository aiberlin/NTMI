
// test all led elements once:
/*
NTMI.nUFO.nUFO.mode = \full;
Tdef(\allLEDs).play;

// test wakeup ballet also from OSC:
// if first time, or longer than 10 sec silence, do ballet
NetAddr.localAddr.sendMsg("/ntmi/imu", 0.0);

*/

Tdef(\allLEDs).set(\dt, 0.1);
Tdef(\allLEDs).set(\repeats, 1);

Tdef(\allLEDs, { |ev|
	try { NTMI.nUFO.skip.stop };
	ev.repeats.do {
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
	try { NTMI.nUFO.skip.stop.play };

	// sync back LEDs state
	0.1.wait;
	NTMI.slots.actives.do { |ndef, i|
		var playVal = ndef.monitor.isPlaying.binaryValue;
		MKtl(\nUFO).elAt(\led, \bk, i).value = playVal;
		0.05.wait;
	};
	NTMI.nUFO.setModeIndex(NTMI.nUFO.modeIndex);
	0.1.wait;
	NTMI.inph.setWPreIndex(NTMI.inph.presIndex);
	0.1.wait;
});

