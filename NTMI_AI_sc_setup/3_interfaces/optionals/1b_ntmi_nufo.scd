/*

TODO:

ALL Controller Mappings on NTMI_esp32_v1:

OK --- back left buttons - slot play/stop
----> hold down for slot mode

OK --- encoder -> main volume
OK --- encHat + enc -> main zoom
OK --- slots + enc -> slot volumes
OK --- encHat + slot + encoder -> sound choice

OK --- caps to inphlux
OK --- imu to influx

OK --- preUp - step inphl up
OK --- preDown step inphl down

OK --- modeBut - cycle full, move, touch, off

OK --- hat + preUP -> mainFX UP
OK --- hat + preDown -> mainFX down
OK --- hat + preUP + Down -> mainFX rand

OK --- encHat - add snapshot

OSCFunc.trace(true, true);
OSCFunc.trace (false);

/*
MKtl(\nUFO).elementsDict.do { |el| el.action.enable(\post) };
*/

*/


(
// use this dict for everything osc related
NTMI.nufo = NTMI.nufo ? ();
NTMI.nufo.nUFO = NTMI.nufo.nUFO ? ();


///////// make a new nufo MKtl from desc in
// ".../0_globals/3_ai-ntmi.desc.scd"
MKtl.all.at(\nUFO).free;
MKtl(\nUFO, "ai-ntmi");


// this is for logging into NTMI-xxx networks only:
// should eventually be done automatically from a listening OSCdef
MKtl(\nUFO).device.updateDstAddr("169.254.1.1", NetAddr.langPort);
MKtl(\nUFO).device.updateSrcAddr("169.254.1.1", NetAddr.langPort);


// **** initialize
MKtl(\nUFO).elAt(\enc).value_(0.5);

/// init all nufo actions as MFuncs, provide posting
MKtl(\nUFO).elementsDict.do(_.action_(MFunc()));
MKtl(\nUFO).elementsDict.do { |el|
	el.action.add(\post, { |el|
		[el.name, el.value.round(0.0001)].postln
	})
};

MKtl(\nUFO).elementsDict.do { |el| el.action.disable(\post) };


// create named elements/groups for imu and pads etc:
MKtl(\nUFO).addNamed(\imu9, MKtl(\nUFO).elAt([\accel, \gyro, \magnet]).flat);
MKtl(\nUFO).addNamed(\slots, MKtl(\nUFO).elAt(\bt, (0..3)));
MKtl(\nUFO).addNamed(\encHat, MKtl(\nUFO).elAt(\bt, \5));
MKtl(\nUFO).addNamed(\steps, MKtl(\nUFO).elAt(\bt, [\6, \7]));
MKtl(\nUFO).addNamed(\modSw, MKtl(\nUFO).elAt(\bt, \8));

MKtl(\nUFO).elAt(\slots);
// init imu values to center, caps to bottom
MKtl(\nUFO).elAt(\imu9).value_(0.5!9);
MKtl(\nUFO).elAt(\cap).valueAction_(0!8);

/// name the elements
MKtl(\nUFO).elAt(\slots).do { |sw, i| sw.elemDesc.label = "SND" + sw.keyInGroup };
MKtl(\nUFO).elAt(\steps).do { |sw, i| sw.elemDesc.label = ["+UP", "-DOWN"]@i  };
MKtl(\nUFO).elAt(\modSw).elemDesc.label_('move Mode');


// prepare for modalization:
// left buttons set up modes for right side and <>
NTMI.nufo.leftDown = List[];
NTMI.nufo.rightDown = List[];
NTMI.nufo.shiftWasUsed = false;
NTMI.nufo.leftWasUsed = false;
NTMI.nufo.rightWasUsed = false;

/*
//////// to test left side actions:
NTMI.nufo.rightDown.clear.add(\preUp);
NTMI.nufo.rightDown.clear.add(\preDown);
NTMI.nufo.rightDown.clear.add(\touchMove);
NTMI.nufo.rightDown.clear;
*/


/***************
How the modal logic for the NTMI buttons + encoder works:
*** pressing down prepares for potential modal actions
*** releasing triggers th action, basic or modal, and resets flags.

*** All buttons have basic actions when nothing else is held:
- left 4 slots buttons toggle sound on/off
- encHat stores snapshots of running sounds
- presetButs step influx presets up and down
- modeBut cycles modes
- encoder adjusts main volume up/down
- encoderHat stores snapshot preset of currently active sounds

*** When a button is  held and another is pressed, a modal action happens.

** Left hand slot button(s) : press-and-hold selects the slots for:
- preUp, preDown buttons step thru presets of the sound(s) in selected slots
- mode button chooses random presets
- encoder adjusts volume for selected tracks up/down
* when encHat is also pressed:
- encoder cycles through other sounds for selected tracks

** when encHat is held, slot buttons toggle couple/decouple of that slot's sound

****************/

// left side, the slot switches:
MKtl(\nUFO).elAt(\slots).do { |but, i|

	but.action.add(\shift, { |but|
		var butIndex = but.indexInGroup;
		// when is button pressed: set up for mode
		if (but.isOn) {
			NTMI.nufo.leftDown.add(butIndex);
		} {
			// when button was released: remove shifter
			NTMI.nufo.leftDown.removeAllSuchThat(_ == butIndex);
		}
	});

	// on button release, do the modal action:
	but.action.add(\modal, { |but|

		var actionFunc;
		var playsNow;
		var slotObj = NTMI.slots.actives[i];

		if (but.isOn.not) {
			// determine whether we are in a mode
			if (NTMI.nufo.rightDown.size == 0) {
				// reset if we just left a mode
				if (NTMI.nufo.leftWasUsed) {
					NTMI.nufo.leftWasUsed = false;
				} {
					// if there was no mode, do the default action
					// " % default action: toggle\n".postf(but.name);
					playsNow = NTMI.slots.toggleAt(i);
					// send led value to show play state on NTMI immediately
					MKtl(\nUFO).elAt(\led, \bk, i).value = playsNow.binaryValue;
				}
			} {
				// "... (right mode for slot buttons) ...".postln;
				// if encoder was held, de/couple this slot from influx
				if (MKtl(\nUFO).elAt(\encHat).isOn) {
					NTMI.inph.clutch(slotObj);
				};
				NTMI.nufo.rightWasUsed = true;
			}
		}
	});
};

MKtl(\nUFO).elAt(\bt, [\5, \6, \7, \8]).do { |but, i|
	// button order of names
	var btname = [\encHat, \preUp, \preDown, \touchMove][i];

	but.action.add(\shift, { |but|
		// 0 is button pressed:
		MKtl(\nUFO).elAt(\led, \bk, i + 4).value = but.value;
		if (but.value == 1) {
			NTMI.nufo.rightDown.add(btname);
			// "rightdown: %\n".postf(NTMI.nufo.rightDown);
		} {
			// button was released: remove shifter
			NTMI.nufo.rightDown.removeAllSuchThat(_ == btname);
			// "rightdown: %\n".postf(NTMI.nufo.rightDown);
		}
	});
};


MKtl(\nUFO).elAt(\modSw).action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: main fx rand
		{ MKtl(\nUFO).elAt(\encHat).isOn }
		{ MFdef(\mainPreStep).value(nil) }

		// slot mode: rand preset
		{ NTMI.nufo.leftDown.size > 0 }
		{
			NTMI.nufo.leftDown.do { |slotIndex|
				// "% - choose rand ndef preset.\n".postf(NTMI.ndefs[slotIndex]);
				NTMI.pre.stepNdefInf( NTMI.ndefs[slotIndex], nil )
			}
		}
	}
});

