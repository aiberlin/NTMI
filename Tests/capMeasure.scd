/**** Capture OSC streams into arrays for analysis

//// 1. measure NTMI cap pads

//// a. measure bottom noise with fingers off:
q.cap.getRange(4);

q.cap.capranges; // capvals indiv. ranges:


//// b. touch every pad individually with one finger, full surface
q.cap.getRange(12);
d.capranges.collect(_.last);

Window.closeAll;

q.cap.win = Window("capture caps").front;
Button(q.cap.win, (100@30).asRect)
	.states_([["getRange"], ["capturing..."]])
	.action_({ q.cap.getRange(12) });

INSIGHTS SO FAR:
*** frame rate seems rather constant at 0.04 - not very fast

*** influx mode:
* base capvals are from 0 to 500
* some caps have a lot of sawtooth noise on them,
* some caps only go to max 1200, not 2000
* cap sensitivity is REALLY different when connected to USB power or not!

*** Binary mode:
* response time: 3-4 frames to go from off to > 0.4,
* decay time: 3-4 frames to go down to < 0.4 again,
-> i.e. tapping latency is always >= 0.12 - 0.16 seconds
compare with


////
****/

q.cap = (
	capvals: [],
	dts: [],
	getRange: { |d, dur = 4, displayRange|
		var count = 0;
		d.capvals = [];
		d.dts = Array[];

		OSCdef(\capsMax, { |msg|
			var nuvals = msg.drop(1);
			var now = Main.elapsedTime;
			var dt = (now - (d.time ? now)).round(0.0001);
			d.time = now;
			if (count % 5 == 0) {
				"\n%: % ".format(count).clipExtend(10).post
			};
			"% ".format(dt).clipExtend(10).post;

			count = count + 1;

			if (dt > 0 and: (dt < 0.3)) { d.dts = d.dts.add(dt) };

			d.capvals = d.capvals.add(nuvals);
		}, "/ntmi/caps").enable;

		fork {
			"\n*** start cap measure - count, dt:".post;
			dur.wait;
			d.end(displayRange);
		};
	},

	end: { |d, displayRange|
		var capchans = d.capvals.flop;
		var capranges = capchans.collect { |chan, i| [chan.minItem, chan.maxItem].round(0.01) };
		var observedRanges = capranges.flop.collect { |vals, i|
			if (i == 0) { vals.minItem } { vals.maxItem }
		};

		displayRange = displayRange ? observedRanges;
		d.capranges = capranges;

		OSCdef(\capsMax).disable;

		"\n*** RESULTS: ".postln;
		"// dt mean: %, range: % \n".postf(d.dts.mean.round(0.0001), [d.dts.minItem, d.dts.maxItem]);
		"caps overall range: % \n".postf(observedRanges);
		"q.cap.capranges; // indiv. cap ranges: ".postln;
		capranges.do { |range, i|
			"%: %\n".postf(i, range);
		};

		defer {
			d.dts.plot("dt jitter", Rect(320, 840, 400, 200));
			capchans.plot("capvals", Rect(320, 20, 400, 800), true,
				minval: displayRange[0], maxval: displayRange[1]);
		};
	},
);

/******** compare results:
/////////// NTMI003, q.bat.intval at 3116 / 11% ////////////

/// free caps:
q.cap.getRange(4);

q.cap.capranges; // indiv. cap ranges:
0: [ 0.0, 0.0 ]
1: [ 156.0, 230.0 ]
2: [ 0.0, 0.0 ]
3: [ 227.0, 374.0 ]
4: [ 73.0, 311.0 ]
5: [ 0.0, 88.0 ]
6: [ 36.0, 159.0 ]
7: [ 0.0, 0.0 ]
-----> chans 1, 3, 4 are quite noisy ...

// fully pressed caps:
q.cap.getRange(12); // press each one fully once

q.cap.capranges; // indiv. cap ranges:
0: [ 0.0, 1827.0 ]
1: [ 79.0, 2034.0 ]
2: [ 0.0, 1895.0 ]
3: [ 115.0, 1887.0 ]
4: [ 64.0, 1959.0 ]
5: [ 0.0, 1935.0 ]
6: [ 54.0, 1927.0 ]
7: [ 0.0, 1955.0 ]
-----> all chans get pretty near max of 2048


//////// NTMI005, q.bat.intval at 3461 / 47% ////////////////

/// free caps:
q.cap.getRange(4);
q.cap.capranges; // indiv. cap ranges:
0: [ 0.0, 0.0 ]
1: [ 0.0, 7.0 ]
2: [ 0.0, 0.0 ]
3: [ 0.0, 284.0 ]
4: [ 0.0, 44.0 ]
5: [ 52.0, 369.0 ]
6: [ 0.0, 0.0 ]
7: [ 4.0, 115.0 ]
-----> chans 3, and 5 are quite noisy ...


// fully pressed caps:
q.cap.getRange(12); // press each one fully once
0: [ 0.0, 1816.0 ]
1: [ 0.0, 1371.0 ]
2: [ 0.0, 2029.0 ]
3: [ 0.0, 2048.0 ]
4: [ 0.0, 2048.0 ]
5: [ 5.0, 2010.0 ]
6: [ 0.0, 2034.0 ]
7: [ 0.0, 1942.0 ]
-----> most chans get near max of 2048, but chan 1 is much less sensitive!


*************/