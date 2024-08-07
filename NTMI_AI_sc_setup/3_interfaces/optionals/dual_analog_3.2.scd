///// ******** dual_analog_3_2 Gamepad patch *********

/*
MKtl.find(\hid);
MKtl('dual_analog_3_2').gui;

There are 4 slots with named sounds - see the left side views.

1. They can be toggled on/off separately: press Buttons 1-4

2. they can be played via influx:
just move joysticks (left and right, X and Y),
and the throttle controls (left and right)

3. Volume can be played and set in 3 ways:
- a. momentary main volume: move left-side wheel
- b. set center of main volume:
hold button 10 down, set with wheel, release button 10, release wheel
-> main volume center is where wheel was when button 10 released.
- c. individual sound volume:
hold one of buttons 1-4, move wheel to set volume, release button


4. Influx behavior has 6 different presets;
- switch influx presets by pressing joystick hat buttons
left hat for down by one,
right hat for up by one,
both for random choice of influx preset

5. sound preset choices:
- hold one of button 1-4, and:
press compass down on left  side for next preset DOWN of that sound,
press compass down on right side for next preset  UP  of that sound,
press button 9                   for random preset    of that sound.

6. sound functions in each slot can be chosen from a repertoire of 20+ choices.
- hold one of button 1-4, and:
press compass down on bottom for next sound choice DOWN in that slot,
press compass down on top    for next sound choice  UP  in that slot,
press button 10              for random next sound      in that slot.

7. MainFX presets:
The nine MainFX presets, named 'theology', 'magic', etc,
can be switched stepped or jumped thru:
- press button 7 for lower preset,
button 8 for next higher preset,
both for a randomly chosen preset.

8. saving snapshots:
When you like the way the active sound processes sound right now,
press button 6 - right shoulder button - to save the current settings as a preset.
This will be stored under a temporary name like "adc_190805_221134",
which you can later change and keep.

9. Other windows on MakeGui window buttons:
All buttons (except the last 2) open GUIs for parts of the nUFO machinery,
and push them to the front.
hold down the option key to force-remake the window if needed.

///////// tests
MKtl('dual_analog_3_2').openDevice;
MKtl('dual_analog_3_2').gui.showLabels;
MKtl('dual_analog_3_2').elAt(\bt, 0).dump

*/

NTMI.dual_analog_3_2 = NTMI.dual_analog_3_2 ? ();
///// look for wired and wireless
if (MKtlLookup.findByIDInfo("Thrustmaster dual analog 3.2_Thrustmaster").size == 1
	or: (MKtlLookup.findByIDInfo("Thrustmaster dual analog 3.2_Thrustmaster").size == 1)) {
	"*** Dual Analog 3.2  found!".postln;
	MKtl.all['dual_analog_3_2'].free;
	MKtl('dual_analog_3_2', "*dual-analog-3.2");
};

if (MKtl('dual_analog_3_2').isNil) {
	"No Dual Analog 3.2 Gamepad found - creating virtual one.".postln;
	MKtl.all['dual_analog_3_2'].free;
	MKtl('dual_analog_3_2', "*dual-analog-3.2");
};
"*** Dual Analog 3.2 Gamepad loading ...".postln;

// prepare all elements for debugging:
MKtl('dual_analog_3_2').elementsDict.do(_.action_(MFunc()));
MKtl('dual_analog_3_2').elementsDict.do { |el|
	el.action.add(\post, { |el| [el.name, el.value.round(0.0001)].postln })
};

MKtl('dual_analog_3_2').elementsDict.do { |el| el.action.enable(\post) };
MKtl('dual_analog_3_2').elementsDict.do { |el| el.action.disable(\post) };

//////// NAME ElementGroups
////////// 4 joyaxes
MKtl('dual_analog_3_2').addNamed(\joyAxes,
	MKtl('dual_analog_3_2').elAt(\joy, nil, [\x, \y]).flat
);

NTMI.dual_analog_3_2.vols = ();
NTMI.dual_analog_3_2.selectedSlots = List[];