NTMI.inph.sendInphPre = {
	fork {
		var ledCol = NTMI.inph.currPresetCol.asArray.keep(3).round.collect(_.asInteger);
		0.1.wait;
		[5, 6].do { |ledIndex|
			try {
				MKtl(\nUFO).device.source.sendMsg("/ntmi/ledCtl/back", ledIndex, *ledCol);
			};
			0.02.wait
		}
	}
};

// if hat clicked and nothing else is done,
/// -> release stores snapshot
// otherwise, hat was shift-key but for other buttons.

NTMI.nufo.encHatUsed = MFunc().add(\used, {
	if (MKtl(\nUFO).elAt(\encHat).isOn) {
		NTMI.nufo.encHatUsed = true;
	}
});

MKtl(\nUFO).elAt(\encHat).action.add(\snap, { |bt|
	if (bt.isOn) {
		NTMI.nufo.encHatUsed = false;
	} {
		if (NTMI.nufo.encHatUsed.not) {
			MFdef('snapshot').value;
		}
	}
});

////// add encHatUsed func to all buttons
MKtl(\nUFO).elAt(\bt, [0,1,2,3,    5,6,7]).do { |el|
	el.action.add(\enchat, NTMI.nufo.encHatUsed)
};
MKtl(\nUFO).elAt(\enc).action.add(\enchat, NTMI.nufo.encHatUsed);


