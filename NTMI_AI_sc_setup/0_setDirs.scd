//////// determine DIRECTORIES: ///////////////
NTMI.dir = NTMI.dir ? ();
NTMI.dir.setup = thisProcess.nowExecutingPath.dirname;
NTMI.dir.fullNames = (NTMI.dir.setup +/+ "*/").pathMatch;
NTMI.dir.names = NTMI.dir.fullNames.collect { |path| path.basename };
NTMI.dir.scSoundfiles = Platform.resourceDir +/+ "sounds";

// NTMI.dev true is a mode which uses quark resources for development,
// NTMI.dev false means normal user mode
NTMI.dev = NTMI.dev ? false;

"*** NTMI: NTMI.dir.setup is at %\n".postf(NTMI.dir.setup.cs);

if(NTMI.dev) {
	// ONLY WHILE DEVELOPING, direct back to dev/project dir!
	NTMI.dir.user = NTMI.dir.setup;
	NTMI.dir.userPOOL = NTMI.dir.setup +/+ "POOL";
} {
	///////////// normal use:
	NTMI.dir.user = Platform.userHomeDir +/+ "NTMI";
	NTMI.dir.userPOOL = NTMI.dir.user +/+ "POOL";
	NTMI.dir.userSoundfiles = NTMI.dir.user +/+ "soundfiles";
	NTMI.dir.userSFExamples = NTMI.dir.user +/+ "soundfiles/examples";

	// check for user dir and make it if needed
	if (File.exists(NTMI.dir.user).not) {
		"NTMI: making NTMI.dir.user".postln;
		unixCmd("mkdir" + quote(NTMI.dir.user));
	};

	// check for soundfiles dir and make it if needed
	if (File.exists(NTMI.dir.userSoundfiles).not) {
		"NTMI: making NTMI.dir.userSoundfiles".postln;
		unixCmd("mkdir" + quote(NTMI.dir.userSoundfiles));
	};
	//// check if soundfiles/examples is already in user NTMI dir,
	//// and if not, copy it there
	if (File.exists(NTMI.dir.userSFExamples).not) {
		"*** NTMI: copying NTMI.dir.userSFExamples folder to NTMI.dir.user".postln;
		unixCmd("cp -nR"
			+ quote(NTMI.dir.setup +/+ "soundfiles/examples")
			+ quote(NTMI.dir.userSFExamples)
		);
		(NTMI.dir.userSFExamples).openOS;
	};

	//// check if POOL is already in user home dir,
	//// and if not, copy it there
	if (File.exists(NTMI.dir.userPOOL).not) {
		"*** NTMI: copying POOL folder to NTMI.dir.user".postln;
		unixCmd("cp -nR"
			+ quote(NTMI.dir.setup +/+ "POOL")
			+ quote(NTMI.dir.user +/+ "POOL")
		);
		NTMI.dir.userPOOL.openOS;
	};
	"*** NTMI: NTMI.dir.user is %\n".postf(NTMI.dir.user.cs);
	"*** NTMI: NTMI.dir.userPOOL is %\n".postf(NTMI.dir.userPOOL.cs);
	"*** NTMI: NTMI.dir.userSoundfiles is %\n".postf(NTMI.dir.userSoundfiles.cs);
};

"\n\n".post;