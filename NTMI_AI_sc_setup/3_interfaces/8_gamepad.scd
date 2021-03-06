///// ******** FERRARI Gamepad patch for Liz Allbee *********
///// ********     adapted into NTMI / UFO app      *********


/*
MKtl.find(\hid);
MKtl('ferrari').gui;


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
q.ferr.mktl.openDevice;
q.ferr.mktl.gui;
q.ferr.mktl.elAt(\bt, 0).dump
*/

// HID.closeAll;

// MKtl.find(\hid);
q = q ? ();
q.ferr = q.ferr ? ();						// sub-Dict for all things gamePad

// MKtl.find(\hid);
// Ferrari wireless gamepad for Liz

if (MKtlLookup.findByIDInfo("Run'N' Drive_Thrustmaster").size == 1) {
	MKtl.all['ferrari'].free;
	MKtl('ferrari', "*run-n-drive");
	q.ferr.mktl = MKtl('ferrari');
} {
	if (MKtlLookup.findByIDInfo("Run'N' Drive Wireless_Thrustmaster").size == 1) {
		MKtl.all['ferrari'].free;
		q.ferr.mktl = MKtl('ferrari', "*run-n-drive-wireless");
	};
};

// // make it anyway:
// MKtl.all['ferrari'].free;
// MKtl('ferrari', "*run-n-drive");
// q.ferr.mktl = MKtl('ferrari');

