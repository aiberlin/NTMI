/*
NTMI.bin.randOrb(64.rand);
*/

(
// RandomOrbit binary clavier:
NTMI.bin = NTMI.bin ? ();
NTMI.bin.binkey = 1;

NTMI.bin.randOrb = { |dict, newNum|
	var newSetName;
	if (NTMI.bin.binkey != newNum) {
		NTMI.bin.binkey = newNum;

		if(newNum > 0) {
			"randOrb newNum: %\n".postf(newNum);

			// ndefs now playing and not decoupled:
			NTMI.inph.toSetNow.do { |px|
				var pre = NdefPreset(px);

				// if outside presets, use newNum as random seed
				if(newNum >= pre.settings.size){
					pre.setCurrIndex(newNum, NTMI.zoom);
					">>> % setRand seed: %\n".postf(pre, newNum);
					pre.proxy.addHalo(\randSeed, newNum);
				}{
					var name = pre.settings[newNum].key;
					pre.setCurrIndex(newNum, NTMI.zoom);
					pre.setProxy(name);
					">>> % preset index: %\n".postf(pre, newNum);
					pre.proxy.addHalo(\randSeed, nil);
				}
			}
		}
	}
};
)
