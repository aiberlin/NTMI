/***
gendy1 example patch:
use Gendy1 oscillator for modulation and synthesis.


ampdist, durdist have 7 possible distributions:
0:	LINEAR.
1:	CAUCHY.
2:	LOGIST.
3:	HYPERBCOS.
4:	ARCSINE.
5:	EXPON.
6:	SINUS.

Ndef(\gendy1).clear;

*/

Ndef(\gendy1).addSpec(\dist, [0, 7]);
Ndef(\gendy1).addSpec(\addd, [0.01, 0.9, \exp]);
Ndef(\gendy1).addSpec(\minfreq1, [1, 100, \exp]);
Ndef(\gendy1).addSpec(\maxfreq1, [1, 100, \exp]);
Ndef(\gendy1).addSpec(\minfreq2, [20, 2000, \exp]);
Ndef(\gendy1).addSpec(\maxfreq2, [20, 2000, \exp]);
Ndef(\gendy1).addSpec(\ascale, [0.001, 1, \exp]);
Ndef(\gendy1).addSpec(\dscale, [0.001, 1, \exp]);

Ndef(\gendy1, { |amp = 0, dist = 3, addd = 0.01,
	minfreq1 = 0.2, maxfreq1 = 20,
	minfreq2 = 20,  maxfreq2 = 2000,
	ascale = 1, dscale = 1|

	var n = q.numChans ? 2;
	var mods, snds;
	// var dist = Rand(0, 7); // choose new random distrib when running
	// var addd = exprand(0.001, 1); // choose new random distrib when running

	dist = dist.lag(1);
	addd = addd.lag(1);
	minfreq1 = minfreq1.lag(1);
	maxfreq1 = maxfreq1.lag(1);
	minfreq2 = minfreq2.lag(1);
	maxfreq2 = maxfreq2.lag(1);

	mods = Gendy1.kr(dist!n, dist, addd, addd,
		min(minfreq1, maxfreq1), max(minfreq1, maxfreq1),
		ascale.lag(1), dscale.lag(1)).exprange(0.001, 1);

	snds = Gendy1.ar(dist!n, dist, addd, addd,
		min(minfreq2, maxfreq2), max(minfreq2, maxfreq2),
		mods, mods);

	snds.sanitize * amp.lag(1);
});