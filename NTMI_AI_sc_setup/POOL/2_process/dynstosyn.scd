// Sergio Luque, DSS patch with demand envgen
// adapted for NTMI by adc, 2022
// \Dynamic_Stochastic_Synthesis

// specifications for the GUI
Ndef(\dynstosyn).addSpec(\bpRatio, [ 0, 1, \lin, 0, 0.5 ]);
Ndef(\dynstosyn).addSpec(\freqA, [ 27.5, 2093, \exp, 0, 27.5 ]);
Ndef(\dynstosyn).addSpec(\freqB, [ 27.5, 2093, \exp, 0, 2093 ]);
Ndef(\dynstosyn).addSpec(\maxDurSt, [ 0, 1, \amp, 0, 0.1]);
Ndef(\dynstosyn).addSpec(\maxAmp, [ 0.1, 1, \exp, 0, 0.1 ]);
Ndef(\dynstosyn).addSpec(\maxAmSt, [ 0, 1, \amp, 0, 0.1]);

Ndef(\dynstosyn,
	{| amp = 0, bpRatio = 0.5, freqA = 27.5, freqB = 2093, maxDurSt = 0.1, maxAmp = 0.1, maxAmSt = 0.1 |
		var numBps, maxNumBps = 1603, freqs, maxDur, minDur, maxDurStep, maxAmpStep;

		freqs = [ min(freqA, freqB), max(freqA, freqB) ];
		maxDur = SampleRate.ir / freqs[0];
		minDur = SampleRate.ir / freqs[1];
		numBps = (minDur * bpRatio).trunc.clip(1, maxNumBps);
		maxDur = maxDur / numBps;
		minDur = minDur / numBps;
		maxDurStep = (maxDur - minDur) * maxDurSt;
		maxAmpStep = (maxAmp * 2) * maxAmSt;
		({
			DemandEnvGen.ar(
				Dswitch1(
					{ Dbrown(maxAmp.neg, maxAmp, maxAmpStep) } ! maxNumBps,
					Dseries(0, 1) % numBps
				),
				Dswitch1(
					{ Dbrown(minDur, maxDur, maxDurStep) } ! maxNumBps,
					Dseries(0, 1) % numBps
			) * SampleDur.ir)
		} ! q.numChans )
		* amp.lag(0.2);
});
