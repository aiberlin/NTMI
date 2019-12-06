/**** chanTest

to check output channels on a speaker setup, use:
- switchable PinkNoise out to first 8 channels
- loop over the 8 chans, task for auto-run

q.prefs.active.keys

************/

q.chantest = ();
Ndef(\pink, { |amp = 0.25, pan = -1|
	Pan2.ar(PinkNoise.ar(amp), pan)
});

q.chantest.pink = Ndef(\pink);
Ndef.dictFor(s).envir.removeAt(\pink);

/*
q.chantest.pink.play(0);
q.chantest.pink.play(1);
*/

q.chantest.task = TaskProxy();
q.chantest.task.source = { |envir|
	loop {
		(0..envir.max).do { |i|
			envir.dt.wait;
			"PINK outchan: ".post;
			q.chantest.pink.play(i.postln);
			defer { try {

				q.chantest.butz.do {|but, buti|
					var butval = (i == buti).binaryValue;
					but.value_(butval);
				}
			} }
		}
	}
};

q.chantest.task.addSpec(\dt, [0.25, 5, \exp, 0.05]);
q.chantest.task.set(\dt, 1);

q.chantest.task.addSpec(\max, [1, 7, \lin, 1]);
q.chantest.task.set(\dt, 1);
q.chantest.task.set(\max, 7);



