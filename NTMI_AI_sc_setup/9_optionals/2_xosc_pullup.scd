///////// xosc support for first batch of NTMI prototypes
/*
MKtl(\xosc).gui;

left buttons:
- toggle sound slot on/off
- if preUp/Down held, next sound
- hold left, press

preUp/Down:
- next inphlux preset
- if left slot button held, volume up/down

zoom - just zoom

on NTMI_xosc1, touch/Move but is dead!

*/

(

q.osc = q.osc ? ();
q.osc.xosc = q.osc.xosc ? ();

// xosc sends here:
thisProcess.openUDPPort(8000);
thisProcess.openPorts.postln;



// make xosc object
MKtl.all[\xosc].free;
MKtl(\xosc, "*x-osc");

/// init all xosc actions as MFuncs, provide posting
MKtl(\xosc).elementsDict.do(_.action_(MFunc()));
MKtl(\xosc).elementsDict.do { |el| el.action.add(\post, { |el|
	[el.name, el.value.round(0.0001)].postln
}) };
MKtl(\xosc).elementsDict.do { |el| el.action.enable(\post) };
MKtl(\xosc).elementsDict.do { |el| el.action.disable(\post) };

// on the collective input of the switches:
// trigger the individual action on the button whose state has changed;
// dont use doAction, because that triggers all group actions -> loop
MKtl(\xosc).collAt(\dIn).action = { |coll|
	// coll.value.postln;
	coll.do { |bt|
		if (bt.value != bt.prevValue) {
			// [ bt.name, bt.value, bt.prevValue].postln;
			bt.action.value(bt);
		};
	};
};


// create elementgroups for imu and pads:
MKtl(\xosc).addNamed(\imu9, MKtl(\xosc).elAt([0, 1, 2]).flat);
MKtl(\xosc).addNamed(\pads8, MKtl(\xosc).elAt(\inA, (8..15)));

/// and for switches:
////////// NOT WORKING - rename inD to \sw, for clarity
////// MKtl(\xosc).addNamed(\sw, MKtl(\xosc).elAt(\inD).asArray);
MKtl(\xosc).addNamed(\slots, MKtl(\xosc).elAt(\inD, (0..3)));
MKtl(\xosc).addNamed(\modSw, MKtl(\xosc).elAt(\inD, \5));
MKtl(\xosc).addNamed(\steps, MKtl(\xosc).elAt(\inD, [\6, \7]));

MKtl(\xosc).elAt(\slots);
// init imu values to center, pads to bottom
MKtl(\xosc).elAt(\imu9).value_(0.5!9);
MKtl(\xosc).elAt(\pads8).valueAction_(0!8);

MKtl(\xosc).elAt(\slots).do { |sw, i| sw.elemDesc.label = "SND" + sw.keyInGroup };
MKtl(\xosc).elAt(\steps).do { |sw, i| sw.elemDesc.label = ["-DOWN", "+UP"]@i  };
MKtl(\xosc).elAt(\modSw).elemDesc.label_('touchMove');


////////////// get battery value:
MKtl(\xosc).elAt(\battery).action = { |bat|
	MFdef('battery').value(bat.deviceValue);
};

///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// DIGITAL INS
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

// pullup hack - switches are 1 when open, 2 when pressed
MKtl(\xosc).elAt(\inD, (0..7)).do (_.valueAction_(1));


// prepare for modalization:
// left buttons set up modes for right side and <>
q.osc.xosc.leftDown = List[];
q.osc.xosc.rightDown = List[];
q.osc.xosc.shiftWasUsed = false;

/*
//////// to test left side actions:
q.osc.xosc.rightDown.clear.add(\preUp);
q.osc.xosc.rightDown.clear.add(\preDown);
q.osc.xosc.rightDown.clear.add(\touchMove);
q.osc.xosc.rightDown.clear;
*/

// the slot switches:
MKtl(\xosc).elAt(\inD, [\1, \2, \3, \4]).do { |but, i|
	but.action.add(\shift, { |but|
		// 0 is button pressed: prep mode
		if (but.value == 0) {
			q.osc.xosc.leftDown.add(i);
		} {
			// button was released: remove shifter
			q.osc.xosc.leftDown.remove(i);
			// q.osc.xosc.leftDown.postln;
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
			if (q.osc.xosc.rightDown.size == 0) {
				// reset if we just left a mode
				if (q.osc.xosc.shiftWasUsed) {
					q.osc.xosc.shiftWasUsed = false;
				} {
					// if no mode, do default action
					// " % default action: toggle\n".postf(btname);
					q.slots.toggleAt(i);
				}
			} {
				// right side has a mode - remember we used it now
				q.osc.xosc.shiftWasUsed = true;
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
				)[q.osc.xosc.rightDown.first];
				actionFunc.value;
			}
		}
	});
};

MKtl(\xosc).elAt(\inD, [\5, \6, \7]).do { |but, i|
	///////// order seems wrong, but posts right - why?
	var btname = [\touchMove, \preUp, \preDown][i];
	but.action.add(\shift, { |but|
		// 0 is button pressed:
		if (but.value == 0) {
			q.osc.xosc.rightDown.add(btname);
			// "rightdown: %\n".postf(q.osc.xosc.rightDown);
		} {
			// button was released: remove shifter
			q.osc.xosc.rightDown.remove(btname);
			// "rightdown: %\n".postf(q.osc.xosc.rightDown);
		}
	});
};

