// ///////////////////////////////////////////////////////////////
// //// I M U
// ///////////////////////////////////////////////////////////////

MKtl(\nUFO).collectivesDict[\imu].action = {
	// trigger the action only once (influx calc)
	MFdef(\nUFOImuFunc).value;
};

// set the first 9 values of the inphlux from the imu params:
NTMI.inphlux.addHalo(\imuNames, NTMI.inphlux.inNames.keep(9));

NTMI.nufo.imuPadFuncName = \setAbs;

MFdef(\nUFOImuFunc).add(\setAbs, {
	var imuInvalsBi = MKtl(\nUFO).elAt(\imu9).value.unibi;
	var calibImuValsBi = imuInvalsBi - NTMI.nufo.zero.imu;
	var keysvals = NTMI.inphlux.getHalo(\imuNames).collect { |name, i|
		var value = calibImuValsBi[i];
		[name, value]
	}.flat;
	NTMI.nufo.rawImuBiValues = imuInvalsBi;
	NTMI.nufo.calibImuValsBi = calibImuValsBi;
	NTMI.nufo.calibImuVals = calibImuValsBi.biuni;

	// "*** imufunc: ".post; keysvals.round(0.0001).postln;
	NTMI.inphlux.set(*keysvals);
}, false);

MFdef(\nUFOImuFunc).disable(\setAbs);

MFdef(\nUFOImuFunc).add(\set, {
	// "nUFOImuFunc, set: %\n".postf(NTMI.nufo.imuPadFuncName);
	MFdef(\nUFOImuFunc).at(NTMI.nufo.imuPadFuncName).value
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
	var pads = MKtl(\nUFO).elAt(\cap);
	var padInNames = NTMI.inphlux.getHalo(\padNames);
	var keysValues = pads.collect { |pad, i|
		[ padInNames[i], pad.value]
	}.flat;
	NTMI.inphlux.set(*keysValues);
});

////// this is the action that gets triggered
////// when values come in from the ntmi -
////// coompensate for base values,
////// and send the final values only once.

MKtl(\nUFO).collAt('caps').groupAction = nil;

MKtl(\nUFO).addHalo(\capLedThresh, 0.3);

NTMI.nufo.capsin = MFunc();
MKtl(\nUFO).collAt('caps').groupAction = NTMI.nufo.capsin;


NTMI.nufo.capsin.add(\set, { |coll|
	var capLedThresh = MKtl(\nUFO).getHalo(\capLedThresh);
	var values = coll.value;

	// reorder for proper order of pads and leds
	values = values[[1, 4, 0, 3, 5, 6, 2, 7]];
	NTMI.nufo.rawPads = values;

	// NTMI.nufo.zero.pads is the rest state of the pads
	// use it to stretch to a range of 0-1
	values.do { |rawval, i|
		var zeroOffset = NTMI.nufo.zero.pads.asArray.wrapAt(i) ? 0;
		var stretched = rawval.linlin(zeroOffset, 0.9, 0, 1);
		values.put(i, stretched);
	};

	// set element values back to the compensated values, no action
	MKtl(\nUFO).elAt('cap').value_(values);
	// trigger touch to inphlux only once ...
	MFdef(\capsToInph).value;

	// light up leds when pads are touched above thresh:
	fork {
		MKtl(\nUFO).elAt(\led, \fr).do { |led, i|
			var newval = (values[i] > capLedThresh).binaryValue;
			if (newval != led.value) {
				led.value = newval;
				0.003.wait;
			}
		}
	}
});

// individual pad action - useful for guis only
/// do global set only once, from MFdef(\touchToInph)
MKtl(\nUFO).elAt(\cap).do { |pad, i|
	pad.action.add(\setAbs, {|ana|
		var name = 	NTMI.inphlux.getHalo(\padNames).clipAt(i);
		NTMI.inphlux.set(name, ana.value.pow(3));
		//.pow(6));
		// the pow(6) helps toflatten the steep curve of the FSRs as they are now.
		ana.value
	})
};
);

