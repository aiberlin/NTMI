/*
* this loadme file reamins inside the app,
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

	"\n\n*** startup file for NTMI_AI_sc_setup loading...\n\n".postln;

	q = q ? ();  // <- dict for most everything
	g = g ? ();  // <- gui stuff goes here!


	//// Set generally useful globals:
	q.time0 = Main.elapsedTime;
	q.myname = Platform.userHomeDir.basename.asSymbol;
	q.hasGui = \View.asClass.notNil;
	if (q.hasGui) { "9_optionals/warnWin.scd".loadRelative };

	//////// DIRECTORIES:
	q.dir = q.dir ? ();
	q.dir.base = thisProcess.nowExecutingPath.dirname;
	q.dir.fullNames = (q.dir.base +/+ "*/").pathMatch;
	q.dir.names = q.dir.fullNames.collect { |path| path.basename };

	// check user dir, make it and migrate pool there if needed
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


	// loads code files or folders with wait and posts load time info:
	q.load = { |q, filename, here, wait = 0.05, dirsup = 0, preText = "", postText = ""|
		forkIfNeeded ({
			var loadDur, t0 = Main.elapsedTime;
			var paths;
			here = here ? q.dir.base;

			dirsup.do { here = here.dirname };
			paths = (here +/+ filename).pathMatch;

			if (paths.size == 0) { "*** no files found for % :\n".postf(filename.cs) };

			if (paths.size > 1) { "****** matching files for % :\n".postf(filename.cs) };

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


	//******* PREFERENCES
	///// read user prefs (if there) or default prefs early on:
	"1_prefs/1_prefs.scd".loadRelative;
	// set q.numChans from prefs
	q.numChans = q.prefs.active.numChans ? 2;
	q.numIns = q.prefs.active.numIns ? q.numChans;
	"*** q.numChans is: %\n".postf(q.numChans);

	q.hasGui = q.prefs.active.hasGui ? q.hasGui;

	///////// dont load HIDs by default, for more stability
	///// MKtl.find(\hid); 0.5.wait;
	///////// do load MIDI devices
	MKtl.find(\midi);

	s.quit; "".postln;

	0.2.wait;
	"\n\n*** *** *** FOLDER %:\n".postf("0_globals");
	q.load("0_globals/*.scd");

	"/Users/adc/NTMI/POOL/1_server_setups/serverBasic2.scd".pathMatch;
	q.load(q.prefs.active.serverSetup, q.dir.user +/+ "POOL/1_*");
	// preload all sounds while server is off!
	q.load("2_liveInput.scd");

	"\n\n*** *** *** FOLDER %:\n".postf("2_process");
	// list all candidate files
	if (q.prefs.active.processNames.isNil) {
		(q.dir.userPOOL +/+ "*process/*.scd").pathMatch
		.collect {|pa| pa.basename.splitext[0].asSymbol }.postcs;
	};

	q.process = q.process ? ();
	q.process.allPaths = (q.dir.userPOOL +/+ "*process/*.scd").pathMatch;
	q.process.allNames = q.process.allPaths.collect { |p|
		p.basename.splitext[0].asSymbol
	};

	0.2.wait;
	// load preferred processNames, or all:
	(q.prefs.active.processNames ? q.process.allNames).do { |name|
		q.load(name ++ ".scd", q.dir.userPOOL +/+ "2_process")
	};

	q.load("2a_preset*.scd");

	"\n\n".postln;

	s.waitForBoot {

		"*** server booted, plays 3 pings on left chan.".postln;
		fork { 3.do { Env.perc.test; 0.3.wait } };

		"\n".postln;

		0.2.wait;
		// activate the ndefs given in prefs:
		q.ndefs = q.prefs.active.defaultActives.collect(Ndef(_));
		//
		// and only wake up my selected sounds:
		q.ndefs.do {|ndef|
			ndef.set(\amp, 0).fadeTime_(1).vol_(0.25);
		};

		0.2.wait;

		"\n\n*** *** *** FOLDER % : \n".postf("3_interfaces");
		q.load("3_interfaces/*scd");

		"\n\n*** *** *** FOLDER % : \n".postf("5_postres");
		q.load("5_postres/*scd");

		if (q.hasGui) {
			"\n\n*** *** *** FOLDER % : \n".postf("8_GUIs");
			q.load("8_GUIs/*scd");
			0.2.wait;
			MFdef(\makeGui).(\MakeGui);
			MFdef(\makeGui).(\NTMI_Main);

		};

		///////// SHOWTIME TWEAKS //////////////
		// disable Zoom on xosc only
		MKtl(\xosc).elAt('inA', 7).disable;
		q.setZoom(1);
		// q.setZoom = nil;

		g.main.skipper.dt = 1/10;

		q.inph.modes = [\full, \touch];

		q.setupTime = (Main.elapsedTime - q.time0).round(0.01);
		"\n*** NTMI SETUP finished in % secs! ***\n\n\n".postf(q.setupTime);

	};
}.play(AppClock);
)

