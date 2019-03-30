(
// use this dict for everything osc related
q.osc = q.osc ? ();

thisProcess.openUDPPort(8000);
thisProcess.openPorts;

MKtl.all[\xosc].free;
x = MKtl(\xosc, "xosc*");

x.addNamed(\imu9, MKtlElementGroup(\imu9, x, x.elAt([0, 1, 2]).flat));
x.addNamed(\pads8, MKtlElementGroup(\pads8, x, x.elAt(\inA, (8..15))));
x.elAt(\imu9);
x.elAt(\pads8);


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

q.osc.batSpec = [3.45, 3.82].asSpec; // observed min,max of battery voltage
q.osc.batString = "battery ?";
q.osc.batval = 0;
q.osc.batPercent = 0;

////////////// get battery value:
OSCdef(\bat, { |msg, time|
	q.osc.oldbatval = q.osc.batval;
	q.osc.batval = msg[1];
	q.osc.batvaltime = time;
	q.osc.batPercent = (q.osc.batSpec.unmap(q.osc.batval ? 0) * 100).round(0.1);
	q.osc.batString = "bat: %V %%".format(q.osc.batval.round(0.01), q.osc.batPercent, $%);
}, "battery").permanent_(true);



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


/////////// // toggle play/stop on the 4 ndefs
////// orig backup
// x.elAt(\sw, (0..3)).do { | bt, i|
// 	bt.action.add(\toggle, {|bt|
// 		if (bt.value == 0) { q.slots.toggleAt(i) }
// 	});
// };

// modalized:
q.osc.leftDown = List[];
q.osc.rightDown = List[];
q.osc.shiftWasUsed = false;

/*
//////// to test left side actions:
q.osc.rightDown.clear.add(\preUp);
q.osc.rightDown.clear.add(\preDown);
q.osc.rightDown.clear.add(\touchMove);
q.osc.rightDown.clear;
*/

x.elAt(\sw, (0..3)).do { |but, i|
	but.action.add(\shift, { |but|
		// 0 is button pressed:
		if (but.value == 0) {
			q.osc.leftDown.add(but.name);
		} {
			// button was released: remove shifter
			q.osc.leftDown.remove(but.name);
			// q.osc.leftDown.postln;
		}
	});

	// on button release, do modal action:
	but.action.add(\modal, {
		var btval = but.value;
		var btnum = 1 + i;
		var btname = but.name;
		var actionFunc;

		[btname, btnum, btval].postln;

		if (btval > 0) {
			// determine whether we are in a mode
			if (q.osc.rightDown.size == 0) {
				// reset if we just left a mode
				if (q.osc.shiftWasUsed) {
					q.osc.shiftWasUsed = false
				} {
					// if no mode, do default action
					// " % default action: toggle\n".postf(btname);
					q.slots.toggleAt(i);
				}
			} {
				// right side has a mode - remember we used it now
				q.osc.shiftWasUsed = true;
				actionFunc = (
					preUp: {
						// "*** rshift 1 action: % NEXT ndef\n".postf(btname);
						q.slots.stepNext(i, 1);
					},
					preDown: {
						// "*** rshift 2 action: % PREV ndef\n".postf(btname);
						q.slots.stepNext(i, -1);
					},
					touchMove: {
						// "*** rshift 3 action: % RAND ndef\n".postf(btname);
						q.slots.chooseNext(i);
					},
				)[q.osc.rightDown.first];
				actionFunc.value;
			}
		}
	});
};

x.elAt(\sw, [\5, \6, \7]).do { |but, i|
	///////// order seems wrong, but posts right - why?
	var btname = [\touchMove, \preUp, \preDown][i];
	but.action.add(\shift, { |but|
		// 0 is button pressed:
		if (but.value == 0) {
			q.osc.rightDown.add(btname);
			// "rightdown: %\n".postf(q.osc.rightDown);
		} {
			// button was released: remove shifter
			q.osc.rightDown.remove(btname);
			// "rightdown: %\n".postf(q.osc.rightDown);
		}
	});
};

/*
q.osc.leftDown.clear.add(\sw_1);
q.osc.leftDown.clear.add(\sw_2);
q.osc.leftDown.clear;
x.elAt(\sw, \5).value_(0);
MFdef(\rightMode).(x.elAt(\sw, \5), { "def".postln }, { "shift".postln });
*/

// modal action for the right side buttons:
MFdef(\rightMode).add(\modal, { |but, defaultAction, shiftAction|
	var btval = but.value;
	var btname = (sw_5: \touchMove, sw_6: \preDown, sw_7: \preUp)[but.name];
	var leftButNames = [\sw_1, \sw_2, \sw_3, \sw_4];
	var slotIndex, player;
	if (q.osc.leftDown.size == 0) {
		// if we just left a mode, just reset
		if (q.osc.shiftWasUsed) {
			q.osc.shiftWasUsed = false
		} {
			// if we were not in any mode, do the default action
			// " % default action: \n".postf(btname);
			defaultAction.value;
		}
	} {
		// lest is held down, and right was pressed,
		// so now we are in shoft mode:
		q.osc.shiftWasUsed = true;
		slotIndex = leftButNames.indexOf(q.osc.leftDown.first);
		player = q.slots.actives[slotIndex];
		// " % shift action for slot %, % \n".postf(btname, slotIndex, player);
		shiftAction.value(player);
	};
});


// switch mode - analog in vs. IMU /// touch vs move mode
q.inph.modes = [\move, \touch];
q.inph.mode = \move;
q.inph.modeIndex = { q.inph.modes.indexOf(q.inph.mode) };

MFdef(\imuMode).add(\toggle, {
	if(  q.inph.mode == \move ) {
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
});

x.elAt(\sw, \5).action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value > 0) {

		MFdef(\rightMode).(bt,
			MFdef(\imuMode),
			{ |ndef|
				"% - choose rand preset...\n".postf(ndef);
				q.stepNdefPreInf( ndef, 10000.rand )
			}
		)
	};
});

