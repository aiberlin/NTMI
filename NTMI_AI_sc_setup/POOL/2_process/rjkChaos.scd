/*
rjkChaos.sc
@author Ron Kuivila, C. Ramakrishnan

A port of Ron Kuivila's "Homage to Toshi Ichiyanagi" patch from SC2 to SC3.
ported to JITLib style by HH, ca. 2015, turned quad/MC 2019

Ron's original comments:
DT phase shift/feedback network simulation
phase shifters and "formant shifting" (ring modulation of hipass and lopass filter outputs)

A little noise is used to activate the feedback.
The basic approach seems to be to get some feedback oscillation and then
destabilize it (so it is not a single tone) with the formant shifting, additional eq,
and changing the mix of different degrees of phase shift.

It is possible to filter the feedback path and then use the
formant shifting to 'recover' lost hi frequencies.

to play - start the basic patch and gradually increase 'rfbk'


q.numChans=4
q.numChans=2
*/

(
Ndef('rjkChaos', { arg amp = 0.1, in = 0.01, cutoff = 2000, phase1 = 2, phase2 = 2, phase3 = 2,
	p1Vol = 0, p2Vol = 0, p3Vol = 1, formant = 500, fbk = 0.9, rfbk = 0, qu = 1, rfq = 1;
	var fin = LocalIn.ar(q.numChans);
	var outs = q.numChans.collect({|i|
		var input, delayedSignal, p1,p2,p3, mixedSignal, inny, fout;

		input = BrownNoise.ar(in);
		delayedSignal = fin.wrapAt(i-1); // Cross Feedback
		p1 = RHPF.ar(delayedSignal, Lag.kr(phase1, 0.95), qu)
		+ RLPF.ar(delayedSignal, phase1, qu);
		p2 = RHPF.ar(p1, Lag.kr(phase2, 0.95), qu)
		+ RLPF.ar(delayedSignal, phase2, qu);
		p3 = RHPF.ar(p2, Lag.kr(phase3, 0.95), qu)
		+ RLPF.ar(delayedSignal, phase3, qu);
		delayedSignal = ((p1 * p1Vol) + (p2 * p2Vol) + (p3 * p3Vol));
		inny = (
			RLPF.ar(delayedSignal, formant, rfq)
			* LPF.ar(RHPF.ar(delayedSignal, formant, rfq) * Lag.kr(rfbk, 0.95), 7000)
		).distort
		+ ((delayedSignal * fbk).distort);
		delayedSignal = Compander.ar(inny.distort, inny, 0.4, 1, 0, 0.01, 0.01);
		delayedSignal = inny.distort;
		mixedSignal = RLPF.ar((delayedSignal) + input, 10000);
		fout = RLPF.ar(mixedSignal, cutoff, 0.5);
		[delayedSignal, fout];
	});
	LocalOut.ar(outs.flop.last);
	LeakDC.ar(outs.flop.first, mul: amp)
})
);

Ndef('rjkChaos').addSpec(\in, [0.000001, 1.0,\exp, 0, 0.01]);
Ndef('rjkChaos').addSpec(\cutoff, [2, 20000, \exp, 1, 2000]);
Ndef('rjkChaos').addSpec(\phase1, [2, 1000, \exp, 0, 2]);
Ndef('rjkChaos').addSpec(\phase2, [2, 1000, \exp, 0, 2]);
Ndef('rjkChaos').addSpec(\phase3, [2, 1000, \exp, 0, 2]);
Ndef('rjkChaos').addSpec(\p1Vol, [-1, 1, \lin, 0, 0]);
Ndef('rjkChaos').addSpec(\p2Vol,  [-1, 1, \lin, 0, 0]);
Ndef('rjkChaos').addSpec(\p3Vol,  [-1, 1, \lin, 0, 1]);
Ndef('rjkChaos').addSpec(\formant, [1, 8000, \exp, 1, 500]);
Ndef('rjkChaos').addSpec(\fbk, [0, 4, \lin, 0, 0.9]);
Ndef('rjkChaos').addSpec(\rfbk, [0, 4, \lin, 0, 0]);
Ndef('rjkChaos').addSpec(\qu, [0.001, 1, \lin, 0, 1]);
Ndef('rjkChaos').addSpec(\rfq, [0.001, 1, \lin, 0, 1]);
Ndef('rjkChaos').addSpec(\gain, [0.001, 2, \lin, 0, 1]);

fork { s.sync; 0.1.wait; Ndef('rjkChaos').end };

Ndef('rjkChaos');

//Ndef('rjkChaos').play(vol: 0.0);
/*(
NdefPreset(Ndef('rjkChaos'));
NdefPresetGui(NdefPreset(Ndef('rjkChaos')), 15);
NdefPreset(Ndef('rjkChaos')).setRand(0.75);
NdefPreset(Ndef('rjkChaos')).setRand(0.05);
)*/
