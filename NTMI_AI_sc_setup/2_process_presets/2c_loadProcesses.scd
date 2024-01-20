/// find all candidates files at given paths
/// try load them
// if Ndef, addHalo for path
// addHalo for preset path
// make preset for it


forkIfNeeded {

	"\n\n*** NTMI loading process folder %:\n".postf("2_process");
	// find matching paths in pool first
	NTMI.process = NTMI.process ? ();
	NTMI.process.procPath = (NTMI.dir.userPOOL +/+ "2_process/*.scd");
	NTMI.process.foundPaths = NTMI.process.procPath.pathMatch;
	NTMI.process.foundNames = NTMI.process.foundPaths.collect { |p|
		p.basename.splitext[0].asSymbol
	};

	// list all candidate files
	"// found % process paths at \n%\n".postf(
		NTMI.process.foundPaths.size, NTMI.process.procPath.cs);
	"// post them with: \nNTMI.process.foundNames.cs".postln;

	if (NTMI.process.namesToLoad.isNil) {
		"loading all % found paths:\n".postf(NTMI.process.foundNames.size);
		NTMI.process.namesToLoad = NTMI.process.foundNames;
	} {
		"loading predefined paths in NTMI.process.namesToLoad:\n %\n"
		.postf(NTMI.processNames.cs);
		NTMI.process.namesToLoad =
		NTMI.process.namesToLoad.sect(NTMI.process.foundNames);
	};

	NTMI.process.allNames = NTMI.process.namesToLoad;

	// load preferred processNames, or all:
	NTMI.process.allNames.do { |name|
		try { LoadMe(name ++ ".scd", NTMI.dir.userPOOL +/+ "2_process") } {
			"*** process load for % failed! others should be fine.\n".postf(name.cs);
		};
	};

	NTMI.ndef = NTMI.ndef ? ();
	NTMI.ndef.groups = NTMI.ndef.groups ? ();

	// filter allNames for nonexistent Ndefs
	NTMI.process.allNames = NTMI.process.allNames.select { |name|
		var found = Ndef.all[s.name][name].isKindOf(Ndef);
		if (found.not) {
			"*** no Ndef for %! please check its code file.\n".postf(name);
		};
		found
	};

	NTMI.processes = NTMI.process.allNames.collect(Ndef(_));
	NTMI.ndef.groups.put(\NTMI, NTMI.processes);

	// kill them all again for startup
	defer ({ NTMI.processes.do(_.end) }, 0.1);

	{
		var allNdefChoices = NTMI.process.allNames.copy;
		var activesToUse = (NTMI.defaultActives ? []).select { |name, i|
			var found = allNdefChoices.includes(name);
			if (found.not) {
				"*** no Ndef for %! please check its code file.\n".postf(name);
			};
			found
		};
		if (activesToUse.size > 4) {
			"too many defaultActives: \n%\nkeeping 4.\n".postf(activesToUse);
			if (NTMI.usesRandomInit) {
				activesToUse = activesToUse.scramble;
			};
			activesToUse = activesToUse.keep(4);
		};
		if (activesToUse.size < 4) {
			"too few defaultActives: \n%\n".postf(activesToUse);
			allNdefChoices.removeAll(activesToUse);
			activesToUse = activesToUse
			++ allNdefChoices.scramble.keep(4 - activesToUse.size);
			"random filling to 4.".postln;
		};
		"actives to use: \n%\n".postf(activesToUse);
		// activate the ndefs given in prefs:
		NTMI.ndefs = activesToUse.collect(Ndef(_));
		"*** NTMI.ndefs: ".postln;
		NTMI.ndefs.postln;
		"\n\n".postln;
	}.value;
};