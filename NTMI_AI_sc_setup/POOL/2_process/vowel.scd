(
Ndef(\vowel, { | amp , freqDev= 1.02,ffreq = 176, distort = 2, fold=1.4, pan= 0.6 |

	var env, gen, uuu, lfmod, for, sig, bal, ruin, out;
	lfmod = { LFDNoise3.ar(XLine.kr(1, 6, 2), XLine.kr( 0.001, 1, 2, 4), 0.501) };
	uuu = Vowel(\u, \soprano) * distort.lag(1);
	for = Formants.ar( [ffreq.lag(0.4) * freqDev.reciprocal.lag(0.05), ffreq.lag(0.2) * freqDev.lag(0.2)] + lfmod, uuu, ampMods: 0.15) /** gen;*/;
	bal = Balance2.ar(for[0], for[1], pan);
	ruin = Clip.ar(bal, (-1* fold).lag(0.2), fold.lag(0.2)) ;
	sig = ruin * AmpComp.kr(ffreq.max(44));
	sig = LeakDC.ar(sig)*amp;
 //out = OffsetOut.ar(0, ruin)
});

//Ndef(\vowel).gui

Ndef(\vowel).addSpec(\distort, [0.01, 10, \exp]);
Ndef(\vowel).addSpec(\ffreq, [5, 100, \exp]);
Ndef(\vowel).addSpec(\freqDev, [0.1, 11, \exp]);
Ndef(\vowel).addSpec(\fold, [0.005, 1, \exp]);

);

fork { s.sync; 0.1.wait; Ndef(\vowel).end };
Ndef(\vowel);
