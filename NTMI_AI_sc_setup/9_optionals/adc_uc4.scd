/******* UC4 setup for NTMI:

- top 4 knobs  		change slots volume / relative
- top 4 hat-buttons toggle sound slots on/off

- lower 4 knobs:
--					scroll thru presets
-- 					if hat held down, scroll thru sounds

- 8 sliders: 		influx!

- xfader:           masterVol via limDrive

- bot buts 1 2 3:	rand, prev, next influx preset
- bot but  5:		snapshot presets
- bot buts 6 7 8:	rand, prev, next MasterFX preset



***********/
// to switch encoders to relative: on the device, select grp1,
// then go into edit mode: hold \shift, press \edit_setup
// select enc1 on knob 1, change ctlmode to Ccr2,
// hold until running bars go away -> all encoders are now relative

MKtlDesc.loadDescs;
m.free; m = MKtl(\uc4, "*uc4_pg"); m.gui;

// add a spec to uc4, for relative use:
// ccr2 is from 58 ... 63 down / 65 .. 70 up,
// so use this for good resolution on gui elements
m.addSpec(\knRel, [56, 72, \lin, 1, 64]);
m.elAt(\pgKn1, \kn).do(_.deviceSpec_(m.getSpec(\knRel)));

/// top 4 knobs change slots volume
m.elAt(\pgKn1, \kn, (0..3)).do { |el, i|
	el.action = { |el|
		var ndef = q.ndefs[i];
		MFdef(\stepVol).(ndef, ((el.deviceValue - 64) * 0.1));
		el.deviceValue = 64;
	};
};

/// top 4 buttons toggle sound slots on/off

m.elAt(\pgKn1, \pbt, (0..3)).do { |el, i|
	el.action = { |el|
		if (el.value > 0) { q.slots.toggleAt(i) }
	};
};

// xfader is master volume before limiter
m.elAt('xfader').action = { |xf|
	// 	s.volume.volume_(\svol.asSpec.map(xf.value))
	q.mFX.pxChain.proxy.setUni(\limDrive, xf.value);
};


// what to use next four knobs for?
// to select next sound?

m.elAt(\pgKn1, \kn, (4..7)).do { |el, i|
	el.action = { |el|
		var ndef = q.ndefs[i];
		var relStep = (el.deviceValue - 64);
		if (el.isOn) {
			if (m.elAt(\pgKn1, \pbt, (4..7)[i]).isOn) {
				// next sound
				q.slots.stepNext(i, relStep);
			} {
				// next preset
				q.stepNdefPreInf(ndef, relStep);
			};
			el.deviceValue = 64;
		};
	}
};

// bt5, snapshots presets of all currently playing sounds
m.elAt(\pgSl1, \bt, 4).action = { |el|
	if (el.isOn) {
		MFdef(\snapshot).value;
	}
};

m.elAt(\pgSl1, \sl).do { |sl, i|
	sl.action = { |sl|
		var name = q.inphlux.inNames[i];
		q.inphlux.set(name, sl.value.unibi);
	}
};

// Left 3 bottom buttons: inphPre rand, -1, +1
m.elAt(\pgSl1, \bt, [0, 1, 2]).do { |el, i|
	el.action = { |el| if (el.value > 0) {
		MFdef(\stepInphWPre).([nil, -1, 1]@i)
	} }
};

// Right 3 bottom buttons: masterfx preset rand, -1, +1
m.elAt(\pgSl1, \bt, [5, 6, 7]).do { |el, i|
	el.action = { |el| if (el.value > 0) {
		MFdef(\mastaPreStep).([nil, -1, 1]@i)
	} }
};