/*
q.osc.xosc.leftDown.clear.add(0);
q.osc.xosc.leftDown.clear.add(1);
q.osc.xosc.leftDown.clear;
MKtl(\xosc).elAt(\inD, \5).value_(0);
MFdef(\rightMode).(MKtl(\xosc).elAt(\inD, \5), { "def".postln }, { "shift".postln });
*/

// modal action for the right side buttons:
MFdef(\rightMode).add(\modal, { |but, defaultAction, shiftAction|
	var btval = but.value;
	var btname = (sw_5: \touchMove, sw_6: \preDown, sw_7: \preUp)[but.name];
	var slotIndex, player;
	if (q.osc.xosc.leftDown.size == 0) {
		// if we just left a mode, just reset
		if (q.osc.xosc.shiftWasUsed) {
			q.osc.xosc.shiftWasUsed = false
		} {
			// if we were not in any mode, do the default action
			// " % default action: \n".postf(btname);
			defaultAction.value;
		}
	} {
		// left is curr. held down, and right was pressed,
		// so now we are in shifted mode:
		q.osc.xosc.shiftWasUsed = true;
		slotIndex = q.osc.xosc.leftDown.first;
		player = q.slots.actives[slotIndex];
		// " % shift action for slot %, % \n".postf(btname, slotIndex, player);
		shiftAction.value(player);
	};
});



MKtl(\xosc).elAt(\inD, \5).action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value > 0) {
		MFdef(\rightMode).(bt,
			MFdef(\inphModeStep),
			{ |ndef|
				"% - choose rand preset...\n".postf(ndef);
				q.pre.stepNdefInf( ndef, nil )
			}
		)
	};
});

/*
MFdef(\stepVol).(q.slots.actives[0]);
MFdef(\stepVol).(q.slots.actives[0], -1);
*/


MKtl(\xosc).elAt(\inD, [\6, \7]).do { |elem, index|
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
// //// I M U
// ///////////////////////////////////////////////////////////////

MKtl(\xosc).collAt(\imu).action = { |imugrp|
	// trigger the action only once (influx calc)
	MFdef(\xoscImuFunc).value;
	// msg.postcs;
};

MFdef(\xoscImuFunc).add(\setInphlux, {
	var imuBiValues = MKtl(\xosc).elAt(\imu9).value.unibi;
	var keysvals = q.inphlux.getHalo(\imuNames).collect { |name, i|
		var value = imuBiValues[i] - q.zero.imu[i];
		[name, value]
	}.flat;
	q.osc.rawImuBiValues = imuBiValues;
	// "*** imufunc: ".post; keysvals.round(0.0001).postln;
	q.inphlux.set(*keysvals);
});

// hack for xosc gui: all element actions trigger imuFunc!
MKtl(\xosc).elAt(['accel', 'gyro', 'magnet']).flat.do(_.action_(MFdef(\imuFunc)));

/*
MFdef(\xoscImuFunc).disable( \setInphlux );
MFdef(\xoscImuFunc).enable( \setInphlux );
*/


///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// ANALOG INS Touchmod
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

(
q.inphlux.addHalo(\padNames, q.inphlux.inNames.copyRange(9, 16));

MFdef(\touchToInph).add(\set, {
	var influx = q.inphlux;
	var pads = MKtl(\xosc).elAt(\pads8);
	var padInNames = q.inphlux.getHalo(\padNames);
	var keysValues = pads.collect { |pad, i|
		[ padInNames[i], pad.value]
	}.flat;
	q.inphlux.set(*keysValues);
});

////// this is the action that gets triggered
////// when values come in from the xosc -
////// use this to compensate for crosstalk,
////// and sending the final values once.

MKtl(\xosc).collAt('aIn').groupAction = nil;

MKtl(\xosc).collAt('aIn').groupAction = { |coll|
	var values = coll.value;
	var xtalkFactor = 0.5;

	// // MAGIC crosstalk compensation - adc Mar 2019 - seems an improvement
	// // value[1] = value[1].linlin(value[0] * 0.5, 1, 0, 1);
	(15..1).do { |i|
		values[i] = values[i].linlin(values[i - 1] * xtalkFactor, 1, 0, 1);
	};

	q.osc.rawPads = values[8..];

	// q.zero.pads is the rest state of the pads
	// use it to stretch to a range of 0-1
	(8..15).do { |i|
		var rawval = values[i];
		var zeroOffset = q.zero.pads.asArray.wrapAt(i);
		var stretched = rawval.linlin(zeroOffset, 0.9, 0, 1);
		values.put(i,stretched);
	};

	// set to the compensated values, no action
	MKtl(\xosc).elAt('inA').value_(values);
	// trigger touch to inphlux only once ...
	MFdef(\touchToInph).value;
	// and explicitly trigger zoom action
	// MKtl(\xosc).elAt('inA', 7).doAction;

};

// set zoom from poti on ana in 8 (it was 7, not worked)
MKtl(\xosc).elAt('inA').at(7).action.add(\setZoom, {|el|
	var val = el.value.clip(0.05, 1).round(0.05);
	if (val != q.zoom) {
		"zoom from xosc: %\n".postf(val);
		q.setZoom(val)
	};
});


// individual pad action - useful for guis
/// do global set only once, from MFdef(\touchToInph)
MKtl(\xosc).elAt(\pads8).do { |pad, i|
	pad.action.add(\setInflux, {|ana|
		var name = 	q.inphlux.getHalo(\padNames).clipAt(i);
		q.inphlux.set(name, ana.value.pow(3));
		//.pow(6));
		// the pow(6) helps toflatten the steep curve of the FSRs as they are now.
		ana.value
	})
};
);
);

