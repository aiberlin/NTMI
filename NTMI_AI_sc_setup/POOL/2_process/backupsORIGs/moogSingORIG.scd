// classic subtractive synthesis
// hh & adc, beijing 2005
/*
// the vintage original from '05
(
Ndef(\moogSing, { arg amp=0, moogRoot=24, lpRatio=36, lfDepth=24, lfSpeed=0.35, reso=0.2;
	var in;
	in = LFSaw.ar(
		(moogRoot.round(1).lag(0.05) + LFDNoise3.kr(lfSpeed, [0, 0.1, -0.162])).midicps,
		0, 0.3).sum;

	(Limiter.ar(RLPF.ar(
		in,
		(moogRoot.midicps *
		(	lpRatio.lag(0.5) +
			LFDNoise3.kr(lfSpeed ! 2, lfDepth*[-0.26 , 0.382,  -0.62, 1].lag(0.2))
		).midiratio).clip(20, 17000), (1/reso).lag(0.1), 0.6
	).clump(2).sum, 0.7) * (amp * 2)).softclip;
});
);
// some strobing
Ndef(\moogSing)[5] = \filter -> { arg in, speed = 4, dense = 0.3;
	var num = 8;
	var multipliers = { IRand(1, 5) + ExpRand(0.99, 1.01) }!num;
	var hack = LFPulse.ar(speed * multipliers, 0, dense);
	hack.clump(2).product.lag(1/2000, 1/speed) * in;
};
*/
// rewrite with internal Multichannel Strobing, hh'14:
(
Ndef(\moogSing, { arg amp=0, moogRoot=24, lpRatio=36, lfDepth=24, lfSpeed=0.35, reso=0.2, strobe = 4, dense = 0.3;
	var in, bunz;
//	var multipliers = { IRand(1, 5) + ExpRand(0.99, 1.01) }!num;
	var multipliers = {|i| i+1%5 + ExpRand(0.99, 1.01) }! 8;
	var hack = LFPulse.ar(strobe * multipliers, 0, dense);

	in = LFSaw.ar(
		(moogRoot.round(1).lag(0.05) + LFDNoise3.kr(lfSpeed, [0, 0.1, -0.162])).midicps,
		0, 0.3).sum;


	bunz = in * hack.clump(4).product.lag(1/2000, 0.2/strobe);
	bunz = RLPF.ar(
		bunz,
		( moogRoot.midicps *
		( lpRatio.lag(0.5) +
			LFDNoise3.kr(lfSpeed ! 2, lfDepth*[-0.26 , 0.382,  -0.62, 1].lag(0.2))
		).midiratio).clip(20, 17000),
		(1/reso).lag(0.1),
		0.6
	);



	(Limiter.ar(bunz.clump(q.numChans).sum, 0.7) * (amp * 2))
	.softclip.wrapExtend(q.numChans);
});
);

Ndef(\moogSing).addSpec(\lpRatio, [12, 60, \lin]);
Ndef(\moogSing).addSpec(\moogRoot, [10, 40, \lin, 0.5]);
Ndef(\moogSing).addSpec(\lfDepth, [0.5, 48, \amp]);
Ndef(\moogSing).addSpec(\lfSpeed, [0.01, 10, \exp]);
Ndef(\moogSing).addSpec(\reso, [1, 100, \exp]);
Ndef(\moogSing).addSpec(\wet5, [0, 1]);
Ndef(\moogSing).addSpec(\dense, [0, 0.9999, -2]);
Ndef(\moogSing).addSpec(\strobe, [0.2, 10, \exp]);


// extra functions as used in old GamePad:
// use a button to step thru increasing lfSpeed and \reso,
// wraps down to very low when too high.

Ndef(\moogSing).addHalo(\stepLfSpeed, { arg val; var curr;
	"moogsing - \stepLfSpeed: ".post;
	curr = Ndef(\moogSing).get(\lfSpeed);
	curr = if (curr < 10, { curr * 1.618 }, 0.01).postln;
	Ndef(\moogSing).set(\lfSpeed, curr)
});

Ndef(\moogSing).addHalo(\stepReso, { arg val; var curr;
	"moogsing - \stepReso: ".post;
	curr = Ndef(\moogSing).get(\reso);
	curr = if (curr < 100, { curr * 1.618 }, 1).postln;
	Ndef(\moogSing).set(\reso, curr);
});

// could add Scales here, for sure...
Ndef(\moogSing).addHalo(\stepFreq, { arg val; var curr;
	"moogsing - \stepFreq: ".post;
	curr = Ndef(\moogSing).get(\moogRoot);
	curr = if (curr < 40, { curr + [2, -2, 3, -3, 7, -7].choose }, curr-12).postln;
	if (curr < 5) { curr = curr+12};
	Ndef(\moogSing).set(\moogRoot, curr);
});

Ndef(\moogSing);
