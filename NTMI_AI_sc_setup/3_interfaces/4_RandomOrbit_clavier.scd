
(
// RandomOrbit binary clavier:
NTMI.bin = NTMI.bin ? ();
NTMI.bin.binkey = 1;

MFdef(\randOrb).add(\setPres, { |newNum|
	var newSetName;
	if (NTMI.bin.binkey != newNum) {
		NTMI.bin.binkey = newNum;

		if(newNum > 0) {
			// "randOrb newNum: %\n".postf(newNum);
			// was:
			// NTMI.slots.nowPlaying.do { |px| };
			// don't set decoupled proxies:
			NTMI.slots.nowPlaying.reject { |px| NTMI.inph.decoupled.includes(px.key) }.do { |px|
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
});
)