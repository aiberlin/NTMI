// if NTMI.helloSnd is not already defined in startup file, do this:
fork {
	NTMI.numChans.do { |i|
		{ LFDNoise3.ar(
			XLine.kr(
				exprand(2000, 5000),
				exprand(2000, 20000),
				0.25, doneAction: 2),
			0.1
		)
		}.play(outbus: i);
		0.25.wait;
	};
}