if (q.ferr.mktl.isNil) {
	"No Ferrari Gamepad present - not loading Gamepad patch.".postln;
} {
	"*** Ferrari Gamepad found - loading it!".postln;

	// prepare all elements for debugging:
	q.ferr.mktl.elementsDict.do(_.action_(MFunc()));
	q.ferr.mktl.elementsDict.do { |el|
		el.action.add(\post, { |el| [el.name, el.value.round(0.0001)].postln })
	};

	q.ferr.mktl.elementsDict.do { |el| el.action.enable(\post) };
	q.ferr.mktl.elementsDict.do { |el| el.action.disable(\post) };

	//////// NAME ElementGroups
	////////// 4 joyaxes
	q.ferr.mktl.addNamed(\joyAxes,
		q.ferr.mktl.elAt(\joy, nil, [\x, \y]).flat
	);


	q.ferr.vols = ();
	q.ferr.selectedSlots = List[];


	// 4 SOUND BUTTONS:
	q.ferr.mktl.addNamed(\sndButs, q.ferr.mktl.elAt(\bt, (0..3)));
	q.ferr.sndButs = q.ferr.mktl.elAt(\sndButs);

	// soundbuttons 1-4 turn 4 slots on/off
	q.ferr.mktl.elAt(\sndButs).do { |bt, i|
		bt.elemDesc.label = "snd % play".format(i+1);
		bt.action.add(\toggle, {
			if (bt.isOn) {
				q.ferr.selectedSlots.add(i).postln;
				if (q.ferr.mode.isNil) {
					"entering slot mode".postln;
					q.ferr.mode = \slot;
				};
			} {
				// do action based on mode:
				(
					slot: {
						if (q.ferr.slotModeWasUsed != true) {
							q.slots.toggleAt(i);
						};
					}
				)[q.ferr.mode].value;
				// when last slot button is released, remove mode
				if (bt.parent.value.sum == 0) {
					q.ferr.mode = nil;
					q.ferr.slotModeWasUsed = false;
					"leaving slot mode".postln;
				};
				q.ferr.selectedSlots.remove(i);
				q.ferr.selectedSlots.postln;
			}
		})
	};

	// ARTICULATION: only play while bt 6 (right shoulder) is held down
	// // ToDo: button may change from gamepad to gamepad!
	// q.ferr.mktl.elAt(\bt, \6).action.add(\holdPlay, {|el|
	// 	if (el.value > 0) {
	// 		"*** GP play: ".post;
	// 		q.slots.nowPlaying.do (_.resume);
	// 	} {
	// 		"*** GP stops all: ".post;
	// 		q.slots.nowPlaying.do (_.pause);
	// 	}
	// });

	////////// 4 joyaxes set influx inputs
	q.ferr.mktl.elAt(\joyAxes).do { |el, i|
		///// orig:
		// var inName = q.inphlux.inNames[i + 9];
		// hand-choose ins: take first 6 pad ins,
		// skip the ones that have amp plus and minus on it:
		var inName = [\q, \o, \n, \m][i];
		var sign = (x: 1, y: -1)[el.key];
		[el, sign].postln;
		el.elemDesc.label = "infl" + inName.cs;
		el.action = { |el| q.inphlux.set(inName, el.value.unibi * sign) };
	};

	////////// 2 throttles set influx inputs
	q.ferr.mktl.elAt(\throt).do { |el, i|
		// influx inputs: ampPlus is input \l, ampminus  p
		// var inName = q.inphlux.inNames[i + 9 + 4];
		var inName = [\p, \l][i];
		el.elemDesc.label = "infl" + inName.cs;
		el.action = { |el| q.inphlux.set(inName, el.value) };
	};

	// joyhat L R switches prev/next preset on inphlux, both: rand
	/// FIXME: mark modalAction has happened,
	// dont do basic action on second release

	q.ferr.hatWasUsed = false;
	q.ferr.mktl.elAt(\joy, \l, \hat).elemDesc.label = "INPH prev";
	q.ferr.mktl.elAt(\joy, \l, \hat).action = { |hat|
		if (hat.isOn.not) {
			if (q.ferr.mktl.elAt(\joy, \r, \hat).isOn) {
				q.ferr.hatWasUsed = true;
				MFdef('stepInphWPre').value(nil); // rand
			} {
				if (q.ferr.hatWasUsed.not) {
					MFdef('stepInphWPre').value(-1); // prev
				};
				q.ferr.hatWasUsed = false;
			};
		};
	};

	q.ferr.mktl.elAt(\joy, \r, \hat).elemDesc.label = "INPH next";
	q.ferr.mktl.elAt(\joy, \r, \hat).action = { |hat|
		hat.elemDesc.label = "prev pre";
		if (hat.isOn.not) {
			if (q.ferr.mktl.elAt(\joy, \l, \hat).isOn) {
				MFdef('stepInphWPre').value(nil); // rand
				q.ferr.mfxWasUsed = true;
			} {
				if (q.ferr.hatWasUsed.not) {
					MFdef('stepInphWPre').value(1); // next
				};
				q.ferr.hatWasUsed = false;
			};
		};
	};

	// but 7 & 8 switch materfx presets prev/next, both: rand
	/// FIXME: mark modalAction has happened,
	// dont do basic action on second release

	q.ferr.mfxWasUsed = false;
	q.ferr.mktl.elAt(\bt, \7).elemDesc.label = "MFX prev";
	q.ferr.mktl.elAt(\bt, \7).action = { |bt|
		if (bt.isOn.not) {
			if (q.ferr.mktl.elAt(\bt, \8).isOn) {
				q.ferr.mfxWasUsed = true;
				MFdef('mainPreStep').value(nil); // rand
			} {
				if (q.ferr.mfxWasUsed.not) {
					MFdef('mainPreStep').value(-1); // prev
				};
				q.ferr.mfxWasUsed = false;
			};
		};
	};
	q.ferr.mktl.elAt(\bt, \8).elemDesc.label = "MFX next";
	q.ferr.mktl.elAt(\bt, \8).action = { |bt|
		if (bt.isOn.not) {
			if (q.ferr.mktl.elAt(\bt, \7).isOn) {
				q.ferr.mfxWasUsed = true;
				MFdef('mainPreStep').value(nil); // rand
			} {
				if (q.ferr.mfxWasUsed.not) {
					MFdef('mainPreStep').value(1); // prev
				};
				q.ferr.mfxWasUsed = false;
			};
		};
	};

	// wheel controls main volume;
	// sets main vol when bt 10 is down;
	// sets slot volume when or more buttons of 1-4 are down
	q.ferr.uniMainVolOffset = 0;
	q.ferr.mktl.elAt(\wheel).action.add(\setvol, { |wheel|
		var indices;
		if (q.ferr.mode == \slot) {
			// get the slot(s) in focus, set its/their volume(s)
			indices = q.ferr.selectedSlots.select(_.isNumber);
			// "set slot vol: %\n".postf(q.ndefs[indices]);
			q.ndefs[indices].do { |ndef|
				ndef.softVol_(wheel.value.squared, 0.05, true, wheel.prevValue.squared);
			};
			q.ferr.slotModeWasUsed = true;
		} {
			if (q.ferr.mktl.elAt(\bt, \10).isOn) {
				"set mainVolume center:".post;
				q.ferr.uniMainVolOffset = (wheel.value - 0.5).postln;
				MFdef(\mainVol).value( wheel.value);
			} {
				// "mainVol: ".postln;
				MFdef(\mainVol).value(q.ferr.uniMainVolOffset + wheel.value);s
			};
		};
	});

	// use compass for navigation of presets and sounds:
	q.ferr.mktl.elAt(\compass).action.add(\stepPre, { |cp|
		var val = (cp.value * 7).round.asInteger;
		var slotFlags = q.ferr.mktl.elAt(\sndButs).value.collect(_ > 0);
		if (q.ferr.mode == \slot) {
			q.ferr.slotModeWasUsed = true;
			val.switch(
				6, {
					slotFlags.do { |down, slIndex|
						if (down) { q.pre.stepNdefInf(q.ndefs[slIndex], -1) }
					};
					"pre down" },
				2, {
					slotFlags.do { |down, slIndex| if (down) {
						q.pre.stepNdefInf(q.ndefs[slIndex], 1) }
					};
					"pre up" },
				4, {
					slotFlags.do { |down, slIndex| if (down) { q.slots.stepNext(slIndex, -1) } };
					"snd down"
				},
				0, {
					slotFlags.do { |down, slIndex| if (down) { q.slots.stepNext(slIndex, 1) } };
					"snd up" }
			)
		};
	});

	// bt 9 -> random preset
	q.ferr.mktl.elAt(\bt, \9).action.add(\randPre, {
		if (q.ferr.mode == \slot) {
			q.ferr.sndButs.do { |bt, slIndex|
				if (bt.isOn) { q.pre.stepNdefInf(q.ndefs[slIndex], nil) }
			}
		}
	});

	// bt 9 -> random sound func
	q.ferr.mktl.elAt(\bt, \10).action.add(\randPre, {
		if (q.ferr.mode == \slot) {
			q.ferr.sndButs.do { |bt, slIndex|
				if (bt.isOn) { q.slots.stepNext(slIndex, nil) }
			}
		}
	});

	q.ferr.mktl.elAt(\bt, \6).action.add(\snapPre, {
		MFdef('snapshot').value;
	});
};
