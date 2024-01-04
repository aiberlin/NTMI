
// track nUFO activity - nUFO always sends imu.
NTMI.nUFO.frame = NTMI.nUFO.frame ? ();
NTMI.nUFO.frame.ring = Array.fill(100, 0);
NTMI.nUFO.frame.index = 0;
NTMI.nUFO.lastInTime = 0;
NTMI.nUFO.timeSinceLast = { Main.elapsedTime - NTMI.nUFO.lastInTime };


OSCdef(\imuAlive, { |msg, time|
	NTMI.nUFO.lastInTime = time;
	NTMI.nUFO.frame.ring.put(NTMI.nUFO.frame.index, Main.elapsedTime);
	NTMI.nUFO.frame.index = NTMI.nUFO.frame.index + 1 % NTMI.nUFO.frame.ring.size;
}, "/imu").permanent_(true);

/*
NTMI.nUFO.frame.rate
NTMI.nUFO.frame.rateStr
*/

// for monitoring the incoming osc activity by timetag
NTMI.nUFO.frame.rate = {
	var dict = NTMI.nUFO.frame;
	var now = Main.elapsedTime.postln;
	var newestIndex = dict.index - 1;
	var newestTime = dict.ring.wrapAt(newestIndex);
	var newestN = dict.ring.select { |time| now - time < 1 };
	newestN.size;
}

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
// when nUFO is connected:
NTMI.nUFO.calibrate;
// when no nUFO present:
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



// calc battery value when battery message comes in (every 5 sec)
MKtl(\nUFO).elAt(\battery).action = { |bat|
	NTMI.nUFO.bat.calc(bat.deviceValue);
};

// ntmi currently sends analog in values as int from 0-4095,
// above 4000 means charger is connected,
// usable range from maxval 3800 = quite full
// down to ca 3200 - network begins to drop out.

// this func is just for ntmi.

NTMI.nUFO.bat = (
	resetVals: { |bat|
		bat.putAll((
			string: "battery?",
			minval: 3200, // guessing, refine!
			maxval: 3800, // guessing, refine!
			totaltime: 180, // guessing, refine by testing
			intval: 0,
			percent: 0,
			remain: 0,
			lastTime: 0
		))
	}
);
NTMI.nUFO.bat.resetVals;

NTMI.nUFO.bat.calc = { |dict, intVal = 0|
	// keep startvals for estimate
	if (NTMI.nUFO.bat.time0.isNil) {
		NTMI.nUFO.bat.time0 = Main.elapsedTime;
		NTMI.nUFO.bat.intval0 = intVal;
	};

	NTMI.nUFO.bat.intval = intVal;
	NTMI.nUFO.bat.lastTime = Main.elapsedTime;
	NTMI.nUFO.bat.percent = intVal.linlin(NTMI.nUFO.bat.minval, NTMI.nUFO.bat.maxval, 0, 100).round(1);

	// calculate likely remaintime
	// conservative guess: known max time
	NTMI.nUFO.bat.remain = intVal.linlin(NTMI.nUFO.bat.minval, NTMI.nUFO.bat.maxval, 0, NTMI.nUFO.bat.totaltime).round(1).asInteger;

	// calculate average loss, use to predict remaining time. stabilizes after maybe 30 mins
	NTMI.nUFO.bat.avgLoss = NTMI.nUFO.bat.intval0 - NTMI.nUFO.bat.intval / (NTMI.nUFO.bat.lastTime - NTMI.nUFO.bat.time0).max(2);
	// NTMI.nUFO.bat.avgLoss;
	NTMI.nUFO.bat.predictedRemain = (NTMI.nUFO.bat.intval - NTMI.nUFO.bat.minval / NTMI.nUFO.bat.avgLoss.clip(0.01, 0.1) / 60);

	NTMI.nUFO.bat.string = "bat: %% %m".format(NTMI.nUFO.bat.percent, "%", NTMI.nUFO.bat.remain);
	NTMI.nUFO.bat.string
};
