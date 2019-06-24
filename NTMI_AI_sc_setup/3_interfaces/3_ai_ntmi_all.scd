/*

TODO:
- ntmi_esp should be shown on maingui
+ change colors on preButs - 6 cols, red, yell, green, cyan, blue, magenta



ALL Controller Mappings on NTMI_esp32_v1:

OK --- back left buttons - slot play/stop
----> hold down for slot mode

OK --- encoder -> master volume
OK --- encHat + enc -> master zoom
OK --- slots + enc -> slot volumes
OK --- encHat + slot + encoder -> sound choice

OK --- caps to inphlux
OK --- imu to influx

OK --- preUp - step inphl up
OK --- preDown step inphl down

OK --- modeBut - cycle full, move, touch, off

OK --- hat + preUP -> masterFX UP
OK --- hat + preDown -> masterFX down
OK --- hat + preUP + Down -> masterFX rand

?? --- encHat - add snapshot? later.



OSCFunc.trace;
OSCFunc.trace (false);

TODO:
- unify/merge xosc and ntmi as much as possible!
q.osc is shared space

*/


(
// use this dict for everything osc related
q.osc = q.osc ? ();
q.osc.ntmi = q.osc.ntmi ? ();


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
MKtl(\ntmi).elAt(\modSw).elemDesc.label_('move Mode');

////////////// get battery value:
MKtl(\ntmi).elAt(\battery).action = { |bat|
	MFdef(\battery).value(bat.deviceValue);
};


// prepare for modalization:
// left buttons set up modes for right side and <>
q.osc.leftDown = List[];
q.osc.rightDown = List[];
q.osc.shiftWasUsed = false;
q.osc.leftWasUsed = false;
q.osc.rightWasUsed = false;

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
		var butIndex = but.indexInGroup;
		// when is button pressed: set up for mode
		if (but.isOn) {
			q.osc.leftDown.add(butIndex);
		} {
			// when button was released: remove shifter
			q.osc.leftDown.removeAllSuchThat(_ == butIndex);
		}
	});

	// on button release, do the modal action:
	but.action.add(\modal, { |but|

		var actionFunc;
		var playsNow;

		if (but.isOn.not) {
			// determine whether we are in a mode
			if (q.osc.rightDown.size == 0) {
				// reset if we just left a mode
				if (q.osc.leftWasUsed) {
					q.osc.leftWasUsed = false;
				} {
					// if there was no mode, do the default action
					// " % default action: toggle\n".postf(but.name);
					playsNow = q.slots.toggleAt(i);
					// send led value to show play state on NTMI immediately
					MKtl(\ntmi).elAt(\led, \bk, i).value = playsNow.binaryValue;
				}
			} {
				///////////// NOT SURE WE STILL REALLY WANT THESE - so take them out for now ////////
				// // right side has set up a mode - remember we used it now
				// q.osc.rightWasUsed = true;
				// actionFunc = (
				// 	preUp: {
				// 		// "*** rshift 1 action: % NEXT ndef\n".postf(btname);
				// 		q.slots.stepNext(i, 1);
				// 	},
				// 	preDown: {
				// 		// "*** rshift 2 action: % PREV ndef\n".postf(btname);
				// 		q.slots.stepNext(i, -1);
				// 	},
				// 	touchMove: {
				// 		// "*** rshift 3 action: % RAND ndef\n".postf(btname);
				// 		q.slots.chooseNext(i);
				// 	},
				// )[q.osc.rightDown.first];
				// actionFunc.value;
			}
		}
	});
};

MKtl(\ntmi).elAt(\bt, [\5, \6, \7, \8]).do { |but, i|
	// hope the button order is correct?
	var btname = [\encHat, \preUp, \preDown, \touchMove][i];

	but.action.add(\shift, { |but|
		// 0 is button pressed:
		MKtl(\ntmi).elAt(\led, \bk, i + 4).value = but.value;
		if (but.value == 1) {
			q.osc.rightDown.add(btname);
			"rightdown: %\n".postf(q.osc.rightDown);
		} {
			// button was released: remove shifter
			q.osc.rightDown.removeAllSuchThat(_ == btname);
			"rightdown: %\n".postf(q.osc.rightDown);
		}
	});
};

