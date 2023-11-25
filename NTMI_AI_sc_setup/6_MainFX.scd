// add all global filter functions to use - these are then available by name.
NTMI.mfx = NTMI.mfx ? ();
NTMI.numChans = NTMI.numChans ? 2;

(NTMI.prefs.active.effects ? ["*.scd" ]).do { |filename|
	LoadMe(filename, NTMI.dir.userPOOL +/+ "4_effects");
};

//////// check integrity of all param specs - complains when specs are missing.
ProxyChain.checkDicts;

(
NTMI.mFX.clear;
NTMI.mFX = MainFX.new(server: s,
	numChannels: NTMI.numChans,
	slotNames: // NTMI.prefs.active.mfxSlotNames ?
	ProxyChain.allSources.keys(Array).sort,
	busIndex: 0
);

// tweak
NTMI.mfx.chain = NTMI.mFX.proxyChain;
NTMI.mfx.chain.proxy.fadeTime = 2;

// apply all know specs to proxy just in case:
ProxyChain.sourceDicts.do { |dict|
	dict.specs.do { |spec| NTMI.mfx.chain.proxy.addSpec(spec) }
};

////////// experimental:
NTMI.mfx.pcPre = ProxyChainPreset(\say);

NTMI.mfx.pxPres = ();

/*
NTMI.mfx.pxPres['3AdCVerb'].setRand(0.25);
*/

fork ({
	0.1.wait;
	NTMI.mfx.chain.add('00_in', 1);
	0.1.wait;
	NTMI.mfx.chain.add('0_DBComp', 1);
	0.1.wait;
	NTMI.mfx.chain.add('3AdCVerb', 0.05);
	0.1.wait;
	NTMI.mfx.chain.add('ampFin', 1);
	0.1.wait;

}, AppClock);
);

// make sure MainFX wake up fully after cmd-period:
ServerTree.add({
	fork ({
		s.sync;
		0.2.wait;
		NTMI.mfx.chain.proxy.rebuild.send
	})
}, s);

////////// MFX presets taken from Ars Brevis ///////////////
//// to be replaced with ProxyChainPreset when done ... ////

NTMI.mfx.preNames = [
	'baseset',
	'theology',
	'magic',
	'rationalism',
	'socialism',
	'psychoanalysis',
	'cybernetics',
	'neoliberalism',
	'neopaganism',
	'transhumanism',
];

(
NTMI.mfx.preMap = (
	'baseset': (
		chainElements: ['00_in', '0_DBComp', ['3AdCVerb', 0.05], \ampFin],
		settings: [\postAmp, 1, \ampLimit, 0.8, \noisefloor, 0.0001],
		// randomize: [\noisefloor ]
	),
	'theology': (
		chainElements: [['3AdCVerb', 0.05], ['1comby', 0.5]],
		randomize: [\mod, \predelay, \revTime, \combScale, \freqscale, \rtscale ],
		// settings: [\postAmp, 1, \ampLimit, 0.8]
	),
	'magic': (
		chainElements: [['3AdCVerb', 0.02], ['7Delay', 0.2], ['6roto', 0.9]],
		randomize: [\mod, \delayTime1, \speed, \combScale],
		settings: [\feedback, 4, \ampLimit, 0.8]
	),
	'rationalism': 	(
		chainElements: [['7Delay', 0.25], ['5LPF', 0.6], ['3AdCVerb', 0.05]],
		randomize: [\modL, \rqL],
		settings: [\mod, 0.11, \feedback, 25, \delayTime1, 0.08, \delayTime2, 0.11]
	),
	'socialism': (
		chainElements: [['1ring', 0.2], ['6roto', 1], ['4ixiVerb', 0.08]],
		randomize: [\predelay, \apDecay, \combdecay, \ringfr, \combScale]
	),
	'psychoanalysis': (
		chainElements: [['1comby', 0.5], ['5HPF', 0.6], ['7Delay', 0.1], ['3AdCVerb', 0.03]],
		settings: [\bpm, 33.33, \freqH, 333, \modH, 0.5, \rqH, 0.5,
			\delaytime2, 0.87, \feedback, 3, \mod, 0.8],
		randomize: [\combScale]
	),
	'cybernetics': (
		chainElements: [['1holz', 0.35], ['3thrasher', 0.2], ['7Delay', 0.3], ['3AdCVerb', 0.02]],
		randomize: [\downsmod, \mod, \reson],
		settings: [\bit, 12, \downsample, 10000, \delayTime1, 1,
			\delaytime2, 0.08, \feedback, 7],
		randomize: [\combScale]
	),
	'neoliberalism': ( // comb filtering of AdCVerb causes trouble...
		chainElements: [['1ring', 0.3], ['3AdCVerb', 0.03], ['7Delay', 0.03]],
		randomize: [\predelay, \revTime, \ringfr, \delayTime1, \delayTime2],
		settings: [\combScale, 0.09]
	),
	'neopaganism': (
		chainElements: [['1holz', 0.2], ['1ixiDist', 0.15], ['3AdCVerb', 0.03]],
		randomize: [\predelay, \revTime, \combScale, \ringfr, \delayTime1, \delayTime2],
		settings: [\pregain, 4, \dFreq, 1300,\loSlop, 0.4 ]
	),
	'transhumanism': (
		chainElements: [['1ring', 0.3], ['4ixiVerb', 0.25], ['7Delay', 0.03]],
		randomize: [\predelay, \apDecay, \combdecay, \ringfr, \delayTime1, \delayTime2],
		settings: [\ixivAmp, 0.1]
	)
)
);

