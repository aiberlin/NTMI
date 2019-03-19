(
// use this dict for everything osc related
q.osc = q.osc ? ();

thisProcess.openUDPPort(8000);
thisProcess.openPorts;

MKtl.all[\xosc].free;
x = MKtl(\xosc, "xosc*");

//// q.guiXOSC = x.gui; // moved to gui section

//  x.device.destination.hostname = "127.0.0.1";

/// try replacing destination ONLY if test send fails:
try { x.device.destination.sendMsg("tralala") } {
	"*** cannot send to: ".postln;
	x.device.destination.postcs;
	"... replacing x.device.destination.hostname_(\"localhost\");".postln;
	x.device.destination.hostname_("localhost");
};

"*** XOSC - FOR NOW, TURN XOSC RESPONDERS OFF, ONLY USE hand-written OSCdefs!".postln;

x.device.oscFuncDictionary.do(_.disable);

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// DIGITAL INS
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

OSCdef(\xdig, { |msg|
	// msg.postln;
	msg.drop(1).do { |val, index|
		var elem = x.elAt('sw').at(index);
		if (elem.value != val) {
			// elem.postln;
			elem.valueAction_(val);
		}
	}
}, '/inputs/digital').permanent_(true);


x.elementsDict.do(_.action_(MFunc()));
x.elementsDict.do { |el| el.action.add(\post, { |el| [el.name, el.value].postln }) };
x.elementsDict.do { |el| el.action.enable(\post) };
x.elementsDict.do { |el| el.action.disable(\post) };

// pullup hack //
x.elAt(\sw, (0..7)).do (_.valueAction_(1));


// // switch one of 4 ndefs to front

x.elAt(\sw, (0..3)).do { | bt, i|
	bt.action.add(\front, {|bt|
		if (bt.value <= 0) {
			q.slots.playAt(i);
			x.elAt(\led)[i].value_(1/2);
		}{
			q.slots.stopAt(i);
			x.elAt(\led)[i].value_(0);
		}
	});
};

// switch mode - analog in vs. IMU /// touch vs move mode
q.inph.modes = [\move, \touch];
q.inph.mode = \move;
q.inph.modeIndex = { q.inph.modes.indexOf(q.inph.mode) };

x.elAt(\sw, \5).action.add(\front, {|bt|
	if (bt.value <=0) {
		if(  q.inph.mode == \move )
		{
			q.inph.mode = \touch;
			"*** enable TOUCH".postln;
			8.do { |i|	x.elAt('inA').at(i + 8).action.enable(\setInflux) };
			MFdef(\imuFunc).disable( \setInphlux );
			x.elAt(\led, \5).value_(0.0);

		}{
			q.inph.mode = \move;
			"*** enable MOVE (IMU) ".postln;
			8.do { |i|	x.elAt('inA').at(i + 8).action.disable(\setInflux) };
			MFdef(\imuFunc).enable( \setInphlux );
			x.elAt(\led, \5).value_(1/2);
		};
	}
});


// switch thru the list of Influx weights
x.elAt(\sw, [\6, \7]).do { |bt, i|
	bt.action.add(\front, {|bt|
		defer {
			if (bt.value <=0) {
				MFdef(\stepInphWPre).( [-1, 1] @ i);
				// reply to OSC device: which LED which Color!
			}
		}
	});
};

x.elAt(\sw, [\6, \7]).do { |bt, i|
	bt.action.add(\preStep, {|bt|
		if (bt.value <=0) {
			var whichNdefs = q.inphlux.action.activeNames.collect(Ndef(_));
			whichNdefs.do { |nd, j|
				q.stepNdefPreInf( nd, [-1, 1] @ i );
			};
		}
	});
};


// /*
// OSCFunc.trace;
// OSCFunc.trace (false);
// */
//
// ///////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////
// //// I M U
// ///////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////

OSCdef(\imu, { |msg|
	var accel = msg.copyRange(1, 3);
	var gyro = msg.copyRange(4, 6);
	var magnet = msg.copyRange(7, 9);
	x.elAt(\accel).deviceValue = accel * 0.1;
	x.elAt(\gyro).deviceValue = gyro * 8;
	x.elAt(\magnet).deviceValue = magnet * 2 * 8;
	// action that triggers
	MFdef(\imuFunc).value;
	//gyro.round(0.001).postln;
}, "/imu").permanent_(true);

q.inphscale = 1;
q.inphscale = 0.4;
q.inphscale = 0.6;


MFdef(\imuFunc).add(\setInphlux, {
	var values = x.elAt(\accel).value.unibi ++ x.elAt(\gyro).value.unibi ++ x.elAt(\magnet).value.unibi;
	var names = q.inphlux.inNames;
	var keysvals = [names, values * q.inphscale].flop.flat;
	q.inphlux.set(*keysvals);
});

// hack for xosc gui: all element actions trigger imuFunc!
x.elAt(['accel', 'gyro', 'magnet']).flat.do(_.action_(MFdef(\imuFunc)));

/*
MFdef(\imuFunc).disable( \setInphlux );
MFdef(\imuFunc).enable( \setInphlux );
*/


// for monitoring the incoming osc activity by timetag
q.osc.lastInTime = 0;
q.osc.timeSinceLast = { Main.elapsedTime - q.osc.lastInTime };
OSCdef(\imuAlive, { |msg, time|
	q.osc.lastInTime = time;
}, "/imu").permanent_(true);


// ///////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////
// //// ANALOG INS handled in 5_analogToInflux.scd
// ///////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////

);
