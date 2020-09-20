/////// all shared osc things between xosc and ntmi go here,
/////// yto avoid code duplication / overwriting
/*
OSCFunc.trace;
OSCFunc.trace (false);
*/

// use this dict for everything osc related
q.osc = q.osc ? ();


// for monitoring incoming osc activity by timetag -
q.osc.lastInTime = 0;
q.osc.timeSinceLast = { Main.elapsedTime - q.osc.lastInTime };
q.osc.timeSinceLast = { Main.elapsedTime - q.osc.lastInTime };
q.osc.deviceName = '???';

// should play LED ballet every time we go from
// OSC silence to receiving stuff from nufo

OSCdef(\xoscAlive, { |msg, time|
	if (q.osc.lastInTime == 0 or: { q.osc.timeSinceLast > 10 }) {
		Tdef(\allLEDs).play;
	};
	q.osc.deviceName = \xosc;
	q.osc.lastInTime = time;
}, "/imu").permanent_(true);

/*
// test wakeup ballet:
// if first time, or longer than 10 sec silence, do ballet
NetAddr.localAddr.sendMsg("/ntmi/imu", 0.0);
*/
OSCdef(\ntmiAlive, { |msg, time|
	// \ntmiAlive.postln;
	if (q.osc.lastInTime == 0 or: { q.osc.timeSinceLast > 10 }) {
		Tdef(\allLEDs).play;
	};
	q.osc.deviceName = \ntmi;
	q.osc.lastInTime = time;
}, "ntmi/imu").permanent_(true);


// init zero values
q.zero = q.zero ? ();
q.osc.rawPads = (0!8);
q.osc.rawImuBiValues = (0!9);

q.zero.imu = q.osc.rawImuBiValues;
q.zero.pads = q.osc.rawPads;

q.zero.path = Platform.userAppSupportDir +/+ "zeroes.scd";

q.zero.write = {
	File.use(q.zero.path, "w", { |file|
		file.write("q.zero.imu =" +  q.zero.imu ++";\n");
		file.write("q.zero.pads =" +  q.zero.pads ++";\n");
		(q.zero.path + "written.").postln;
	})
};
q.zero.read = { "reading zeroes file.".postln; q.zero.path.load };

// read old zero values if there
q.zero.read;

// set the first 9 values of the inphlux from the imu params:
q.inphlux.addHalo(\imuNames, q.inphlux.inNames.keep(9));
q.inphlux.addHalo(\padNames, q.inphlux.inNames.drop(9));
q.inphlux.addHalo(\capNames, q.inphlux.inNames.drop(9));


// // too simple capture for zero position for imu and pads
// /* // get zero values while xosc is running:
// MFdef(\ZERO).value;
// */
// MFdef(\ZERO).add(\set, {
// 	q.zero.imu = q.osc.rawImuBiValues;
// 	q.zero.pads = q.osc.rawPads;
// 	"*** ZERO was set: ".postln;
// 	"imu: %\n".postf(q.zero.imu.round(0.001));
// 	"pads: %\n".postf(q.zero.imu.round(0.001));
// 	q.zero.write;
// });


// xosc sends battery voltage as float in volts, usable range 3.2-4.1 volts

// ntmi currently sends analog in values as int from 0-4095,
// above 4000 means charger is connected,
// usable range from maxval 3800 = quite full
// down to ca 3200 - network begins to drop out.

// this func is just for ntmi.

q.bat = (
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
q.bat.resetVals;

MFdef('battery').add(\calc, { |intVal = 0|
	// keep startvals for estimate
	if (q.bat.time0.isNil) {
		q.bat.time0 = Main.elapsedTime;
		q.bat.intval0 = intVal;
	};

	q.bat.intval = intVal;
	q.bat.lastTime = Main.elapsedTime;
	q.bat.percent = intVal.linlin(q.bat.minval, q.bat.maxval, 0, 100).round(1);

	// calculate likely remaintime
	// conservative guess: known max time
	q.bat.remain = intVal.linlin(q.bat.minval, q.bat.maxval, 0, q.bat.totaltime).round(1).asInteger;

	// calculate average loss, use to predict remaining time. stabilizes after maybe 30 mins
	q.bat.avgLoss = q.bat.intval0 - q.bat.intval / (q.bat.lastTime - q.bat.time0).max(2);
	// q.bat.avgLoss;
	q.bat.predictedRemain = (q.bat.intval - q.bat.minval / q.bat.avgLoss.clip(0.01, 0.1) / 60);

	q.bat.string = "bat: %% %m".format(q.bat.percent, "%", q.bat.remain);
	q.bat.string
});

// switch modes - analog in vs. IMU /// touch vs move mode
// q.inph.modes = [\full, \move, \touch, \binary, \off];
q.inph.modes = [\full, \touch, \binary]; //
q.inph.modeIndex = 0;
q.inph.mode = { q.inph.modes.wrapAt(q.inph.modeIndex) };


/////// functions that switch the main modes components on/off:
// MFdef(\moveON).add(\info, { "move ON".postln });
// MFdef(\moveOFF).add(\info, { "move OFF".postln });
// MFdef(\touchON).add(\info, { "touch ON".postln });
// MFdef(\touchOFF).add(\info, { "touch OFF".postln });
// MFdef(\touchON).add(\info, { "binary ON".postln });
// MFdef(\touchOFF).add(\info, { "binary OFF".postln });


MFdef(\inphModeSetIndex).add(\set, { |modeIndex = 0|
	if (q.inph.modeIndex != modeIndex) {
		q.inph.modeIndex = modeIndex % q.inph.modes.size;
		"\n******* NEW MODE: % *****\n".postf(q.inph.mode);
		(
			move:  { MFdef(\moveON).value;  MFdef(\touchOFF).value; MFdef(\binOFF).value; },
			touch: { MFdef(\moveOFF).value; MFdef(\touchON).value; MFdef(\binOFF).value; },
			full:  { MFdef(\moveON).value;  MFdef(\touchON).value; MFdef(\binOFF).value; },
			binary: { MFdef(\moveOFF).value;  MFdef(\touchOFF).value; MFdef(\binON).value; },
			off: { MFdef(\moveOFF).value;  MFdef(\touchOFF).value; MFdef(\binOFF).value; },
		)[q.inph.mode].value;
	};
});

MFdef(\inphModeStep).add(\step, { |inc = 1|
	inc = inc ?? { 3.rand };
	MFdef(\inphModeSetIndex).value(q.inph.modeIndex + inc);
});

MFdef(\mainStepVol).add(\step, { |inc = 0|
	// for fast turns, accelerate changes:
	// 0.0 is linear, step1 -> 1, step 2 -> 2 etc
	// 1.0 is quadratic, step1 -> 1, step 2 -> 4 etc
	var acceleration = inc.abs ** 1.0;
	"mainVol % by %\n".postf([\down, \up].wrapAt(inc.clip(0, 1)), inc);
	RelSet(q.mFX.pxChain.proxy, \mainVol, inc * acceleration * 0.01);
});

MFdef(\stepVol).add(\step, { |ndef, step = 1|
	var acceleration = step.abs ** 1.0;
	var stepsize = 0.01; // 100 steps from 0 to 1
	var ampspec = \amp.asSpec;
	"% stepVol %\n".postf(ndef, step);
	ndef.vol = ampspec.map(ampspec.unmap(ndef.vol) + (step * acceleration * stepsize))
});

MFdef(\stepSlotPres).add(\step, { |step = 1|
	var activeNdefs = q.inphlux.action.activeNames.collect(Ndef(_));
	activeNdefs.do { |nd, j|
		q.pre.stepNdefInf( nd, step );
	};
});

