/*
NdefPresetGui(NdefPreset(\allArm), 20);
q.pre.userSettingsDir.openOS;
q.pre.incrementSeed(Ndef(\allArm));
*/
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

