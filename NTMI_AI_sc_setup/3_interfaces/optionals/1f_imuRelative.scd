MFdef(\nUFOImuFunc).disable(\setAbs);

NTMI.zooms = NTMI.zooms ? ();
NTMI.zooms.nufo = NTMI.zooms.nufo ? 1;

/*
MKtl(\nUFO).collAt.imu.valueAction_(
	MKtl(\nUFO).collAt.imu.value.collect(_ + 0.05.rand2)
);
*/

MKtl(\nUFO).elAt(\imu9).value = 0.5;

MFdef(\nUFOImuFunc).add(\setRel, {
	var debug = "nUFOImuFunc setRel".postln;
	var imu = MKtl(\nUFO).elAt(\imu9);
	var diffs = imu.value - imu.prevValue;

	// NTMI.inphlux.getHalo(\imuNames);

	// for now, influence the playing slots
	NTMI.slots.nowPlaying.do { |ndef|
		// unless they are decoupled ?
		if (NTMI.inph.decoupled.includes(ndef.key).not) {
			// quick and dirty - check with processes,
			// some have non-influxable params
			var numParams = ndef.controlKeys.size;
			NTMI.inphlux.setRel(ndef,
				(0..numParams-1),
				diffs,
				NTMI.inphlux.inScaler
				* NTMI.zooms.nufo
			);
		};
	};
});

MFdef(\capsToInph).disable(\setAbs);

MFdef(\capsToInph).add(\setRel, {
	var debug = "capsToInph setRel".postln;
	var pads = MKtl(\nUFO).elAt(\cap);
	var diffs = pads.value - pads.prevValue;

	// for now, influence the playing slots
	NTMI.slots.nowPlaying.do { |ndef|
		// unless they are decoupled ?
		if (NTMI.inph.decoupled.includes(ndef.key).not) {
			// quick and dirty - check with processes,
			// some have non-influxable params
			var numParams = ndef.controlKeys.size;
			NTMI.inphlux.setRel(ndef,
				(0..numParams-1),
				diffs,
				NTMI.inphlux.inScaler
				* NTMI.zooms.nufo
			);
		};
	};
});
