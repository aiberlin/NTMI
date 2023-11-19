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

	if (NTMI.prefs.active.processNames.isNil) {
		"loading all % found paths:\n".postf(NTMI.process.foundNames.size);
		NTMI.process.namesToLoad = NTMI.process.foundNames;
	} {
		"loading predefined paths in NTMI.prefs.active.processNames:\n";
		NTMI.process.namesToLoad =
		NTMI.prefs.active.processNames.sect(NTMI.process.foundNames);
	};

	NTMI.process.allNames = NTMI.process.namesToLoad;

	// load preferred processNames, or all:
	NTMI.process.namesToLoad.do { |name|
		try { LoadMe(name ++ ".scd", NTMI.dir.userPOOL +/+ "2_process") } {
			"*** process load for % failed! others should be fine.\n".postf(name.cs);
		};
	};

	NTMI.ndef = NTMI.ndef ? ();
	NTMI.ndef.groups = NTMI.ndef.groups ? ();

	NTMI.ndef.groups.put(\NTMI,
		NTMI.process.namesToLoad.collect(Ndef.all[s.name][_]);
	);
	// kill them all again for startup
	defer ({ NTMI.ndef.groups.at(\NTMI).do(_.end) }, 0.1);

	// activate the ndefs given in prefs:
	NTMI.ndefs = NTMI.prefs.active.defaultActives.collect(Ndef(_));
	"\n\n".postln;
};