/*
NdefPresetGui(NdefPreset(\allArm), 20);
NTMI.pre.userSettingsDir.openOS;
NTMI.pre.incrementSeed(Ndef(\allArm));
*/
"\n... loading presets ...".postln;

/*
/// A function to shift an ndefs params
// by a list of unpolar deltapairs, like this:
var ndef = Ndef(\bleepo);
var deltaPairs = ndef.controlKeys.collect { |key| [key, 0.1.rand2] };
MFdef(\relSet).(ndef, deltaPairs);

this is for using influx changevectors to nudge ndefs.
*/

MFdef(\relSet).add(\relSet, { |obj, deltaPairs|
	var newvals = deltaPairs.collect {|pair, i|
		var param, delta, spec, unival, newuni, newval;
		#param, delta = pair;
		spec = obj.getSpec(param);
		unival = spec.unmap(obj.get(param));
		newuni = unival + delta;
		newval = spec.map(newuni);
		[ param, newval ];
	};
	obj.set(*newvals.flat);
});


NTMI.pre = NTMI.pre ? ();
NTMI.pre.settingsDir = NTMI.dir.userPOOL +/+ "2_process/presets/";
NTMI.pre.settingsDir.pathMatch;

if (ProxyPreset.findMethod(\addsToTop).notNil) {
	"*** ProxyPreset: adding new presets to top".postln;
	NTMI.pre.addsToTop = true;
} {
	"*** ProxyPreset: cannot add new presets to top - Please do:\n"
	" Quark(\"JITLibExtensions\").update;\n".postln;
};

(
NTMI.pre.makePreset = { |preDict, proxy|

	var controlKeys = proxy.controlKeys;
	// store all params except \amp:
	var defaultNamesToStore = controlKeys.reject( _ == \amp);
	var name = proxy.key;
	var preset, presPath, namesToStore;

	// set namesToStore if not already defined:
	if (proxy.getHalo(\namesToStore).isNil) {
		proxy.addHalo(\namesToStore, defaultNamesToStore)
	};
	// use all params as namesToInflux unless already defined:
	if (proxy.getHalo(\namesToInflux).isNil) {
		proxy.addHalo(\namesToInflux, controlKeys)
	};

	// // uses getHalo(\namesToStore):
	preset = NdefPreset(proxy);
	presPath = (NTMI.pre.settingsDir +/+ name ++ ".pxpreset.scd");
	preset.storePath_(presPath);

	if(File.exists(presPath)){
		preset.loadSettings(presPath);
		"  + preset % with % settings loaded. \n"
		.postf(name, preset.settings.size);
	} {
		"--- PRESET %: no preset found! \n".postf(name);
	};

	if (NTMI.pre.addsToTop == true){
		preset.perform(\addsToTop_, true);
	};
	preset
};

// making all the presets here
NTMI.pre.presets = NTMI.processes.collect { |proxy, i|
	NTMI.pre.makePreset(proxy)
};
);

// init to first preset if there are any saved ones
NTMI.pre.ntmi.do { |pre|
	var secondSet;
	if (pre.settings.size > 1) {
		secondSet = pre.settings[1].key;
		pre.setCurr(secondSet).setProxy(secondSet);
	};
};

"set preferred preset names:".postln;
NTMI.prefs.active.presetNames.printAll;
NTMI.prefs.active.presetNames.do { |assoc, i|
	var key = assoc.key, val = assoc.value.value;
	var preset = NdefPreset.all[key];
	var prekey = if (val.isKindOf(Symbol)) { val } { preset.settings.wrapAt(val).key };
	"% : % -> % \n".postf(preset, val.cs, prekey.cs);
	try { preset.setCurr(prekey).setProxy(prekey) };
};


// increments and stores a random seed per ndefPreset.
NTMI.pre.incrementSeed = {|q, proxy, inc=1|
	var preset = proxy.getHalo(\ndefPreset);
	var seed = proxy.getHalo(\seed) ? 0;
	if(preset.notNil){
		seed = seed + inc;
		postf("% has nu seed: %\n", preset, seed);
		proxy.addHalo(\seed, seed);
		seed;
	}{ "%: sorry, no preset present.\n".postf(proxy) }
};


///// add a preset on the fly while playing
MFdef(\snapshot1).add(\getset, { |proxy|
	var presy = NdefPreset(proxy);
	var name = "%".format(Date.getDate.stamp).asSymbol;
	"% - adding preset %\n".postf(presy, name);
	// saves to disk!
	presy.addSet(name, toDisk: true);
});

MFdef(\snapshot).add(\getset, { |proxy|
	"MFdef(\snapshot) stores:".postln;
	NTMI.slots.nowPlaying.do { |proxy|
		MFdef(\snapshot1).(proxy);
	};
});

// inc nil: rand, 1 is next, 2 is prev in list
NTMI.pre.stepNdefInf = { |dict, ndef, inc|
	var pre = NdefPreset(ndef.key);
	var nextNames = pre.getSetNames.reject(_ == \curr);
	var currName, currIndex, nextIndex, nextName;
	if (nextNames.isEmpty) {
		"*** % has no settings yet, so it cannot switch.\n".postf(pre);
	} {
		currName = pre.currSet.key;
		currIndex = nextNames.indexOf(currName) ? 0;
		inc = inc ?? {
			"rand".postln;
			rrand(1, nextNames.lastIndex)
		};
		nextIndex = currIndex + inc % nextNames.size;
		nextName = nextNames[nextIndex];
		">>> % setting: % at index: % \n\n".postf(pre, nextName.cs, nextIndex);
		pre.setCurr(nextName, true).setProxy(nextName);
		NTMI.inphlux.offsetsFromPreset(*[pre, nextName]);
	};
};
