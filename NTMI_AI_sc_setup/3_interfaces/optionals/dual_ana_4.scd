///// ******** Thrustmaster dual_analog_4 Gamepad patch *********
///// ********     adapted into NTMI / UFO app *********


/*
MKtl.find(\hid);
MKtl('dual_ana_4').gui;

///////// tests
MKtl('dual_ana_4').openDevice;
MKtl('dual_ana_4').gui.showLabels;
MKtl('dual_ana_4').elAt(\bt, 0).dump

*/

NTMI.dual_ana_4 = NTMI.dual_ana_4 ? ();
///// look for wired and wireless
if (MKtlLookup.findByIDInfo("Thrustmaster dual analog 4_Thrustmaster").size == 1) {
	"*** wired Dual Analog 4  found!".postln;
	MKtl.all['dual_ana_4'].free;
	MKtl('dual_ana_4', "*dual-analog-4");
};

if (MKtl('dual_ana_4').isNil) {
	"No Dual Analog 4 Gamepad found - creating virtual one.".postln;
	MKtl.all['dual_ana_4'].free;
	MKtl('dual_ana_4', "*dual-analog-4");
};
"*** Dual Analog 4 Gamepad loading ...".postln;

// prepare all elements for debugging:
MKtl('dual_ana_4').elementsDict.do(_.action_(MFunc()));
MKtl('dual_ana_4').elementsDict.do { |el|
	el.action.add(\post, { |el| [el.name, el.value.round(0.0001)].postln })
};

MKtl('dual_ana_4').elementsDict.do { |el| el.action.enable(\post) };
MKtl('dual_ana_4').elementsDict.do { |el| el.action.disable(\post) };

//////// NAME ElementGroups
////////// 4 joyaxes
MKtl('dual_ana_4').addNamed(\joyAxes,
	MKtl('dual_ana_4').elAt(\joy, nil, [\x, \y]).flat
);

NTMI.dual_ana_4.vols = ();
NTMI.dual_ana_4.selectedSlots = List[];


// 4 SOUND BUTTONS:
MKtl('dual_ana_4').addNamed(\sndButs, MKtl('dual_ana_4').elAt(\bt, (0..3)));
NTMI.dual_ana_4.sndButs = MKtl('dual_ana_4').elAt(\sndButs);

// soundbuttons 1-4 turn 4 slots on/off
MKtl('dual_ana_4').elAt(\sndButs).do { |bt, i|
	bt.elemDesc.label = "snd % play".format(i+1);
	bt.action.add(\toggle, {
		if (bt.isOn) {
			NTMI.dual_ana_4.selectedSlots.add(i).postln;
			if (NTMI.dual_ana_4.mode.isNil) {
				"entering slot mode".postln;
				NTMI.dual_ana_4.mode = \slot;
			};
		} {
			// do action based on mode:
			(
				slot: {
					if (NTMI.dual_ana_4.slotModeWasUsed != true) {
						NTMI.slots.toggleAt(i);
					};
				}
			)[NTMI.dual_ana_4.mode].value;
			// when last slot button is released, remove mode
			if (bt.parent.value.sum == 0) {
				NTMI.dual_ana_4.mode = nil;
				NTMI.dual_ana_4.slotModeWasUsed = false;
				"leaving slot mode".postln;
			};
			NTMI.dual_ana_4.selectedSlots.remove(i);
			NTMI.dual_ana_4.selectedSlots.postln;
		}
	})
};

NTMI.dual_ana_4.zoom = 0.5;

////////// 4 joyaxes set relative influx inputs
MKtl('dual_ana_4').elAt(\joyAxes).do { |el, i|
	var inIndex = [9, 11, 12, 13][i];
	var sign = (x: 1, y: -1)[el.key];
	el.elemDesc.label = "infl" + inIndex;
	el.action = { |el|
		if (NTMI.dual_ana_4.influxMode == \setAbs) {
			NTMI.inphlux.set(inIndex, el.value.unibi);
		} {
			MFdef(\setRelInf).(
				inIndex,
				(el.value - el.prevValue),
				NTMI.zoom * NTMI.dual_ana_4.zoom * sign
			);
		}
	}
};


// joyhat L R switches prev/next preset on inphlux, both: rand
/// FIXME: mark modalAction has happened,
// dont do basic action on second release

