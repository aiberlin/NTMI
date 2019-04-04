///// handle default preferences and user preferences

/*
// write current settings to user prefs:
q.prefs.readUser;
... then use it in setup ...
q.prefs.writeUser;

q.prefs.userPrefPath.openOS;
*/

q.prefs = q.prefs ? ();
q.prefs.defaultPath = "ntmi_prefs_default.scd".resolveRelative;
////// multiple example prefs with app?
// q.prefs.found = "ntmi_prefs_*".resolveRelative.pathMatch;
q.prefs.default = q.prefs.defaultPath.load;
q.prefs.userPrefPath = (Platform.userAppSupportDir +/+  "ntmi_prefs.scd");

q.prefs.readUser = {
	var prefdict;
	// try to read user prefs
	if (File.exists(q.prefs.userPrefPath)) {
		prefdict = q.prefs.userPrefPath.load;
		q.prefs.fromUser = prefdict;
		"*** found user prefs: ".postln;
		prefdict.postcs;
	} {
		"copying default prefs to user dir: ".postln;
		unixCmd(
			("cp" + quote(q.prefs.defaultPath) + quote(q.prefs.userPrefPath).postcs
			)
		);
	}
};

q.prefs.writeUser = {
	var dict = (
		name: q.myname,
		numChans: q.numChans,
		defaultActives: q.slots.actives.collect(_.key)
	);
	File.use(q.prefs.userPrefPath, "w", { |f| f.write(dict.cs) });
	"*** stored user prefs: ".postln;
	dict.postcs
};

q.prefs.readUser;


q.prefs.active = q.prefs.fromUser ? q.prefs.default;

"";

