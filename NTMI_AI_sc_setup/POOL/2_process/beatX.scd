
/*
// Hannes example for writing Ndefs step by step

Ndef(\beatX).document;

// compare that we have all the specs, except globals like \amp:
Ndef(\beatX).controlKeys
Ndef(\beatX).getSpec.keys

Ndef(\beatX).edit(8);
Ndef(\beatX).play;

*/


Ndef(\beatX).addSpec(\bpm, [12, 1200, \exp, 1]);
Ndef(\beatX).addSpec(\att, [0, 0.2, 5]);
Ndef(\beatX).addSpec(\dcy, [0.04, 0.5, 5]);
Ndef(\beatX).addSpec(\ffreq, [70, 2000]);
Ndef(\beatX).addSpec(\reso, [1, 30, \exp]);
Ndef(\beatX).addSpec(\mod, \amp);
Ndef(\beatX).addSpec(\thresh, [0.1, 1]);
Ndef(\beatX).addSpec(\patt, [1, 8, 0, 1]);
Ndef(\beatX).addSpec(\ffreq2, [80, 400]);

// gobal for old NanoKtl
Spec.add(\bpm, [12, 1200, \exp, 1]);
Spec.add(\att, [0, 0.2, 5]);
Spec.add(\dcy, [0.01, 1, 5]);
Spec.add(\ffreq, \freq);
Spec.add(\reso, [1, 100, \exp]);
Spec.add(\mod, \amp);

(
// the Ndef iself
Ndef(\beatX, { arg amp=0, /*bpm=120, */att=0.002, dcy=0.05, ffreq=5000, reso=2, mod=0.2, patt=0;
	var metro = Impulse.ar(120*4/60); // pipe in global metro w' BPM changeable elsewhere!!
	var cnt = Stepper.ar(metro, 0, 0, 15);

	var bassseq = 	Dseq([1, 0, 0, 1,   0, 0, 1, 0,    0, 1, 0, 0,    1, 0,1,0], inf);
	var downBeat = Decay2.ar(metro* Demand.ar(metro, 0, bassseq), att, dcy);

	var pattGate = ( Hasher.ar(cnt*patt).madd(pi).mod(1)); // patternizer
	var env = Decay2.ar(metro, att, dcy) * pattGate.cubed;
	var sig = GrayNoise.ar(amp.dup);
	sig = env * sig;
	ffreq = ((mod*env+1) * ffreq).clip(20, 20000);
	sig = RLPF.ar(sig, ffreq, 1/reso)
	+
	Ringz.ar(downBeat * BrownNoise.ar(0.05), 80, 0.5, 0.4).dup;
	Limiter.ar(sig, amp);
});
);

fork { s.sync; 0.1.wait; Ndef(\beatX).end };
Ndef(\beatX);
