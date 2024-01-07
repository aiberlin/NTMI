
// calc battery value when battery message comes in:
MKtl(\nUFO).elAt(\battery).action = { |bat|
	NTMI.nUFO.bat.calc(bat.deviceValue);
};

//// calculate frame rate by incoming imu messages
MFdef(\nUFOImuFunc).add(\frame, {
	NTMI.nUFO.frame.ring.put(NTMI.nUFO.frame.index, Main.elapsedTime);
	NTMI.nUFO.frame.index = NTMI.nUFO.frame.index + 1 % NTMI.nUFO.frame.ring.size;
});

/*
NTMI.nUFO.frame.rate
NTMI.nUFO.frame.rateStr
*/

// for monitoring the incoming osc activity by timetag
NTMI.nUFO.lastInTime = 0;
NTMI.nUFO.timeSinceLast = { Main.elapsedTime - NTMI.nUFO.lastInTime };

OSCdef(\imuAlive, { |msg, time|
	NTMI.nUFO.lastInTime = time;
}, "/imu").permanent_(true);


NTMI.nUFO.frame = NTMI.nUFO.frame ? ();
NTMI.nUFO.frame.ring = Array.fill(100, 0);
NTMI.nUFO.frame.index = 0;
NTMI.nUFO.frame.rate = {
	var now = Main.elapsedTime;
	var newest = NTMI.nUFO.frame.ring.wrapAt(NTMI.nUFO.frame.index - 1);
	var oldest = NTMI.nUFO.frame.ring.at(NTMI.nUFO.frame.index);
	var frameRate =
	if (now - newest < 0.5) {
		NTMI.nUFO.frame.ring.size - 1 / (newest - oldest);
	} {
		// "// oops, dropout?".postln;
		NTMI.nUFO.frame.ring.size - 1 / (now - oldest);
	};
	// "old: % new: % avg: %\n".postf(*[oldest, newest, frameRate].round(0.001));
	frameRate
};
NTMI.nUFO.frame.rateStr = { "nUFO @ % fps".format(NTMI.nUFO.frame.rate.round(0.1)) };


//////// calibrate imu and pads:
/*
// when nufo is connected:
NTMI.nUFO.calibrate;
// when no nufo present:
NTMI.nUFO.calibTest
*/

NTMI.nUFO.calibTest = {
	// test calibrating with no device present
	fork {
		NTMI.nUFO.calibrate;
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
NTMI.nUFO.calibrate = { |dict, dt = 1, whenDone|

	"*** calibrating nUFO ***".postln;
	NTMI.capture = ();

	NTMI.capture.imu = List[];
	NTMI.capture.pads = List[];

	MFdef(\nUFOImuFunc).add(\capture, {
		NTMI.capture.imu.add(NTMI.nUFO.rawImuBiValues);
	});

	NTMI.nUFO.capsin.add(\capture, {
		NTMI.capture.pads.add(NTMI.nUFO.rawPads);
	});

	defer ({
		var padsflopped, padmeans, padmaxes, padjitters, padoffsets;
		var captureOK;
		MFdef(\nUFOImuFunc).remove(\capture);
		NTMI.nUFO.capsin.remove(\capture);

		"*** nUFO calibration: ***".postln;
		captureOK = NTMI.capture.imu.size > 5
		and: { NTMI.capture.pads.size > 5 };
		if (captureOK.not) {
			"no values captured - calibration impossible.".postln;
		} {
			"NTMI.nUFO.zero.imu = mean of % captured values:\n".postf( NTMI.capture.imu.size);
			NTMI.nUFO.zero.imu = NTMI.capture.imu.mean;
			NTMI.nUFO.zero.imu.round(0.001).postln;

			padsflopped = NTMI.capture.pads.flop;
			padmaxes = padsflopped.collect(_.maxItem);
			padmeans = padsflopped.collect(_.mean);
			padjitters = padsflopped.collect { |vals, i| (vals - padmeans[i]).abs.maxItem };

			"NTMI.nUFO.zero.pads = maxes + 0.5 jitter of % captured values\n"
			.postf( NTMI.capture.pads.size);
			NTMI.nUFO.zero.pads = padmaxes + (padjitters * 0.5);
			NTMI.nUFO.zero.pads.round(0.001).postln;
			NTMI.nUFO.zero.write;
			"*** nUFO calibrated. ***".postln;
		};
		whenDone.value(captureOK);
	}, dt);
};