// reset right-side back leds to their proper values
// e.g. after modal action of buttons for MainFX
NTMI.nufo.resetModePreLEDs = MFunc().add(\reset, { |delay=0.1|
	defer ({
		"NTMI.nufo.resetModePreLEDs".postln;
		NTMI.nufo.nUFO.setModeIndex(NTMI.nufo.nUFO.modeIndex);
		NTMI.inph.setWPreIndex(NTMI.inph.at(\presIndex));
	}, delay);
});


MKtl(\nUFO).elAt(\modSw).action.add(\modal, {|bt|
	// do modal action on release, i.e. if
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: main fx rand
		{ MKtl(\nUFO).elAt(\encHat).isOn }
		{
			MFdef(\mainPreStep).value(nil);
			NTMI.nufo.resetModePreLEDs.value(0.1);
			NTMI.nufo.encHatUsed.value;
		}

		// slot mode: rand preset
		{ NTMI.nufo.leftDown.size > 0 }
		{
			NTMI.nufo.leftDown.do { |slotIndex|
				// "% - choose rand ndef preset.\n".postf(NTMI.ndefs[slotIndex]);
				NTMI.pre.stepNdefInf( NTMI.ndefs[slotIndex], nil )
			};
			NTMI.nufo.leftWasUsed = true;
		}
		// default: step inph preset
		{
			NTMI.nufo.modeStep(1);
			NTMI.nufo.resetModePreLEDs.value(0.1);
		}

	}
});

// preUp button:
MKtl(\nUFO).elAt(\steps)[0].action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: main fx up by one
		{ MKtl(\nUFO).elAt(\encHat).isOn }
		{
			MFdef(\mainPreStep).value(1);
			NTMI.nufo.resetModePreLEDs.value(0.1);
			NTMI.nufo.encHatUsed.value;
		}

		// slot mode: ndef preset up by one
		{ NTMI.nufo.leftDown.size > 0 }
		{
			NTMI.nufo.leftDown.do { |slotIndex|
				"%  ndef preset up 1.\n".postf(NTMI.ndefs[slotIndex]);
				NTMI.pre.stepNdefInf( NTMI.ndefs[slotIndex], 1 );
				// reset button color
				NTMI.nufo.nUFO.setModeIndex(NTMI.nufo.nUFO.modeIndex);
				NTMI.inph.setWPreIndex(NTMI.inph.at(\presIndex));
			};
			NTMI.nufo.leftWasUsed = true;
		}
		// default: step inph preset
		{ NTMI.inph.stepWPre(1) }

	}
});

