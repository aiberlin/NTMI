/////// all basic nufo /ntmi things go here:
///////

/*
OSCFunc.trace(true, true);
OSCFunc.trace (false);
*/

// use this dict for everything nufo related
NTMI.nufo = NTMI.nufo ? ();


// for monitoring incoming osc activity by timetag -
NTMI.nufo.lastInTime = 0;
NTMI.nufo.timeSinceLast = { Main.elapsedTime - NTMI.nufo.lastInTime };
NTMI.nufo.deviceName = '???';

// should play LED ballet every time we go from
// OSC silence to receiving stuff from nufo

OSCdef(\xoscAlive, { |msg, time|
	if (NTMI.nufo.lastInTime == 0 or: { NTMI.nufo.timeSinceLast > 10 }) {
		Tdef(\allLEDs).play;
	};
	NTMI.nufo.deviceName = \xosc;
	NTMI.nufo.lastInTime = time;
}, "/imu").permanent_(true);

/*
// test wakeup ballet:
// if first time, or longer than 10 sec silence, do ballet
NetAddr.localAddr.sendMsg("/ntmi/imu", 0.0);
*/
OSCdef(\nUFOAlive, { |msg, time|
	// \nUFOAlive.postln;
	if (NTMI.nufo.lastInTime == 0 or: { NTMI.nufo.timeSinceLast > 10 }) {
		Tdef(\allLEDs).play;
	};
	NTMI.nufo.deviceName = \nUFO;
	NTMI.nufo.lastInTime = time;
}, "ntmi/imu").permanent_(true);


// init zero values
NTMI.nufo.zero = NTMI.nufo.zero ? ();
NTMI.nufo.rawPads = (0!8);
NTMI.nufo.rawImuBiValues = (0!9);

NTMI.nufo.zero.imu = NTMI.nufo.rawImuBiValues;
NTMI.nufo.zero.pads = NTMI.nufo.rawPads;

NTMI.nufo.zero.path = NTMI.dir.user +/+ "zeroes.scd";

NTMI.nufo.zero.write = {
	File.use(NTMI.nufo.zero.path, "w", { |file|
		file.write("NTMI.nufo.zero.imu =" +  NTMI.nufo.zero.imu ++";\n");
		file.write("NTMI.nufo.zero.pads =" +  NTMI.nufo.zero.pads ++";\n");
		(NTMI.nufo.zero.path + "written.").postln;
	})
};
NTMI.nufo.zero.read = {
	try {
		NTMI.nufo.zero.path.load;
		"NTMI.nufo.zero - file read OK.".postln;
	} {
		"*** NTMI.nufo.zero.read failed - please calibrate again."
	};
};

NTMI.nufo.zero.read;

// read old zero values if there

// set the first 9 values of the inphlux from the imu params:
NTMI.inphlux.addHalo(\imuNames, NTMI.inphlux.inNames.keep(9));
NTMI.inphlux.addHalo(\padNames, NTMI.inphlux.inNames.drop(9));


// ntmi currently sends analog in values as int from 0-4095,
// above 4000 means charger is connected,
// usable range from maxval 3800 = quite full
// down to ca 3200 - network begins to drop out.

// this func is just for ntmi.

NTMI.nufo.bat = (
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
NTMI.nufo.bat.resetVals;

NTMI.nufo.bat.calc = { |dict, intVal = 0|
	// keep startvals for estimate
	if (NTMI.nufo.bat.time0.isNil) {
		NTMI.nufo.bat.time0 = Main.elapsedTime;
		NTMI.nufo.bat.intval0 = intVal;
	};

	NTMI.nufo.bat.intval = intVal;
	NTMI.nufo.bat.lastTime = Main.elapsedTime;
	NTMI.nufo.bat.percent = intVal.linlin(NTMI.nufo.bat.minval, NTMI.nufo.bat.maxval, 0, 100).round(1);

	// calculate likely remaintime
	// conservative guess: known max time
	NTMI.nufo.bat.remain = intVal.linlin(NTMI.nufo.bat.minval, NTMI.nufo.bat.maxval, 0, NTMI.nufo.bat.totaltime).round(1).asInteger;

	// calculate average loss, use to predict remaining time. stabilizes after maybe 30 mins
	NTMI.nufo.bat.avgLoss = NTMI.nufo.bat.intval0 - NTMI.nufo.bat.intval / (NTMI.nufo.bat.lastTime - NTMI.nufo.bat.time0).max(2);
	// NTMI.nufo.bat.avgLoss;
	NTMI.nufo.bat.predictedRemain = (NTMI.nufo.bat.intval - NTMI.nufo.bat.minval / NTMI.nufo.bat.avgLoss.clip(0.01, 0.1) / 60);

	NTMI.nufo.bat.string = "bat: %% %m".format(NTMI.nufo.bat.percent, "%", NTMI.nufo.bat.remain);
	NTMI.nufo.bat.string
};
