/*
OSCFunc.trace;
OSCFunc.trace (false);

TODO:
- button polarity NOT like xosc!
-- buttons are 0 when open, and 1 when pressed!

- ADD FULL mode: touch and move together!

Controller Mapping:

+ IMU to inphlux  in  move mode [and full mode]
+ CAP to inphlux in touch mode [and full mode]

*** MODE - But8:
+ touch
+ move
- full
-- off?
-- hold down for mode?

*** SLOT buttons 1-4:
+ base mode: sound on/off
+ pressing shifts to slot mode!

*** STEP buttons 6 7:
+ base mode: step inphlux presets
+ slot mode: inc/dec/rand presets
+ hat mode: step mfx presets

*** ENCODER:
+ base mode -> inc/dev master volume
+ hat  mode -> zoom!
+ slot mode -> inc/dec slot volume
+ sl+hat mode -> inc/dec sounds?


*/


(
// use this dict for everything osc related
q.osc = q.osc ? ();

///////// make a new
MKtl.all.at(\ntmi).free;
MKtl(\ntmi, "ai-ntmi");
MKtl(\ntmi).device.updateDstAddr("169.254.1.1", 57120);
MKtl(\ntmi).device.updateSrcAddr("169.254.1.1", 57120);

MKtl(\ntmi).elAt(\enc).value_(0.5);


/// init all xosc actions as MFuncs, provide posting
MKtl(\ntmi).elementsDict.do(_.action_(MFunc()));
MKtl(\ntmi).elementsDict.do { |el| el.action.add(\post, { |el|
	[el.name, el.value.round(0.0001)].postln
}) };
MKtl(\ntmi).elementsDict.do { |el| el.action.enable(\post) };
MKtl(\ntmi).elementsDict.do { |el| el.action.disable(\post) };


// create named elements/groups for imu and pads etc:
MKtl(\ntmi).addNamed(\imu9, MKtl(\ntmi).elAt([\accel, \gyro, \magnet]).flat);
MKtl(\ntmi).addNamed(\slots, MKtl(\ntmi).elAt(\bt, (0..3)));
MKtl(\ntmi).addNamed(\encHat, MKtl(\ntmi).elAt(\bt, \5));
MKtl(\ntmi).addNamed(\steps, MKtl(\ntmi).elAt(\bt, [\6, \7]));
MKtl(\ntmi).addNamed(\modSw, MKtl(\ntmi).elAt(\bt, \8));

MKtl(\ntmi).elAt(\slots);
// init imu values to center, caps to bottom
MKtl(\ntmi).elAt(\imu9).value_(0.5!9);
MKtl(\ntmi).elAt(\cap).valueAction_(0!8);

/// name the elements
MKtl(\ntmi).elAt(\slots).do { |sw, i| sw.elemDesc.label = "SND" + sw.keyInGroup };
MKtl(\ntmi).elAt(\steps).do { |sw, i| sw.elemDesc.label = ["+UP", "-DOWN"]@i  };
MKtl(\ntmi).elAt(\modSw).elemDesc.label_('touchMove');


// init zero values
q.zero = q.zero ? ();
q.zero.imu = 0!9;
q.zero.pads = 0!8;
q.osc.rawPads = (0!8);

// capture current zero position for imu and pads
/* // get zero values while xosc is running:
MFdef(\ZERO).value;
*/
MFdef(\ZERO).add(\set, {
	q.zero.imu = MKtl(\ntmi).elAt(\imu9).value.unibi;
	q.zero.pads = q.osc.rawPads;
	"*** ZERO was set: ".postln;
	"imu: %\n".postf(q.zero.imu.round(0.001));
	"pads: %\n".postf(q.zero.imu.round(0.001));
});

// battery values and display
q.osc.batString = "? battery ?";
q.osc.batval = 0;
q.osc.batPercent = 0;

////////////// get battery value:
MKtl(\ntmi).elAt(\battery).action = { |bat|
	q.osc.oldbatval = q.osc.batval;
	q.osc.batval = bat.deviceValue;
	q.osc.batvaltime = Main.elapsedTime;
	q.osc.batPercent = (bat.value * 100).round(0.1);
	q.osc.batString = "bat: %V %%".format(q.osc.batval.round(0.01), q.osc.batPercent, $%);
	q.osc.batString.postcln;
};


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
MKtl(\ntmi).elAt(\slots).do { |but, i|
	but.action.add(\shift, { |but|
		// 1 is button pressed: prep mode
		if (but.isOn) {
			q.osc.leftDown.add(but.indexInGroup);
		} {
			// button was released: remove shifter
			q.osc.leftDown.remove(but.indexInGroup);
			// q.osc.leftDown.postln;
		}
	});

	// on button release, do modal action:
	but.action.add(\modal, { |but|
		var btval = but.value;
		var btnum = 1 + i;
		var btname = but.name;
		var actionFunc;

		[btname, btnum, btval].postln;

		if (but.isOn.not) {
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

MKtl(\ntmi).elAt(\bt, [\6, \7, \8]).do { |but, i|
	// hope the button sorder is correct?
	var btname = [\preUp, \preDown, \touchMove][i];
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
MFdef(\rightMode).(MKtl(\ntmi).elAt(\inD, \5), { "def".postln }, { "shift".postln });
*/

// modal action for the right side buttons:
MFdef(\rightMode).add(\modal, { |but, defaultAction, shiftAction|
	var btval = but.value;
	var btname = (bt_8: \touchMove, bt_7: \preDown, bt_6: \preUp)[but.name];
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
		// left is held down, and right was pressed,
		// so now we are in shift mode:
		q.osc.shiftWasUsed = true;
		slotIndex = q.osc.leftDown.first;
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
		MKtl(\ntmi).elAt('cap').do { |cap| cap.action.enable(\setInflux) };
		MFdef(\imuFunc).disable( \setInphlux );
		/////// pads set inphlux in unipolar, 0-1 range!
		q.inphlux.set(*q.inphlux.inNames.keep(9).collect([_, 0]).flat);
		// MKtl(\ntmi).elAt(\led, \5).value_(0.0);
	}{
		q.inph.mode = \move;
		"*** enable MOVE (IMU) ".postln;
		MKtl(\ntmi).elAt('pads8').do { |pad| pad.action.disable(\setInflux) };
		q.inphlux.set(*q.inphlux.inNames.drop(9).collect([_, 0]).flat);
		MFdef(\imuFunc).enable( \setInphlux );
		// MKtl(\ntmi).elAt(\led, \5).value_(1/2);
	};
});

MKtl(\ntmi).elAt(\modSw).action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value > 0) {
		MFdef(\rightMode).(bt,
			MFdef(\imuMode),
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

MFdef(\mastaStepVol).(1);

*/

MFdef(\mastaStepVol).add(\step, { |inc=0|
	RelSet(q.mFX.pxChain.proxy, \mastaVol, inc * 0.01);
});

MFdef(\stepVol).add(\step, { |ndef, step = 1|
	var stepsize = 0.01; // 100 steps from 0 to 1
	var ampspec = \amp.asSpec;
	ndef.vol = ampspec.map(ampspec.unmap(ndef.vol) + (step * stepsize))
});

MFdef(\stepSlotPres).add(\step, { |step = 1|
	var activeNdefs = q.inphlux.action.activeNames.collect(Ndef(_));
	activeNdefs.do { |nd, j|
		q.pre.stepNdefInf( nd, step );
	};
});

// -- base mode -> inc/dev master volume
// -- hat  mode -> zoom!
// -- slot mode -> inc/dec slot volume
// -- sl+hat mode -> inc/dec sounds?

MKtl(\ntmi).elAt(\enc).action.add(\modal, { |enc|
	var slotDown = (q.osc.leftDown.size > 0).binaryValue;
	var hatDown = MKtl(\ntmi).elAt(\encHat).isOn.binaryValue;
	var modeNum = slotDown * 2 + hatDown;

	modeNum.postln.switch(
		0, {
			"base: mastaStepVol".postln;
			MFdef(\mastaStepVol).(enc.deviceValue);
		},
		1, {
			"hat: zoom".postln;
			q.incZoom(enc.deviceValue * 0.05);
		},
		2, {
			"slot: slot volume".postln;
			q.osc.leftDown.do { |slotIndex|
				MFdef(\stepVol).(q.slots.actives[slotIndex], enc.deviceValue);
			};
		},
		3, {
			"slotHat: sound selection".postln;
			q.osc.leftDown.do { |slotIndex|
				q.slots.stepNext(slotIndex);
			};

		}
	);
	enc.deviceValue = 0;
});


// *** TODO: STEP buttons 6 7:
// + base mode: step inphlux presets
// -- slot mode: inc/dec/rand presets
// -- hat mode: step mfx presets

MKtl(\ntmi).elAt(\steps).do { |elem, index|
	elem.action.add(\modal, {|bt|

		var step = [1, -1]@index; // 6 is up, 7 is down
		// do modal action on release only
		if (bt.value == 0) {
			if (MKtl(\ntmi).elAt(\encHat).isOn) {
				MFdef(\mastaPreStep.postcs).(step);
			} {
				if (q.osc.leftDown.notEmpty) {
					q.osc.leftDown.do { |slotIndex|
						"stepNdefPreInf".postln;
						q.pre.stepNdefInf(q.ndefs[slotIndex], step)
					}
				} {
					"base: step inphlux preset.".postln;
					// reply to OSC device: which LED os which Color!
					MFdef(\stepInphWPre).(step);
					// MFdef(\stepSlotPres).(step);
				}
			};
		};
	})
};

// ///////////////////////////////////////////////////////////////
// //// I M U
// ///////////////////////////////////////////////////////////////

MKtl(\ntmi).collectivesDict[\imu].action = {
	// trigger the action only once (influx calc)
	MFdef(\imuFunc).value;
};

// set the first 9 values of the inphlux from the imu params:
q.inphlux.addHalo(\imuNames, q.inphlux.inNames.keep(9));

MFdef(\imuFunc).add(\setInphlux, {
	var keysvals = q.inphlux.getHalo(\imuNames).collect { |name, i|
		var value = MKtl(\ntmi).elAt(\imu9, i).value.unibi - q.zero.imu[i];
		[name, value]
	}.flat;
	// "*** imufunc: ".post; keysvals.round(0.0001).postln;
	q.inphlux.set(*keysvals);
});

// hack for xosc gui: all element actions trigger imuFunc!
MKtl(\ntmi).elAt(['accel', 'gyro', 'magnet']).flat.do(_.action_(MFdef(\imuFunc)));

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


///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// Caps
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

(
q.inphlux.addHalo(\padNames, q.inphlux.inNames.copyRange(9, 16));

MFdef(\capsToInph).add(\set, {
	var influx = q.inphlux;
	var pads = MKtl(\ntmi).elAt(\cap);
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

MKtl(\ntmi).collAt('caps').groupAction = nil;

MKtl(\ntmi).collAt('caps').groupAction = { |coll|
	var values = coll.value;

	q.osc.rawPads = values;

	// q.zero.pads is the rest state of the pads
	// use it to stretch to a range of 0-1
	values.do { |rawval, i|
		var zeroOffset = q.zero.pads.asArray.wrapAt(i);
		var stretched = rawval.linlin(zeroOffset, 0.9, 0, 1);
		values.put(i, stretched);
	};

	// set to the compensated values, no action
	MKtl(\ntmi).elAt('cap').value_(values);
	// trigger touch to inphlux only once ...
	MFdef(\capsToInph).value;
};

// individual pad action - useful for guis only
/// do global set only once, from MFdef(\touchToInph)
MKtl(\ntmi).elAt(\cap).do { |pad, i|
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

