"*** startup file for NTMI_AI_sc_setup loading...".postln;

q = q ? ();

// ~trioPlayers = ["arik", "laVulega", "isakhan"];
q.me = unixCmdGetStdOut("whoami").split(Char.nl).first.asSymbol;
q.myname = Platform.userHomeDir.basename.asSymbol;
q.hasGui = \View.asClass.notNil;

// read early prefs if there
(Platform.userAppSupportDir +/+ "preprefs.scd").loadPaths;

// should move to preprefs ?
q.numChans = q.numChans ? 4;

q.soundsPerPlayer = ( // a dict for filename beginnings
	\arik: 3,
	\laVulega: 2,
	\isakhan: 1,
	\adc: 1,
);

q.choiseNdefs_storePath = thisProcess.nowExecutingPath.dirname +/+ "presets/choiceNdefs.scd";

"*** loading globals: ".postln;
"0_globals/*.scd".resolveRelative.pathMatch.do { |path|
	path.basename.postln;
	path.loadPaths;
};

q[\load];

p = Ndef.dictFor(s); // p.push;

MKtl.find;

Task {
	s.quit;
	1.wait;

	s.waitForBoot {
		"*** server booted, plays 3 pings.".postln;
		fork{ 3.do { Env.perc.test; 0.3.wait } };

		"*** folder % : \n".postf("2_processes");

		q.load("2_liveInput.scd");

		0.2.wait;

		///////// adc: dont understand all of this,
		///////// looks like it could be simpler
		q.mySoundsIndex = q.soundsPerPlayer[q.me]  ? 1; // attribute a group of sounds to each player, else just 1
		q.allSoundPaths = "2_processes/*.scd".resolveRelative.pathMatch;

		q.allSoundNames = q.allSoundPaths.collect{|p| p.basename.split($.)[0].reject{|c| c == $_}.reject(_.isDecDigit) }.asSet.asArray.sort;


		q.mySoundPaths =
		q.allSoundPaths//.select{ |path| path.basename.first == ( q.mySoundsIndex.asDigit) }
		.sort.reverse
		.wrapExtend(4);  // we ALWAYS want 4

		// assume file existing !!!
		/*betteR:
		- if File.exists
		{
		load it. if all 4 keys are found,
		{load em all}{load existing, replace others}
		}{ replace with SOME 4}
		*/

		if( File.exists(q.choiseNdefs_storePath) ){
			q.choice = q.choiseNdefs_storePath.load.postcln;
			q.mySoundPaths = q.choice.collect{|key| q.allSoundPaths.detect{|path| path.contains(key.asString) } };
		}{"no preset file".error};
		q.mySoundPaths.do { |path|
			"***      loading file %\n".postf(path.basename);
			path.load;
			0.2.wait;
		};

		q.ndefs = q.getNdefs;
		q.ndefs.do {|ndef|
			ndef.set(\amp, 0).fadeTime_(1).play;
			ndef.vol_(0.25).monitor.fadeTime_(0.3);
		};
		0.2.wait;



		"*** folder % : \n".postf("3_interfaces");
		"3_interfaces/*.scd".resolveRelative.pathMatch.do { |path|
			"***      loading file %\n".postf(path.basename);
			path.load;
			0.2.wait;
		};

		"*** folder % : \n".postf("5_postres");
		"5_postres/*.scd".resolveRelative.pathMatch.do { |path|
			"***      loading file %\n".postf(path.basename);
			path.load;
			0.2.wait;
		};

		if (q.hasGui) {
			"*** folder % : \n".postf("5_postres");
			"8_GUIs/*.scd".resolveRelative.pathMatch.do { |path|
				"***      loading file %\n".postf(path.basename);
				path.load;
				0.2.wait;
			};
		};


	};
}.play(AppClock);