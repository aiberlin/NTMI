/****
*** AutoPilot variant for ntmi sound processes:
- load all sound processes and presets
- Tdef picks a sound, and morphs between its presets
- amp is random-modualted for dynamics
- setting a randSeed makes rand sequences reproduceable;
- can be used for choir of machines playing the same sequence.


Tdef(\ntmiPilot).set(\randSeed, 4711);
Tdef(\ntmiPilot).set(\randSeed, 666);
Tdef(\ntmiPilot).set(\randSeed, nil);

Tdef(\ntmiPilot).gui
NdefMixer(s)

****/

q = q ? ();
q.dir = q.dir ? ();

if (q[\load].isNil) {
	// simple replacement for use outside NTMI
	q.load = { |q, path| try { path.loadRelative } };
};

// q.process = nil;

s.waitForBoot {

	/// load ntmiPilot only if not loaded yet:
	if (q.process.isNil) {
		"LOADING NTMI Processes and presets...".postln;
		q.codeDirNTMI = thisProcess.nowExecutingPath.dirname;
		q.dir.user = q.codeDirNTMI;

		// find matching paths in pool first
		q.process = q.process ? ();
		q.dir = q.dir ? ();
		q.dir.userPOOL = q.codeDirNTMI +/+ "POOL";

		q.process.dirName = (q.codeDirNTMI +/+ "POOL/2_process");
		q.process.procPath = (q.process.dirName +/+ "*.scd");
		q.process.foundPaths = q.process.procPath.pathMatch;
		q.process.foundNames = q.process.foundPaths.collect { |p|
			p.basename.splitext[0].asSymbol
		};
		// could use only special subset list here?
		q.process.namesToLoad = q.process.foundNames;
		q.process.allNames = q.process.namesToLoad;

		// list all candidate files
		"// found % process paths at \n%\n".postf(
			q.process.foundPaths.size, q.process.procPath.cs);
		"// post them with: \nq.process.foundNames.cs".postln;

		if ( \WavesetsEvent.asClass.isNil) {
			q.process.namesToLoad = q.process.namesToLoad.reject(_ == \wsetta);
		};


		forkIfNeeded ({
			var ndefKeysAlreadyThere, ndefKeysNowLoaded;

			q.load("0_globals/1_loadGlobalUtils.scd");
			s.sync;
			"\n\nloading NTMI buffers and processes in %:\n".postf("2_process");

			ndefKeysAlreadyThere = Ndef.dictFor(s).envir.keys;
			q.load("2_liveInput.scd");
			// load preferred processNames, or all:
			q.process.namesToLoad.do { |name|
				q.load("POOL/2_process" +/+ name.postln ++ ".scd");
				s.sync;
				0.05.wait;
			};

			ndefKeysNowLoaded = Ndef.dictFor(s).envir.keys.removeAll(ndefKeysAlreadyThere);

			// simple replacement for use outside NTMI
			if (q[\getNdefs].isNil) {
				// ndefKeysNowLoaded.postcs;
				q.getNdefs = ndefKeysNowLoaded.collect(Ndef(_));
			};

			q.load("2a_preset*.scd");

			"found % NdefPresets.\n\n".postf(NdefPreset.all.size);

			"*** ntmiPilot prep done. ***\n\n".postln;

			// Tdef(\ntmiPilot).play;

		}, AppClock);

} };

Tdef(\ntmiPilot, { |envir|
	var presetsToChoose, preset, ndef, waitTime, settings, setname;
	var timeFunc = {
		var dt = [3, 5, 8, 13 ].choose;
		envir.waitTime = dt;
		dt;
	};

	var seed = Tdef(\ntmiPilot).get(\randSeed);
	if (seed.isNumber) {
		" Tdef(\ntmiPilot): randSeed is %\n".postf(seed);
		thisThread.randSeed = seed
	};

	presetsToChoose = NdefPreset.all.select { |pre| pre.settings.size > 3 };
	envir.numNdefs = presetsToChoose.size;

	Ndef(\gainride, {
		LFDNoise3.kr(
			LFDNoise1.kr(1/30).exprange(0.1, 5)
		).range(-20, 0).dbamp
	});

	inf.do {
		preset !? { presetsToChoose.removeAt(preset.key) };
		preset = presetsToChoose.choose;
		ndef = preset.proxy;

		envir.currNdef = ndef;

		"ntmiPilot uses %\n".postf(preset);
		preset.morphTask.set(\dt, 0.05);
		ndef.set(\amp, 0.25).play;
		ndef.map(\amp, Ndef(\gainride));

		timeFunc.value.wait;

		// random start
		settings = preset.settings.drop(1).collect(_.key);
		setname = settings.choose;
		preset.xfadeTo(setname, rrand(0.5, 2));
		envir.currSetting = setname;

		exprand(3, 8).round.postln.do { |i|
			waitTime = timeFunc.value.postln;

			settings = preset.settings.drop(1).collect(_.key);
			settings.remove(setname);
			setname = settings.choose;
			envir.currSetting = setname;

			"xfading to % in % secs".postf(setname, waitTime);
			preset.xfadeTo(setname, waitTime);
			waitTime.do { ".".post; 1.wait }; "|".postln;
			timeFunc.value.wait;
		};
		waitTime = timeFunc.value;
		ndef.end(waitTime * 2);
		"ntmiPilot loops.".postln;
	};
});