MKtl(\ntmi).collAt('caps').action = MFunc();
MKtl(\ntmi).collAt('caps').action.add(\yo, { \yo });
MKtl(\ntmi).collAt('caps').action.add(\setLed, { |coll|
	coll.elements.do { |el, i|
		var led = MKtl(\ntmi).elAt(\led, \fr, i);
		var oldval = led.value;
		var newval = (el.value > 0.25).binaryValue;
		if (oldval != newval) {
			// [\yo, i].postln;
			led.value = newval;
		};
	};
});


/////////// add funcs to inphMode switching so NTMI can do it /////////

MFdef(\touchON).add(\ntmi, {
	"ntmi - touchON".postln;
	MFdef(\capsToInph).enable;
	MKtl(\ntmi).collAt('caps').enable;
	MKtl(\ntmi).elAt('cap').do { |cap| cap.action.enable(\setInflux) };
});

MFdef(\touchOFF).add(\ntmi, {
	"ntmi - touchOFF".postln;
	MFdef(\capsToInph).disable;

	MKtl(\ntmi).elAt('cap').do { |cap| cap.action.disable(\setInflux) };
	q.inphlux.set(*q.inphlux.getHalo(\capNames).collect([_, 0]).flat);
	q.inphlux.set(*q.inphlux.getHalo(\padNames).collect([_, 0]).flat);
});

MFdef(\moveON).add(\ntmi, {
	"ntmi - moveON".postln;
	MFdef(\ntmiImuFunc).enable(\setInflux);
	MKtl(\ntmi).elAt('imu9').do { |ax| ax.action.enable(\setInflux) };

});

MFdef(\moveOFF).add(\ntmi, {
	"ntmi - moveOFF".postln;
	MFdef(\ntmiImuFunc).disable(\setInflux);

	MKtl(\ntmi).elAt('imu9').do { |ax| ax.action.disable(\setInflux) };
	/////// pads set inphlux in unipolar, 0-1 range!
	q.inphlux.set(*q.inphlux.getHalo(\imuNames).collect([_, 0]).flat);
});

// show modes as colors:
// green = both, red = move, blue = touch, black = off

MKtl(\ntmi).elAt(\modSw).action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: masta fx rand
		{ MKtl(\ntmi).elAt(\encHat).isOn }
		{ MFdef(\mastaPreStep).value(nil) }

		// slot mode: rand preset
		{ q.osc.leftDown.size > 0 }
		{
			q.osc.leftDown.do { |slotIndex|
				// "% - choose rand ndef preset.\n".postf(q.ndefs[slotIndex]);
				q.pre.stepNdefInf( q.ndefs[slotIndex], nil )
			}
		}
	}
});

MFdef(\inphModeSetIndex).add(\modeSwColor, {
	defer ({
		var msg = [0,0,0,0].put(q.inph.modeIndex, 1);
		MKtl(\ntmi).device.source.sendMsg("/ntmi/ledCtl/back", 7, *msg.keep(3));
	}, 0.05);
});


MFdef(\setInphWPre).add(\setLEDs, {
	fork {
		var ledCol = q.inph.currPresetCol.asArray.keep(3).round.collect(_.asInteger);
		ledCol.postln;
		0.1.wait;
		[5, 6].do { |ledIndex|
			MKtl(\ntmi).device.source.sendMsg("/ntmi/ledCtl/back", ledIndex, *ledCol);
			0.02.wait
		}
	}
});


MKtl(\ntmi).elAt(\modSw).action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: masta fx rand
		{ MKtl(\ntmi).elAt(\encHat).isOn }
		{ MFdef(\mastaPreStep).value(nil) }

		// slot mode: rand preset
		{ q.osc.leftDown.size > 0 }
		{
			q.osc.leftDown.do { |slotIndex|
				// "% - choose rand ndef preset.\n".postf(q.ndefs[slotIndex]);
				q.pre.stepNdefInf( q.ndefs[slotIndex], nil )
			};
			q.osc.leftWasUsed = true;
		}
		// default: step inph preset
		{ MFdef(\inphModeStep).value(1) }

	}
});

// preUp button:
MKtl(\ntmi).elAt(\steps)[0].action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: masta fx rand
		{ MKtl(\ntmi).elAt(\encHat).isOn }
		{ MFdef(\mastaPreStep).value(1) }

		// slot mode: rand preset
		{ q.osc.leftDown.size > 0 }
		{
			q.osc.leftDown.do { |slotIndex|
				// "% - choose rand ndef preset.\n".postf(q.ndefs[slotIndex]);
				q.pre.stepNdefInf( q.ndefs[slotIndex], 1 )
			};
			q.osc.leftWasUsed = true;
		}
		// default: step inph preset
		{ MFdef(\stepInphWPre).value(1) }

	}
});

