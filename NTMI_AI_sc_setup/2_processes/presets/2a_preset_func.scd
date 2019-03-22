/*
NdefPresetGui(NdefPreset(\allArm), 20);
q.pre.userSettingsDir.openOS;
q.pre.incrementSeed(Ndef(\allArm));

*/
q.pre = q.pre ? ();
q.pre.appSettingsDir = thisProcess.nowExecutingPath.dirname;
q.pre.userSettingsDir = Platform.userAppSupportDir +/+ "presets/";
File.mkdir(q.pre.userSettingsDir);
// where to store presets?
q.pre.settingsDir = q.pre.userSettingsDir;

// // replaced by 	q.mtx.actives
// q.active = q.active ?? {()};
// q.active.presWin = Set.new;
// try { q.active.presWin.add(q.ndefs.first) };
// // here, we need a bloody single item, not a set !
// // try{ q.active.presWin = (q.ndefs.first) };

(
q.pre.makePreset = { |pre, proxy|

	var name = proxy.key;
	var namesToStore = proxy.controlKeys.reject( _ == \amp); // everything except amp
	var preset = NdefPreset(proxy, namesToStore);	// <- dont store amp along
	var userPresPath = (q.pre.userSettingsDir +/+ name ++ ".pxpreset.scd");
	var appPresPath = (q.pre.appSettingsDir +/+ name ++ ".pxpreset.scd");

	//////// enable this line to tell influx to use same names;
	//////// so Influx will not set amp values.
	//////// e.g. if amp comes from overall interface activity etc...
	// proxy.addHalo(\orderedNames, namesToStore);

	// try to read from local user path:
	if(File.exists(userPresPath)){
		preset.loadSettings(userPresPath);
		"  *  userDir preset % loaded.\n".postf(name);
	} {
		// or else read from default path inside project dir.
		if(File.exists(appPresPath)){
			preset.loadSettings(appPresPath);
			"  + default preset % loaded. \n".postf(name);
		} {
			"--- PRESET %: no user or app preset found! \n".postf(name);
		};
	};
	preset.storePath_(userPresPath);

	if(preset.settings.notNil){ // load first real preset ...
		preset.setCurr(preset.settings.wrapAt(1).key);
	}{ "sorry, no settings there yet".warn };
	proxy.addHalo(\ndefPreset, preset);
};

// making all the presets here
q.getInfluxDestins.do { |proxy, i|	q.pre.makePreset(proxy) };
// ****** preset.loadSettings(appPresPath); with xFMSH
/// somehow creates a global var l - a List of settings - why?
// quick fix: set it to nil
l = nil;
);

// increments and stores a ransom seed per ndefPreset.
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

