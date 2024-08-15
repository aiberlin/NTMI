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
NTMI.nUFO = NTMI.nUFO ? ();

///////// make a new nUFO MKtl from desc in this folder:
MKtl.all.at(\nUFO).free;
MKtl(\nUFO, "nUFO");


// send login message to nUFO, so it knows where to send
NTMI.nUFO.skipLogin.stop.free;
NTMI.nUFO.skipLogin = SkipJack({
	try { MKtl(\nUFO).device.source.sendMsg("/ntmi/login") }
}, 0.5);

// this is for logging into NTMI-xxx networks only:
// should eventually be done automatically from a listening OSCdef
MKtl(\nUFO).device.updateDstAddr("169.254.1.1", NetAddr.langPort);
MKtl(\nUFO).device.updateSrcAddr("169.254.1.1", NetAddr.langPort);


// **** initialize
MKtl(\nUFO).elAt(\enc).value_(0.5);

/// init all nUFO actions as MFuncs, provide posting
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
MKtl(\nUFO).elAt(\modSw).elemDesc.label_('nUFO Mode');


// prepare for modalization:
// left buttons set up modes for right side and <>
NTMI.nUFO.leftDown = List[];
NTMI.nUFO.rightDown = List[];
NTMI.nUFO.shiftWasUsed = false;
NTMI.nUFO.leftWasUsed = false;
NTMI.nUFO.rightWasUsed = false;

