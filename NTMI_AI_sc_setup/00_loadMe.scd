(
"*** startup file for NTMI_AI_sc_setup loading...".postln;

q = q ? ();

//// generally usful globals:
q.me = unixCmdGetStdOut("whoami").split(Char.nl).first.asSymbol;
q.myname = Platform.userHomeDir.basename.asSymbol;
q.basedir = thisProcess.nowExecutingPath;
q.hasGui = \View.asClass.notNil;

// function to load code files or folders which can wait and posts loading time info:
q.load = { |q, filename, wait = 0.1, dirsup = 0, preText = "", postText = ""|
	forkIfNeeded ({
		var here = "".resolveRelative;
		var paths;
		var loadDur, t0 = Main.elapsedTime;

		dirsup.do { here = here.dirname };
		paths = (here +/+ filename).postcs.pathMatch;

		if (paths.size == 0) { "*** no files found for % :\n".postf(filename.cs) };

		if (paths.size > 1) { "*** loading matching files for % :\n".postf(filename.cs) };

		paths.do { |path|
			"*** loading file % : %\n".postf(path.basename, preText);
			path.load;
			if (s.serverRunning) { try { s.sync } };
			loadDur = (Main.elapsedTime - t0).round(0.001);
			"--- took % secs. % ---\n".postf(loadDur, postText);
			wait.wait;
		};

		"";
	}, AppClock)
};

// read early prefs if there
(Platform.userAppSupportDir +/+ "preprefs.scd").loadPaths;

// should move to preprefs ?
q.numChans = q.numChans ? 4;


// ~trioPlayers = ["arik", "laVulega", "isakhan"];

// q.soundsPerPlayer = ( // a dict for filename beginnings
// 	\arik: 3,
// 	\laVulega: 2,
// 	\isakhan: 1,
// 	\adc: 1,
// );
//
// q.choiseNdefs_storePath = thisProcess.nowExecutingPath.dirname +/+ "presets/choiceNdefs.scd";

// dont do HID by default, more stable
MKtl.find(\midi);

Task {
	s.quit;
	0.5.wait;

	"*** loading globals: ".postln;
	q.load("0_globals/*.scd");

	// preload all sounds while server is off!
	q.load("2_liveInput.scd");

	"*** loading folder % : \n".postf("2_processes");
	q.allSoundPaths = "2_processes/*.scd".resolveRelative.pathMatch;
	q.allSoundNames = q.allSoundPaths.collect{|p|
		p.basename.split($.)[0].reject{|c| c == $_}.reject(_.isDecDigit)
	}.asSet.asArray.sort.collect(_.asSymbol);

	q.load("2_processes/*scd");

	0.2.wait;

	q.load("2a_preset_func.scd");

	s.waitForBoot {

		"*** server booted, plays 3 pings left.".postln;
		fork{ 3.do { Env.perc.test; 0.3.wait } };

		0.5.wait;

		/// for now, random - later, replace from user prefs
		"\n\n*** choose my 4 random starting Ndefs: \n*** ".post;
		q.ndefs = q.getNdefs.scramble.keep(4).postcs;

		// only wake up my selected sounds:
		q.ndefs.do {|ndef|
			ndef.set(\amp, 0).fadeTime_(1).play(vol: 0.25);
			// 0.2.wait;
			ndef.monitor.fadeTime_(0.3);
		};

		0.2.wait;

		"*** folder % : \n".postf("3_interfaces");

		q.load("3_interfaces/*scd");

		"*** folder % : \n".postf("5_postres");

		q.load("5_postres/*scd");

		if (q.hasGui) {
			"*** folder % : \n".postf("8_GUIs");
			q.load("8_GUIs/*scd");
		};

		"\n*** NTMI SETUP loading finished! ***\n".postln;
	};
}.play(AppClock);
)