// 4 SOUND BUTTONS:
MKtl('dual_analog_3_2').addNamed(\sndButs, MKtl('dual_analog_3_2').elAt(\bt, (0..3)));
NTMI.dual_analog_3_2.sndButs = MKtl('dual_analog_3_2').elAt(\sndButs);

// soundbuttons 1-4 turn 4 slots on/off
MKtl('dual_analog_3_2').elAt(\sndButs).do { |bt, i|
	bt.elemDesc.label = "snd % play".format(i+1);
	bt.action.add(\toggle, {
		if (bt.isOn) {
			NTMI.dual_analog_3_2.selectedSlots.add(i).postln;
			if (NTMI.dual_analog_3_2.mode.isNil) {
				"entering slot mode".postln;
				NTMI.dual_analog_3_2.mode = \slot;
			};
		} {
			// do action based on mode:
			(
				slot: {
					if (NTMI.dual_analog_3_2.slotModeWasUsed != true) {
						NTMI.slots.toggleAt(i);
					};
				}
			)[NTMI.dual_analog_3_2.mode].value;
			// when last slot button is released, remove mode
			if (bt.parent.value.sum == 0) {
				NTMI.dual_analog_3_2.mode = nil;
				NTMI.dual_analog_3_2.slotModeWasUsed = false;
				"leaving slot mode".postln;
			};
			NTMI.dual_analog_3_2.selectedSlots.remove(i);
			NTMI.dual_analog_3_2.selectedSlots.postln;
		}
	})
};

NTMI.dual_analog_3_2.zoom = 0.5;

////////// 4 joyaxes set relative influx inputs
MKtl('dual_analog_3_2').elAt(\joyAxes).do { |el, i|
	var inIndex = [9, 11, 12, 13][i];
	var sign = (x: 1, y: -1)[el.key];
	el.elemDesc.label = "infl" + inIndex;
	el.action = { |el|
		if (NTMI.dual_analog_3_2.influxMode == \setAbs) {
			NTMI.inphlux.set(inIndex, el.value.unibi);
		} {
			MFdef(\setRelInf).(
				inIndex,
				(el.value - el.prevValue),
				NTMI.zoom * NTMI.dual_analog_3_2.zoom * sign
			);
		}
	}
};


// joyhat L R switches prev/next preset on inphlux, both: rand
/// FIXME: mark modalAction has happened,
// dont do basic action on second release

NTMI.dual_analog_3_2.hatWasUsed = false;
MKtl('dual_analog_3_2').elAt(\joy, \l, \hat).elemDesc.label = "INPH prev";
MKtl('dual_analog_3_2').elAt(\joy, \l, \hat).action = { |hat|
	if (hat.isOn.not) {
		if (MKtl('dual_analog_3_2').elAt(\joy, \r, \hat).isOn) {
			NTMI.dual_analog_3_2.hatWasUsed = true;
			NTMI.inph.stepWPre(nil); // rand
		} {
			if (NTMI.dual_analog_3_2.hatWasUsed.not) {
				NTMI.inph.stepWPre(-1); // prev
			};
			NTMI.dual_analog_3_2.hatWasUsed = false;
		};
	};
};

MKtl('dual_analog_3_2').elAt(\joy, \r, \hat).elemDesc.label = "INPH next";
MKtl('dual_analog_3_2').elAt(\joy, \r, \hat).action = { |hat|
	hat.elemDesc.label = "prev pre";
	if (hat.isOn.not) {
		if (MKtl('dual_analog_3_2').elAt(\joy, \l, \hat).isOn) {
			NTMI.inph.stepWPre(nil); // rand
			NTMI.dual_analog_3_2.mfxWasUsed = true;
		} {
			if (NTMI.dual_analog_3_2.hatWasUsed.not) {
				NTMI.inph.stepWPre(1); // next
			};
			NTMI.dual_analog_3_2.hatWasUsed = false;
		};
	};
};

// but 7 & 8 switch materfx presets prev/next, both: rand
/// FIXME: mark modalAction has happened,
// dont do basic action on second release

