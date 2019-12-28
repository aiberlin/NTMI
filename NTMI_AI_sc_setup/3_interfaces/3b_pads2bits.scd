/********* Using pads as triggers

* all 8 pads are bits combined into a number
and triggered when the number changes
* every pad can also be an individual trigger

MFdef(\capsToInph).activeNames;
MFdef(\capsToInph).enable(\binKey);
MFdef(\capsToInph).disable(\set);

***********/

q.bin = ();

// tweak bin-threshold to your ntmi!
q.bin.thresh = 0.3;

q.bin.bins = 0!8;
q.bin.binkey = 1;

(
// RandomOrbit binary clavier:

MFdef(\randOrb).add(\setPres, { |newNum|
	if (q.bin.binkey != newNum) {
		q.bin.binkey = newNum;

		if(newNum > 0){
			q.slots.nowPlaying.do({ |px|
				var pre = NdefPreset(px);
				// if outside presets, use newNum as random seed
				if(newNum >= pre.settings.size){

					pre.setRand(q.zoom, seed: newNum);
					">>> % setRand seed: %\n".postf(pre, newNum);
				}{
					// if within presets, jump to the existing preset at that index
					pre.setCurr( pre.getSetNames.wrapAt(newNum) );
					">>> % preset index: %\n".postf(pre, newNum);
				}
			})
		}
	}
});
/*
MFdef(\randOrb).value(64.rand);
*/

// sneak binkey function into func that triggers when pads array is received:
MFdef(\capsToInph).add(\binKey, {
	// var binMap = [ 128, 64, 32, 16, 8, 4, 2,   1];
	var binMap = [ 2,    8, 32, 128, 1, 4, 16, 64];
	var caps = MKtl('ntmi').collAt(\caps);
	var vals = caps.value;
	var bins = vals.collect { |val| (val > q.bin.thresh).binaryValue };
	var newNum = (bins * binMap).sum;

	MFdef(\randOrb).(newNum);
	caps.do { |cap, i|
		if (bins[i] != q.bin.bins[i]) {
			// cap.post; [bins[i], ~bins[i]].postln;
			///// cap.action.value;
		}
	};
	q.bin.bins = bins
});
);
