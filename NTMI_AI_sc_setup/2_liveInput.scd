q=q?();
q.liveInput = NodeProxy(s, \audio, 1);

q.liveInput.source = { |inChanA=0, inAmpA=1, inChanB=1, inAmpB=0, threshG=0.01|
	var in = SoundIn.ar([inChanA, inChanB], [inAmpA, inAmpB]).sum;
	var amp = Amplitude.kr(in, 0, 2);
	in = (amp>threshG) * in;
	/* in = Compander.ar(
		in, in,
		threshG, 10, 1,
		0.0001, 0.6 //attG, decG
	) + BrownNoise.ar(0.00001).dup(q.numChans); // no bangs!*/
	Limiter.ar(in);
};

// q.liveInput.playN( (1..q.numChans)-1, vol: 0);

Spec.add(\inChanA, [0, 7, 0, 1]);
Spec.add(\inChanB, \inChanA.asSpec);
Spec.add(\inAmpA, [0, 8, \amp] );
Spec.add(\inAmpB, \inAmpA.asSpec);
Spec.add(\threshG, \amp.asSpec );

/*
q.liveInput.scope;
*/
