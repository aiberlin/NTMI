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
OK: ndefMixer
OK: presets
OK: uc4
OK: nUFO

too high: slotSounds 609.0
too high: mainFX 609.0 // needs fixing
too wide: nanoKtl 912.0

