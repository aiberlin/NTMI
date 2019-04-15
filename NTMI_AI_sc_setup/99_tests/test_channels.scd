Tdef(\pink).set(\dt, 0.25);
Tdef(\pink).set(\chans, (0..5));

Tdef(\pink, { |ev|
	Ndef(\pink, { PinkNoise.ar(0.1) });
	loop {
		ev.chans.do { |i|
			Ndef(\pink).play(i.postln);
			ev.dt.wait;
		};
	}
}).play;


Ndef(\pink).gui;
