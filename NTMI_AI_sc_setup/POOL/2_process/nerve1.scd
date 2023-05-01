/*

FitzHugh-Nagumo model of firing nerve cells:
e.g.
8 nerve cells are connected in a ring fashion,
and each one plays its spikes into the next cell.
Audio input and pink noise can also influence into the cells.

// to load from outside NTMI package:
NdefPreset(\nerve1).storePath = "presets/nerve1.pxpreset.scd".resolveRelative;
NdefPreset(\nerve1).loadSettings;

NdefPresetGui(NdefPreset(\nerve1), 12);
Ndef(\nerve1).play;

*/

Spec.add(\rateU, [0.001, 0.2, \exp]);
Spec.add(\rateW, [0.001, 0.2, \exp]);
Spec.add(\b0, [0.1, 0.4]);
Spec.add(\b1, [0.1, 1.9]);
Spec.add(\minCFreq, [0.01, 0.5, \exp]);
Spec.add(\maxCFreq, [0.01, 0.5, \exp]);

Spec.add(\noisLevel, [0, 1, \amp]);
Spec.add(\feedLevel, [0, 1, \amp]);
Spec.add(\micLevel, [0, 1, \amp]);

Spec.add(\lag, [0.001, 100, \exp]);

Ndef(\nerve1, { |amp = 0, minCFreq = 0.021, maxCFreq = 0.089,
	rateU = 0.03, rateW = 0.03, b0 = 0.25, b1 = 1.0,
	feedLevel = 0, noisLevel = 0, micLevel = 0, lag = 0.02|

	var numNerves = 8; /// q.numNerves;

	 // single audio in chan for now
	var micIn = SoundIn.ar(0).asArray;
	var micVol = Amplitude.kr(micIn * 10, 0.0, 1.0).min(1);
	// convert to pulses
	var micPulses = (micIn.max(0) * (10 * micLevel.lag(lag))).wrapExtend(numNerves);
	// add multichannel noise for decorrelation
	var noise = (PinkNoise.kr(noisLevel.lag(lag) * 10 ! numNerves));

	// get nerve signals from last block, rotatr by 1 for spike chain
	var nervefeedback = LocalIn.ar(numNerves).rotate(1) * feedLevel.lag(lag);

	var feedSigs = (nervefeedback + noise + micPulses);
	var outSigs;

	var minFreq = SampleRate.ir * minCFreq.lag(lag);
	var maxFreq = SampleRate.ir * maxCFreq.lag(lag);

	var paramDrift = micLevel.linlin(0, 1, 1, 10)
	** LFDNoise3.kr([0.2, 0.3, 0.4, 0.5], micVol);
	// loud mic input makes model parameters drift
	rateU = (rateU.lag(lag) * paramDrift[0]).clip(0.001, 0.2);
	rateW = (rateW.lag(lag) * paramDrift[1]).clip(0.001, 0.2);
	b0 = 	(b0.lag(lag)	* paramDrift[2]).clip(0.1, 0.4);
	b1 = 	(b1.lag(lag)	* paramDrift[3]).clip(0.1, 1.9);


	outSigs = feedSigs.collect( { |feedsig, j|

		// the nerve cell
		Fhn2DC.ar(
			// make the running rates slightly varied
			minFreq * rrand(0.95, 1.05),
			maxFreq * rrand(0.95, 1.05),
			// common control parameters of all cells:
			rateU,
			rateW,
			b0,
			b1,
			feedsig
		).zap.tanh
		* (j % 2 * 2 - 1); // flip sign on every 2nd cell
	}).flat;

	// rausschreiben, damit als feedbacksignal wieder reinholbar
	LocalOut.ar(outSigs);

	outSigs = LeakDC.ar(outSigs, 0.999);
	// outSigs = Ringz.ar(outSigs, LFDNoise3.kr(0.03!numNerves).exprange(100, 1000), 0.03);
	//// auf multikanal mischen, lautstaerke runter
	// SplayAz.ar(q.numChans, outSigs.scramble.postln, 0.5, amp);
	//// auf stereo mischen, lautstaerke runter
	Splay.ar(outSigs.scramble, 1, amp);

});
