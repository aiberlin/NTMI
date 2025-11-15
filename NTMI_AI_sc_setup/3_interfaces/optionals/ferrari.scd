///// ******** FERRARI Gamepad patch for Liz Allbee *********
///// ********     adapted into NTMI / nUFO app      *********


/*

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


4. Influx behavior has different presets;
- switch influx presets by pressing joystick hat buttons
left hat for down by one,
right hat for up by one,
or both for random choice of influx preset.

5. sound preset choices:
- hold one of buttons 1-4, and:
press compass down on left  side for next preset DOWN of that sound,
press compass down on right side for next preset  UP  of that sound,
press button 9                   for random preset    of that sound.

6. sound functions in each slot can be chosen from the repertoire.
- hold one of button 1-4, and:
press compass down on bottom for next sound choice DOWN in that slot,
press compass down on top    for next sound choice  UP  in that slot,
or press button 10           for random next sound      in that slot.

7. MainFX presets:
The MainFX presets, named 'theology', 'magic', etc,
can be switched stepped thru or jumped:
- press button 7 for lower preset,
-       button 8 for next higher preset,
     or both for a randomly chosen preset.

8. Saving Snapshots:
When you like the way the active sound processes sound right now,
press button 6 - right shoulder button - to save the current settings as a preset.
This will be stored under a temporary name like "adc_190805_221134",
which you can later change and keep.

*/

// var m;
"ferrari file, NTMI.currInfo:".postln;
NTMI.currInfo.postcs;
// only finds wired for now:
m = NTMI.makeMKtl(\ferrari, "*run-n-drive", NTMI.currInfo);

// prepare all elements for debugging:
m.elementsDict.do(_.action_(MFunc()));
m.elementsDict.do { |el|
	el.action.add(\post, { |el| [el.name, el.value.round(0.0001)].postln })
};

m.elementsDict.do { |el| el.action.enable(\post) };
m.elementsDict.do { |el| el.action.disable(\post) };


////First, NAME all elementGroups:
////////// 4 joyaxes
m.addNamed(\joyAxes, m.elAt(\joy, nil, [\x, \y]).flat);

// tweak and store volume levels:
m.getHalo.vols = ();
// modal functions: apply for selectedSlots
m.getHalo.selectedSlots = List[];


// 4 SOUND BUTTONS:
m.addNamed(\sndButs, m.elAt(\bt, (0..3)));
m.getHalo.sndButs = m.elAt(\sndButs);

// soundbuttons 1-4 turn 4 slots on/off
m.elAt(\sndButs).do { |bt, i|
	bt.elemDesc.label = "snd % play".format(i+1);
	bt.action.add(\toggle, {
		if (bt.isOn) {
			m.getHalo.selectedSlots.add(i).postln;
			if (m.getHalo.mode.isNil) {
				"entering slot mode".postln;
				m.getHalo.mode = \slot;
			};
		} {
			// do action based on mode:
			(
				slot: {
					if (m.getHalo.slotModeWasUsed != true) {
						NTMI.slots.toggleAt(i);
					};
				}
			)[m.getHalo.mode].value;
			// when last slot button is released, remove mode
			if (bt.parent.value.sum == 0) {
				m.getHalo.mode = nil;
				m.getHalo.slotModeWasUsed = false;
				"leaving slot mode".postln;
			};
			m.getHalo.selectedSlots.remove(i);
			m.getHalo.selectedSlots.postln;
		}
	})
};

////////// 4 joyaxes set relative influx inputs
m.elAt(\joyAxes).do { |el, i|
	var inIndex = [9, 11, 12, 13][i];
	var sign = (x: 1, y: -1)[el.key];
	el.elemDesc.label = "infl" + inIndex;
	el.action = { |el|
		if (m.getHalo.influxMode == \setAbs) {
			NTMI.inphlux.set(inIndex, el.value.unibi);
		} {
			MFdef(\setRelInf).(
				inIndex,
				(el.value - el.prevValue),
				NTMI.zoom * m.getHalo.zoom * sign
			);
		}
	}
};


////////// 2 throttles set relative influx inputs
m.elAt(\throt).do { |el, i|
	// influx inputs: ampPlus is input \l, ampminus  p
	// var inName = NTMI.inphlux.inNames[i + 9 + 4];
	var inIndex = [10, 14][i];
	el.elemDesc.label = "infl" + inIndex;
	el.action = { |el|
		if (m.getHalo.influxMode == \setAbs) {
			NTMI.inphlux.set(inIndex, el.value.unibi);
		} {
			MFdef(\setRelInf).(
				inIndex,
				(el.value - el.prevValue),
				NTMI.zoom * m.getHalo.zoom
			)
		};
	};
};


// joyhat L R switches prev/next preset on inphlux, both: rand
/// FIXME: mark modalAction has happened,
// dont do basic action on second release

