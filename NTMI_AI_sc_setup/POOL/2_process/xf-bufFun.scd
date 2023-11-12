Ndef('xf-bufFun').addSpec(\pitch1, [-36, 36, 0, 1/4]);
Ndef('xf-bufFun').addSpec(\pitch2, [-36, 36, 0, 1/4]);
Ndef('xf-bufFun').addSpec(\newLvl, [0.8, 1, \amp]);
Ndef('xf-bufFun').addSpec(\oldLvl, \amp);
Ndef('xf-bufFun').addSpec(\lag, [0.02, 5, \exp]);
Ndef('xf-bufFun').addSpec(\direct, \amp);
Ndef('xf-bufFun').addSpec(\secs, [0.1, 10, \exp]);
Ndef('xf-bufFun').addSpec(\flip, [0, 1, 0, 1]);
Ndef('xf-bufFun').addSpec(\freeze, [0, 1, 3, 1]);


Ndef('xf-bufFun', { arg amp=0.1, newLvl=1, oldLvl=0.1, secs=1, pitch1= -2, pitch2=1, flip=1, freeze=0, lag=1;
	var inChan=0, phaW, trans, env, sd, frams, bs, ot, usedframs, offs=0, phaR;
	var buf = LocalBuf.new(10  * 44100, 2);
//	var in = SoundIn.ar(inChan);
	var in = q.liveInput.ar(1);
	ClearBuf(buf);
	frams = BufFrames.ir(buf);
	usedframs = BufSampleRate.ir(buf) * secs.max(0.0001);
	phaW = Phasor.ar(0, BufRateScale.kr(buf) * K2A.ar(1-freeze.clip(0,1)), 0, usedframs);
	phaR = Phasor.ar(0,
		BufRateScale.kr(buf)
		* (flip).madd(2, -1)
		* [pitch1, pitch2].midiratio.lag2(lag) ,
		0, usedframs
	);
	sd = SampleDur.ir;
	bs = (SampleRate.ir / ControlRate.ir);

	ot = BufRd.ar(2, buf, 		// expands to twice stereo, thus:
		phaR % usedframs,
		1, 4
	) * [[1, 0.001], [0.001, 1 ]];
	ot = ot.sum;				// sum it up
	ot = Rotate2.ar(ot[0], ot[1], SinOsc.kr( (Amplitude.kr(in).squared * 2), 0, 3 ).wrap2(1) );

	BufWr.ar( in*newLvl.squared.min(1).lag(0.5)
		+ (ot * oldLvl.lag(0.7).cubed), buf, phaW); // loop rec into the buf
	ot * amp
});
