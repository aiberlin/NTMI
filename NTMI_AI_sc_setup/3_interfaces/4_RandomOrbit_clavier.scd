
(
// RandomOrbit binary clavier:
q.bin = q.bin ? ();
q.bin.binkey = 1;

MFdef(\randOrb).add(\setPres, { |newNum|
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
					pre.setRand(q.zoom, seed: newNum);
					">>> % setRand seed: %\n".postf(pre, newNum);
					pre.proxy.addHalo(\randSeed, newNum);
				}{
					// if within presets, jump to the existing preset at that index
					pre.setCurr( pre.getSetNames.wrapAt(newNum) );
					">>> % preset index: %\n".postf(pre, newNum);
					pre.proxy.addHalo(\randSeed, nil);
				}
			}
		}
	}
});
)