NTMI.dual_ana_4.hatWasUsed = false;
MKtl('dual_ana_4').elAt(\joy, \l, \hat).elemDesc.label = "INPH prev";
MKtl('dual_ana_4').elAt(\joy, \l, \hat).action = { |hat|
	if (hat.isOn.not) {
		if (MKtl('dual_ana_4').elAt(\joy, \r, \hat).isOn) {
			NTMI.dual_ana_4.hatWasUsed = true;
			NTMI.inph.stepWPre(nil); // rand
		} {
			if (NTMI.dual_ana_4.hatWasUsed.not) {
				NTMI.inph.stepWPre(-1); // prev
			};
			NTMI.dual_ana_4.hatWasUsed = false;
		};
	};
};

MKtl('dual_ana_4').elAt(\joy, \r, \hat).elemDesc.label = "INPH next";
MKtl('dual_ana_4').elAt(\joy, \r, \hat).action = { |hat|
	hat.elemDesc.label = "prev pre";
	if (hat.isOn.not) {
		if (MKtl('dual_ana_4').elAt(\joy, \l, \hat).isOn) {
			NTMI.inph.stepWPre(nil); // rand
			NTMI.dual_ana_4.mfxWasUsed = true;
		} {
			if (NTMI.dual_ana_4.hatWasUsed.not) {
				NTMI.inph.stepWPre(1); // next
			};
			NTMI.dual_ana_4.hatWasUsed = false;
		};
	};
};

// but 7 & 8 switch materfx presets prev/next, both: rand
/// FIXME: mark modalAction has happened,
// dont do basic action on second release

NTMI.dual_ana_4.mfxWasUsed = false;
MKtl('dual_ana_4').elAt(\bt, \7).elemDesc.label = "MFX prev";
MKtl('dual_ana_4').elAt(\bt, \7).action = { |bt|
	if (bt.isOn.not) {
		if (MKtl('dual_ana_4').elAt(\bt, \8).isOn) {
			NTMI.dual_ana_4.mfxWasUsed = true;
			MFdef('mainPreStep').value(nil); // rand
		} {
			if (NTMI.dual_ana_4.mfxWasUsed.not) {
				MFdef('mainPreStep').value(-1); // prev
			};
			NTMI.dual_ana_4.mfxWasUsed = false;
		};
	};
};
MKtl('dual_ana_4').elAt(\bt, \8).elemDesc.label = "MFX next";
MKtl('dual_ana_4').elAt(\bt, \8).action = { |bt|
	if (bt.isOn.not) {
		if (MKtl('dual_ana_4').elAt(\bt, \7).isOn) {
			NTMI.dual_ana_4.mfxWasUsed = true;
			MFdef('mainPreStep').value(nil); // rand
		} {
			if (NTMI.dual_ana_4.mfxWasUsed.not) {
				MFdef('mainPreStep').value(1); // prev
			};
			NTMI.dual_ana_4.mfxWasUsed = false;
		};
	};
};

"dual_ana_4: gets  here?".postln;

// use compass for navigation of presets and sounds:
MKtl('dual_ana_4').elAt(\compass).elemDesc.label = "step pre";

MKtl('dual_ana_4').elAt(\compass).action.add(\stepPre, { |cp|
	var val = (cp.value * 7).round.asInteger;
	var slotFlags = MKtl('dual_ana_4').elAt(\sndButs).value.collect(_ > 0);
	if (NTMI.dual_ana_4.mode == \slot) {
		NTMI.dual_ana_4.slotModeWasUsed = true;
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
MKtl('dual_ana_4').elAt(\bt, \9).elemDesc.label = "rand pre";
MKtl('dual_ana_4').elAt(\bt, \9).action.add(\randPre, {
	if (NTMI.dual_ana_4.mode == \slot) {
		NTMI.dual_ana_4.sndButs.do { |bt, slIndex|
			if (bt.isOn) { NTMI.pre.stepNdefInf(NTMI.ndefs[slIndex], nil) }
		}
	}
});

// bt 9 -> random sound func
MKtl('dual_ana_4').elAt(\bt, \10).elemDesc.label = "rand snd";
MKtl('dual_ana_4').elAt(\bt, \10).action.add(\randPre, {
	if (NTMI.dual_ana_4.mode == \slot) {
		NTMI.dual_ana_4.sndButs.do { |bt, slIndex|
			if (bt.isOn) { NTMI.slots.stepNext(slIndex, nil) }
		}
	}
});

MKtl('dual_ana_4').elAt(\bt, \6).elemDesc.label = "snap Pre";
MKtl('dual_ana_4').elAt(\bt, \6).action.add(\snapPre, {
	MFdef('snapshot').value;
});

MKtl('dual_ana_4');
