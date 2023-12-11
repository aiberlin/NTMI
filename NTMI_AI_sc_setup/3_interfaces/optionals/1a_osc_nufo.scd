/////// all shared osc things between xosc and ntmi go here,
/////// to avoid code duplication / overwriting
/*
OSCFunc.trace;
OSCFunc.trace (false);
*/

// use this dict for everything osc related
NTMI.nufo = NTMI.nufo ? ();


// for monitoring incoming osc activity by timetag -
NTMI.nufo.lastInTime = 0;
NTMI.nufo.timeSinceLast = { Main.elapsedTime - NTMI.nufo.lastInTime };
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
NTMI.zero = NTMI.zero ? ();
NTMI.nufo.rawPads = (0!8);
NTMI.nufo.rawImuBiValues = (0!9);

NTMI.zero.imu = NTMI.nufo.rawImuBiValues;
NTMI.zero.pads = NTMI.nufo.rawPads;

NTMI.zero.path = Platform.userAppSupportDir +/+ "zeroes.scd";

NTMI.zero.write = {
	File.use(NTMI.zero.path, "w", { |file|
		file.write("NTMI.zero.imu =" +  NTMI.zero.imu ++";\n");
		file.write("NTMI.zero.pads =" +  NTMI.zero.pads ++";\n");
		(NTMI.zero.path + "written.").postln;
	})
};
NTMI.zero.read = { "reading zeroes file.".postln; NTMI.zero.path.load };

// read old zero values if there
NTMI.zero.read;

// set the first 9 values of the inphlux from the imu params:
NTMI.inphlux.addHalo(\imuNames, NTMI.inphlux.inNames.keep(9));
NTMI.inphlux.addHalo(\padNames, NTMI.inphlux.inNames.drop(9));


// ntmi currently sends analog in values as int from 0-4095,
// above 4000 means charger is connected,
// usable range from maxval 3800 = quite full
// down to ca 3200 - network begins to drop out.

// this func is just for ntmi.

NTMI.bat = (
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
NTMI.bat.resetVals;

NTMI.bat.calc = { |dict, intVal = 0|
	// keep startvals for estimate
	if (NTMI.bat.time0.isNil) {
		NTMI.bat.time0 = Main.elapsedTime;
		NTMI.bat.intval0 = intVal;
	};

	NTMI.bat.intval = intVal;
	NTMI.bat.lastTime = Main.elapsedTime;
	NTMI.bat.percent = intVal.linlin(NTMI.bat.minval, NTMI.bat.maxval, 0, 100).round(1);

	// calculate likely remaintime
	// conservative guess: known max time
	NTMI.bat.remain = intVal.linlin(NTMI.bat.minval, NTMI.bat.maxval, 0, NTMI.bat.totaltime).round(1).asInteger;

	// calculate average loss, use to predict remaining time. stabilizes after maybe 30 mins
	NTMI.bat.avgLoss = NTMI.bat.intval0 - NTMI.bat.intval / (NTMI.bat.lastTime - NTMI.bat.time0).max(2);
	// NTMI.bat.avgLoss;
	NTMI.bat.predictedRemain = (NTMI.bat.intval - NTMI.bat.minval / NTMI.bat.avgLoss.clip(0.01, 0.1) / 60);

	NTMI.bat.string = "bat: %% %m".format(NTMI.bat.percent, "%", NTMI.bat.remain);
	NTMI.bat.string
};
