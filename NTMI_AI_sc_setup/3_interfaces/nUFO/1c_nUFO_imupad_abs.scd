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

// available influx modes:
NTMI.nUFO.influxModes = [\setRel, \setAbs];

// when loading, keep if already set, else default to setRel
NTMI.nUFO.influxMode = NTMI.nUFO.influxMode ? \setRel;
// same with
NTMI.nUFO.zoom = NTMI.nUFO.zoom ? 1;

// ///////////////////////////////////////////////////////////////
// //// I M U
// ///////////////////////////////////////////////////////////////


MKtl(\nUFO).collAt(\imu).action = {
	// trigger the action only once when array from imu comes in,
	// not several times for every input value
	MFdef(\nUFOImuFunc).value;
};

// set the first 9 values of the inphlux from the imu params:
NTMI.inphlux.addHalo(\imuNames, NTMI.inphlux.inNames.keep(9));

MFdef(\nUFOImuFunc).add(\makeCalibVals, {
	var imuInvalsBi = MKtl(\nUFO).elAt(\imu9).value.unibi;
	var calibImuValsBi = imuInvalsBi - NTMI.nUFO.zero.imu;
	NTMI.nUFO.rawImuBiValues = imuInvalsBi;
	NTMI.nUFO.calibImuValsBi = calibImuValsBi;
	NTMI.nUFO.calibImuVals = calibImuValsBi.biuni;
});

MFdef(\nUFOImuFunc).add(\setAbs, {
	var calibImuValsBi = NTMI.nUFO.calibImuValsBi;
	var indivZoom = NTMI.nUFO.zoom;
	var keysvals = NTMI.inphlux.getHalo(\imuNames).collect { |name, i|
		var value = calibImuValsBi[i];
		[name, value * indivZoom]
	}.flat;

	// "*** imufunc setAbs: ".post; keysvals.round(0.01).postln;
	NTMI.inphlux.set(*keysvals);
}, false);

MFdef(\nUFOImuFunc).add(\set, {
	if (NTMI.nUFO.debugOn) {
		"nUFOImuFunc - NTMI.nUFO.influxMode: %\n".postf(NTMI.nUFO.influxMode);
	};
	MFdef(\nUFOImuFunc).at(NTMI.nUFO.influxMode).value
});


/*
NTMI.nUFO.debugOn = true;
*/

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// Caps
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

(
MFdef(\capsToInph).orderedNames;

NTMI.inphlux.addHalo(\padNames, NTMI.inphlux.inNames.copyRange(9, 16));

MFdef(\capsToInph).add(\setAbs, {
	// var debug = "capsToInph setAbs".postln;
	var influx = NTMI.inphlux;
	var padVals = NTMI.nUFO.padVals;
	var padInNames = NTMI.inphlux.getHalo(\padNames);
	var indivZoom = NTMI.nUFO.zoom;
	var keysValues = padVals.collect { |padval, i|
		[ padInNames[i], padval * indivZoom]
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

MKtl(\nUFO).addHalo(\capLedThresh, 0.3);

NTMI.nUFO.capsin = MFunc();
MKtl(\nUFO).collAt('caps').action = NTMI.nUFO.capsin;


NTMI.nUFO.capsin.add(\set, { |elOrColl|
	// var debug =  "NTMI.nUFO.capsin set".postln;
	var capLedThresh = MKtl(\nUFO).getHalo(\capLedThresh);
	var rawPads = MKtl(\nUFO).elAt('cap').value;
	var calibPadVals;

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

	// this func gets called from collective caps when from nUFO,
	// and from indiv element when from GUI:
	if (elOrColl.isKindOf(MKtlElement)) {
		// if from single element, set all element values,
		// to get correct differences for relative modes
		MKtl(\nUFO).elAt('cap').do { |el, i| el.value_(rawPads[i]) };
	};

	///// trigger touch to inphlux only once ...
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

);

