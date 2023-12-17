
// calc battery value when battery message comes in:
MKtl(\nUFO).elAt(\battery).action = { |bat|
	NTMI.nufo.bat.calc(bat.deviceValue);
};

//// calculate frame rate by incoming imu messages
MFdef(\nUFOImuFunc).add(\frame, {
	NTMI.nufo.frame.ring.put(NTMI.nufo.frame.index, Main.elapsedTime);
	NTMI.nufo.frame.index = NTMI.nufo.frame.index + 1 % NTMI.nufo.frame.ring.size;
});

/*
NTMI.nufo.frame.rate
NTMI.nufo.frame.rateStr
*/

// for monitoring the incoming osc activity by timetag
NTMI.nufo.lastInTime = 0;
NTMI.nufo.timeSinceLast = { Main.elapsedTime - NTMI.nufo.lastInTime };

OSCdef(\imuAlive, { |msg, time|
	NTMI.nufo.lastInTime = time;
}, "/imu").permanent_(true);


NTMI.nufo.frame = NTMI.nufo.frame ? ();
NTMI.nufo.frame.ring = Array.fill(100, 0);
NTMI.nufo.frame.index = 0;
NTMI.nufo.frame.rate = {
	var now = Main.elapsedTime;
	var newest = NTMI.nufo.frame.ring.wrapAt(NTMI.nufo.frame.index - 1);
	var oldest = NTMI.nufo.frame.ring.at(NTMI.nufo.frame.index);
	var frameRate =
	if (now - newest < 0.5) {
		NTMI.nufo.frame.ring.size - 1 / (newest - oldest);
	} {
		// "// oops, dropout?".postln;
		NTMI.nufo.frame.ring.size - 1 / (now - oldest);
	};
	// "old: % new: % avg: %\n".postf(*[oldest, newest, frameRate].round(0.001));
	frameRate
};
NTMI.nufo.frame.rateStr = { "nUFO @ % fps".format(NTMI.nufo.frame.rate.round(0.1)) };


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
			"NTMI.nufo.zero.imu = mean of % captured values:\n".postf( NTMI.capture.imu.size);
			NTMI.nufo.zero.imu = NTMI.capture.imu.mean;
			NTMI.nufo.zero.imu.round(0.001).postln;

			padsflopped = NTMI.capture.pads.flop;
			padmaxes = padsflopped.collect(_.maxItem);
			padmeans = padsflopped.collect(_.mean);
			padjitters = padsflopped.collect { |vals, i| (vals - padmeans[i]).abs.maxItem };

			"NTMI.nufo.zero.pads = maxes + 0.5 jitter of % captured values\n".postf( NTMI.capture.pads.size);
			NTMI.nufo.zero.pads = padmaxes + (padjitters * 0.5);
			NTMI.nufo.zero.pads.round(0.001).postln;
			NTMI.nufo.zero.write;
			"*** nUFO calibrated. ***".postln;
		};
		whenDone.value(captureOK);
	}, dt);
};

