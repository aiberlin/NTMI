/********* Using pads as triggers for binary clavier

* all 8 pads are bits combined into a number
and triggered when the number changes
* every pad can also be an individual trigger

MFdef(\capsToInph).activeNames;
MFdef(\capsToInph).enable(\binKey);
MFdef(\capsToInph).disable(\set);

***********/
(
NTMI.bin = NTMI.bin ? ();

// tweak bin-threshold to your nUFO!
// when pressing fully, 0.4 is reached after 3 frames,
// and reached again falling from full level after 3-4 frames.

NTMI.bin.thresh = 0.3;
NTMI.bin.bins = 0!8;
/*
MFdef(\randOrb).value(64.rand);
*/

// sneak binkey function into func that triggers when pads array is received:
MFdef(\capsToInph).add(\binKey, {
	// var binMap = [ 128, 64, 32, 16, 8, 4, 2,   1];
	var binMap = [ 2,    8, 32, 128, 1, 4, 16, 64];
	var caps = MKtl('nUFO').collAt(\caps);
	var vals = caps.value;
	var bins = vals.collect { |val| (val > NTMI.bin.thresh).binaryValue };
	var newNum = (bins * binMap).sum;

	MFdef(\randOrb).(newNum);
	caps.do { |cap, i|
		if (bins[i] != NTMI.bin.bins[i]) {
			// cap.post; [bins[i], ~bins[i]].postln;
			///// cap.action.value;
		}
	};
	NTMI.bin.bins = bins
});
MFdef(\capsToInph).disable(\binKey);
);
