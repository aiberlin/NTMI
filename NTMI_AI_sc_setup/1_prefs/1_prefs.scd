///// handle default preferences and user preferences

/*
// read current settings from user prefs:
// this copies the default prefs to user home dir if not there
NTMI.prefs.readUser;

// open user prefs:
NTMI.prefs.open;

*/

NTMI.prefs = NTMI.prefs ? ();
NTMI.prefs.defaultPath = "ntmi_prefs_default.scd".resolveRelative;
////// multiple example prefs with app?
// NTMI.prefs.found = "ntmi_prefs_*".resolveRelative.pathMatch;
NTMI.prefs.default = NTMI.prefs.defaultPath.load;
NTMI.prefs.userPrefPath = (NTMI.dir.user +/+  "ntmi_prefs.scd");

NTMI.prefs.open = { NTMI.prefs.userPrefPath.openOS };

[ "finalSetup.scd", "postBootSetup.scd", "preBootSetup.scd" ].do { |file|
	var pathInQuarkDir = NTMI.dir.setup +/+ "1_prefs" +/+ file;
	var pathInUserDir = NTMI.dir.user +/+ file;
	if (File.exists(pathInUserDir).not) {
		unixCmd(
			("cp" + quote(pathInQuarkDir) + quote(pathInUserDir)
			)
		)
	}
};

NTMI.prefs.readUser = {
	var prefdict;
	// try to read user prefs
	if (File.exists(NTMI.prefs.userPrefPath)) {
		prefdict = NTMI.prefs.userPrefPath.load;
		NTMI.prefs.fromUser = prefdict;
		"... found user prefs ...  ".postln;
		// prefdict.postcs;
	} {
		"copying default prefs to user dir: ".postln;
		unixCmd(
			("cp" + quote(NTMI.prefs.defaultPath) + quote(NTMI.prefs.userPrefPath).postcs
			)
		);
	}
};

NTMI.prefs.readUser;

// set
NTMI.prefs.active = NTMI.prefs.fromUser ? NTMI.prefs.default;

"";