(
MFdef(\mainPre).add(\voiceFXSwitch, { |domainName|
	var chain = NTMI.mfx.chain;
	var dict = NTMI.mfx.preMap[domainName];
	var randSettings;

	if (dict.isNil) {
		"*** MainPre: no domain %, not switching.".postf(domainName);
	} {
		NTMI.mfx.prevDomain = NTMI.mfx.currDomain;
		NTMI.mfx.currDomain =  domainName;
		NTMI.mfx.domainIndex = NTMI.mfx.preNames.indexOf(domainName);

		"\n*** MainPre: switching to %. ***\n".postf(domainName.cs);

		// remove all but...
		NTMI.mfx.srcKeys
		.reject({|it| NTMI.mfx.preMap.baseset.chainElements.includes(it) })
		.reject({|it| (dict.chainElements ? []).includes(it) })
		.do( chain.remove(_));
		// add all
		dict.chainElements.do{|el, i|
			if(el.isKindOf(SequenceableCollection))
			{ chain.add(el[0], el[1]) }
			{ chain.add(el, 1)};
		};
		// set
		if(dict.settings.notNil){
			chain.proxy.set( *dict.settings );
		};
		// rand
		if(dict.randomize.notNil){
			randSettings = [dict.randomize, {rrand(0.2, 0.8)}.dup(dict.randomize.size)].flop.flat;
			chain.proxy.setUni(*randSettings);
			"MainFX rand: %\n".postf(randSettings);
		};
		// looks better with cleanNodeMap, but better that nodeMap remembers last settings!
		// chain.proxy.cleanNodeMap;

		"[ [voiceFX: % - %\n".postf(domainName, dict.chainElements);
	};
});

MFdef(\getMainVol).add(\get, { |univol = 0.5|
	q.mFX.proxyChain.proxy.getUni(\mainVol);
});

MFdef(\mainVol).add(\main, { |univol = 0.5|
	NTMI.mFX.pxChain.proxy.setUni(\mainVol, univol);
});

MFdef(\mainPre).value(NTMI.prefs.active.mfxPreset ? NTMI.mfx.preNames.choose);

MFdef(\mainPreStep).add(\inc, { |inc|
	var nextIndex, nextName;
	inc = inc ?? { rrand(1, NTMI.mfx.preNames.lastIndex) };
	nextIndex = NTMI.mfx.domainIndex + inc % NTMI.mfx.preNames.size;
	nextName = NTMI.mfx.preNames[nextIndex];
	MFdef(\mainPre).(nextName);
});
);