m.getHalo.hatWasUsed = false;
m.elAt(\joy, \l, \hat).elemDesc.label = "INPH prev";
m.elAt(\joy, \l, \hat).action = { |hat|
	if (hat.isOn.not) {
		if (m.elAt(\joy, \r, \hat).isOn) {
			m.getHalo.hatWasUsed = true;
			NTMI.inph.stepWPre(nil); // rand
		} {
			if (m.getHalo.hatWasUsed.not) {
				NTMI.inph.stepWPre(-1); // prev
			};
			m.getHalo.hatWasUsed = false;
		};
	};
};

m.elAt(\joy, \r, \hat).elemDesc.label = "INPH next";
m.elAt(\joy, \r, \hat).action = { |hat|
	hat.elemDesc.label = "prev pre";
	if (hat.isOn.not) {
		if (m.elAt(\joy, \l, \hat).isOn) {
			NTMI.inph.stepWPre(nil); // rand
			m.getHalo.mfxWasUsed = true;
		} {
			if (m.getHalo.hatWasUsed.not) {
				NTMI.inph.stepWPre(1); // next
			};
			m.getHalo.hatWasUsed = false;
		};
	};
};

// but 7 & 8 switch materfx presets prev/next, both: rand
/// FIXME: mark modalAction has happened,
// dont do basic action on second release

m.getHalo.mfxWasUsed = false;
m.elAt(\bt, \7).elemDesc.label = "MFX prev";
m.elAt(\bt, \7).action = { |bt|
	if (bt.isOn.not) {
		if (m.elAt(\bt, \8).isOn) {
			m.getHalo.mfxWasUsed = true;
			MFdef('mainPreStep').value(nil); // rand
		} {
			if (m.getHalo.mfxWasUsed.not) {
				MFdef('mainPreStep').value(-1); // prev
			};
			m.getHalo.mfxWasUsed = false;
		};
	};
};
m.elAt(\bt, \8).elemDesc.label = "MFX next";
m.elAt(\bt, \8).action = { |bt|
	if (bt.isOn.not) {
		if (m.elAt(\bt, \7).isOn) {
			m.getHalo.mfxWasUsed = true;
			MFdef('mainPreStep').value(nil); // rand
		} {
			if (m.getHalo.mfxWasUsed.not) {
				MFdef('mainPreStep').value(1); // prev
			};
			m.getHalo.mfxWasUsed = false;
		};
	};
};

// wheel controls main volume;
// sets main vol when bt 10 is down;
// sets slot volume when or more buttons of 1-4 are down
m.getHalo.uniMainVolOffset = 0;
m.elAt(\wheel).elemDesc.label = "set vol";
m.elAt(\wheel).action.add(\setvol, { |wheel|
	var indices;
	if (m.getHalo.mode == \slot) {
		// get the slot(s) in focus, set its/their volume(s)
		indices = m.getHalo.selectedSlots.select(_.isNumber);
		// "set slot vol: %\n".postf(NTMI.ndefs[indices]);
		NTMI.ndefs[indices].do { |ndef|
			ndef.softVol_(wheel.value.squared, 0.05, true, wheel.prevValue.squared);
		};
		m.getHalo.slotModeWasUsed = true;
	} {
		if (m.elAt(\bt, \10).isOn) {
			"set mainVolume center:".post;
			m.getHalo.uniMainVolOffset = (wheel.value - 0.5).postln;
			MFdef(\mainVolSetUni).value( wheel.value);
		} {
			// "mainVol: ".postln;
			MFdef(\mainVolSetUni).value(m.getHalo.uniMainVolOffset + wheel.value);
		};
	};
});

// use compass for navigation of presets and sounds:
m.elAt(\compass).elemDesc.label = "step pre";

m.elAt(\compass).action.add(\stepPre, { |cp|
	var val = (cp.value * 7).round.asInteger;
	var slotFlags = m.elAt(\sndButs).value.collect(_ > 0);
	if (m.getHalo.mode == \slot) {
		m.getHalo.slotModeWasUsed = true;
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
m.elAt(\bt, \9).elemDesc.label = "rand pre";
m.elAt(\bt, \9).action.add(\randPre, {
	if (m.getHalo.mode == \slot) {
		m.getHalo.sndButs.do { |bt, slIndex|
			if (bt.isOn) { NTMI.pre.stepNdefInf(NTMI.ndefs[slIndex], nil) }
		}
	}
});

// bt 9 -> random sound func
m.elAt(\bt, \10).elemDesc.label = "rand snd";
m.elAt(\bt, \10).action.add(\randPre, {
	if (m.getHalo.mode == \slot) {
		m.getHalo.sndButs.do { |bt, slIndex|
			if (bt.isOn) { NTMI.slots.stepNext(slIndex, nil) }
		}
	}
});

m.elAt(\bt, \6).elemDesc.label = "snap Pre";
m.elAt(\bt, \6).action.add(\snapPre, {
	MFdef('snapshot').value;
});

// return the mktl:
m;
