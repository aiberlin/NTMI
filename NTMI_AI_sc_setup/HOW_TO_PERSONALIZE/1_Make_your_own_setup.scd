///// Make_your_own_setup files

//// 1. The NTMI prefs file
// NTMI loads default preferences and user preferences here:
q.prefs;

// the user prefs file is here:
q.prefs.userPrefPath
// and can be opened like this for
// detailed reading and editing!
q.prefs.open;

// There is a copy of the default prefs file in the quark,
// which is here - may be useful for comparisons/repairs
q.prefs.defaultPath
// It has these settings:
q.prefs.default

q.keys(Array).sort;
q.prefs.userPrefPath.openOS;