NTMI.dual_analog_3_2.mfxWasUsed = false;
MKtl('dual_analog_3_2').elAt(\bt, \7).elemDesc.label = "MFX prev";
MKtl('dual_analog_3_2').elAt(\bt, \7).action = { |bt|
	if (bt.isOn.not) {
		if (MKtl('dual_analog_3_2').elAt(\bt, \8).isOn) {
			NTMI.dual_analog_3_2.mfxWasUsed = true;
			MFdef('mainPreStep').value(nil); // rand
		} {
			if (NTMI.dual_analog_3_2.mfxWasUsed.not) {
				MFdef('mainPreStep').value(-1); // prev
			};
			NTMI.dual_analog_3_2.mfxWasUsed = false;
		};
	};
};
MKtl('dual_analog_3_2').elAt(\bt, \8).elemDesc.label = "MFX next";
MKtl('dual_analog_3_2').elAt(\bt, \8).action = { |bt|
	if (bt.isOn.not) {
		if (MKtl('dual_analog_3_2').elAt(\bt, \7).isOn) {
			NTMI.dual_analog_3_2.mfxWasUsed = true;
			MFdef('mainPreStep').value(nil); // rand
		} {
			if (NTMI.dual_analog_3_2.mfxWasUsed.not) {
				MFdef('mainPreStep').value(1); // prev
			};
			NTMI.dual_analog_3_2.mfxWasUsed = false;
		};
	};
};

"dual_analog_3_2: gets  here?".postln;

// use compass for navigation of presets and sounds:
MKtl('dual_analog_3_2').elAt(\compass).elemDesc.label = "step pre";

MKtl('dual_analog_3_2').elAt(\compass).action.add(\stepPre, { |cp|
	var val = (cp.value * 7).round.asInteger;
	var slotFlags = MKtl('dual_analog_3_2').elAt(\sndButs).value.collect(_ > 0);
	if (NTMI.dual_analog_3_2.mode == \slot) {
		NTMI.dual_analog_3_2.slotModeWasUsed = true;
		val.switch(
			6, {
				slotFlags.do { |down, slIndex|
					if (down) { NTMI.pre.stepNdefInf(NTMI.ndefs[slIndex], -1) }
				};
				"pre down" },
			2, {
				slotFlags.do { |down, slIndex| if (down) {
					NTMI.pre.stepNdefInf(NTMI.ndefs[slIndex], 1) }
				};
				"pre up" },
			4, {
				slotFlags.do { |down, slIndex| if (down) { NTMI.slots.stepNext(slIndex, -1) } };
				"snd down"
			},
			0, {
				slotFlags.do { |down, slIndex| if (down) { NTMI.slots.stepNext(slIndex, 1) } };
				"snd up" }
		)
	};
});

// bt 9 -> random preset
MKtl('dual_analog_3_2').elAt(\bt, \9).elemDesc.label = "rand pre";
MKtl('dual_analog_3_2').elAt(\bt, \9).action.add(\randPre, {
	if (NTMI.dual_analog_3_2.mode == \slot) {
		NTMI.dual_analog_3_2.sndButs.do { |bt, slIndex|
			if (bt.isOn) { NTMI.pre.stepNdefInf(NTMI.ndefs[slIndex], nil) }
		}
	}
});

// bt 9 -> random sound func
MKtl('dual_analog_3_2').elAt(\bt, \10).elemDesc.label = "rand snd";
MKtl('dual_analog_3_2').elAt(\bt, \10).action.add(\randPre, {
	if (NTMI.dual_analog_3_2.mode == \slot) {
		NTMI.dual_analog_3_2.sndButs.do { |bt, slIndex|
			if (bt.isOn) { NTMI.slots.stepNext(slIndex, nil) }
		}
	}
});

MKtl('dual_analog_3_2').elAt(\bt, \6).elemDesc.label = "snap Pre";
MKtl('dual_analog_3_2').elAt(\bt, \6).action.add(\snapPre, {
	MFdef('snapshot').value;
});

MKtl('dual_analog_3_2');
