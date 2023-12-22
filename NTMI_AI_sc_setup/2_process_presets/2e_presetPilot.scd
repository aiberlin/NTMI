Tdef(\presetPilot).addSpec(\preProb, [0, 1, 4.4]);
Tdef(\presetPilot).addSpec(\sndProb, [0, 1, 4.4]);

Tdef(\presetPilot).set(\preProb, 0.1);
Tdef(\presetPilot).set(\sndProb, 0.05);

Tdef(\presetPilot, { |e|
	inf.do { |i|
		1.wait;
		if (e.sndProb.coin) {
			var slot = NTMI.ndefs.size.rand;
			NTMI.slots.stepNext(slot);
			NTMI.slots.playAt(slot);
		};
		if (e.preProb.coin) {
			var ndef = NTMI.slots.nowPlaying.choose;
			var ndefpre = NdefPreset(ndef).postln;
			var nextpre = ndefpre.getSetNames.choose;
			ndefpre.xfadeTo(*[nextpre, exprand(3, 13).round(0.1)].postln);
		};
	};

});
