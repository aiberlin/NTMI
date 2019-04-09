///// ******** FERRARI Gamepad patch for Liz Allbee *********

/*



*/

q = q ? ();
q.ferr = ();						// sub-Dict for all things gamePad

// MKtl.find(\hid);
// Ferrari wireless gamepad for Liz

if (MKtlLookup.findByIDInfo("Run'N' Drive_Thrustmaster").size == 1) {
	MKtl.all['ferr'].free;
	q.ferr.mktl = MKtl('ferr', "*run-n-drive");
} {
	if (MKtlLookup.findByIDInfo("Run'N' Drive Wireless_Thrustmaster").size == 1) {
		MKtl.all['ferr'].free;
		q.ferr.mktl = MKtl('ferr', "*run-n-drive-wireless");
	};
};

MKtl.all['ferr'].free;
q.ferr.mktl = MKtl('ferr', "*run-n-drive");


if (q.ferr.mktl.isNil) {
	"No Ferrari Gamepad present - not loading gamepad patch.".postln;
} {
	"*** Ferrari Gamepad present - loading gamepad patch!!!".postln;

	g.makeGui = q.makeGui ? ();
	g.makeGui.ferrari = { q.ferr.mktl.gui };


	// prepare all elements for debugging:
	q.ferr.mktl.elementsDict.do(_.action_(MFunc()));
	q.ferr.mktl.elementsDict.do { |el|
		el.action.add(\post, { |el| [el.name, el.value.round(0.0001)].postln })
	};

	q.ferr.mktl.elementsDict.do { |el| el.action.enable(\post) };
	q.ferr.mktl.elementsDict.do { |el| el.action.disable(\post) };


	// buttons 1-4 turn 4 slots on/off
	q.ferr.mktl.elAt(\bt, (0..3)).do { |bt, i|
		bt.elemDesc.label = "snd % play".format(i+1);
		bt.action.add(\toggle, {
			if (bt.isOn.not) { q.slots.toggleAt(i) }
		})
	};


	q.ferr.vols = ();

	// ARTICULATION: only play while bt 6 (right shoulder) is held down
	// ToDo: button may change from gamepad to gamepad!
	q.ferr.mktl.elAt(\bt, \6).action.add(\holdPlay, {|el|
		if (el.value > 0) {
			"*** GP play: ".post;
			q.slots.nowPlaying.do (_.resume);
		} {
			"*** GP stops all: ".post;
			q.slots.nowPlaying.do (_.pause);
		}
	});

	////////// 4 joyaxes set 4 INFLUX ins
	q.ferr.mktl.addNamed(\joyAxes,
		MKtlElementGroup(\joys, q.ferr.mktl,
			q.ferr.mktl.elAt(\joy, nil, [\x, \y]).flat
		)
	);

	q.ferr.mktl.elAt(\joyAxes).do { |el, i|
		var inName = q.inphlux.inNames[i];
		el.elemDesc.label = "inf" + inName.cs;
		el.action = { |el| q.inphlux.set(inName, el.value.unibi) };
		// in gui: el.mouseUpAction = { el.valueAction_(0.5) };
	};

	// joyhat L R switches prev/next preset on active sounds, both: rand
	/// FIXME: mark modalAction has happened,
	// dont do basic action on second release
	q.ferr.mktl.elAt(\joy, \l, \hat).action = { |hat|
		if (hat.isOn.not) {
			if (q.ferr.mktl.elAt(\joy, \r, \hat).isOn) {
				MFdef('stepInphWPre').value(nil); // rand
			} {
				MFdef('stepInphWPre').value(-1); // prev
			};
		};
	};
	q.ferr.mktl.elAt(\joy, \r, \hat).action = { |hat|
		if (hat.isOn.not) {
			if (q.ferr.mktl.elAt(\joy, \l, \hat).isOn) {
				MFdef('stepInphWPre').value(nil); // rand
			} {
				MFdef('stepInphWPre').value(1); // next
			};
		};
	};

	// but 7 & 8 switch materfx presets prev/next, both: rand
	/// FIXME: mark modalAction has happened,
	// dont do basic action on second release
	q.ferr.mktl.elAt(\bt, \7).action = { |bt|
		if (bt.isOn.not) {
			if (q.ferr.mktl.elAt(\bt, \8).isOn) {
				MFdef('mastaPreStep').value(nil); // rand
			} {
				MFdef('mastaPreStep').value(-1); // prev
			};
		};
	};
	q.ferr.mktl.elAt(\bt, \8).action = { |bt|
		if (bt.isOn.not) {
			if (q.ferr.mktl.elAt(\bt, \8).isOn) {
				MFdef('mastaPreStep').value(nil); // rand
			} {
				MFdef('mastaPreStep').value(1); // prev
			};
		};
	};

	// wheel sets master vol when bt 10 is down;
	// single slot volume when that button 1-4 is down
	q.ferr.uniMasterVolOffset = 0;
	q.ferr.mktl.elAt(\wheel).action = { |wheel|
		if (q.ferr.mktl.elAt(\bt, \10).isOn) {
			"masterVolume offset:".post;
			q.ferr.uniMasterVolOffset = (wheel.value - 0.5).postln;
			q.mFX.pxChain.proxy.setUni(\limDrive, wheel.value);
		} {
			// "masterVol: ".postln;
			q.mFX.pxChain.proxy.setUni(\limDrive,
				q.ferr.uniMasterVolOffset + wheel.value);
		};
	};


	// bt 5-6: next inphlux preset both together: rand!
	// bt 1-4 held down -> bt 5,6 switch prev/next sound, 5+6: rand
	// bt 1-4 held down + throt left: set volume(s),
	// bt 6 held + throt left: set master vol
	// bt 5 held + throt right: set master vol
};