// preDown button - same but -1
MKtl(\nUFO).elAt(\steps)[1].action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: main fx down by one
		{ MKtl(\nUFO).elAt(\encHat).isOn }
		{
			MFdef(\mainPreStep).value(-1);
			NTMI.nufo.resetModePreLEDs.value(0.1);
			NTMI.nufo.encHatUsed.value;
		}

		// slot mode: ndef preset down by one
		{ NTMI.nufo.leftDown.size > 0 }
		{
			NTMI.nufo.leftDown.do { |slotIndex|
				"%  ndef preset down 1.\n".postf(NTMI.ndefs[slotIndex]);
				NTMI.pre.stepNdefInf( NTMI.ndefs[slotIndex], -1 );
				// reset button color
				NTMI.nufo.nUFO.setModeIndex(NTMI.nufo.nUFO.modeIndex);
				NTMI.inph.setWPreIndex(NTMI.inph.at(\presIndex));
			};
			NTMI.nufo.leftWasUsed = true;
		}
		// default: step inph preset down
		{ NTMI.inph.stepWPre(-1) }

	}
});

// -- base mode -> inc/dev main volume
// -- hat  mode -> zoom!
// -- slot mode -> inc/dec slot volume
// -- sl+hat mode -> inc/dec sounds

MKtl(\nUFO).elAt(\enc).action.add(\modal, { |enc|
	var slotDown = (NTMI.nufo.leftDown.size > 0).binaryValue;
	var hatDown = MKtl(\nUFO).elAt(\encHat).isOn.binaryValue;
	var modeNum = slotDown * 2 + hatDown;

	modeNum.switch(
		0, {
			// "base: mainVolStep".postln;
			MFdef(\mainVolStep).(enc.deviceValue);
		},
		1, {
			// "hat: zoom".postln;
			NTMI.incZoom(enc.deviceValue * \zoom.asSpec.step.max(0.01));
		},
		2, {

			NTMI.nufo.leftWasUsed = true;
			// "NTMI.nufo.leftWasUsed: %\n".postf(NTMI.nufo.leftWasUsed);
			NTMI.nufo.leftDown.do { |slotIndex|
				"SLOT %: ".postf(slotIndex);
				MFdef(\ndefVolStep).(NTMI.slots.actives[slotIndex], enc.deviceValue);
			};
		},
		3, {
			// "slotHat - select sound: ".post;
			NTMI.nufo.leftWasUsed = true;
			// "NTMI.nufo.leftWasUsed: %\n".postf(NTMI.nufo.leftWasUsed);
			NTMI.nufo.leftDown.do { |slotIndex|
				NTMI.slots.stepNext(slotIndex, enc.deviceValue);
				"   % : %\n".postf(slotIndex, NTMI.slots[slotIndex]);
			};

		}
	);
	enc.deviceValue = 0;
});


// ///////////////////////////////////////////////////////////////
// //// I M U
// ///////////////////////////////////////////////////////////////

MKtl(\nUFO).collectivesDict[\imu].action = {
	// trigger the action only once (influx calc)
	MFdef(\nUFOImuFunc).value;
};

// set the first 9 values of the inphlux from the imu params:
NTMI.inphlux.addHalo(\imuNames, NTMI.inphlux.inNames.keep(9));

NTMI.nufo.imuPadFuncName = \setAbs;

MFdef(\nUFOImuFunc).add(\setAbs, {
	var imuInvalsBi = MKtl(\nUFO).elAt(\imu9).value.unibi;
	var calibImuValsBi = imuInvalsBi - NTMI.zero.imu;
	var keysvals = NTMI.inphlux.getHalo(\imuNames).collect { |name, i|
		var value = calibImuValsBi[i];
		[name, value]
	}.flat;
	NTMI.nufo.rawImuBiValues = imuInvalsBi;
	NTMI.nufo.calibImuValsBi = calibImuValsBi;
	NTMI.nufo.calibImuVals = calibImuValsBi.biuni;

	// "*** imufunc: ".post; keysvals.round(0.0001).postln;
	NTMI.inphlux.set(*keysvals);
}, false);

MFdef(\nUFOImuFunc).disable(\setAbs);

MFdef(\nUFOImuFunc).add(\set, {
	// "nUFOImuFunc, set: %\n".postf(NTMI.nufo.imuPadFuncName);
	MFdef(\nUFOImuFunc).at(NTMI.nufo.imuPadFuncName).value
});


/*
MFdef(\nUFOImuFunc).disable( \setInflux );
MFdef(\nUFOImuFunc).enable( \setInflux );
*/

