/*

Concept by Shuoxin Tan & Joseph Baader
Implementation by Shuoxin Tan & Joseph Baader & Bruno Gola in 2024

*/

(
var maxDens = 40;
Ndef(\torus).addSpec(\stretch, [1, 600, \exp]);
Ndef(\torus).addSpec(\shift, [1, 3000, \exp]);
Ndef(\torus).addSpec(\trigRate, [0.7, 700, \exp]);
Ndef(\torus).addSpec(\att, [0.001, 3, \exp]);
Ndef(\torus).addSpec(\rel, [0.001, 3, \exp]);
Ndef(\torus).addSpec(\dens, [3, maxDens, \lin]);

Ndef(\torus, { arg amp = 0.5, dens = 6, trigRate=8, att=0.012, rel=0.024, stretch=342, shift=1300;
	var circle = maxDens.collect {|n| [cos(2pi*n/dens.floor), sin(2pi*n/dens.floor)]};
	var seq = [circle, circle].allTuples;
	var trig = Impulse.kr(trigRate); // rate of oscillating through the torus
	var indx = Stepper.kr(trig, 0, 0, (dens.floor.pow(2)-1));
	var env = EnvGen.ar(Env.perc(att, rel), trig);
	var frq = Select.kr(indx, seq);
	var sig = SinOsc.ar(2 + frq * stretch + shift + 50).sum * env;
	sig * amp;
})
);
