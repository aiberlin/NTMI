// test lighting all leds once:

~ntaddr = MKtl(\ntmi).device.source;

Tdef(\allColors).set(\dt, 0.05);
Tdef(\allColors, { |ev|
	"colors back".postln;
	8.do { |led|
		3.do { |col|
			var msg = [0, 0, 0, 0].put(0, led).put(col + 1, 1).postln;
			~ntaddr.sendMsg("/ntmi/ledCtl/back", *msg);
			ev.dt.wait;
		};
	};

	"colors back off".postln;
	8.do { |led|
		var msg = [0, 0, 0, 0].put(0, led);
		~ntaddr.sendMsg("/ntmi/ledCtl/back", *msg);
		// safe pause between block sets
		ev.dt.wait;
	};

	"front".postln;
	8.do { |led|
		~ntaddr.sendMsg("/ntmi/ledCtl/front", led.postln, 1);
		ev.dt.wait;
	};
	"front off".postln;
	8.do { |led|
		~ntaddr.sendMsg("/ntmi/ledCtl/front", led.postln, 0);
		ev.dt.wait;
	};

}).play;

