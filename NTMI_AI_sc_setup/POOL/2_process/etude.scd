

/*
// Hannes example for writing Ndefs step by step

Ndef(\etude).document;

// compare that we have all the specs, except globals like \amp:
Ndef(\etude).controlKeys
Ndef(\etude).getSpec.keys

Ndef(\etude).edit(8);
Ndef(\etude).play;

// gobal for old NanoKtl
Spec.add(\bpm, [12, 1200, \exp, 1]);
Spec.add(\att, [0, 0.2, 5]);
Spec.add(\dcy, [0.01, 1, 5]);
Spec.add(\ffreq, \freq);
Spec.add(\reso, [1, 100, \exp]);
Spec.add(\mod, \amp);

*/


Ndef(\etude).addSpec(\bpm, [12, 1200, \exp, 1]);
Ndef(\etude).addSpec(\att, [0, 0.2, 5]);
Ndef(\etude).addSpec(\dcy, [0.01, 1, 5]);
Ndef(\etude).addSpec(\ffreq, \freq);
Ndef(\etude).addSpec(\reso, [1, 100, \exp]);
Ndef(\etude).addSpec(\mod, \amp);

// gobal for old NanoKtl
Ndef(\etude).addSpec(\bpm, [12, 1200, \exp, 1]);
Ndef(\etude).addSpec(\att, [0, 0.2, 5]);
Ndef(\etude).addSpec(\dcy, [0.01, 1, 5]);
Ndef(\etude).addSpec(\ffreq, \freq);
Ndef(\etude).addSpec(\reso, [1, 100, \exp]);
Ndef(\etude).addSpec(\mod, \amp);


// the Ndef iself
Ndef(\etude, { arg amp=0, bpm=120, att=0.002, dcy=0.05, ffreq=5000, reso=2, mod=0.2;
	var metro = Impulse.ar(bpm/60);
	var env = Decay2.ar(metro, att, dcy);
	var sig = GrayNoise.ar(amp.dup);
	sig = env * sig;
	ffreq = ((mod*env+1) * ffreq).clip(20, 20000);
	sig = RLPF.ar(sig, ffreq, 1/reso);
	Limiter.ar(sig, amp);
});

fork { s.sync; 0.1.wait; Ndef(\etude).end };
Ndef(\etude);

