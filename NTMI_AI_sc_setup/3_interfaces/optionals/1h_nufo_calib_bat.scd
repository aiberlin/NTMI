
// calc battery value when battery message comes in:
MKtl(\nUFO).elAt(\battery).action = { |bat|
	NTMI.bat.calc(bat.deviceValue);
};

//////// calibrate imu and pads:
/*
// when nufo is connected:
NTMI.nufo.calibrate;
// when no nufo present:
NTMI.nufo.calibTest
*/

NTMI.nufo.calibTest = {
	// test calibrating with no device present
	fork {
		NTMI.nufo.calibrate;
		10.do {
			MFdef(\nUFOImuFunc).value;
			MFdef(\capsin).value;
			0.1.wait;
		};
	};
};

//////// capture incoming values for a while
//////// imu zero values by averaged
//////// pad zero values by maxes + average deviation/jitter
NTMI.nufo.calibrate = { |dict, dt = 1, whenDone|

	"*** calibrating nUFO ***".postln;
	NTMI.capture = ();

	NTMI.capture.imu = List[];
	NTMI.capture.pads = List[];

	MFdef(\nUFOImuFunc).add(\capture, {
		NTMI.capture.imu.add(NTMI.nufo.rawImuBiValues);
	});

	NTMI.nufo.capsin.add(\capture, {
		NTMI.capture.pads.add(NTMI.nufo.rawPads);
	});

	defer ({
		var padsflopped, padmeans, padmaxes, padjitters, padoffsets;
		var captureOK;
		MFdef(\nUFOImuFunc).remove(\capture);
		NTMI.nufo.capsin.remove(\capture);

		"*** nUFO calibration: ***".postln;
		captureOK = NTMI.capture.imu.size > 5
		and: { NTMI.capture.pads.size > 5 };
		if (captureOK.not) {
			"no values captured - calibration impossible.".postln;
		} {
			"NTMI.zero.imu = mean of % captured values:\n".postf( NTMI.capture.imu.size);
			NTMI.zero.imu = NTMI.capture.imu.mean;
			NTMI.zero.imu.round(0.001).postln;

			padsflopped = NTMI.capture.pads.flop;
			padmaxes = padsflopped.collect(_.maxItem);
			padmeans = padsflopped.collect(_.mean);
			padjitters = padsflopped.collect { |vals, i| (vals - padmeans[i]).abs.maxItem };

			"NTMI.zero.pads = maxes + 0.5 jitter of % captured values\n".postf( NTMI.capture.pads.size);
			NTMI.zero.pads = padmaxes + (padjitters * 0.5);
			NTMI.zero.pads.round(0.001).postln;
			NTMI.zero.write;
			"*** nUFO calibrated. ***".postln;
		};
		whenDone.value(captureOK);
	}, dt);
};

