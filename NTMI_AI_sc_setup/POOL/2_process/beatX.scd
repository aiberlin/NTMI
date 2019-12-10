/*
// a beats Ndef Hannes 2019
// tweaked in Shanghai by HH: more bass lines, add hihat

Ndef(\beatX).document;

// compare that we have all the specs, except globals like \amp:
Ndef(\beatX).controlKeys
Ndef(\beatX).getSpec.keys

Ndef(\beatX).gui;
Ndef(\beatX).play;

*/


Ndef(\beatX).addSpec(\bpm, [12, 1200, \exp, 1]);
Ndef(\beatX).addSpec(\att, [0, 0.1, 5]);
Ndef(\beatX).addSpec(\dcy, [0.04, 0.5, 6]);
Ndef(\beatX).addSpec(\ffreq, [220, 4000, \exp, 1]);
Ndef(\beatX).addSpec(\reso, [1, 30, \exp]);
Ndef(\beatX).addSpec(\mod, [0, 3, 7]);
Ndef(\beatX).addSpec(\seqSel, [0,1, 0, 0.01]);
Ndef(\beatX).addSpec(\thresh, [0.1, 1]);
Ndef(\beatX).addSpec(\patt, [1, 18, 0, 1]);
Ndef(\beatX).addSpec(\ffreq2, [80, 400]);
Ndef(\beatX).addSpec(\volKick, \amp);
Ndef(\beatX).addSpec(\volSnare, \amp);
Ndef(\beatX).addSpec(\volHat, \amp);

// gobal for old NanoKtl
Spec.add(\bpm, [12, 1200, \exp, 1]);
Spec.add(\att, [0, 0.2, 5]);
Spec.add(\dcy, [0.01, 1, 5]);
Spec.add(\ffreq, \freq);
Spec.add(\reso, [1, 100, \exp]);
Spec.add(\mod, \amp);

(
// the Ndef iself
Ndef(\beatX, { arg amp=0, seqSel=0, att=0.002, dcy=0.05, ffreq=5000, reso=2, mod=0.2, patt=0, volKick=0.5, volSnare=0.5, volHat=0.5;
	var mix, snare, kick, hat;
	var metro = Impulse.ar(120*4/60); // pipe in global metro w' BPM changeable elsewhere!!
	var cnt = Stepper.ar(metro, 0, 0, 7);
	var hatPatt = [1, 0.5, 0.75, 0.5].cubed;
	var bassPatts = [
		[1, 0, 0, 1,   0, 0, 1, 0,    0, 1, 0, 0,    1, 0, 1, 0], // base
		[1, 0, 0, 1,   0, 0,1,0,      1, 0, 0, 1,    0, 0,1,0],   // half time tresillo
		[1, 0, 0, 1,   0, 0, 1, 0,    0, 1, 0, 1,    0, 0, 1, 0],
		[1, 0, 0, 1,   0, 0, 1, 0,    0, 1, 0, 0,    1, 0, 1, 0], // base again
		[1, 0, 1, 0,    1, 1, 0, 0,    0, 0, 0.6, 0,   1, 0, 0, 0],
		[1, 0, 1, 0,    1, 0, 0, 0.5,   1, 0, 0, 0,    0.5, 1, 0, 0]
	];
	var bassPatt = Select.kr((bassPatts.size * seqSel.clip(0,0.999)).floor, bassPatts);
	var bassseq = 	Dseq(bassPatt, inf);
	var downBeat = Decay2.ar(metro* Demand.ar(metro, 0, bassseq), att, dcy);

	var hatGate = Decay2.ar(metro * Demand.ar(metro, 0, Dseq(hatPatt, inf)), 0.01, dcy*1.8);
	var hats = BPF.ar(WhiteNoise.ar(hatGate * volHat), [6000, 9000, 11000], 0.07).sum.dup;

	var pattGate = ( Hasher.ar(cnt*patt).madd(pi).mod(1)); // patternizer
	var env = Decay2.ar(metro * pattGate, att.min(dcy*0.5), dcy);
	kick = 	Ringz.ar(downBeat * BrownNoise.ar(0.075 * volKick), 80, 0.5, 0.4).dup; // kick/bass.
	ffreq = ((mod * env + 1) * ffreq).fold(20, 20000);
	snare = RLPF.ar(GrayNoise.ar(env * volSnare), ffreq, reso.reciprocal); // snr/clap/melodiq

	mix = snare + kick + hats;
	Limiter.ar(mix, amp);
});
);

fork { s.sync; 0.1.wait; Ndef(\beatX).end };
Ndef(\beatX);
