// simple varsaw modulation network, adc&hh 2014
// maybe add kr/lofreq VarSaws as strobes on the output?

Ndef(\varsawFB).addSpec(\minFreq, [1, 20000, \exp]);
Ndef(\varsawFB).addSpec(\maxFreq, \widefreq);
Ndef(\varsawFB).addSpec(\width, [0.001, 0.999]);
Ndef(\varsawFB).addSpec(\lagFreq, [200, 20000, \exp]);
Ndef(\varsawFB).addSpec(\freqDev, [0, 1, \amp]);
Ndef(\varsawFB).addSpec(\freqRate, [0.01, 100, \exp]);
Ndef(\varsawFB).addSpec(\dens, [0.2, 1, 2]);

/*Spec.add(\minFreq, \widefreq);
Spec.add(\maxFreq, \widefreq);
Spec.add(\width, [0.001, 0.999]);
Spec.add(\lagFreq, [200, 20000, \exp]);
Spec.add(\freqDev, [0, 1, \amp]);
Spec.add(\freqRate, [0.01, 100, \exp]);
Spec.add(\dens, [0, 1, 2]);*/


// VarSaw, strobe variant:
(
Ndef(\varsawFB, { |amp = 0.25, width = 0.5,
	lagFreq = 1000, minFreq = 0.1, maxFreq = 10000,
	freqDev = 0.25, freqRate = 0.3, dens=0.9|
	// 8 VarSaws controlling each others frequencies
	var num = 13;
	var saws = [];
	var mod = LocalIn.ar(1);
	var freq = mod.exprange(minFreq, maxFreq);
	var ampcomp = AmpComp.kr(freq, 100).min(1) * amp;
	var strobe;
	width = (width * 2 - 1) ** 0.25 + 1 * 0.5;

	num.do { |i|
		var num1 = num - 1;
		var freqMod = (2 ** LFDNoise3.kr(freqRate, freqDev));
		var saw = VarSaw.ar(freq * freqMod, Rand(), width);
		// filter saw
		saw = saw.lag(1/lagFreq);
		saw = OnePole.ar(saw, 0.8 ** 1);
		mod = saw;
		saws = saws.add(saw);
	};
	LocalOut.ar(saws.last);
	strobe = LPF.ar(saws, 3).clump(q.numChans).sum.abs  < dens;
	LeakDC.ar(SplayAz.ar(q.numChans, saws) * strobe.lag(5/lagFreq, 10/lagFreq) * (ampcomp));
})
);

fork { s.sync; 0.1.wait; Ndef(\varsawFB).end };
Ndef(\varsawFB);


/*

Ndef(\varsawFB).gui;
Ndef(\varsawFB).play;

b.attachToButton(2, Ndef(\varsawFB));

*/
/* listening to \varsawFB: "Klatschen die alle?" - "nein, das klingt nur so" - "Und was klingt so wie grüne Augen, wie grünes Gras?" (JH)
*/