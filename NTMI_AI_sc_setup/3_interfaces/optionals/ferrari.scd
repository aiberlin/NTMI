///// ******** FERRARI Gamepad patch for Liz Allbee *********
///// ********     adapted into NTMI / UFO app      *********


/*
MKtl.find(\hid);
MKtl(~ferrari).gui;

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

- NTMI_Main opens or remakes the main gui window.
- ntmi opens a GUI for the NTMI/nUFO interface (for debugging)
- inphlux opens a GUI for the Influx which shows the current weights and in/out values
- slotSounds opens a window showing editors for the sounds in the four slots
- liveInput allows editing the liveInput process used by the xf-sounds
- ndefMixer opens a Mixer for all available Ndefs = sound processes
- mainFX opens a GUI for the MainFX section
- nanoKtl opens a GUI for a korg nanoKontrol faderbox
- ferrari opens a GUI for a Thrustmaster Ferrari gamepad
- uc4 opens a GUI for a FaderFox UC4 faderbox
- ndefPresets opens a GUI for trying out and editing the sound presets
- z_CLOSEALL closes all windows (except MakeGui)
- z_setAll posts the current positions of all open windows as code,
so the positions can be stored and reset to these  positions.



///////// tests
MKtl(~ferrari).openDevice;
MKtl(~ferrari).gui.showLabels;
MKtl(~ferrari).elAt(\bt, 0).dump

*/

~ferrari = ~ferrari ? \ferrari;
NTMI.put(~ferrari, NTMI.at(~ferrari) ? ());

///// look for wired and wireless
if (MKtlLookup.findByIDInfo("Run'N' Drive_Thrustmaster").size == 1) {
	"*** wired Ferrari  found!".postln;
	MKtl.all[~ferrari].free;
	MKtl(~ferrari, "*run-n-drive");
} {
	if (MKtlLookup.findByIDInfo("Run'N' Drive Wireless_Thrustmaster").size == 1) {
		"*** wireless Ferrari  found!".postln;
		MKtl.all[~ferrari].free;
		MKtl(~ferrari, "*run-n-drive-wireless");
	};
};

if (MKtl(~ferrari).isNil) {
	"No Ferrari Gamepad found - creating virtual one.".postln;
	MKtl.all[~ferrari].free;
	MKtl(~ferrari, "*run-n-drive");
};
"*** Ferrari Gamepad loading ...".postln;

// prepare all elements for debugging:
MKtl(~ferrari).elementsDict.do(_.action_(MFunc()));
MKtl(~ferrari).elementsDict.do { |el|
	el.action.add(\post, { |el| [el.name, el.value.round(0.0001)].postln })
};

MKtl(~ferrari).elementsDict.do { |el| el.action.enable(\post) };
MKtl(~ferrari).elementsDict.do { |el| el.action.disable(\post) };

//////// NAME ElementGroups
////////// 4 joyaxes
MKtl(~ferrari).addNamed(\joyAxes,
	MKtl(~ferrari).elAt(\joy, nil, [\x, \y]).flat
);

NTMI.ferrari.vols = ();
NTMI.ferrari.selectedSlots = List[];


// 4 SOUND BUTTONS:
MKtl(~ferrari).addNamed(\sndButs, MKtl(~ferrari).elAt(\bt, (0..3)));
NTMI.ferrari.sndButs = MKtl(~ferrari).elAt(\sndButs);

// soundbuttons 1-4 turn 4 slots on/off
MKtl(~ferrari).elAt(\sndButs).do { |bt, i|
	bt.elemDesc.label = "snd % play".format(i+1);
	bt.action.add(\toggle, {
		if (bt.isOn) {
			NTMI.ferrari.selectedSlots.add(i).postln;
			if (NTMI.ferrari.mode.isNil) {
				"entering slot mode".postln;
				NTMI.ferrari.mode = \slot;
			};
		} {
			// do action based on mode:
			(
				slot: {
					if (NTMI.ferrari.slotModeWasUsed != true) {
						NTMI.slots.toggleAt(i);
					};
				}
			)[NTMI.ferrari.mode].value;
			// when last slot button is released, remove mode
			if (bt.parent.value.sum == 0) {
				NTMI.ferrari.mode = nil;
				NTMI.ferrari.slotModeWasUsed = false;
				"leaving slot mode".postln;
			};
			NTMI.ferrari.selectedSlots.remove(i);
			NTMI.ferrari.selectedSlots.postln;
		}
	})
};

