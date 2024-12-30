// GendyChor adapt from historic SC2 to SC3

// fixed setup params go to Tdef,
// modulatable params to Ndef,

// Tdef('envGendy1').set(\maxVoices, 6);
/*
Ndef(\gendyfyre).gui(14);
Ndef(\gendyfyre).play;
*/

// data to keep and mutate
q.gendy = q.gendy ? ();
q.gendy.maxSegs = 42;

q.gendy.levels = { 1.0.bilinrand }.dup(41);
q.gendy.times = { exprand(3, 300) }.dup(42);

/*
q.gendy.times = { 30 }.dup(42);
q.gendy.levels = ([1, -1] / (1..21)).flat.keep(41);

// debug
q.gendy.times.round(0.1).postln.plot;

*/

// a synthdef that plays one gendy segment

SynthDef('envGendy1', { |out, amp = 0.25, pan, curve = 0, numsegs = 42, timescale = 1, sustain = 0.1|
	var segGates = (numsegs - (1..q.gendy.maxSegs)).clip(0, 1);
	var levels = \levels.ir({ 1.0.bilinrand }.dup(q.gendy.maxSegs - 1)) * segGates.drop(1);
	var samps = \times.ir({ exprand(3, 300) }.dup(q.gendy.maxSegs)) * segGates;
	var cutoff = Env.cutoff(0.001).kr(2);
	var env = Env([0] ++ levels ++ [0], samps * (timescale / s.sampleRate), curve);
	OffsetOut.ar(out,
		Pan2.ar(EnvGen.ar(env, doneAction: 2), pan, amp)
	);
}).add;

/*
(instrument: 'envGendy1').play;
(instrument: 'envGendy1', numsegs: 42).play;
(instrument: 'envGendy1', numsegs: 21, pan: 1).play;
(instrument: 'envGendy1', timescale: exprand(0.3, 10), pan: 1.0.rand).play;
(instrument: 'envGendy1', amp: exprand(0.1, 1.0)).play;
(instrument: 'envGendy1', timescale: 10, curve: 8.0.rand2).play;

(instrument: 'envGendy1',
levels: [Array.rand2(42, 1.0)],
curve: 8.0.rand2).play;


*/
(
// Tdef(\gendyfyre, { |ev|
// 	"boom".postln;
// }).play;

Ndef(\gendyfyre).prime(Tdef(\gendyfyre));

// dummy so we own that bus, and have these storable param names
Ndef(\gendyfyre).put(5, { |amp=0,
	numsegs = 11.23, playprob = 1, curve = 0, ampdrift = 0.25,
	mintime = 10, maxtime = 100, timescale = 1, timedrift = 0.25
	// pandrift = 0.25
	|
	Silent.ar(2);
});

Ndef(\gendyfyre).supplementNodeMap;

Ndef(\gendyfyre).stop;


// s.latency = 0.1;

Ndef(\gendyfyre).addSpec(\numsegs, [8, 42, \exp]);
Ndef(\gendyfyre).addSpec(\playprob, [0, 1, -1]);
Ndef(\gendyfyre).addSpec(\curve, [-10, 10]);
Ndef(\gendyfyre).addSpec(\ampdrift, [0, 1, \amp]);
Ndef(\gendyfyre).addSpec(\mintime, [3, 300, \exp]);
Ndef(\gendyfyre).addSpec(\maxtime, [3, 300, \exp]);
Ndef(\gendyfyre).addSpec(\timescale, [0.25, 4, \exp]);
Ndef(\gendyfyre).addSpec(\timedrift, [0, 1, \amp]);
Ndef(\gendyfyre).addSpec(\pandrift, [0, 1, \amp]);

);

(
Tdef(\gendyfyre).quant = 0;
Tdef(\gendyfyre, { |ev|
	var levels, times, maxtime, mintime;
	var numsegs, numSamps, dur = 0.02, timespec;
	var ndef = Ndef(\gendyfyre);
	var mymap = ndef.nodeMap;

	"Tdef(\gendyfyre) starts".postln;

	ndef.play;
	ndef.set(\pan, 0);

	loop {
		// "gendyfier".postln;
		levels = q.gendy.levels;
		times = q.gendy.times;

		// mymap[\pan] = (mymap[\pan] + mymap[\pandrift].bilinrand).clip(-0.9, 0.9);

		levels.collectInPlace { |lev, i|
			(lev + mymap[\ampdrift].bilinrand).clip(-1, 1);
		};

		timespec = [mymap[\mintime], mymap[\maxtime]].sort.add(\exp).asSpec;
		times.collectInPlace { |lev, i|
			timespec.map(timespec.unmap(lev) + mymap[\timedrift].bilinrand)
		};
		numsegs = (mymap[\numsegs] + 1.0.rand).asInteger;
		numSamps = times.keep(numsegs).sum;
		dur = numSamps * (mymap[\timescale] / s.sampleRate);
		// mymap[\numSamps] = numSamps;
		mymap[\freq] = 1/dur;

		if (mymap[\playprob].coin) {
			[levels, levels.reverse].do { |mylevels, i|
				// Synth('envGendy1', [
				// 	levels: mylevels,
				// 	times: times,
				// 	timescale: mymap[\timescale],
				// 	pan: mymap[\pan],
				// 	numsegs: numsegs,
				// 	curve: mymap[\curve],
				// 	pan: mymap[\pan] + [-0.5, 0.5][i],
				// 	amp: mymap[\amp],
				// 	out: ndef.index
				// ]);
				(instrument: 'envGendy1',
					levels: [mylevels],
					times: [times],
					timescale: mymap[\timescale],
					pan: mymap[\pan],
					numsegs: numsegs,
					curve: mymap[\curve],
					pan: mymap[\pan] + [-0.5, 0.5][i],
					amp: mymap[\amp],
					out: ndef.index
				).play;
			}
		};

		max(dur, 0.001).wait;
	};
});
);

Ndef(\gendyfyre);