// preDown button - same but -1
MKtl(\ntmi).elAt(\steps)[1].action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: masta fx rand
		{ MKtl(\ntmi).elAt(\encHat).isOn }
		{ MFdef(\mastaPreStep).value(-1) }

		// slot mode: rand preset
		{ q.osc.leftDown.size > 0 }
		{
			q.osc.leftDown.do { |slotIndex|
				// "% - choose rand ndef preset.\n".postf(q.ndefs[slotIndex]);
				q.pre.stepNdefInf( q.ndefs[slotIndex], -1 )
			};
			q.osc.leftWasUsed = true;
		}
		// default: step inph preset
		{ MFdef(\stepInphWPre).value(-1) }

	}
});

// -- base mode -> inc/dev master volume
// -- hat  mode -> zoom!
// -- slot mode -> inc/dec slot volume
// -- sl+hat mode -> inc/dec sounds

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
			q.incZoom(enc.deviceValue * \zoom.asSpec.step.max(0.01));
		},
		2, {
			"slot: volume step: ".postln;
			q.osc.leftWasUsed = true;
			// "q.osc.leftWasUsed: %\n".postf(q.osc.leftWasUsed);
			q.osc.leftDown.do { |slotIndex|
				MFdef(\stepVol).(*[q.slots.actives[slotIndex], enc.deviceValue].postln);
			};
		},
		3, {
			"slotHat: select sound ".postln;
			q.osc.leftWasUsed = true;
			// "q.osc.leftWasUsed: %\n".postf(q.osc.leftWasUsed);
			q.osc.leftDown.do { |slotIndex|
				q.slots.stepNext(slotIndex, enc.deviceValue);
				"   % : %\n".postf(slotIndex, q.slots[slotIndex]);
			};

		}
	);
	enc.deviceValue = 0;
});


// ///////////////////////////////////////////////////////////////
// //// I M U
// ///////////////////////////////////////////////////////////////

MKtl(\ntmi).collectivesDict[\imu].action = {
	// trigger the action only once (influx calc)
	MFdef(\ntmiImuFunc).value;
};

// set the first 9 values of the inphlux from the imu params:
q.inphlux.addHalo(\imuNames, q.inphlux.inNames.keep(9));

MFdef(\ntmiImuFunc).add(\setInflux, {
	var imuInvalsBi = MKtl(\ntmi).elAt(\imu9).value.unibi;
	var keysvals = q.inphlux.getHalo(\imuNames).collect { |name, i|
		var value = imuInvalsBi[i] - q.zero.imu[i];
		[name, value]
	}.flat;
	q.osc.rawImuBiValues = imuInvalsBi;
	// "*** imufunc: ".post; keysvals.round(0.0001).postln;
	q.inphlux.set(*keysvals);
});

// hack for xosc gui: all element actions trigger imuFunc!
MKtl(\ntmi).elAt(['accel', 'gyro', 'magnet']).flat.do(_.action_(MFdef(\ntmiImuFunc)));

/*
MFdef(\imuFunc).disable( \setInflux );
MFdef(\imuFunc).enable( \setInflux );
*/


// for monitoring the incoming osc activity by timetag
q.osc.lastInTime = 0;
q.osc.timeSinceLast = { Main.elapsedTime - q.osc.lastInTime };
q.osc.timeSinceLast = { Main.elapsedTime - q.osc.lastInTime };

OSCdef(\imuAlive, { |msg, time|
	q.osc.lastInTime = time;
}, "/imu").permanent_(true);

///////// update slot LEDs
q.osc.ntmiSkip.stop.free;
q.osc.ntmiSkip = SkipJack({
	var cols = [[0,0,0], [0,1,0]], col;
	fork {
		MKtl(\ntmi).elAt(\led, \bk, (0..3)).do { |led, ledi|
			var isPlaying = q.ndefs[ledi].monitor.isPlaying;
			var newval = isPlaying.binaryValue;
			if (newval != led.prevValue) {
				led.value = newval;
				col = cols[newval];
				// "ntmi: sending changed color to led_bk %: %\n".postf(ledi, col);
				2.do {
					rrand(0.03, 0.07).wait;
					MKtl(\ntmi).device.source.sendMsg("/ntmi/ledCtl/back", ledi, *col);
				};
			};

		};
	}
});


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

	// reorder for proper order of pads and leds
	values = values[[1, 4, 0, 3, 5, 6, 2, 7]];
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