NTMI.ferrari.zoom = 0.5;

////////// 4 joyaxes set relative influx inputs
MKtl(~ferrari).elAt(\joyAxes).do { |el, i|
	var inIndex = [9, 11, 12, 13][i];
	var sign = (x: 1, y: -1)[el.key];
	el.elemDesc.label = "infl" + inIndex;
	el.action = { |el|
		if (NTMI.ferrari.influxMode == \setAbs) {
			NTMI.inphlux.set(inIndex, el.value.unibi);
		} {
			MFdef(\setRelInf).(
				inIndex,
				(el.value - el.prevValue),
				NTMI.zoom * NTMI.ferrari.zoom * sign
			);
		}
	}
};


////////// 2 throttles set relative influx inputs
MKtl(~ferrari).elAt(\throt).do { |el, i|
	// influx inputs: ampPlus is input \l, ampminus  p
	// var inName = NTMI.inphlux.inNames[i + 9 + 4];
	var inIndex = [10, 14][i];
	el.elemDesc.label = "infl" + inIndex;
	el.action = { |el|
		if (NTMI.ferrari.influxMode == \setAbs) {
			NTMI.inphlux.set(inIndex, el.value.unibi);
		} {
			MFdef(\setRelInf).(
				inIndex,
				(el.value - el.prevValue),
				NTMI.zoom * NTMI.ferrari.zoom
			)
		};
	};
};


// joyhat L R switches prev/next preset on inphlux, both: rand
/// FIXME: mark modalAction has happened,
// dont do basic action on second release

NTMI.ferrari.hatWasUsed = false;
MKtl(~ferrari).elAt(\joy, \l, \hat).elemDesc.label = "INPH prev";
MKtl(~ferrari).elAt(\joy, \l, \hat).action = { |hat|
	if (hat.isOn.not) {
		if (MKtl(~ferrari).elAt(\joy, \r, \hat).isOn) {
			NTMI.ferrari.hatWasUsed = true;
			NTMI.inph.stepWPre(nil); // rand
		} {
			if (NTMI.ferrari.hatWasUsed.not) {
				NTMI.inph.stepWPre(-1); // prev
			};
			NTMI.ferrari.hatWasUsed = false;
		};
	};
};

MKtl(~ferrari).elAt(\joy, \r, \hat).elemDesc.label = "INPH next";
MKtl(~ferrari).elAt(\joy, \r, \hat).action = { |hat|
	hat.elemDesc.label = "prev pre";
	if (hat.isOn.not) {
		if (MKtl(~ferrari).elAt(\joy, \l, \hat).isOn) {
			NTMI.inph.stepWPre(nil); // rand
			NTMI.ferrari.mfxWasUsed = true;
		} {
			if (NTMI.ferrari.hatWasUsed.not) {
				NTMI.inph.stepWPre(1); // next
			};
			NTMI.ferrari.hatWasUsed = false;
		};
	};
};

// but 7 & 8 switch materfx presets prev/next, both: rand
/// FIXME: mark modalAction has happened,
// dont do basic action on second release

