// Reinhold Friedel special, HH 2022

// a Gendy Synth with filters
// adc: switched Gendy5 to gendy1 so we dont need SC3-plugins,
// and Gendy3 to gendy2 for stability (gendy3 is unstable on macOS

(
Ndef(\gendhy).addSpec(\minfreq, [1, 200, \exp]);
Ndef(\gendhy).addSpec(\maxfreq, [100, 1000, \lin]);
Ndef(\gendhy).addSpec(\ampdist, [0, 7]);
Ndef(\gendhy).addSpec(\durdist, [0, 7]);
Ndef(\gendhy).addSpec(\ampdistF, [0, 7]);
Ndef(\gendhy).addSpec(\durdistF, [0, 7]);
Ndef(\gendhy).addSpec(\filter, [0, 1, 6]);
Ndef(\gendhy).addSpec(\balance, [0, 1, -1]);
Ndef(\gendhy).addSpec(\rq1, [0.1, 2, \exp]);
Ndef(\gendhy).addSpec(\rq2, [0.2, 2, \lin]);

Ndef(\gendhy, { |amp=0.2
	minfreq=10, maxfreq=660,
	ampdist=7, durdist=0,
	ampdistF=0, durdistF=7,
	rq1=0.5, rq2=1, filter=0.5, balance=0
	|

	var ge = Gendy1.ar(
		ampdist ! q.numChans,
		durdist + [0, 3] % 7,
		minfreq:minfreq,
		maxfreq:[500, 750].reverse,
		mul:0.2*amp
	);
	var ge3 = Gendy2.ar(
		ampdist + [0, 2] % 7,
		durdist + [1, 5] % 7,
		mul:0.2*amp
	);
	var ffr = Gendy1.ar(
		ampdistF ! 2,
		durdistF,
		minfreq: 0.03, maxfreq:40
	).linexp(-1,1, 50, 5000);

	var in = blend(ge, ge3, balance);
	var filt =
	RLPF.ar(in, ffr[0], rq1)
	-
	RLPF.ar(in, ffr[1], rq2);

	blend(filt, in, 1-filter).tanh;
});

);