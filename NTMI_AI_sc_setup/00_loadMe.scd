/*
* this loadme file resides in the project folder,
* and is not intended for user-introduced changes.

It is configurable with variables and flags within NTMI.q,
which you can set before running this file with NTMI.run.

// these can be useful for testing that code works
// on various conditions, e.g. specific platforms:

NTMI.hasGui   = false; // headless mode, e.g. for raspi or bela
NTMI.isPi     = true // simulate default raspi OS account
NTMI.isPatch  = false; // detect raspi patchbox OS
NTMI.myname = \KoolKat; // use as flag to make adjustments based on user name

// speedup booting
NTMI.usesMidi = false; // will not look for MIDI interfaces
NTMI.usesHID = false; // will not look for HID interfaces

NTMI.reboot = false; // keep server running, dont set its options
NTMI.usesMainFX = false; // dont load MainFX

*/

(

Task {

	0.1.wait; /// wait for SC Welcome post ...

	"\n\n*** loadMe file for NTMI_AI_sc_setup loading...\n\n".postln;
	LoadMe.start;

	//// Set generally useful global  defaults, if not set in startup file:

	// internally useful:
	NTMI.myname = NTMI.myname ?? { Platform.userHomeDir.basename.asSymbol };
	NTMI.isPi     = NTMI.isPi ?? { NTMI.myname == 'pi' };
	NTMI.isPatch     = NTMI.isPatch ?? { NTMI.myname == 'patch' };

	LoadMe("0_setDirs.scd");

	0.1.wait;

	//******* PREFERENCES
	// ///// read user prefs (if there) or copy default prefs there:
	// LoadMe("1_prefs/1_prefs.scd");

	// Set flags for which parts to load:
	// on headless systems, dont use guis
	NTMI.hasGui = NTMI.hasGui ?? { \View.asClass.notNil };
	NTMI.hasSmallScreen = NTMI.hasSmallScreen ?? false;
	NTMI.usesRandomInit = NTMI.usesRandomInit ? true;

	// which types of controllers will be used?
	// these may have been set in startup file already:
	NTMI.usesMidi = NTMI.usesMidi ? true;
	NTMI.usesHid  = NTMI.usesHid ? true;
	// which of the supported interfaces should be loaded?
	// can include custom ones in userPOOL
	NTMI.interfacesToLoad  = NTMI.interfacesToLoad ? [ "nanoKtl", "xtm" ];

	// reboot server when starting NTMI?
	NTMI.reboot = NTMI.reboot ? false;

	// turn off MainFX if desired (if off, mainVol will use s.volume)
	NTMI.usesMainFX = NTMI.usesMainFX ? true;

	// replace warning window with post if no GUI
	if (NTMI.hasGui) {
		"8_GUIs/warnWin.scd".loadRelative;
	} {
		NTMI.warnWin = { |q, string="?!?", title="?!?"| warn(title + string) }
	};

	if (NTMI.reboot) {
		// Server.killAll; // ?
		"*** NTMI kills server to reboot.".postln;
		s.quit; "".postln;
		0.2.wait;
	};

	"\n\n*** *** *** FOLDER %:\n".postf("0_globals");
	LoadMe("0_globals/*.scd");

	// set NTMI.numChans if not present
	NTMI.numChans = NTMI.numChans ? NTMI.defaults.numChans ? 2;
	NTMI.numIns = NTMI.numIns ?  NTMI.defaults.numIns ? 2;

	if (s.serverRunning) {
		var serverNumOuts = s.options.numOutputBusChannels;
		var serverNumIns = s.options.numOutputBusChannels;
		"*** server running already, cannot adjust settings!".postln;
		"may not be possible to do everything in preBootSetup ...".postln;
		if (NTMI.numChans > serverNumOuts) {
			"reducing NTMI.numChans to %\n".postf(serverNumOuts);
			NTMI.numChans = serverNumOuts;
		};
		if (NTMI.numIns > serverNumIns) {
			"reducing NTMI.numIns to %\n".postf();
			NTMI.numIns = serverNumIns;
		};

	} {
		// set default samplerate to ensure boot with different input/output devices
		s.options.sampleRate = s.options.sampleRate ? 44100;

		"NTMI setting up server ... ".postln;
		NTMI.serverSetupFile = NTMI.serverSetupFile ? NTMI.defaults.serverSetupFile;
		// load a setup file with memory etc settings
		if (NTMI.serverSetupFile.isNil) {
			"no NTMI.serverSetupFile".postln;
		} {
			LoadMe(NTMI.serverSetupFile, NTMI.dir.user +/+ "POOL/1_*")
		};

		s.options.numInputBusChannels = NTMI.numIns;
		s.options.numOutputBusChannels = NTMI.numChans;
	};

	"*** NTMI.numChans is: %\n".postf(NTMI.numChans);
	"*** NTMI.numIns is: %\n".postf(NTMI.numIns);

	"*** NTMI.preBoot runs.".postln;
	NTMI.preBoot;

	"\n\n".postln;


	s.waitForBoot {
		var prevLatency = s.latency;

		// avoid late messages while loading
		s.latency = nil;

		"\n".postln;

		NTMI.helloSound ?? { NTMI.defaults.helloSound };
		"NTMI.helloSound plays".postln;

		"*** NTMI.postBoot runs.".postln;
		NTMI.postBoot;

		LoadMe("2_process_presets/*.scd");

		"*** NTMI.postPresets runs.".postln;
		NTMI.postPresets;

		/********** INTERFACES *********/

		"\n\n*** *** *** FOLDER % : \n".postf("3_interfaces");
		LoadMe("3_interfaces/*scd");

		"NTMI.interfacesToLoad: %\n\n".postf(NTMI.interfacesToLoad);
		NTMI.interfacesToLoad.do { |name|
			LoadMe("3_interfaces/*/*%*scd".format(name));
		};

		"*** NTMI.postInterfaces runs.".postln;
		NTMI.postInterfaces;

		if (NTMI.usesMainFX) {
			LoadMe("6_MainFX.scd");
		} {
			// fallback mainVol - use server volume
			MFdef(\mainVol).add(\main, { |univol = 0.5|
				var model = s.volume;
				var spec = [model.min, model.max, \db].asSpec;
				model.volume = spec.map(univol);
			});
			MFdef(\mainVolGet).add(\get, {
				var model = s.volume;
				var spec = [model.min, model.max, \db].asSpec;
				spec.unmap(model.volume);
			});
		};

		if (NTMI.hasGui) {
			"*** NTMI.preGui runs.".postln;
			NTMI.preGui;

			"\n\n*** *** *** FOLDER % : \n".postf("8_GUIs");
			LoadMe("8_GUIs/*scd");
			// 0.1.wait;
			if (NTMI.hasSmallScreen != true) {
				WinBounds.showOrMake(\Main_NTMI);
			} {
				WinBounds.showOrMake(\miniNTMI);
			};

			if (NTMI.loadDemos ? NTMI.defaults.loadDemos) {
				LoadMe("9_demos/*scd")
			};
		};

		"*** NTMI.finalSetup runs.".postln;
		NTMI.finalSetup;

		// reinstate orig. latency
		if (s.latency.isNil) {
			s.latency = prevLatency;
			"// server latency back to % after loading.\n\n".postf(s.latency);
		} {
			"*** server prevLatency was %\n;"
			"*** server latency now  is % - leaving it as is.\n".postf(prevLatency, s.latency);
		};

		LoadMe.end("\n\n*** NTMI SETUP finished ***\n\n");

	};
}.play(AppClock);
)

