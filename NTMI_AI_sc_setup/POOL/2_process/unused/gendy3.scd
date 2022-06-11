/***
WARNING:
**** Gendy3 is often goes into NaN-areas on macOS 12.4,
so we take it out for now. ****

gendy3 example patch:
use Gendy3 oscillator for modulation and synthesis,
Gendy3 forces pitch to the desired value, which is counter-xenakis.


ampdist, durdist have 7 possible distributions:
0:	LINEAR.
1:	CAUCHY.
2:	LOGIST.
3:	HYPERBCOS.
4:	ARCSINE.
5:	EXPON.
6:	SINUS.

Ndef(\gendy3).clear;
*/

Ndef(\gendy3).addSpec(\dist, [0, 7]);
Ndef(\gendy3).addSpec(\addd, [0.0001, 1, \exp]);
Ndef(\gendy3).addSpec(\minfreq, [2, 200, \exp]);
Ndef(\gendy3).addSpec(\maxfreq, [20, 1000, \exp]);
Ndef(\gendy3).addSpec(\ascale, [0.1, 2, \exp]);
Ndef(\gendy3).addSpec(\dscale, [0.1, 2, \exp]);

Ndef(\gendy3, { |amp = 0, dist = 3, addd = 0.01, minfreq = 30, maxfreq = 6000,
	ascale = 1, dscale = 1|
	var n = q.numChans ? 2;
	var freq = LFDNoise3.kr(minfreq * 0.01).exprange(minfreq, maxfreq);
	// var dist = Rand(0, 7); // choose new random distrib when running
	// var addd = exprand(0.001, 1); // choose new random distrib when running

	var mods = Gendy3.kr(dist!n, dist, addd, addd, freq * 0.1, ascale, dscale).exprange(0.001, 0.1);
	var snds = Gendy3.ar(dist!n, dist, addd, addd, freq, mods, mods);

	snds * amp.lag;
});