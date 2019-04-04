// add all global filter functions to use - these are then available by name.
q=q?();
q.numChans = q.numChans ? 2;

(q.prefs.active.effects ? ["*.scd" ]).do { |filename|
	q.load(filename, q.dir.userPOOL +/+ "4_effects");
};

//////// check integrity of all param specs - complains when specs are missing.
ProxyChain.checkDicts;

(
q.mFX = MasterFX.new(server: s,
	numChannels: q.numChans,
	slotNames: q.prefs.active.mfxSlotNames ? ProxyChain.allSources.keys(Array).sort,
	busIndex: 0
);

// pre-set ons:
q.mFX.pxChain.add('00_in', 1);
q.mFX.pxChain.add('0_DBComp', 1);

// q.mFX.pxChain.add('3AdCVerb', 0.1);
// q.mFX.pxChain.add('3ring', 0.1);
// q.mFX.pxChain.add('5LPF', 0.1);
q.mFX.pxChain.add('ampFin', 1);

);

// tweak
q.mFX.pxChain.proxy.fadeTime = 2;
// add Panic Button?
/*
q.mFX .pxChain . dump
q.mFX .pxChain . proxy.dump

MasterFX.clear('localhost')
q.mFX.pxChain.proxy.controlKeys
*/