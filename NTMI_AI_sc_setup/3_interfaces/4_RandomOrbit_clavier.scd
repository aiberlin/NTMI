
(
// RandomOrbit binary clavier:
q.bin = q.bin ? ();
q.bin.binkey = 1;

MFdef(\randOrb).add(\setPres, { |newNum|
	var newSetName;
	if (q.bin.binkey != newNum) {
		q.bin.binkey = newNum;

		if(newNum > 0) {
			// was:
			// q.slots.nowPlaying.do { |px| };
			// don't set decoupled proxies:
			q.slots.nowPlaying.reject { |px| q.inph.decoupled.includes(px.key) }.do { |px|
				var pre = NdefPreset(px);

				// if outside presets, use newNum as random seed
				if(newNum >= pre.settings.size){
					pre.setCurrIndex(newNum, q.zoom);
					">>> % setRand seed: %\n".postf(pre, newNum);
					pre.proxy.addHalo(\randSeed, newNum);
				}{
					pre.setCurrIndex(newNum, q.zoom);
					">>> % preset index: %\n".postf(pre, newNum);
					pre.proxy.addHalo(\randSeed, nil);
				}
			}
		}
	}
});
)