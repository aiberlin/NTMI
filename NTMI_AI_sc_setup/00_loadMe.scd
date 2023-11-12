/*
* this loadme file resides in the project folder,
* and is not intended for user-introduced changes.

(
var types = ();
q.keysValuesDo { |key, val|
var class = val.class;
types.put(class, (types[class] ?? { List[] }).add(key))
};
types.postcs
)

"--- contents of q: ---".postln;
q.size.postln;
q.keys(SortedList).do("q.% : %\n".postf(_, _, _));
"--- end contents of q ---".postln;
"";

*/

(

Task {

	0.1.wait; /// wait for SC Welcome post ...

	"\n\n*** loadMe file for NTMI_AI_sc_setup loading...\n\n".postln;

	q = q ? ();  // <- dict for most everything
	g = g ? ();  // <- gui stuff goes here!


	//// Set generally useful globals:

	// internally useful:
	q.isPi     = q.isPi ?? { q.myname == 'pi' };
	q.time0 = Main.elapsedTime;
	q.myname = Platform.userHomeDir.basename.asSymbol;

	//////// determine DIRECTORIES: ///////////////
	q.dir = q.dir ? ();
	q.dir.ntmi = thisProcess.nowExecutingPath.dirname;
	q.dir.fullNames = (q.dir.ntmi +/+ "*/").pathMatch;
	q.dir.names = q.dir.fullNames.collect { |path| path.basename };


	q.dev = q.dev ? false;

	"*** NTMI: setup dir q.dir.ntmi is %\n".postf(q.dir.ntmi.cs);

	if(q.dev) {
		// ONLY WHILE DEVELOPING, direct back to dev/project dir!
		q.dir.user = q.dir.ntmi;
		q.dir.userPOOL = q.dir.ntmi +/+ "POOL";
	} {
		///////////// normal use:
		q.dir.user = Platform.userHomeDir +/+ "NTMI";
		q.dir.userPOOL = q.dir.user +/+ "POOL";

		// check for user dir and make it if needed
		if (File.exists(q.dir.user).not) {
			"NTMI: making q.dir.user".postln;
			unixCmd("mkdir" + quote(q.dir.user));
		};

		//// check if POOL is already in user home dir,
		//// and if not, copy it there
		if (File.exists(q.dir.userPOOL).not) {
			"*** NTMI: copying POOL folder to q.dir.user".postln;
			unixCmd("cp -nR"
				+ quote(q.dir.ntmi +/+ "POOL")
				+ quote(q.dir.user +/+ "POOL")
			);
			q.dir.userPOOL.openOS;
		};
		"*** NTMI: q.dir.user is %\n".postf(q.dir.user.cs);
		"*** NTMI: q.dir.userPOOL is %\n".postf(q.dir.userPOOL.cs);
	};


	// custom load function:
	// loads local or absolute filenames or paths,
	// with wait time and posted load time info:
	// maybe move to LoadMe class eventually.
	q.load = { |q, filename, here, wait = 0.0, dirsup = 0, preText = "", postText = ""|
		var paths, path;
		if (filename.isNil) { warn("path was nil!") } {

			path = filename.standardizePath;
			if (path[0].isPathSeparator.not) {
				here = here ? q.dir.ntmi;
				dirsup.do { here = here.dirname };
				path = (here +/+ path);
			};

			paths = path.pathMatch;

			forkIfNeeded ({
				var loadDur, t0 = Main.elapsedTime;

				if (paths.size == 0) { "*** no files found for % :\n".postf(path.cs) };

				if (paths.size > 1) { "****** % matching files for % :\n".postf(paths.size, path.cs) };

				paths.do { |path|
					"*** loading % : %".postf(path.basename, preText);
					path.load;
					if (s.serverRunning) { try { s.sync } };
					loadDur = (Main.elapsedTime - t0).round(0.001);
					" % secs. %\n".postf(loadDur, postText);
					if (wait > 0) { wait.wait };
				};

				"";
			}, AppClock)
		};
	};

	"\n\n".post;

	//******* PREFERENCES
	///// read user prefs (if there) or copy default prefs there:
	"1_prefs/1_prefs.scd".loadRelative;

	// Set flags for which parts to load:
	// on headless systems, dont use guis
	q.hasGui = q.prefs.active.hasGui ? q.hasGui ?? { \View.asClass.notNil };
	q.hasSmallScreen = q.prefs.active.hasSmallScreen ? q.hasSmallScreen ?? false;

	// which types of controllers will be used?
	// these may have been set in startup file already:
	q.usesMidi = q.prefs.active.usesMidi ? q.usesMidi ? true;
	q.usesHid  = q.prefs.active.usesHid  ? q.usesHid ? true;
	// which of the supported interfaces should be loaded?
	// can include custom ones in userPOOL
	q.interfacesToLoad  = q.prefs.active.interfacesToLoad ? [ "uc4" ];
	// reboot server when starting NTMI?
	q.reboot = q.prefs.active.reboot ? q.reboot ? false;

	// turn off MainFX if desired (loses mainVol control)
	q.usesMainFX = q.prefs.active.usesMainFX ? q.usesMainFX ? true;

	if (q.hasGui) {
		"8_GUIs/warnWin.scd".loadRelative;
	} {
		q.warnWin = { |q, string="?!?", title="?!?"| warn(title + string) }
	};

	"*** Modality: find MIDI and HID devices if enabled ***".postln;
	if (q.usesMidi) {
		MKtl.find(\midi); 0.1.wait;
	};

	if (q.usesHid) {
		Platform.case(\windows) {
			"HID on windows is not working in SC3.13.0.".warn
		} {
			MKtl.find(\hid); 0.1.wait;
		};
	};


	if (q.reboot) {
		// Server.killAll; // ?
		"*** NTMI kills server to reboot.".postln;
		s.quit; "".postln;
		0.2.wait;
	};

	"\n\n*** *** *** FOLDER %:\n".postf("0_globals");
	q.load("0_globals/*.scd");

	// set q.numChans from prefs
	q.numChans = q.prefs.active.numChans ? 2;
	q.numIns = q.prefs.active.numIns ? q.numChans;

	if (s.serverRunning) {
		"*** server running already, cannot adjust settings!".postln;
		"may not be able to do everything in preBootSetup ...".postln;
		q.numChans = min(q.numChans, s.options.numOutputBusChannels);
		q.numIns =   min(q.numIns,   s.options.numInputBusChannels);

	} {
		"setting up server ... ".postln;
		q.load(q.prefs.active.serverSetup, q.dir.user +/+ "POOL/1_*");

		s.options.numInputBusChannels = q.numIns;
		s.options.numOutputBusChannels = q.numChans;
	};

	"*** q.numChans is: %\n".postf(q.numChans);
	"*** q.numIns is: %\n".postf(q.numIns);

	q.load(q.prefs.active.preBootSetup);

	"\n\n".postln;


	s.waitForBoot {
		var prevLatency = s.latency;

		// avoid late messages while loading
		s.latency = nil;

		q.helloSnd ?? {
			// if q.helloSnd is not already defined in startup file, do:
			fork {
				q.numChans.do { |i|
					{ LFDNoise3.ar(
						XLine.kr(
							exprand(2000, 5000),
							exprand(2000, 20000),
							0.25, doneAction: 2),
						0.1
					)
					}.play(outbus: i);
					0.25.wait;
				};
			};
		};

		"\n".postln;

		q.load(q.prefs.active.postBootSetup);


		q.load("2_process_presets/2a_bufferLoader.scd");
		q.load("2_process_presets/2b_liveInput.scd");

		q.load("2_process_presets/2c_loadProcesses.scd");


		/********** INTERFACES *********/

		"\n\n*** *** *** FOLDER % : \n".postf("3_interfaces");
		q.load("3_interfaces/*scd");

		q.interfacesToLoad.do { |name|
			q.load("3_interfaces/*/*%*scd".format(name));
		};

		if (q.usesMainFX) {
			q.load("6_MainFX.scd");
		};


		if (q.hasGui) {
			"\n\n*** *** *** FOLDER % : \n".postf("8_GUIs");
			q.load("8_GUIs/*scd");
			// 0.1.wait;
			if (q.hasSmallScreen != true) {
				g.makeGui[\Main_NTMI].value;
			} {
				g.makeGui['miniNTMI'].value;
			};
		};

		q.load(q.prefs.active.finalSetup);

		// reinstate prev. latency
		if (s.latency.isNil) {
			s.latency = prevLatency;
			"// server latency back to % after loading.\n\n".postf(s.latency);
		} {
			"*** server prevLatency was %\n;"
			"*** server latency now  is % - leaving it as is.\n".postf(prevLatency, s.latency);
		};

		q.setupTime = (Main.elapsedTime - q.time0).round(0.01);
		"\n*** NTMI SETUP finished in % secs! ***\n\n\n".postf(q.setupTime);

	};
}.play(AppClock);
)

