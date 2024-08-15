/////// all basic nUFO /ntmi things go here:
///////

/*
OSCFunc.trace(true, true);
OSCFunc.trace (false);
*/

// use this dict for everything nUFO related
NTMI.nUFO = NTMI.nUFO ? ();


// for monitoring incoming osc activity by timetag -
NTMI.nUFO.lastInTime = 0;
NTMI.nUFO.timeSinceLast = { Main.elapsedTime - NTMI.nUFO.lastInTime };
NTMI.nUFO.deviceName = '???';

// should play LED ballet every time we go from
// OSC silence to receiving stuff from nUFO

OSCdef(\xoscAlive, { |msg, time|
	if (NTMI.nUFO.lastInTime == 0 or: { NTMI.nUFO.timeSinceLast > 10 }) {
		Tdef(\allLEDs).play;
	};
	NTMI.nUFO.deviceName = \xosc;
	NTMI.nUFO.lastInTime = time;
}, "/imu").permanent_(true);

/*
// test wakeup ballet:
// if first time, or longer than 10 sec silence, do ballet
NetAddr.localAddr.sendMsg("/ntmi/imu", 0.0);
*/
NTMI.nUFO.timeOutTime = 3;
NTMI.nUFO.lastInTime = -100;
NTMI.nUFO.timedOut = false;

NTMI.nUFO.timeOut = {
	if (NTMI.nUFO.timedOut.not) {
		"NTMI.nUFO has timed out!".warn;
		NTMI.nUFO.timedOut = true;
		"// NTMI.nUFO.onTimeOut.value:".postln;
		NTMI.nUFO.onTimeOut.value.postln;
	};
};

NTMI.nUFO.alive = {
	Main.elapsedTime - NTMI.nUFO.lastInTime < 3;
};

OSCdef(\nUFOAlive, { |msg, time|
	// \nUFOAlive.postln;
	if (NTMI.nUFO.lastInTime == 0 or: { NTMI.nUFO.timeSinceLast > 10 }) {
		"*** OSCdef nUFOAlive triggers Tdef(\allLEDs).play;".postln;
		Tdef(\allLEDs).play;
	};
	NTMI.nUFO.deviceName = \nUFO;
	NTMI.nUFO.lastInTime = time;
}, "ntmi/imu").permanent_(true);


// init zero values
NTMI.nUFO.zero = NTMI.nUFO.zero ? ();
NTMI.nUFO.rawPads = (0!8);
NTMI.nUFO.rawImuBiValues = (0!9);

NTMI.nUFO.zero.imu = NTMI.nUFO.rawImuBiValues;
NTMI.nUFO.zero.pads = NTMI.nUFO.rawPads;

NTMI.nUFO.zero.path = NTMI.dir.user +/+ "zeroes.scd";

NTMI.nUFO.zero.write = {
	File.use(NTMI.nUFO.zero.path, "w", { |file|
		file.write("NTMI.nUFO.zero.imu =" +  NTMI.nUFO.zero.imu ++";\n");
		file.write("NTMI.nUFO.zero.pads =" +  NTMI.nUFO.zero.pads ++";\n");
		(NTMI.nUFO.zero.path + "written.").postln;
	})
};
NTMI.nUFO.zero.read = {
	try {
		NTMI.nUFO.zero.path.load;
		"NTMI.nUFO.zero - file read OK.".postln;
	} {
		"*** NTMI.nUFO.zero.read failed - please calibrate again."
	};
};

NTMI.nUFO.zero.read;

// read old zero values if there

// set the first 9 values of the inphlux from the imu params:
NTMI.inphlux.addHalo(\imuNames, NTMI.inphlux.inNames.keep(9));
NTMI.inphlux.addHalo(\padNames, NTMI.inphlux.inNames.drop(9));


NTMI.nUFO.setAbs = {
	NTMI.nUFO.influxMode = \setAbs;
	"*** NTMI.nUFO.influxMode is now setAbs!".postln;
};

NTMI.nUFO.setRel = {
	NTMI.nUFO.influxMode = \setRel;
	"*** NTMI.nUFO.influxMode is now setRel!".postln;
};

// initialize to abs if not set already before
if (NTMI.nUFO.influxMode == \setRel) {
	NTMI.nUFO.setRel
} {
	NTMI.nUFO.setAbs;
};
