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
}, active: true);

/***
use tanh/atanh compression curve on bival to create elastic borders
and to avoid hitting min or max values really quickly.
tune maxTanh to determine where to clip above compression:

maxTanh -> bival
0.96.atanh // +-1.95
0.98.atanh // +-2.3
0.99.atanh // +-2.65
0.995.atanh // +-3
0.999.atanh // +-3.8

*/
// set the hard clip border for tanh:
NTMI.maxTanh = 0.995; // +- 2.994

// define the two modes:
MFdef(\relSet).modes.put(\lin, (on: \relSet, off: \relSetTan));
MFdef(\relSet).modes.put(\tan, (on: \relSetTan, off: \relSet));
/*
// switch modes:
// use standard relSet, hardclip at +-1
MFdef(\relSet).mode = \lin; MFdef(\relSet).activeNames;
// use new tanh
MFdef(\relSet).mode = \tan; MFdef(\relSet).activeNames;
*/

MFdef(\relSet).add(\relSetTan, { |obj, deltaPairs|
	// maxtanval limits

	var newvals = deltaPairs.collect {|pair, i|
		var param, delta, spec, bival, bivaltan,
		newbi, newval;
		#param, delta = pair;
		spec = obj.getSpec(param);
		bival = obj.getUni(param).unibi;
		// clip here:
		bivaltan = bival.clip2(NTMI.maxTanh).atanh;
		newbi = (bivaltan + (delta * 2)).tanh;
		newval = spec.map(newbi.biuni);
		[ param, newval ];
	};
	obj.set(*newvals.flat);
}, active: false);



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
	if (controlKeys.first != \amp) {
		warn("% : first control name must be amp! cannot make preset".format(proxy));
		nil
	} {

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

		preset.storeToDisk = true;

		if (NTMI.pre.addsToTop == true){
			preset.perform(\addsToTop_, true);
		};
		preset
	};
};

// making all the presets here
NTMI.pre.presets = NTMI.processes.collectAs( { |proxy, i|
	NTMI.pre.makePreset(proxy)
}, List);

// init to first preset if there are any saved ones
NTMI.pre.presets.do { |pre|
	var setIndex = 1, setName;

	if (pre.settings.size > 1) {
		if (NTMI.usesRandomInit) {
			setIndex = rrand(1, pre.settings.lastIndex);
		};
		setName = pre.settings[setIndex].key;
		pre.setCurr(setName).setProxy(setName);
	};
};

// for the known ones, set these
if (NTMI.initialPresetNames.isNil) {
	"no preferred initialPresetNames".postln;
} {
	"\n --- Setting preferred initialPresetNames:".postln;
	NTMI.initialPresetNames.printAll;
	NTMI.initialPresetNames.do { |assoc, i|
		var key = assoc.key, val = assoc.value.value;
		var preset = NdefPreset.all[key];
		var prekey = if (val.isKindOf(Symbol)) { val } { preset.settings.wrapAt(val).key };
		"% : % -> % \n".postf(preset, val.cs, prekey.cs);
		try { preset.setCurr(prekey).setProxy(prekey) };
	};
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

/*
// two snapModes:
NTMI.snapDialog = true; // open dialog(s)
NTMI.snapDialog = nil;  // default, saves with datestamp
*/

///// add a preset on the fly while playing
MFdef(\snapshot1).add(\getset, { |proxy|
	var presy = NdefPreset(proxy);
	var name = "%".format(Date.getDate.stamp).asSymbol;
	if (NTMI.snapDialog == true) {
		presy.storeDialog(loc: Window.screenBounds.center - (75 @ -200));
		Window.allWindows.last.name_(proxy.key);
	} {
		"% - adding preset %\n".postf(presy);
		// always saves to disk!
		presy.addSet(name, toDisk: true);
	};
});


MFdef(\snapshot).add(\getset, { |proxy|
	var ndefsToSave = NTMI.slots.nowPlaying;
	if (ndefsToSave.isEmpty) {
		"snap: nothing playing, nothing to save.".postln
	} {
		"MFdef(\snapshot) stores:".postln;
		ndefsToSave.do { |proxy|
			MFdef(\snapshot1).(proxy)
		};
	}
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


// add an Ndef while running:
NTMI.addNdef = { |slots, ndef|
	// wrap in preset, config preset to save at NTMI pool
	NTMI.pre.makePreset(ndef);
	// add to all lists:
	NTMI.processes.add(ndef);
	NTMI.process.allNames.add(ndef.key);
	// then make sure slots have and show it
	NTMI.slots.updateChoices
};

/* - test:
Ndef('test2').addSpec('dist', [0,5]);
Ndef(\test2, { |amp, freq=200, dist = 2|
	(Saw.ar(freq + [-1, 1]) * dist) * amp
});
NTMI.addNdef(Ndef(\test2));
*/
)