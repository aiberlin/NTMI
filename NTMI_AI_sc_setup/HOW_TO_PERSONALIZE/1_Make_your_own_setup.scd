///// Make_your_own_setup files

//// 1. The NTMI prefs file
// NTMI loads default preferences and user preferences here:
q.prefs;

// the user prefs file is here:
q.prefs.userPrefPath
// and can be opened like this:
q.prefs.open;

// this is a copy of the default prefs file in the quark,
// which is here:
q.prefs.defaultPath
// and has these settings:
q.prefs.default

q.keys(Array).sort;
q.prefs.userPrefPath.openOS;