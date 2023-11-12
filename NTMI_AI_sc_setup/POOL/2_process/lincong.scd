// Sound from Jonas, uses internal feedback and the LinCongN Chaotic Ugen


// specs
Ndef(\lincong).addSpec(\chaos, [1, 5, \exp]);
Ndef(\lincong).addSpec(\fbQ, [0.1, 2, 1]);
Ndef(\lincong).addSpec(\freq, [100, 1500, \exp]);

Ndef(\lincong, {|amp = 0.0, freq=567, chaos=2, fbQ=1.0|
	var src, kaos, local, soundIn, ampIn;
	local = LocalIn.ar(q.numChans);
	soundIn = SoundIn.ar(0);
	ampIn = Amplitude.kr(soundIn, mul:10);
	// use interpolating linCongC for wah-wah and more gliss
	kaos = LinCongN.ar(chaos**4,
		ampIn.linlin(0,1,0.9,1.9),
		0.001 + Ndef.ar(\lincong)*fbQ,
		1-local
		).linlin(-1,1,0,2);

	src = SinOsc.ar(freq*[kaos/2, kaos, kaos/4, kaos*2, kaos/10], 0, kaos/2);

	local = OnePole.ar(local, 0.4);
	local = OnePole.ar(local, -0.08);
	local = Rotate2.ar(local[0], local[1], 0.2);
	local = LeakDC.ar(local);
	local = (local + kaos);
	LocalOut.ar(local);

	Limiter.ar(Splay.ar(src.sum, 1, amp), 0.99);
});
