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
	var calibImuValsBi = imuInvalsBi - NTMI.zero.imu;
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