/*
//////// to test left side actions:
NTMI.nUFO.rightDown.clear.add(\preUp);
NTMI.nUFO.rightDown.clear.add(\preDown);
NTMI.nUFO.rightDown.clear.add(\touchMove);
NTMI.nUFO.rightDown.clear;
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
			NTMI.nUFO.leftDown.add(butIndex);
		} {
			// when button was released: remove shifter
			NTMI.nUFO.leftDown.removeAllSuchThat(_ == butIndex);
		}
	});

	// on button release, do the modal action:
	but.action.add(\modal, { |but|

		var actionFunc;
		var playsNow;
		var slotObj = NTMI.slots.actives[i];

		if (but.isOn.not) {
			// determine whether we are in a mode
			if (NTMI.nUFO.rightDown.size == 0) {
				// reset if we just left a mode
				if (NTMI.nUFO.leftWasUsed) {
					NTMI.nUFO.leftWasUsed = false;
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
				NTMI.nUFO.rightWasUsed = true;
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
			NTMI.nUFO.rightDown.add(btname);
			// "rightdown: %\n".postf(NTMI.nUFO.rightDown);
		} {
			// button was released: remove shifter
			NTMI.nUFO.rightDown.removeAllSuchThat(_ == btname);
			// "rightdown: %\n".postf(NTMI.nUFO.rightDown);
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
		{ NTMI.nUFO.leftDown.size > 0 }
		{
			NTMI.nUFO.leftDown.do { |slotIndex|
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

NTMI.nUFO.encHatUsed = MFunc().add(\used, {
	if (MKtl(\nUFO).elAt(\encHat).isOn) {
		NTMI.nUFO.encHatUsed = true;
	}
});

MKtl(\nUFO).elAt(\encHat).action.add(\snap, { |bt|
	if (bt.isOn) {
		NTMI.nUFO.encHatUsed = false;
	} {
		if (NTMI.nUFO.encHatUsed.not) {
			MFdef('snapshot').value;
		}
	}
});

////// add encHatUsed func to all buttons
MKtl(\nUFO).elAt(\bt, [0,1,2,3,    5,6,7]).do { |el|
	el.action.add(\enchat, NTMI.nUFO.encHatUsed)
};
MKtl(\nUFO).elAt(\enc).action.add(\enchat, NTMI.nUFO.encHatUsed);


// reset right-side back leds to their proper values
// e.g. after modal action of buttons for MainFX
NTMI.nUFO.resetModePreLEDs = MFunc().add(\reset, { |delay=0.1|
	defer ({
		"NTMI.nUFO.resetModePreLEDs".postln;
		NTMI.nUFO.setModeIndex(NTMI.nUFO.modeIndex);
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
			NTMI.nUFO.resetModePreLEDs.value(0.1);
			NTMI.nUFO.encHatUsed.value;
		}

		// slot mode: rand preset
		{ NTMI.nUFO.leftDown.size > 0 }
		{
			NTMI.nUFO.leftDown.do { |slotIndex|
				// "% - choose rand ndef preset.\n".postf(NTMI.ndefs[slotIndex]);
				NTMI.pre.stepNdefInf( NTMI.ndefs[slotIndex], nil )
			};
			NTMI.nUFO.leftWasUsed = true;
		}
		// default: step inph preset
		{
			NTMI.nUFO.modeStep(1);
			NTMI.nUFO.resetModePreLEDs.value(0.1);
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
			NTMI.nUFO.resetModePreLEDs.value(0.1);
			NTMI.nUFO.encHatUsed.value;
		}

		// slot mode: ndef preset up by one
		{ NTMI.nUFO.leftDown.size > 0 }
		{
			NTMI.nUFO.leftDown.do { |slotIndex|
				"%  ndef preset up 1.\n".postf(NTMI.ndefs[slotIndex]);
				NTMI.pre.stepNdefInf( NTMI.ndefs[slotIndex], 1 );
				// reset button color
				NTMI.nUFO.setModeIndex(NTMI.nUFO.modeIndex);
				NTMI.inph.setWPreIndex(NTMI.inph.at(\presIndex));
			};
			NTMI.nUFO.leftWasUsed = true;
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
			NTMI.nUFO.resetModePreLEDs.value(0.1);
			NTMI.nUFO.encHatUsed.value;
		}

		// slot mode: ndef preset down by one
		{ NTMI.nUFO.leftDown.size > 0 }
		{
			NTMI.nUFO.leftDown.do { |slotIndex|
				"%  ndef preset down 1.\n".postf(NTMI.ndefs[slotIndex]);
				NTMI.pre.stepNdefInf( NTMI.ndefs[slotIndex], -1 );
				// reset button color
				NTMI.nUFO.setModeIndex(NTMI.nUFO.modeIndex);
				NTMI.inph.setWPreIndex(NTMI.inph.at(\presIndex));
			};
			NTMI.nUFO.leftWasUsed = true;
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
	var slotDown = (NTMI.nUFO.leftDown.size > 0).binaryValue;
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

			NTMI.nUFO.leftWasUsed = true;
			// "NTMI.nUFO.leftWasUsed: %\n".postf(NTMI.nUFO.leftWasUsed);
			NTMI.nUFO.leftDown.do { |slotIndex|
				"SLOT %: ".postf(slotIndex);
				MFdef(\ndefVolStep).(NTMI.slots.actives[slotIndex], enc.deviceValue);
			};
		},
		3, {
			// "slotHat - select sound: ".post;
			NTMI.nUFO.leftWasUsed = true;
			// "NTMI.nUFO.leftWasUsed: %\n".postf(NTMI.nUFO.leftWasUsed);
			NTMI.nUFO.leftDown.do { |slotIndex|
				NTMI.slots.stepNext(slotIndex, enc.deviceValue);
				"   % : %\n".postf(slotIndex, NTMI.slots[slotIndex]);
			};

		}
	);
	enc.deviceValue = 0;
});


NTMI.nUFO.skipMFunc = NTMI.nUFO.skipMFunc ?? { MFunc() };

NTMI.nUFO.skipMFunc.add(\timeOut, {
	if (NTMI.nUFO.alive.not) {
		NTMI.nUFO.timeOut.value;
	};
});

///////// update slot LEDs
NTMI.nUFO.skip.stop.free;
NTMI.nUFO.skip = SkipJack(NTMI.nUFO.skipMFunc, 0.05, false, \nUFOSkip);

NTMI.nUFO.skipMFunc.add(\updateSlotLEDs, {
	var cols = [[0,0,0], [0,1,0]], col;
	if (MKtl(\nUFO).hasDevice) {
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
	};
});
);