NTMI.nufo.skipLogin.stop.free;
NTMI.nufo.skipLogin = SkipJack({
	try { MKtl(\nUFO).device.source.sendMsg("/ntmi/login") }
}, 0.5);

// for monitoring the incoming osc activity by timetag
NTMI.nufo.lastInTime = 0;
NTMI.nufo.timeSinceLast = { Main.elapsedTime - NTMI.nufo.lastInTime };

OSCdef(\imuAlive, { |msg, time|
	NTMI.nufo.lastInTime = time;
}, "/imu").permanent_(true);

///////// update slot LEDs
NTMI.nufo.skip.stop.free;
NTMI.nufo.skip = SkipJack({
	var cols = [[0,0,0], [0,1,0]], col;
	fork {
		MKtl(\nUFO).elAt(\led, \bk, (0..3)).do { |led, ledi|
			var isPlaying = NTMI.ndefs[ledi].monitor.isPlaying;
			var newval = isPlaying.binaryValue;
			if (newval != led.prevValue) {
				led.value = newval;
				col = cols[newval];
				// "nUFO: sending changed color to led_bk %: %\n".postf(ledi, col);
				2.do {
					rrand(0.03, 0.07).wait;
					try {
						MKtl(\nUFO).device.source.sendMsg("/ntmi/ledCtl/back", ledi, *col);
					}
				};
			};

		};
	}
}, 0.05);


///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
//// Caps
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////

(
NTMI.inphlux.addHalo(\padNames, NTMI.inphlux.inNames.copyRange(9, 16));

MFdef(\capsToInph).add(\setAbs, {
	// var debug = "capsToInph setAbs".postln;
	var influx = NTMI.inphlux;
	var pads = MKtl(\nUFO).elAt(\cap);
	var padInNames = NTMI.inphlux.getHalo(\padNames);
	var keysValues = pads.collect { |pad, i|
		[ padInNames[i], pad.value]
	}.flat;
	NTMI.inphlux.set(*keysValues);
});

////// this is the action that gets triggered
////// when values come in from the ntmi -
////// coompensate for base values,
////// and send the final values only once.

MKtl(\nUFO).collAt('caps').groupAction = nil;

MKtl(\nUFO).addHalo(\capLedThresh, 0.3);

NTMI.nufo.capsin = MFunc();
MKtl(\nUFO).collAt('caps').groupAction = NTMI.nufo.capsin;


NTMI.nufo.capsin.add(\set, { |coll|
	var capLedThresh = MKtl(\nUFO).getHalo(\capLedThresh);
	var values = coll.value;

	// reorder for proper order of pads and leds
	values = values[[1, 4, 0, 3, 5, 6, 2, 7]];
	NTMI.nufo.rawPads = values;

	// NTMI.zero.pads is the rest state of the pads
	// use it to stretch to a range of 0-1
	values.do { |rawval, i|
		var zeroOffset = NTMI.zero.pads.asArray.wrapAt(i) ? 0;
		var stretched = rawval.linlin(zeroOffset, 0.9, 0, 1);
		values.put(i, stretched);
	};

	// set element values back to the compensated values, no action
	MKtl(\nUFO).elAt('cap').value_(values);
	// trigger touch to inphlux only once ...
	MFdef(\capsToInph).value;

	// light up leds when pads are touched above thresh:
	fork {
		MKtl(\nUFO).elAt(\led, \fr).do { |led, i|
			var newval = (values[i] > capLedThresh).binaryValue;
			if (newval != led.value) {
				led.value = newval;
				0.003.wait;
			}
		}
	}
});

// individual pad action - useful for guis only
/// do global set only once, from MFdef(\touchToInph)
MKtl(\nUFO).elAt(\cap).do { |pad, i|
	pad.action.add(\setAbs, {|ana|
		var name = 	NTMI.inphlux.getHalo(\padNames).clipAt(i);
		NTMI.inphlux.set(name, ana.value.pow(3));
		//.pow(6));
		// the pow(6) helps toflatten the steep curve of the FSRs as they are now.
		ana.value
	})
};
);
);