/*
MFdef(\stepVol).(q.slots.actives[0]);
MFdef(\stepVol).(q.slots.actives[0], -1);
*/

MFdef(\stepVol).add(\step, { |ndef, step = 1|
	ndef.vol = (ndef.vol * step.dbamp).clip(0, 1);
});

MFdef(\stepSlotPres).add(\step, { |step = 1|
	var activeNdefs = q.inphlux.action.activeNames.collect(Ndef(_));
	activeNdefs.do { |nd, j|
		q.stepNdefPreInf( nd, step );
	};
});


x.elAt(\sw, [\6, \7]).do { |elem, index|
	elem.action.add(\modal, {|bt|
		var step = [1, -1]@index; // down, then up
		// do modal action on release
		if (bt.value == 0) {
			MFdef(\rightMode).(bt,
				{
					// reply to OSC device: which LED which Color!
					MFdef(\stepInphWPre).(step);
					MFdef(\stepSlotPres).(step);
				},
				{ |ndef| MFdef(\stepVol).(ndef, step) }
			)
		};
	})
};



/////////////// ORIG funcs for backup
// // switch thru the list of Influx weights
// x.elAt(\sw, [\6, \7]).do { |bt, i|
// 	bt.action.add(\front, {|bt|
// 		defer {
// 			if (bt.value <=0) {
// 				MFdef(\stepInphWPre).( [1, -1] @ i);
// 			}
// 		}
// 	});
// };
//
// x.elAt(\sw, [\6, \7]).do { |bt, i|
// 	bt.action.add(\preStep, {|bt|
// 		if (bt.value <=0) {
// 			var whichNdefs = q.inphlux.action.activeNames.collect(Ndef(_));
// 			whichNdefs.do { |nd, j|
// 				q.stepNdefPreInf( nd, [1, -1] @ i );
// 			};
// 		}
// 	});
// };


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

// permanent tweak factor???
q.inph.scale = 1;
q.inph.scale = 0.4;
q.inph.scale = 0.6;


MFdef(\imuFunc).add(\setInphlux, {
	var values = x.elAt(\accel).value.unibi ++ x.elAt(\gyro).value.unibi ++ x.elAt(\magnet).value.unibi;
	var names = q.inphlux.inNames;
	var keysvals = [names, values * q.inph.scale].flop.flat;
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
