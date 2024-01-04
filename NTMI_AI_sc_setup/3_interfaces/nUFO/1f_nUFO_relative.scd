
/****

MKtl(\nUFO).elAt(\imu9, 0).valueAction = 0.6;

/*
MKtl(\nUFO).collAt.imu.valueAction_(
MKtl(\nUFO).collAt.imu.value.collect(_ + 0.05.rand2)
);
*/

MKtl(\nUFO).elAt(\imu9).valueAction = 0.5;
MKtl(\nUFO).elAt(\imu9).choose.action.funcDict.cs
MFdef(\nUFOImuFunc).activeNames;

MKtl(\nUFO).elAt(\imu9, 0).valueAction = 1.0.rand;

Tdef(\testImuRel, {
loop {
MKtl(\nUFO).collAt(\imu).valueAction =
MKtl(\nUFO).elAt(\imu9).value.collect { |val|
(val + 0.02.rand2).clip(0, 1)
};
0.03.wait;
}
}).play;

NTMI.nUFO.debugOn = true;
NTMI.nUFO.debugOn = false;

NTMI.nUFO.setRel;

***/

(
NTMI.nUFO.zoom = NTMI.nUFO.zoom ? 1;

MFdef(\nUFOImuFunc).add(\setRel, {
	var imu = MKtl(\nUFO).elAt(\imu9);
	var diffs = imu.value - imu.prevValue;

	if (NTMI.nUFO.debugOn) {
		// "nUFOImuFunc setRel- ".post;
		// "diff sum: ".post; diffs.sum.round(0.01).postln;
		// "abs sum: ".post; diffs.abs.sum.round(0.01).postln;
	};
	// set imu to current values so prevVals are now currvals,
	// and we dont get the same diffs multiple times.
	// imu.value = imu.value;

	MFdef(\setRelInf).(
		(0..diffs.size-1) + 8,
		diffs,
		NTMI.inphlux.inScaler * NTMI.nUFO.zoom
	);
}, false);
MFdef(\nUFOImuFunc).disable(\setRel);
);

(
/////
MFdef(\capsToInph).disable(\setRel);
MFdef(\capsToInph).disable(\setAbs);
MKtl(\nUFO).elAt(\cap).do { |pad| pad.action.disable(\setAbs) };

MKtl(\nUFO).elAt(\cap).action = { |el|
	if (NTMI.nUFO.debugOn) { "pad global action".postln };
	// value change should set all other indiv. elements,
	// so prevValues are correctly 0:

	MKtl(\nUFO).elAt(\cap).do { |el2|
		if (el2 != el) { el2.value = el2.value };
	};
	// then trigger global set had come in:
	MFdef(\capsToInph).value;
};

MFdef(\capsToInph).add(\setRel, {
	var diffs = NTMI.nUFO.padVals - NTMI.nUFO.prevPadVals;

	if (NTMI.nUFO.debugOn) {
		"capsToInph setRel - ".post;
		"diffs sum: ".post; diffs.sum.round(0.01).postln;
	};

	// influence the playing slots
	MFdef(\setRelInf).(
		(0..diffs.size-1), // no offset for pads
		diffs,
		NTMI.inphlux.inScaler * NTMI.nUFO.zoom
	);

}, false);

);