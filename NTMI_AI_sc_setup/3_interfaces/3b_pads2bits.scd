/********* Using pads as triggers

* all 8 pads are bits combined into a number
and triggered when the number changes
* every pad can also be an individual trigger

***********/

~bins = 0!8;
(
// sneak binkey function into func that triggers when pads array is received:
MFdef(\capsToInph).add(\binKey, {
	var caps = MKtl('ntmi').collAt(\caps);
	var thresh = 0.4;
	var vals = caps.value;
	var bins = vals.collect { |val| (val > thresh).binaryValue };
	// var binMap = [ 128, 64, 32, 16, 8, 4, 2,   1];
	   var binMap = [ 2,    8, 32, 128, 1, 4, 16, 64];
	var sum = (bins * binMap).sum;

	if (~binkey != sum) {
		~binkey = sum;
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
		if (bins[i] != ~bins[i]) {
			// cap.post; [bins[i], ~bins[i]].postln;
			///// cap.action.value;
		}
	};
	~bins = bins
});
);

//// MKtl('ntmi').collAt(\caps).elements[0].action.activeNames;

/**** tests: new number post triggers
MKtl('ntmi').collAt(\caps).groupAction.value({ rrand(0.0, 1.0) } !8);
MKtl('ntmi').collAt(\caps).groupAction.value({ rrand(0.0, 0.5) } !8);

// test changing them slowly - where are the thresholds?
MKtl('ntmi').collAt(\caps).groupAction.value({ 0.4 } !8);
MKtl('ntmi').collAt(\caps).groupAction.value({ 0.44 } !8);
MKtl('ntmi').collAt(\caps).groupAction.value({ 0.45 } !8);
MKtl('ntmi').collAt(\caps).groupAction.value({ 0.46 } !8);

MKtl('ntmi').collAt(\caps).groupAction.value((0!8).put(0, 1));
MKtl('ntmi').collAt(\caps).groupAction.value((0!8).put(1, 1));
MKtl('ntmi').collAt(\caps).groupAction.value((0!8).put(2, 1));
****/