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

OSCdef(\xoscAlive, { |msg, time|
	if (q.osc.lastInTime == 0) {
		Tdef(\allLEDs).play;
	};
	q.osc.lastInTime = time;
}, "/imu").permanent_(true);

OSCdef(\ntmiAlive, { |msg, time|
	if (q.osc.lastInTime == 0) {
		Tdef(\allLEDs).play;
	};
	q.osc.lastInTime = time;
}, "ntmi/imu").permanent_(true);


// init zero values
q.zero = q.zero ? ();
q.zero.imu = 0!9;
q.zero.pads = 0!8;
q.osc.rawPads = (0!8);
q.osc.rawImuBiValues = (0!9);

// set the first 9 values of the inphlux from the imu params:
q.inphlux.addHalo(\imuNames, q.inphlux.inNames.keep(9));
q.inphlux.addHalo(\padNames, q.inphlux.inNames.drop(9));
q.inphlux.addHalo(\capNames, q.inphlux.inNames.drop(9));


// capture current zero position for imu and pads
/* // get zero values while xosc is running:
MFdef(\ZERO).value;
*/

MFdef(\ZERO).add(\set, {
	q.zero.imu = q.rawImuBiValues;
	q.zero.pads = q.osc.rawPads;
	"*** ZERO was set: ".postln;
	"imu: %\n".postf(q.zero.imu.round(0.001));
	"pads: %\n".postf(q.zero.imu.round(0.001));
});

// battery values and display
// MKtl(\xosc).elAt(\battery).deviceSpec;
q.osc.batString = "? battery ?";
q.osc.batval = 0;
q.osc.batPercent = 0;

MFdef('battery').add(\calc, { |voltage = 0.0|
	q.osc.oldbatval = q.osc.batval;
	q.osc.batval = voltage;
	q.osc.batvaltime = Main.elapsedTime;
	q.osc.batPercent = ([3.2, 4.0].asSpec.unmap(voltage) * 100).round(0.1);
	q.osc.batString = "bat: %V %%".format(q.osc.batval.round(0.01), q.osc.batPercent, $%);
	q.osc.batString.postcln;
});

// switch mode - analog in vs. IMU /// touch vs move mode
q.inph.modes = [\move, \touch];
q.inph.mode = \move;
q.inph.modeIndex = { q.inph.modes.indexOf(q.inph.mode) };



MFdef(\imuMode).add(\toggle, {
	if(  q.inph.mode == \move ) {
		q.inph.mode = \touch;
		"*** enable TOUCH".postln;
		8.do { |i|	MKtl(\xosc).elAt('inA').at(i + 8).action.enable(\setInflux) };
		MFdef(\imuFunc).disable( \setInphlux );
		/////// pads set inphlux in unipolar, 0-1 range!
		q.inphlux.set(*q.inphlux.inNames.keep(9).collect([_, 0]).flat);
		MKtl(\xosc).elAt(\led, \5).value_(0.0);
	}{
		q.inph.mode = \move;
		"*** enable MOVE (IMU) ".postln;
		MKtl(\xosc).elAt('pads8').do { |pad| pad.action.disable(\setInflux) };
		q.inphlux.set(*q.inphlux.inNames.drop(9).collect([_, 0]).flat);
		MFdef(\imuFunc).enable( \setInphlux );
		MKtl(\xosc).elAt(\led, \5).value_(1/2);
	};
});



// switch modes - analog in vs. IMU /// touch vs move mode
q.inph.modes = [\move, \touch, \full];
q.inph.modeIndex = 0;
q.inph.mode = { q.inph.modes.wrapAt(q.inph.modeIndex) };


MFdef(\moveON).add(\info, { "move ON".postln });
MFdef(\moveOFF).add(\info, { "move OFF".postln });
MFdef(\touchON).add(\info, { "touch ON".postln });
MFdef(\touchOFF).add(\info, { "touch OFF".postln });

MFdef(\inphMode).add(\cycle, {
	q.inph.modeIndex = (q.inph.modeIndex + 1 % 3).postln; '';
	"\n******* NEW MODE: % *****\n".postf(q.inph.mode);
	(
		move:  { MFdef(\moveON).value;  MFdef(\touchOFF).value; },
		touch: { MFdef(\moveOFF).value; MFdef(\touchON).value; },
		full:  { MFdef(\moveON).value;  MFdef(\touchON).value; },
	)[q.inph.mode].value;
});

MFdef(\mastaStepVol).add(\step, { |inc=0|
	RelSet(q.mFX.pxChain.proxy, \mastaVol, inc * 0.01);
});

MFdef(\stepVol).add(\step, { |ndef, step = 1|
	var stepsize = 0.05; // 20 steps from 0 to 1
	var ampspec = \amp.asSpec;
	ndef.vol = ampspec.map(ampspec.unmap(ndef.vol) + (step * stepsize))
});

MFdef(\stepSlotPres).add(\step, { |step = 1|
	var activeNdefs = q.inphlux.action.activeNames.collect(Ndef(_));
	activeNdefs.do { |nd, j|
		q.pre.stepNdefInf( nd, step );
	};
});

