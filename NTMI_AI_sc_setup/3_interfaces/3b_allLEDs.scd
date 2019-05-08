
// test all led elements once:
/*
Tdef(\allLEDs).play;
*/

Tdef(\allLEDs).set(\dt, 0.05);
Tdef(\allLEDs, { |ev|
	2.do {
	"leds back ON".postln;
	MKtl(\ntmi).elAt(\led, \bk).do { |led|
		led.value = 1;
			ev.dt.wait;
	};

	"back OFF".postln;
	MKtl(\ntmi).elAt(\led, \bk).do { |led|
		led.value = 0;
			ev.dt.wait;
	};

	"front on".postln;
	MKtl(\ntmi).elAt(\led, \fr).do { |led|
		led.value = 1;
			ev.dt.wait;
	};

	"front off".postln;
	MKtl(\ntmi).elAt(\led, \fr).do { |led|
		led.value = 0;
			ev.dt.wait;
	};
	}

});
