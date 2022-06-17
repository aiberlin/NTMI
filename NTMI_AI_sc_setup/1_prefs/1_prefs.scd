///// handle default preferences and user preferences

/*
// read current settings from user prefs:
q.prefs.readUser;

// copy default prefs to user location to customize:
q.prefs.copyDefaultToUser;

// open user prefs to edit:
q.prefs.open;

*/

q.prefs = q.prefs ? ();
q.prefs.defaultPath = "ntmi_prefs_default.scd".resolveRelative;
////// multiple example prefs with app?
// q.prefs.found = "ntmi_prefs_*".resolveRelative.pathMatch;
q.prefs.default = q.prefs.defaultPath.load;

q.prefs.userPrefPath = (Platform.userAppSupportDir +/+  "ntmi_prefs.scd");
q.prefs.open = { q.prefs.userPrefPath.openOS };

q.prefs.deleteUserPrefs = {
	"deleting user prefs: ".postln;
	unixCmd(("rm" + quote(q.prefs.userPrefPath)).postcs);
};

q.prefs.readUser = {
	var prefdict;
	// try to read user prefs
	if (File.exists(q.prefs.userPrefPath)) {
		prefdict = q.prefs.userPrefPath.load;
		q.prefs.fromUser = prefdict;
		"NTMI: user prefs found.".postln;
	} {
		"NTMI: no user prefs found -".postln
	}
};

// only do this by hand
q.prefs.copyDefaultToUser = {
	"NTMI: copying default prefs to user dir: ".postln;
	unixCmd(
		("cp" + quote(q.prefs.defaultPath) + quote(q.prefs.userPrefPath).postcs
		)
	);
};

q.prefs.readUser;

// set
q.prefs.active = q.prefs.fromUser ?? {
	"- using default prefs.".postln;
	q.prefs.default;
};
"";

