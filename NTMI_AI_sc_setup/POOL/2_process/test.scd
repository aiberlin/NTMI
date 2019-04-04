(
Ndef(\test, { |amp=0.1, freq=250, intv=19, timescale=1, curve=0, loopnode=0, formfact=2, widfact=0.5, spread=1|
		var env = EnvGen.kr(
			Env(
			{ Rand(-1,1.0) }!11,
			{ Rand(0, 1.0)}!10 * timescale,
				curve,
				releaseNode: 9,
				loopNode: loopnode)
		);
		var pitch = (env * [1, 0.33, -1] * intv).midiratio * freq;
		Splay.ar(
			Formant.ar(pitch, pitch.scramble * formfact, pitch.scramble * widfact), spread) * amp;
});
Ndef(\test).addSpec(\intv, [0, 36, \lin]);
Ndef(\test).addSpec(\timescale, [0.001, 10, \exp]);
Ndef(\test).addSpec(\curve, [-10, 10]);
Ndef(\test).addSpec(\loopnode, [0, 7, \lin, 1]);
Ndef(\test).addSpec(\formfact, [0.1, 10, \exp]);
Ndef(\test).addSpec(\widfact, [0.1, 10, \exp]);
Ndef(\test).addSpec(\spread, \unipolar);
);
//Ndef(\test).gui