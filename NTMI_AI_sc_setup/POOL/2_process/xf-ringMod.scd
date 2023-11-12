Ndef('xf-ringMod').addSpec(\oct, [-5, 5]);
Ndef('xf-ringMod').addSpec(\which, [-2, 2]);
Ndef('xf-ringMod').addSpec(\pow, [0.5, 8, \exp]);
Ndef('xf-ringMod').ar(q.numChans);

Ndef('xf-ringMod', { arg amp=0.1, oct=2, which=0, pow=1;
	var sines, p, hsf;
	var inChan=0;
	// var in = SoundIn.ar(inChan*amp);
	var in = q.liveInput.ar(1);
	p = Pitch.kr(in)[0];
	sines = q.numChans.collect{|i|
		var sins = SinOsc.ar(2**(oct) * (2 ** [-2, -1, 0, 1, 2]) * p, LFNoise1.kr(1, 20)).pow(pow);
		SelectXFocus.ar( (which+2), sins);
	};
	Limiter.ar(in * amp * sines)
});
