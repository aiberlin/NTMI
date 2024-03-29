// vivid noise synthesis,
// hh, cologne 2003-
// made MC 2019

Ndef(\kiteHi).addSpec(\ffreq, [-1000, 30000, \lin]);
Ndef(\kiteHi).addSpec(\move, [0.05, 40, \exp]);
Ndef(\kiteHi).addSpec(\hack, [1, 40, \exp]);
Ndef(\kiteHi).addSpec(\dustfreq, [0.20, 100000, \exp]);
Ndef(\kiteHi).addSpec(\width, [0.01, 1.0, \amp]);
Ndef(\kiteHi).addSpec(\lag, [0, 4.0, 5]);

Ndef(\kiteHi).addHalo(\stepDustfreq, { arg val; var curr;
	var nd = Ndef(\kiteHi);
	curr = nd.get(\dustfreq);
	"% - \stepDustfreq: ".postf(nd);
	curr = if (curr < 10000, { curr * 1.618 }, 0.2).postln;
	nd.set(\dustfreq, curr);
});

Ndef(\kiteHi).addHalo(\stepWidth, { arg val; var curr;
	var nd = Ndef(\kiteHi);
	curr = nd.get(\width);
	"% - \width: ".postf(nd);
	curr = if (curr < 1, { curr * 1.618 }, 0.01).postln;
	nd.set(\width, curr);
});

Ndef(\kiteHi, { arg amp=0, ffreq=12000, move = 0.2, hack=3, dustfreq=100, width=0.3, lag=0.25;
	var n=5;
	var snd = ({
		var in = LFClipNoise.ar(dustfreq.lag(lag),  LFPulse.ar( hack * Rand(0.5, 2), Rand(0, 2pi), width+Rand(-0.3, 0.4)) );
		Ringz.ar(in,
			ffreq.lag(lag) *  LFDNoise1.kr(move-0.05, 0.95, 1),
			1.25/hack
		)
	} ! n)
	.clump( q.numChans ).sum;

	(LPF.ar(snd, 400) + HPF.ar(snd, 400, 0.33)).softclip * (amp * 0.25).lag(0.03);
});
