// check for raspi screen

Window.allWindows.do { |w|
	var bnds = w.bounds;
	if (bnds.width > 790) {
		("too wide:" + w.name + bnds.width).postln;
		bnds.width = min(bnds.width, 790);
	};
	if (bnds.height > 440) {
		("too high:" + w.name + bnds.height).postln;
		bnds.height = min(bnds.height, 440);
	};
	bnds.left = 0;
	bnds.top = 0;
	w.bounds = bnds;
};

OK: wsetta

too high: slotSounds 609.0
too high: presets 500.0
too high: ndefMixer 540.0
too high: mainFX 609.0 // needs fixing

too high: nUFO 462.0
too wide: nanoKtl 912.0
too high: uc4 510.0
q.slots.choices.collect(_.size);
q.keys(Array).sort
g.ndefMixer.numItems
NdefMixer(s, 21).parent.bounds.height;