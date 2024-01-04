/***
IMU AND PADS can do absolute and relative influx:

// this switches them to absolute
NTMI.nUFO.setRel;
NTMI.nUFO.setAbs;

NTMI.nUFO.debugOn = false;
NTMI.nUFO.debugOn = true;


The main funcs of imu and pads use that name to look up which
function to run, see below.
***/

NTMI.nUFO.debugOn = false;

// keep if already set, else set to abs for now
NTMI.nUFO.influxMode = NTMI.nUFO.influxMode ? \setAbs;

// ///////////////////////////////////////////////////////////////
// //// I M U
// ///////////////////////////////////////////////////////////////


MKtl(\nUFO).collectivesDict[\imu].action = {
	// trigger the action only once (influx calc)
	MFdef(\nUFOImuFunc).value;
};

// set the first 9 values of the inphlux from the imu params:
NTMI.inphlux.addHalo(\imuNames, NTMI.inphlux.inNames.keep(9));


MFdef(\nUFOImuFunc).add(\setAbs, {
	var imuInvalsBi = MKtl(\nUFO).elAt(\imu9).value.unibi;
	var calibImuValsBi = imuInvalsBi - NTMI.nUFO.zero.imu;
	var keysvals = NTMI.inphlux.getHalo(\imuNames).collect { |name, i|
		var value = calibImuValsBi[i] * NTMI.nUFO.zoom;
		[name, value]
	}.flat;
	NTMI.nUFO.rawImuBiValues = imuInvalsBi;
	NTMI.nUFO.calibImuValsBi = calibImuValsBi;
	NTMI.nUFO.calibImuVals = calibImuValsBi.biuni;

	// "*** imufunc: ".post; keysvals.round(0.0001).postln;
	NTMI.inphlux.set(*keysvals);
}, false);

MFdef(\nUFOImuFunc).disable(\setAbs);

MFdef(\nUFOImuFunc).add(\set, {
	if (NTMI.nUFO.debugOn) {
		"nUFOImuFunc - NTMI.nUFO.influxMode: %\n".postf(NTMI.nUFO.influxMode);
	};
	MFdef(\nUFOImuFunc).at(NTMI.nUFO.influxMode).value
});


/*
MFdef(\nUFOImuFunc).disable( \setInflux );
MFdef(\nUFOImuFunc).enable( \setInflux );
*/

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// Caps
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

(

NTMI.inphlux.addHalo(\padNames, NTMI.inphlux.inNames.copyRange(9, 16));

MFdef(\capsToInph).add(\setAbs, {
	// var debug = "capsToInph setAbs".postln;
	var influx = NTMI.inphlux;
	var padVals = NTMI.nUFO.padVals;
	var padInNames = NTMI.inphlux.getHalo(\padNames);
	var keysValues = padVals.collect { |padval, i|
		[ padInNames[i], padval * NTMI.nUFO.zoom]
	}.flat;
	NTMI.inphlux.set(*keysValues);
});

MFdef(\capsToInph).disable(\setAbs);

MFdef(\capsToInph).add(\set, {
	if (NTMI.nUFO.debugOn) {
		"capsToInph  - NTMI.nUFO.influxMode: %\n".postf(NTMI.nUFO.influxMode);
	};
	MFdef(\capsToInph).at(NTMI.nUFO.influxMode).value
});


////// this is the action that gets triggered
////// when values come in from the ntmi -
////// coompensate for base values,
////// and send the final values only once.

MKtl(\nUFO).collAt('caps').groupAction = nil;

MKtl(\nUFO).addHalo(\capLedThresh, 0.3);

NTMI.nUFO.capsin = MFunc();
MKtl(\nUFO).collAt('caps').groupAction = NTMI.nUFO.capsin;


NTMI.nUFO.capsin.add(\set, { |coll|
	var capLedThresh = MKtl(\nUFO).getHalo(\capLedThresh);
	var rawPads = coll.value;
	var calibPadVals;

	// reorder for proper order of pads and leds
	rawPads = rawPads[[1, 4, 0, 3, 5, 6, 2, 7]];

	NTMI.nUFO.rawPads = rawPads;

	// NTMI.nUFO.zero.pads is the rest state of the pads
	// use it to stretch to a range of 0-1
	calibPadVals = rawPads.collect { |rawval, i|
		var zeroOffset = NTMI.nUFO.zero.pads.asArray.wrapAt(i) ? 0;
		var stretched = rawval.linlin(zeroOffset, 0.9, 0, 1);
		stretched;
	};
	// keep prev and new reordered and calibrated padVals here:
	NTMI.nUFO.prevPadVals = NTMI.nUFO.padVals;
	NTMI.nUFO.padVals = calibPadVals;

	// // set element values back to the compensated values, no action
	// MKtl(\nUFO).elAt('cap').value_(values);
	// trigger touch to inphlux only once ...
	MFdef(\capsToInph).value;

	// light up leds when pads are touched above thresh:
	fork {
		MKtl(\nUFO).elAt(\led, \fr).do { |led, i|
			var newval = (rawPads[i] > capLedThresh).binaryValue;
			if (newval != led.value) {
				led.value = newval;
				0.003.wait;
			}
		}
	}
});

NTMI.nUFO.setInfFromPad

// individual pad action - useful for guis only
/// do global set only once, from MFdef(\touchToInph)
MKtl(\nUFO).elAt(\cap).action = {
	// just trigger main nufo2influx func
};
);

