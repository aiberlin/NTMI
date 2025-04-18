/**** todo:
on Windows currently,
making "~/NTMI" creates a folder without editing permission.
therefore, copying soundfiles/ and POOL/ fails.
this requires copying them over by hand.
how to make the folder with direct permission?
****/

//////// determine DIRECTORIES: ///////////////
NTMI.dir = NTMI.dir ? ();
NTMI.dir.setup = thisProcess.nowExecutingPath.dirname ?? {
	// just in case
	NTMI.filenameSymbol.asString.dirname.dirname +/+ "NTMI_AI_sc_setup";
};
NTMI.dir.fullNames = (NTMI.dir.setup +/+ "*/").pathMatch;
NTMI.dir.names = NTMI.dir.fullNames.collect { |path| path.basename };

// NTMI.dev true is a mode which uses quark resources for development,
// NTMI.dev false means normal user mode,
NTMI.dev = NTMI.dev ? false;

"\n\n*** NTMI: NTMI.dir.setup is at \n%\n".postf(NTMI.dir.setup.cs);

if(NTMI.dev) {
	// ONLY WHILE DEVELOPING, direct back to dev/project dir!
	NTMI.dir.user = NTMI.dir.setup;
	NTMI.dir.userPOOL = NTMI.dir.setup +/+ "POOL";
	NTMI.dir.userSoundfiles = NTMI.dir.user +/+ "soundfiles";
	// done here.
} {
	var numAttempts = 10;
	// normal use - if not there, make them in userHomeDir/NTMI
	// later, provide update/sync functionality
	NTMI.dir.user = Platform.userHomeDir +/+ "NTMI";
	NTMI.dir.userPOOL = NTMI.dir.user +/+ "POOL";
	NTMI.dir.userSoundfiles = NTMI.dir.user +/+ "soundfiles";
	NTMI.dir.userSFExamples = NTMI.dir.user +/+ "soundfiles/examples";

	// check for user dir and make it if needed
	if (File.exists(NTMI.dir.user).not) {
		while { File.exists(NTMI.dir.user).not and: (numAttempts > 0) } {
			"NTMI: making NTMI.dir.user".postln;
			unixCmd("mkdir" + quote(NTMI.dir.user));
			0.5.wait;
			numAttempts = (numAttempts - 1).postln;
		};
		if (File.exists(NTMI.dir.user)) {
			NTMI.dir.user.openOS;
		} {
			"*** NTMI: making NTMI.dir.user FAILED. \n"
			"Please make a folder called NTMI in your home dir, \n"
			"and repeat NTMI.run. STOPPING HERE.\n"
			"%\n".postf(Platform.userHomeDir);
			Platform.userHomeDir.openOS;
			thisThread.stop;
		};
	};
};

//// check if folders soundfiles and POOL are already in user home dir,
//// and if not, copy them there
["soundfiles", "POOL"].do { |name|
	var numAttempts = 10;
	var targetDir = NTMI.dir.user +/+ name;
	"making %\n".postf(targetDir);
	while { File.exists(targetDir).not and: (numAttempts > 0) } {
		unixCmd("cp -nR"
			+ quote(NTMI.dir.setup +/+ name)
			+ quote(targetDir)
		);
		numAttempts = (numAttempts - 1).postln;
		0.5.wait;
	};
	if (File.exists(targetDir).not) {
		"*** NTMI: making % FAILED. \n".postf(targetDir);
		"Please copy folder '%' \n"
		"from NTMI.dir.setup to homedir/NTMI by hand! \n"
		"then do NTMI.run again.".postf(name);
		2.wait;
		NTMI.dir.setup.openOS;
		thisThread.stop;
	};
};

"\n*** NTMI: NTMI.dir.user is %\n".postf(NTMI.dir.user.cs);
"*** NTMI: NTMI.dir.userPOOL is %\n".postf(NTMI.dir.userPOOL.cs);
"*** NTMI: NTMI.dir.userSoundfiles is %\n".postf(NTMI.dir.userSoundfiles.cs);

"\n".post;

