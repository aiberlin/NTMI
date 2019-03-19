///// handle default preferences and user preferences

/*
// write current settings to user prefs:
q.prefs.readUser;
... then use it in setup ...
q.prefs.writeUser;
*/

q.prefs = q.prefs ? ();
////// multiple example prefs with app?
// q.prefs.found = "ntmi_prefs_*".resolveRelative.pathMatch;
q.prefs.default = "ntmi_prefs_default.scd".loadRelative[0];
q.prefs.userPrefPath = (Platform.userAppSupportDir +/+  "ntmi_prefs.scd");

q.prefs.readUser = {
	// try to read user prefs
	if (File.exists(q.prefs.userPrefPath)) {
		var prefdict = q.prefs.userPrefPath.load;
		q.prefs.fromUser = prefdict;
		"*** found user prefs: ".postln;
		prefdict.postcs;
	};
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
// read user prefs on startup
q.prefs.readUser;

q.prefs.active = q.prefs.fromUser ? q.prefs.default;

"";

