/*

"--- contents of q: ---".postln;
q.size.postln;
q.keys(SortedList).do("q.% : %\n".postf(_, _, _));
"--- contents of q: ---".postln;
"";

*/

(
/// wait for SC Welcome post ...

Task {
	0.1.wait;

	"\n\n*** startup file for NTMI_AI_sc_setup loading...\n\n".postln;

	q = q ? ();  // <- dict for most everything
	g = g ? ();  // <- gui stuff goes here!


	//// Generally useful globals:
	q.time0 = Main.elapsedTime;
	q.myname = Platform.userHomeDir.basename.asSymbol;
	q.hasGui = \View.asClass.notNil;
	if (q.hasGui) { "9_optionals/warnWin.scd".loadRelative };

	q.dir = q.dir ? ();
	q.dir.base = thisProcess.nowExecutingPath.dirname;

	// function to load code files or folders which can wait and posts loading time info:
	q.load = { |q, filename, wait = 0.05, dirsup = 0, preText = "", postText = ""|
		forkIfNeeded ({
			var here = "".resolveRelative;
			var paths;
			var loadDur, t0 = Main.elapsedTime;

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
	"*** q.numChans is: %\n".postf(q.numChans);

	// dont find HIDs by default, for more stability
	MKtl.find(\midi);

	s.quit; "".postln;

	0.2.wait;

	"\n\n*** *** *** FOLDER globals: ".postln;
	q.load("0_globals/*.scd");

	// preload all sounds while server is off!
	q.load("2_liveInput.scd");

	"\n\n*** *** *** FOLDER % : \n".postf("2_processes");
	q.process = q.process ? ();
	q.process.allPaths = "2_processes/*_*.scd".resolveRelative.pathMatch;
	q.process.allNames = q.process.allPaths.collect { |p|
		p.basename.split($.)[0].reject {|c| (c == $_) }.reject(_.isDecDigit)
	}.collectInPlace(_.asSymbol).asSet.asArray.sort;

	q.load("2_processes/*scd");

	0.2.wait;

	q.load("2_processes/presets/2a_preset_func.scd");

	s.waitForBoot {

		"*** server booted, plays 3 pings left.".postln;
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
			g.makeGui.main_adc;
		};

		q.setupTime = (Main.elapsedTime - q.time0).round(0.01);
		"\n*** NTMI SETUP finished in % secs! ***\n\n\n".postf(q.setupTime);

	};
}.play(AppClock);
)