NTMI.ferrari.mfxWasUsed = false;
MKtl(~ferrari).elAt(\bt, \7).elemDesc.label = "MFX prev";
MKtl(~ferrari).elAt(\bt, \7).action = { |bt|
	if (bt.isOn.not) {
		if (MKtl(~ferrari).elAt(\bt, \8).isOn) {
			NTMI.ferrari.mfxWasUsed = true;
			MFdef('mainPreStep').value(nil); // rand
		} {
			if (NTMI.ferrari.mfxWasUsed.not) {
				MFdef('mainPreStep').value(-1); // prev
			};
			NTMI.ferrari.mfxWasUsed = false;
		};
	};
};
MKtl(~ferrari).elAt(\bt, \8).elemDesc.label = "MFX next";
MKtl(~ferrari).elAt(\bt, \8).action = { |bt|
	if (bt.isOn.not) {
		if (MKtl(~ferrari).elAt(\bt, \7).isOn) {
			NTMI.ferrari.mfxWasUsed = true;
			MFdef('mainPreStep').value(nil); // rand
		} {
			if (NTMI.ferrari.mfxWasUsed.not) {
				MFdef('mainPreStep').value(1); // prev
			};
			NTMI.ferrari.mfxWasUsed = false;
		};
	};
};

"ferrari: gets  here?".postln;

// wheel controls main volume;
// sets main vol when bt 10 is down;
// sets slot volume when or more buttons of 1-4 are down
NTMI.ferrari.uniMainVolOffset = 0;
MKtl(~ferrari).elAt(\wheel).elemDesc.label = "set vol";
MKtl(~ferrari).elAt(\wheel).action.add(\setvol, { |wheel|
	var indices;
	if (NTMI.ferrari.mode == \slot) {
		// get the slot(s) in focus, set its/their volume(s)
		indices = NTMI.ferrari.selectedSlots.select(_.isNumber);
		// "set slot vol: %\n".postf(NTMI.ndefs[indices]);
		NTMI.ndefs[indices].do { |ndef|
			ndef.softVol_(wheel.value.squared, 0.05, true, wheel.prevValue.squared);
		};
		NTMI.ferrari.slotModeWasUsed = true;
	} {
		if (MKtl(~ferrari).elAt(\bt, \10).isOn) {
			"set mainVolume center:".post;
			NTMI.ferrari.uniMainVolOffset = (wheel.value - 0.5).postln;
			MFdef(\mainVolSetUni).value( wheel.value);
		} {
			// "mainVol: ".postln;
			MFdef(\mainVolSetUni).value(NTMI.ferrari.uniMainVolOffset + wheel.value);
		};
	};
});

// use compass for navigation of presets and sounds:
MKtl(~ferrari).elAt(\compass).elemDesc.label = "step pre";

MKtl(~ferrari).elAt(\compass).action.add(\stepPre, { |cp|
	var val = (cp.value * 7).round.asInteger;
	var slotFlags = MKtl(~ferrari).elAt(\sndButs).value.collect(_ > 0);
	if (NTMI.ferrari.mode == \slot) {
		NTMI.ferrari.slotModeWasUsed = true;
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
MKtl(~ferrari).elAt(\bt, \9).elemDesc.label = "rand pre";
MKtl(~ferrari).elAt(\bt, \9).action.add(\randPre, {
	if (NTMI.ferrari.mode == \slot) {
		NTMI.ferrari.sndButs.do { |bt, slIndex|
			if (bt.isOn) { NTMI.pre.stepNdefInf(NTMI.ndefs[slIndex], nil) }
		}
	}
});

// bt 9 -> random sound func
MKtl(~ferrari).elAt(\bt, \10).elemDesc.label = "rand snd";
MKtl(~ferrari).elAt(\bt, \10).action.add(\randPre, {
	if (NTMI.ferrari.mode == \slot) {
		NTMI.ferrari.sndButs.do { |bt, slIndex|
			if (bt.isOn) { NTMI.slots.stepNext(slIndex, nil) }
		}
	}
});

MKtl(~ferrari).elAt(\bt, \6).elemDesc.label = "snap Pre";
MKtl(~ferrari).elAt(\bt, \6).action.add(\snapPre, {
	MFdef('snapshot').value;
});

MKtl(~ferrari);
