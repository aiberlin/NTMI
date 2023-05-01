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
	q.hasGui   = q.hasGui ?? { \View.asClass.notNil };
	q.isPi     = q.isPi ?? { q.myname == 'pi' };
	q.time0 = Main.elapsedTime;
	q.myname = Platform.userHomeDir.basename.asSymbol;


	if (q.hasGui) {
		"9_optionals/warnWin.scd".loadRelative;
	} {
		q.warnWin = { |q, string="?!?", title="?!?"|
			warn(title + string)
		}
	};

	//////// DIRECTORIES:
	q.dir = q.dir ? ();
	q.dir.ntmi = thisProcess.nowExecutingPath.dirname;
	q.dir.fullNames = (q.dir.ntmi +/+ "*/").pathMatch;
	q.dir.names = q.dir.fullNames.collect { |path| path.basename };

	// check user dir, make it and migrate pool there if desired
	q.dir.user = Platform.userHomeDir +/+ "NTMI";


	// ///////// set for dev mode here :
	// if (q.myname == \adcxxx) {
	// 	q.dev = true;
	// } {
	// 	q.dev = false;
	// };

	/// user mode not working yet, so switching to dev mode for now:
	q.dev = true;

	if(q.dev) {
		///////////// WHILE DEVELOPING, direct back to dev/project dir!
		q.dir.user = q.dir.ntmi;
		q.dir.userPOOL = q.dir.ntmi +/+ "POOL";
	} {
		///////////// non-dev: copy pool to user home dir
		if (File.exists(q.dir.user).not) {
			"NTMI: making user home dir".postln;
			unixCmd("mkdir" + quote(q.dir.user));
			unixCmd("cp -nR"
				+ quote(q.dir.ntmi +/+ "POOL")
				+ quote(q.dir.user +/+ "POOL")
			);
		};
		q.dir.userPOOL = q.dir.user +/+ "POOL";
		q.dir.user.openOS;
	};

	// loads local or absolute filenames or paths,
	// with wait time and posted load time info:
	q.load = { |q, filename, here, wait = 0.05, dirsup = 0, preText = "", postText = ""|
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
					wait.wait;
				};

				"";
			}, AppClock)
		};
	};

	"\n\n".post;


	//******* PREFERENCES
	///// read user prefs (if there) or default prefs early on:
	"1_prefs/1_prefs.scd".loadRelative;

	// these may have been set in startup file already:
	q.usesMidi = q.prefs.active.usesMidi ? true;
	q.usesHid  = q.prefs.active.usesHid  ? true;
	q.interfacesToLoad  = q.prefs.active.interfacesToLoad ? [ "uc4" ];
	q.reboot = q.prefs.active.reboot  ? false;

	// turning this off does not work yet
	q.usesMainFX  = /*q.prefs.active.usesMainFX  ?*/ true;

	// "*** Modality: find MIDI and HID devices if enabled ***".postln;
	if (q.usesMidi) {
		MKtl.find(\midi); 0.5.wait;
	};
	if (q.usesHid) {
		MKtl.find(\hid); 0.5.wait;
	};

	// Server.killAll;
	if (q.reboot) {
		s.quit; "".postln;
		0.2.wait;
	};

	"\n\n*** *** *** FOLDER %:\n".postf("0_globals");
	q.load("0_globals/*.scd");

	// set q.numChans from prefs
	q.numChans = q.prefs.active.numChans ? 2;
	q.numIns = q.prefs.active.numIns ? q.numChans;

	if (s.serverRunning) {
		"server running already, cannot adjust settings".postln;
		q.numChans = min(q.numChans, s.options.numOutputBusChannels);
		q.numIns =   min(q.numIns,   s.options.numInputBusChannels);

	} {
		"setting up server ... ".postln;
		q.load(q.prefs.active.serverSetup, q.dir.user +/+ "POOL/1_*");

		s.options.numInputBusChannels = q.numIns;
		s.options.numOutputBusChannels = q.numChans;

		q.load(q.prefs.active.preBootSetup);
	};
	"*** q.numChans is: %\n".postf(q.numChans);
	"*** q.numIns is: %\n".postf(q.numIns);

	"\n\n".postln;

	s.waitForBoot {
		var prevLatency = s.latency;

		// avoid late messages while loading
		s.latency = nil;

		q.ndefGroups = q.ndefGroups ? ();

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


		"\n\n*** *** *** FOLDER %:\n".postf("2_process");
		q.load("2_bufferLoader.scd");

		// find matching paths in pool first
		q.process = q.process ? ();
		q.process.procPath = (q.dir.userPOOL +/+ "2_process/*.scd");
		q.process.foundPaths = q.process.procPath.pathMatch;
		q.process.foundNames = q.process.foundPaths.collect { |p|
			p.basename.splitext[0].asSymbol
		};

		// list all candidate files
		"// found % process paths at \n%\n".postf(
			q.process.foundPaths.size, q.process.procPath.cs);
		"// post them with: \nq.process.foundNames.cs".postln;

		0.5.wait;

		q.load("2_liveInput.scd");

		if (q.prefs.active.processNames.isNil) {
			"loading % found paths:\n".postf(q.process.foundNames.size);
			q.process.namesToLoad = q.process.foundNames;
		} {
			"loading predefined paths in q.prefs.active.processNames:\n";
			q.process.namesToLoad = q.prefs.active.processNames;
		};

		q.process.allNames = q.process.namesToLoad;

		// load preferred processNames, or all:
		q.process.namesToLoad.do { |name|
			q.load(name ++ ".scd", q.dir.userPOOL +/+ "2_process");
			s.sync;
			0.05.wait;
		};


		q.load("2a_preset*.scd");

		q.ndef = q.ndef ? ();
		q.ndef.groups = q.ndef.groups ? ();
		q.ndef.groups.put(\NTMI, q.process.allNames.collect(Ndef(_)));

		"\n\n".postln;

		0.2.wait;
		// activate the ndefs given in prefs:
		q.ndefs = q.prefs.active.defaultActives.collect(Ndef(_));

		"\n\n*** *** *** FOLDER % : \n".postf("3_interfaces");
		q.load("3_interfaces/*scd");

		q.interfacesToLoad.do { |name|
			q.load("3_interfaces/*/*%*scd".format(name));
		};

		"\n\n*** *** *** FOLDER % : \n".postf("5_postres");
		q.load("5_postres/*scd");

		if (q.usesMainFX) {
			q.load("6_MainFX.scd");
		};

		if (q.hasGui) {
			"\n\n*** *** *** FOLDER % : \n".postf("8_GUIs");
			q.load("8_GUIs/*scd");
			0.2.wait;
			if (q.isPi != true) {
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

