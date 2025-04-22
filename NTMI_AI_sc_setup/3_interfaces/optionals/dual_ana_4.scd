///// ******** Thrustmaster dual_analog_4 Gamepad patch *********
///// ********     adapted into NTMI / UFO app *********


/*
MKtl.find(\hid);

///////// tests
m.gui.showLabels;

*/

var m;
m = NTMI.makeMKtl(\dual_ana_4, "*dual-analog-4", NTMI.currInfo);

// prepare all elements for debugging:
m.elementsDict.do(_.action_(MFunc()));
m.elementsDict.do { |el|
	el.action.add(\post, { |el| [el.name, el.value.round(0.0001)].postln })
};

m.elementsDict.do { |el| el.action.enable(\post) };
m.elementsDict.do { |el| el.action.disable(\post) };


//////// NAME ElementGroups:
////////// 4 joyaxes
m.addNamed(\joyAxes,
	m.elAt(\joy, nil, [\x, \y]).flat
);

m.addHalo(\vols, ());
m.addHalo(\selectedSlots, List[]);


// 4 SOUND BUTTONS:
m.addNamed(\sndButs, m.elAt(\bt, (0..3)));

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
		m.elAt(\sndButs).do { |bt, slIndex|
			if (bt.isOn) { NTMI.pre.stepNdefInf(NTMI.ndefs[slIndex], nil) }
		}
	}
});

// bt 9 -> random sound func
m.elAt(\bt, \10).elemDesc.label = "rand snd";
m.elAt(\bt, \10).action.add(\randPre, {
	if (m.getHalo.mode == \slot) {
		m.elAt(\sndButs).do { |bt, slIndex|
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
