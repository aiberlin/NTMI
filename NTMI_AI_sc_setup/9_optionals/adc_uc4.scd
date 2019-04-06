// UC4 for NTMI setup

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
		MFdef(\stepVol).(ndef, ((el.deviceValue - 64) * 0.1).postln);
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

// // what to use next four knobs for?
// m.elAt(\pgKn1, \kn, (4..7)).do { |el, i|
// 	el.action = { |el|
// 		var ndef = q.ndefs[i];
// 		MFdef(\stepVol).(ndef, ((el.deviceValue - 64) * 0.1).postln);
// 		el.deviceValue = 64;
// 	};
// };


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

