// /*
// OSCFunc.trace;
// OSCFunc.trace (false);
// */
//

(
// use this dict for everything osc related
q.osc = q.osc ? ();

// xosc sends here:
thisProcess.openUDPPort(8000);
thisProcess.openPorts.postln;

// make xosc object
MKtl.all[\xosc].free;
MKtl(\xosc, "xosc*");


/// init all xosc actions as MFuncs, provide posting
MKtl(\xosc).elementsDict.do(_.action_(MFunc()));
MKtl(\xosc).elementsDict.do { |el| el.action.add(\post, { |el|
	[el.name, el.value.round(0.0001)].postln
}) };
MKtl(\xosc).elementsDict.do { |el| el.action.enable(\post) };
MKtl(\xosc).elementsDict.do { |el| el.action.disable(\post) };


// create elementgroups for imu and pads:
MKtl(\xosc).addNamed(\imu9, MKtlElementGroup(\imu9, x, MKtl(\xosc).elAt([0, 1, 2]).flat));
MKtl(\xosc).addNamed(\pads8, MKtlElementGroup(\pads8, x, MKtl(\xosc).elAt(\inA, (8..15))));
MKtl(\xosc).addNamed(\slots, MKtlElementGroup(\slots, x, MKtl(\xosc).elAt(\sw, (0..3))));
MKtl(\xosc).addNamed(\modSw, MKtl(\xosc).elAt(\sw, \5));
MKtl(\xosc).addNamed(\steps, MKtl(\xosc).elAt(\sw, [\6, \7]));

// init imu values to center, pads to bottom
MKtl(\xosc).elAt(\imu9).value_(0.5!9);
MKtl(\xosc).elAt(\pads8).valueAction_(0!8);

MKtl(\xosc).elAt(\slots).do { |sw, i| sw.elemDesc.label = "SND" + sw.keyInGroup };
MKtl(\xosc).elAt(\steps).do { |sw, i| sw.elemDesc.label = ["-DOWN", "+UP"]@i  };
MKtl(\xosc).elAt(\modSw).elemDesc.label_('touchMove');

// init zero values
q.zero = q.zero ? ();
q.zero.imu = 0!9;
q.zero.pads = 0!8;
q.osc.rawPads = (0!8);

// capture current zero position for imu and pads
MFdef(\ZERO).add(\set, {
	q.zero.imu = MKtl(\xosc).elAt(\imu9).value.unibi;
	q.zero.pads = q.osc.rawPads;
	"*** ZERO was set: ".postln;
	"imu: %\n".postf(q.zero.imu.round(0.001));
	"pads: %\n".postf(q.zero.imu.round(0.001));
});

/*
// get zero values while xosc is running:
MFdef(\ZERO).value;
*/

//  MKtl(\xosc).device.destination.hostname = "127.0.0.1";

/// try replacing destination ONLY if test send fails:
try { MKtl(\xosc).device.destination.sendMsg("tralala") } {
	"*** cannot send to: ".postln;
	MKtl(\xosc).device.destination.postcs;
	"... replacing MKtl(\xosc).device.destination.hostname_(\"localhost\");".postln;
	MKtl(\xosc).device.destination.hostname_("localhost");
};

"*** XOSC - FOR NOW, TURN XOSC RESPONDERS OFF, ONLY USE hand-written OSCdefs!".postln;

MKtl(\xosc).device.oscFuncDictionary.do(_.disable);


// battery values and display
q.osc.batSpec = [3.45, 3.85].asSpec; // observed min, max of battery voltage
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
		var elem = MKtl(\xosc).elAt('sw').at(index);
		if (elem.value != val) {
			// elem.postln;
			elem.valueAction_(val);
		}
	}
}, '/inputs/digital').permanent_(true);

// pullup hack - switches are 1 when open, 2 when pressed
MKtl(\xosc).elAt(\sw, (0..7)).do (_.valueAction_(1));


// prepare for modalization:
// left buttons set up modes for right side and <>
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

// the slot switches:
MKtl(\xosc).elAt(\sw, (0..3)).do { |but, i|
	but.action.add(\shift, { |but|
		// 0 is button pressed: prep mode
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

MKtl(\xosc).elAt(\sw, [\5, \6, \7]).do { |but, i|
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
MKtl(\xosc).elAt(\sw, \5).value_(0);
MFdef(\rightMode).(MKtl(\xosc).elAt(\sw, \5), { "def".postln }, { "shift".postln });
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

MKtl(\xosc).elAt(\sw, \5).action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value > 0) {
		MFdef(\rightMode).(bt,
			MFdef(\imuMode),
			{ |ndef|
				"% - choose rand preset...\n".postf(ndef);
				q.stepNdefPreInf( ndef, nil )
			}
		)
	};
});

/*
MFdef(\stepVol).(q.slots.actives[0]);
MFdef(\stepVol).(q.slots.actives[0], -1);
*/

MFdef(\stepVol).add(\step, { |ndef, step = 1|
	var stepsize = 0.05; // 20 steps from 0 to 1
	var ampspec = \amp.asSpec;
	ndef.vol = ampspec.map(ampspec.unmap(ndef.vol) + (step * stepsize))
});

MFdef(\stepSlotPres).add(\step, { |step = 1|
	var activeNdefs = q.inphlux.action.activeNames.collect(Ndef(_));
	activeNdefs.do { |nd, j|
		q.stepNdefPreInf( nd, step );
	};
});


MKtl(\xosc).elAt(\sw, [\6, \7]).do { |elem, index|
	elem.action.add(\modal, {|bt|
		var step = [1, -1]@index; // down, then up
		// 0 is press, 1 is release:
		// do modal action on release
		if (bt.value == 1) {
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

// ///////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////
// //// I M U
// ///////////////////////////////////////////////////////////////
// ///////////////////////////////////////////////////////////////

OSCdef(\imu, { |msg|
	var accel = msg.copyRange(1, 3);
	var gyro = msg.copyRange(4, 6);
	var magnet = msg.copyRange(7, 9);

	msg.postcs;
	//////////// FIXME: get proper minmax values
	//////////// for 'accel', 'gyro', 'magnet'!
	// just set all values, no action:
	MKtl(\xosc).elAt(\accel).deviceValue = accel * 0.06;
	MKtl(\xosc).elAt(\gyro).deviceValue = gyro * 4.8;
	MKtl(\xosc).elAt(\magnet).deviceValue = magnet * 9.6;

	// trigger the action only once (influx calc)
	MFdef(\imuFunc).value;

}, "/imu").permanent_(true);


// set the first 9 values of the inphlux from the imu params:
q.inphlux.addHalo(\imuNames, q.inphlux.inNames.keep(9));

MFdef(\imuFunc).add(\setInphlux, {
	var keysvals = q.inphlux.getHalo(\imuNames).collect { |name, i|
		var value = MKtl(\xosc).elAt(\imu9, i).value.unibi - q.zero.imu[i];
		[name, value]
	}.flat;
	// "*** imufunc: ".post; keysvals.round(0.0001).postln;
	q.inphlux.set(*keysvals);
});

// hack for xosc gui: all element actions trigger imuFunc!
MKtl(\xosc).elAt(['accel', 'gyro', 'magnet']).flat.do(_.action_(MFdef(\imuFunc)));

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
