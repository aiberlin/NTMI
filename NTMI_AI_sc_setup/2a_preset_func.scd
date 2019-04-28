/*
NdefPresetGui(NdefPreset(\allArm), 20);
q.pre.userSettingsDir.openOS;
q.pre.incrementSeed(Ndef(\allArm));
*/
"\n... loading presets ...".postln;

q.pre = q.pre ? ();
q.pre.settingsDir = q.dir.userPOOL +/+ "2_process/presets/";
q.pre.settingsDir.pathMatch;

(
q.pre.makePreset = { |pre, proxy|

	var name = proxy.key;
	var namesToStore = proxy.controlKeys.reject( _ == \amp); // everything except amp
	var preset = NdefPreset(proxy, namesToStore);	// <- dont store amp along
	var presPath = (q.pre.settingsDir +/+ name ++ ".pxpreset.scd");

	//////// enable this line to tell influx to use same names;
	//////// so Influx will not set amp values.
	//////// e.g. if amp comes from overall interface activity etc...
	// proxy.addHalo(\orderedNames, namesToStore);

	if(File.exists(presPath)){
		preset.loadSettings(presPath);
		"  + preset % with % settings loaded. \n"
		.postf(name, preset.settings.size);
	} {
		"--- PRESET %: no preset found! \n".postf(name);
	};
	preset.storePath_(presPath);

	// if(preset.settings.size < 2){
	// 	// load first real preset ...
	// 	preset.setCurr(preset.settings.wrapAt(1).key);
	// }{ "sorry, no settings there yet".warn };
	// proxy.addHalo(\ndefPreset, preset);
};

// making all the presets here
q.getNdefs.do { |proxy, i|	q.pre.makePreset(proxy) };
// FIXME /////// ****** preset.loadSettings(presPath); with xFMSH
/// somehow creates a global var l - a List of settings - why?
// quick and dirty fix: set it to nil
l = nil;
);

// init to first preset if there are any saved ones
NdefPreset.all.do { |pre|
	if (pre.settings.size > 1) { pre.setCurr(pre.settings[1].key) };
};

// increments and stores a random seed per ndefPreset.
q.pre.incrementSeed = {|q, proxy, inc=1|
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
	var setty = proxy.getKeysValues(presy.namesToStore).postcs;
	var name = "%_%".format(q.myname, Date.getDate.stamp).asSymbol.postcs;
	presy.addSet(name, setty);
});

MFdef(\snapshot).add(\getset, { |proxy|
	q.slots.nowPlaying.do { |proxy|
		MFdef(\snapshot1).(proxy);
	};
});


// inc nil: rand, 1 is next, 2 is prev in list
q.pre.stepNdefInf = { |dict, ndef, inc|
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
		pre.setCurr(nextName);
		q.inphlux.offsetsFromPreset(*[pre, nextName]);
	};
};

