/*
* this loadme file resides in the project folder,
* and is not intended for user-introduced changes.

It is configurable with variables and flags within NTMI.q.

NTMI.hasGui = false; // headless
NTMI.usesMIDI = false; // will not use MIDI interfaces
NTMI.usesHID = false; // will not use MIDI interfaces

NTMI.reboot = false; // keep server running, dont set its options
NTMI.usesMainFX = false; // dont load MainFX
NTMI.usesHID = false; // will not use MIDI interfaces



*/

(

Task {

	0.1.wait; /// wait for SC Welcome post ...

	"\n\n*** loadMe file for NTMI_AI_sc_setup loading...\n\n".postln;
	LoadMe.start;


	// q = q ? ();  // <- dict for most everything
	// g = g ? ();  // <- gui stuff goes here!

	//// Set generally useful globals:

	// internally useful:
	NTMI.myname = Platform.userHomeDir.basename.asSymbol;
	NTMI.isPi     = NTMI.isPi ?? { NTMI.myname == 'pi' };
	NTMI.isPatch     = NTMI.isPatch ?? { NTMI.myname == 'patch' };

	LoadMe("0_setDirs.scd");

	0.1.wait;

	//******* PREFERENCES
	///// read user prefs (if there) or copy default prefs there:
	LoadMe("1_prefs/1_prefs.scd");

	// Set flags for which parts to load:
	// on headless systems, dont use guis
	NTMI.hasGui = NTMI.prefs.active.hasGui ? NTMI.hasGui ?? { \View.asClass.notNil };
	NTMI.hasSmallScreen = NTMI.prefs.active.hasSmallScreen ? NTMI.hasSmallScreen ?? false;

	// which types of controllers will be used?
	// these may have been set in startup file already:
	NTMI.usesMidi = NTMI.prefs.active.usesMidi ? NTMI.usesMidi ? true;
	NTMI.usesHid  = NTMI.prefs.active.usesHid  ? NTMI.usesHid ? true;
	// which of the supported interfaces should be loaded?
	// can include custom ones in userPOOL
	NTMI.interfacesToLoad  = NTMI.prefs.active.interfacesToLoad ? [ "uc4" ];
	// reboot server when starting NTMI?
	NTMI.reboot = NTMI.prefs.active.reboot ? NTMI.reboot ? false;

	// turn off MainFX if desired (loses mainVol control)
	NTMI.usesMainFX = NTMI.prefs.active.usesMainFX ? NTMI.usesMainFX ? true;

	if (NTMI.hasGui) {
		"8_GUIs/warnWin.scd".loadRelative;
	} {
		NTMI.warnWin = { |q, string="?!?", title="?!?"| warn(title + string) }
	};

	"*** Modality: find MIDI and HID devices if enabled ***".postln;
	if (NTMI.usesMidi) {
		MKtl.find(\midi); 0.1.wait;
	};

	if (NTMI.usesHid) {
		Platform.case(\windows) {
			"HID on windows is not working in SC3.13.0.".warn
		} {
			MKtl.find(\hid); 0.1.wait;
		};
	};


	if (NTMI.reboot) {
		// Server.killAll; // ?
		"*** NTMI kills server to reboot.".postln;
		s.quit; "".postln;
		0.2.wait;
	};

	"\n\n*** *** *** FOLDER %:\n".postf("0_globals");
	LoadMe("0_globals/*.scd");

	// set NTMI.numChans from prefs
	NTMI.numChans = NTMI.prefs.active.numChans ? 2;
	NTMI.numIns = NTMI.prefs.active.numIns ? NTMI.numChans;

	if (s.serverRunning) {
		"*** server running already, cannot adjust settings!".postln;
		"may not be able to do everything in preBootSetup ...".postln;
		NTMI.numChans = min(NTMI.numChans, s.options.numOutputBusChannels);
		NTMI.numIns =   min(NTMI.numIns,   s.options.numInputBusChannels);

	} {
		"setting up server ... ".postln;
		LoadMe(NTMI.prefs.active.serverSetup, NTMI.dir.user +/+ "POOL/1_*");

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

		NTMI.helloSound ?? { LoadMe("0_helloSound.scd") };

		"*** NTMI.postBoot runs.".postln;
		NTMI.postBoot;

		LoadMe("2_process_presets/2a_bufferLoader.scd");
		LoadMe("2_process_presets/2b_liveInput.scd");
		LoadMe("2_process_presets/2c_loadProcesses.scd");
		LoadMe("2_process_presets/2d_preset*.scd");

		"*** NTMI.postPresets runs.".postln;
		NTMI.postPresets;

		/********** INTERFACES *********/

		"\n\n*** *** *** FOLDER % : \n".postf("3_interfaces");
		LoadMe("3_interfaces/*scd");

		NTMI.interfacesToLoad.do { |name|
			LoadMe("3_interfaces/*/*%*scd".format(name));
		};

		"*** NTMI.preMainFX runs.".postln;
		NTMI.preMainFX;

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
		};

		"*** NTMI.finalSetup runs.".postln;
		NTMI.finalSetup;

		// reinstate prev. latency
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

