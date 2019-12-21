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

(
// sneak binkey function into func that triggers when pads array is received:
MFdef(\capsToInph).add(\binKey, {
	// var binMap = [ 128, 64, 32, 16, 8, 4, 2,   1];
	var binMap = [ 2,    8, 32, 128, 1, 4, 16, 64];
	var caps = MKtl('ntmi').collAt(\caps);
	var vals = caps.value;
	var bins = vals.collect { |val| (val > q.bin.thresh).binaryValue };
	var sum = (bins * binMap).sum;

	if (q.bin.binkey != sum) {
		q.bin.binkey = sum;
		// MKtl('ntmi').collAt(\caps).value.round(0.001).postln;
//		("*** trigger new binkey: " + ~binkey).postln;

		if(sum > 0){
			// move out to MFdef later..
			q.slots.nowPlaying.do({ |px|
				var pres = NdefPreset(px);
				if(sum > pres.settings.size){

					pres.setRand(q.zoom, seed: sum);                  // RandomOrbit binary clavier -
					">>> setrand: %\n".postf(sum);
				}{
					pres.setCurr( pres.getSetNames.wrapAt(sum) );  // jump to the existing presets
					">>> preset: %\n".postf(sum);
				}
			})
		}


	};
	caps.do { |cap, i|
		if (bins[i] != q.bin.bins[i]) {
			// cap.post; [bins[i], ~bins[i]].postln;
			///// cap.action.value;
		}
	};
	q.bin.bins = bins
});
);
