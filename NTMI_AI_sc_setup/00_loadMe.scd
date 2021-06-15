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
	q.time0 = Main.elapsedTime;
	q.myname = Platform.userHomeDir.basename.asSymbol;

	// these may be set in startup file already?
	q.hasGui = q.hasGui ?? { \View.asClass.notNil };
	q.isPi = q.isPi ?? { q.myname == 'pi' };
	q.usesMidi = q.usesMidi ? true;

	if (q.hasGui) {
		"9_optionals/warnWin.scd".loadRelative
	} {
		q.warnWin = { |q, string="?!?", title="?!?"|
			warn(title + string)
		}
	};

	//////// DIRECTORIES:
	q.dir = q.dir ? ();
	q.dir.base = thisProcess.nowExecutingPath.dirname;
	q.dir.fullNames = (q.dir.base +/+ "*/").pathMatch;
	q.dir.names = q.dir.fullNames.collect { |path| path.basename };

	// check user dir, make it and migrate pool there if needed
	q.dir.user = Platform.userHomeDir +/+ "NTMI";


	// "*** Modality: find MIDI and HID devices if enabled ***".postln;
	if (q.usesMidi) {
		MKtl.find(\midi); 0.5.wait;
	};
	if (q.usesHid) {
		MKtl.find(\hid); 0.5.wait;
	};

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
		q.dir.user = q.dir.base;
		q.dir.userPOOL = q.dir.base +/+ "POOL";
	} {
		///////////// non-dev: copy pool to user home dir
		if (File.exists(q.dir.user).not) {
			"NTMI: making user home dir".postln;
			unixCmd("mkdir" + quote(q.dir.user));
			unixCmd("cp -nR"
				+ quote(q.dir.base +/+ "POOL")
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
				here = here ? q.dir.base;
				dirsup.do { here = here.dirname };
				path = (here +/+ path);
			};

			paths = path.pathMatch;

			forkIfNeeded ({
				var loadDur, t0 = Main.elapsedTime;

				if (paths.size == 0) { "*** no files found for % :\n".postf(path.cs) };

				if (paths.size > 1) { "****** matching files for % :\n".postf(path.cs) };

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
	// set q.numChans from prefs
	q.numChans = q.prefs.active.numChans ? 2;
	q.numIns = q.prefs.active.numIns ? q.numChans;
	"*** q.numChans is: %\n".postf(q.numChans);
	"*** q.numIns is: %\n".postf(q.numIns);

	// Server.killAll;
	s.quit; "".postln;

	0.2.wait;
	"\n\n*** *** *** FOLDER %:\n".postf("0_globals");
	q.load("0_globals/*.scd");

	q.load(q.prefs.active.serverSetup, q.dir.user +/+ "POOL/1_*");

	s.options.numInputBusChannels = q.numIns;

	q.load(q.prefs.active.preBootSetup);

	"\n\n".postln;

	s.waitForBoot {

		q.helloSnd ?? {
			// if q.helloSnd is not already defined in startup file, do:
			"*** server booted, plays 3 pings on left chan.".postln;
			fork { 3.do { Env.perc.test; 0.3.wait } };
		};

		"\n".postln;

		q.load(q.prefs.active.postBootSetup);

		"\n\n*** *** *** FOLDER %:\n".postf("2_process");
		// list all candidate files
		if (q.prefs.active.processNames.isNil) {
			(q.dir.userPOOL +/+ "*process/*.scd").pathMatch
			.collect {|pa| pa.basename.splitext[0].asSymbol }.postcs;
		};

		q.load("2_bufferLoader.scd");

		q.process = q.process ? ();
		q.process.allPaths = (q.dir.userPOOL +/+ "*process/*.scd").pathMatch;
		q.process.allNames = q.process.allPaths.collect { |p|
			p.basename.splitext[0].asSymbol
		};

		0.5.wait;

		q.load("2_liveInput.scd");

		// load preferred processNames, or all:
		(q.prefs.active.processNames ? q.process.allNames).do { |name|
			q.load(name ++ ".scd", q.dir.userPOOL +/+ "2_process");
			s.sync;
			0.05.wait;
		};

		q.load("2a_preset*.scd");

		"\n\n".postln;

		0.2.wait;
		// activate the ndefs given in prefs:
		q.ndefs = q.prefs.active.defaultActives.collect(Ndef(_));

		"\n\n*** *** *** FOLDER % : \n".postf("3_interfaces");
		q.load("3_interfaces/*scd");

		"\n\n*** *** *** FOLDER % : \n".postf("5_postres");
		q.load("5_postres/*scd");

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

		q.setupTime = (Main.elapsedTime - q.time0).round(0.01);
		"\n*** NTMI SETUP finished in % secs! ***\n\n\n".postf(q.setupTime);

		q.load(q.prefs.active.finalSetup);

	};
}.play(AppClock);
)

