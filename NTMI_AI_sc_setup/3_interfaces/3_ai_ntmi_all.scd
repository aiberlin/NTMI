/*

TODO:
- ntmi_esp should be shown on maingui
+ change colors on preButs - 6 cols, red, yell, green, cyan, blue, magenta



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

//////// calibrate imu and pads:
//////// capture incoming values for a while
//////// imu zero values by averaged
//////// pad zero values by maxes + average deviation/jitter
MFdef(\calibrate).add(\set, { |dt = 1, whenDone|

	"*** calibrating nUFO ***".postln;
	q.capture = ();

	q.capture.imu = List[];
	q.capture.pads = List[];

	MFdef(\ntmiImuFunc).add(\capture, {
		q.capture.imu.add(q.osc.rawImuBiValues);
	});

	MFdef(\capsin).add(\capture, {
		q.capture.pads.add(q.osc.rawPads);
	});

	defer ({
		var padsflopped, padmeans, padmaxes, padjitters, padoffsets;
		MFdef(\ntmiImuFunc).remove(\capture);
		MFdef(\capsin).remove(\capture);

		"*** nUFO calibration: ***".postln;
		"q.zero.imu = mean of % captured values:\n".postf( q.capture.imu.size);
		q.zero.imu = q.capture.imu.mean;
		q.zero.imu.round(0.001).postln;

		padsflopped = q.capture.pads.flop;
		padmaxes = padsflopped.collect(_.maxItem);
		padmeans = padsflopped.collect(_.mean);
		padjitters = padsflopped.collect { |vals, i| (vals - padmeans[i]).abs.maxItem };

		"q.zero.pads = maxes + 0.5 jitter of % captured values\n".postf( q.capture.pads.size);
		q.zero.pads = padmaxes + (padjitters * 0.5);
		q.zero.pads.round(0.001).postln;
		q.zero.write;
		whenDone.value;
		"*** nUFO calibrated. ***".postln;
	}, dt);
});

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
		var slotObj = q.slots.actives[i];

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
				// "... (right mode for slot buttons) ...".postln;
				if (MKtl(\ntmi).elAt(\encHat).isOn) {
					MFdef(\clutch).value(slotObj);
				};
				q.osc.rightWasUsed = true;
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
			// "rightdown: %\n".postf(q.osc.rightDown);
		} {
			// button was released: remove shifter
			q.osc.rightDown.removeAllSuchThat(_ == btname);
			// "rightdown: %\n".postf(q.osc.rightDown);
		}
	});
};

/////////// add funcs to inphMode switching so NTMI can do it /////////

MFdef(\touchON).add(\ntmi, {
	"ntmi - touchON".postln;
	MFdef(\capsToInph).enable(\set);
	q.slots.nowPlaying.do { |obj|
		if (q.inph.decoupled.includes(obj.key).not) {
			MFdef(\inphCouple).(obj)
		}
	}
});

MFdef(\touchOFF).add(\ntmi, {
	"ntmi - touchOFF".postln;
	q.slots.nowPlaying.do { |nd| q.inphlux.action.disable(nd.key) };
	MFdef(\capsToInph).disable(\set);
	q.inphlux.set(*q.inphlux.getHalo(\padNames).collect([_, 0]).flat);
});

MFdef(\moveON).add(\ntmi, {
	"ntmi - moveON".postln;
	MFdef(\ntmiImuFunc).enable(\setInflux);
	MKtl(\ntmi).elAt('imu9').do { |ax| ax.action.enable(\setInflux) };
	q.slots.nowPlaying.do { |obj|
		if (q.inph.decoupled.includes(obj.key).not) {
			MFdef(\inphCouple).(obj);
		}
	}
});

MFdef(\moveON).value;

MFdef(\moveOFF).add(\ntmi, {
	"ntmi - moveOFF".postln;
	MFdef(\ntmiImuFunc).disable(\setInflux);
	MKtl(\ntmi).elAt('imu9').do { |ax| ax.action.disable(\setInflux) };
	/////// pads set inphlux in unipolar, 0-1 range!
	q.inphlux.set(*q.inphlux.getHalo(\imuNames).collect([_, 0]).flat);
});

MFdef(\binON).add(\ntmi, {
	"ntmi - binON".postln;
	MFdef(\capsToInph).enable(\binKey);
	// q.slots.nowPlaying.do { |obj|
	// 	MFdef(\inphDecouple).(obj)
	// };
});

MFdef(\binOFF).add(\ntmi, {
	"ntmi - binOFF".postln;
	MFdef(\capsToInph).disable(\binKey);
});

// show modes as colors:
// green = both, red = move, blue = touch, black = off

MKtl(\ntmi).elAt(\modSw).action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: main fx rand
		{ MKtl(\ntmi).elAt(\encHat).isOn }
		{ MFdef(\mainPreStep).value(nil) }

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

	var msg = [
		[ 0, 1, 0 ], // green is full
		[ 1, 0, 0 ], // red is touch
		[ 0, 0, 1 ], // [ blue is move ]
		[ 0, 0, 0 ]  // [ black is off ]
	].clipAt(q.inph.modeIndex);
	// send 3 times to make sure it arrives
	fork { 3.do {
		0.02.wait;
		MKtl(\ntmi).device.source.sendMsg("/ntmi/ledCtl/back", 7, *msg.keep(3));
	} };
});


MFdef(\setInphWPre).add(\setLEDs, {
	fork {
		var ledCol = q.inph.currPresetCol.asArray.keep(3).round.collect(_.asInteger);
		0.1.wait;
		[5, 6].do { |ledIndex|
			MKtl(\ntmi).device.source.sendMsg("/ntmi/ledCtl/back", ledIndex, *ledCol);
			0.02.wait
		}
	}
});

//// should be :
// if hat clicked and nothing else is done,
/// -> release stores snapshot
// otherwise, hat was shift but for other buttons.

MFdef(\encHat).add(\used, {
	if (MKtl(\ntmi).elAt(\encHat).isOn) {
		"q.osc.encHatUsed = true ".postln;
		q.osc.encHatUsed = true;
	}
});

MFdef(\encHat).value;

MKtl(\ntmi).elAt(\encHat).action.add(\snap, { |bt|
	if (bt.isOn) {
		q.osc.encHatUsed = false;
	} {
		if (q.osc.encHatUsed.not) {
			'snapshot happens too often ... FIXME.'.postln;
			// MFdef('snapshot').value;
			q.osc.encHatUsed = true;
		}
	}
});

//////
MKtl(\ntmi).elAt(\bt, [0,1,2,3,    5,6,7]).do { |el| el.action.add(\enchat, MFdef(\encHat)) };
MKtl(\ntmi).elAt(\enc).action.add(\enchat, MFdef(\encHat));


// reset right back leds to their proper values
// e.g. after modal action of buttons for MainFX
MFdef(\resetModePreLEDs).add(\reset, { |delay=0.1|
	defer ({
		MFdef(\resetModePreLEDs).postln;
		MFdef(\inphModeSetIndex).value(q.inph.modeIndex);
		MFdef(\setInphWPre).value(q.inph.at(\presIndex));
	}, delay);
});


MKtl(\ntmi).elAt(\modSw).action.add(\modal, {|bt|
	// do modal action on release, i.e. if
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: main fx rand
		{ MKtl(\ntmi).elAt(\encHat).isOn }
		{
			MFdef(\mainPreStep).value(nil);
			MFdef(\resetModePreLEDs).value(0.1);
		}

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
		{
			MFdef(\inphModeStep).value(1);
			MFdef(\resetModePreLEDs).value(0.1);
		}

	}
});

// preUp button:
MKtl(\ntmi).elAt(\steps)[0].action.add(\modal, {|bt|
	// do modal action on release
	// [bt.name, bt.value].postln;
	if (bt.value == 0) {
		case
		// hat is down: main fx up by one
		{ MKtl(\ntmi).elAt(\encHat).isOn }
		{
			MFdef(\mainPreStep).value(1);
			MFdef(\resetModePreLEDs).value(0.1);
		}

		// slot mode: rand preset
		{ q.osc.leftDown.size > 0 }
		{
			q.osc.leftDown.do { |slotIndex|
				"%  ndef preset up 1.\n".postf(q.ndefs[slotIndex]);
				q.pre.stepNdefInf( q.ndefs[slotIndex], 1 );
				// reset button color
				MFdef(\inphModeSetIndex).value(q.inph.modeIndex);
				MFdef(\setInphWPre).value(q.inph.at(\presIndex));
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
		// hat is down: main fx down by one
		{ MKtl(\ntmi).elAt(\encHat).isOn }
		{
			MFdef(\mainPreStep).value(-1);
			MFdef(\resetModePreLEDs).value(0.1);
		}

		// slot mode: ndef preset down by one
		{ q.osc.leftDown.size > 0 }
		{
			q.osc.leftDown.do { |slotIndex|
				"%  ndef preset down 1.\n".postf(q.ndefs[slotIndex]);
				q.pre.stepNdefInf( q.ndefs[slotIndex], -1 );
				// reset button color
				MFdef(\inphModeSetIndex).value(q.inph.modeIndex);
				MFdef(\setInphWPre).value(q.inph.at(\presIndex));
			};
			q.osc.leftWasUsed = true;
		}
		// default: step inph preset down
		{ MFdef(\stepInphWPre).value(-1) }

	}
});

// -- base mode -> inc/dev main volume
// -- hat  mode -> zoom!
// -- slot mode -> inc/dec slot volume
// -- sl+hat mode -> inc/dec sounds

MKtl(\ntmi).elAt(\enc).action.add(\modal, { |enc|
	var slotDown = (q.osc.leftDown.size > 0).binaryValue;
	var hatDown = MKtl(\ntmi).elAt(\encHat).isOn.binaryValue;
	var modeNum = slotDown * 2 + hatDown;

	modeNum.switch(
		0, {
			// "base: mainStepVol".postln;
			MFdef(\mainStepVol).(enc.deviceValue);
		},
		1, {
			// "hat: zoom".postln;
			q.incZoom(enc.deviceValue * \zoom.asSpec.step.max(0.01));
		},
		2, {

			q.osc.leftWasUsed = true;
			// "q.osc.leftWasUsed: %\n".postf(q.osc.leftWasUsed);
			q.osc.leftDown.do { |slotIndex|
				"SLOT %: ".postf(slotIndex);
				MFdef(\stepVol).(q.slots.actives[slotIndex], enc.deviceValue);
			};
		},
		3, {
			// "slotHat - select sound: ".post;
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

q.osc.ntmiSkipLogin.stop.free;
q.osc.ntmiSkipLogin = SkipJack({ try { MKtl(\ntmi).device.source.sendMsg("/ntmi/login") } }, 0.5);

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
}, 0.05);


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
////// when values come in from the ntmi -
////// coompensate for base values,
////// and send the final values only once.

MKtl(\ntmi).collAt('caps').groupAction = nil;

MKtl(\ntmi).addHalo(\capLedThresh, 0.3);

MKtl(\ntmi).collAt('caps').groupAction = MFdef(\capsin);

MFdef(\capsin).add(\set, { |coll|
	var capLedThresh = MKtl(\ntmi).getHalo(\capLedThresh);
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

	// set element values back to the compensated values, no action
	MKtl(\ntmi).elAt('cap').value_(values);
	// trigger touch to inphlux only once ...
	MFdef(\capsToInph).value;

	// light up leds when pads are touched above thresh:
	fork {
		MKtl(\ntmi).elAt(\led, \fr).do { |led, i|
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

