/*******
Pulselet is a very simple variant of pulsar synthesis, adc 2021
+ Like Pulsar Generator, has fundamental freq and 3 pulse trains with form, amp, pan
+ uses Formlet resonator for sinewave with simple Decay2 envelope
+ new: random coinGate pulse reduction
+ new: spread introduces phase shift between pulse trains

Ndef(\pulselet).clear;
Ndef(\pulselet).gui;
Ndef(\pulselet).play;
*/

Ndef(\pulselet).addSpec(\fund, [1, 4000, \exp]);
Ndef(\pulselet).addSpec(\spread, \bipolar);
Ndef(\pulselet).addSpec(\coinDrop, [0, 2]);
Ndef(\pulselet).addSpec(\decay, [1, 16, \exp]);

Ndef(\pulselet).addSpec(\form1, [25, 10000, \exp]);
Ndef(\pulselet).addSpec(\form2, [25, 10000, \exp]);
Ndef(\pulselet).addSpec(\form3, [25, 10000, \exp]);

Ndef(\pulselet).addSpec(\amp1, \bipolar);
Ndef(\pulselet).addSpec(\amp2, \bipolar);
Ndef(\pulselet).addSpec(\amp3, \bipolar);
Ndef(\pulselet).addSpec(\pan1, \bipolar);
Ndef(\pulselet).addSpec(\pan2, \bipolar);
Ndef(\pulselet).addSpec(\pan3, \bipolar);


(
// modulating formant frequency
Ndef(\pulselet, { arg amp=0,
	fund=20, spread = 0, coinDrop = 1, decay = 4,
	form1 =  166.67, form2 = 500, form3 = 1500,
	amp1 = 0.33, amp2 = 0.33, amp3 = 0.33,
	pan1 = 0, pan2 = 0, pan3 = 0;
	// burst1, burst2, burstOn, spread;

	var formfreqs = [form1, form2, form3];
	var formtimes = 1/formfreqs;
	var trig = Impulse.ar(fund, (spread * ([0, 1, 2] / 3)));
	var trig2 = CoinGate.ar(coinDrop, trig);
	var formz = Formlet.ar(trig2, formfreqs, formtimes * decay * 0.1, formtimes * decay);
	var panz;
	// expand to multichans
	if (q.numChans ? 2 > 2) {
		panz = PanAz.ar(q.numChans, formz, [pan1, pan2, pan3], [amp1, amp2, amp3]);
	} {
		panz = Pan2.ar(formz, [pan1, pan2, pan3], [amp1, amp2, amp3])
	};
	//
	(panz.sum * amp.lag(0.1)).tanh;
});
);

