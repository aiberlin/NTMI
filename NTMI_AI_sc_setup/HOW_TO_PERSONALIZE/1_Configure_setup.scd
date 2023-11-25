/***** Make_your_own_setup - OVERVIEW ******/

// There are several ways to customize the NTMI setup
// to your preferences.

// 1.  configure which elements NTMI setup loads
// 1a. add additional code at different stages in the load process
// --- explained in this file!

// 2. add, rename, and edit presets for all sound processes - see:
"2_adding_presets.scd".resolveRelative.openOS;

// 3. choose which sound processes to use,
// and add your own sound processes - see:

// 4. choose which supported physical interfaces to connect
// and add your own interfaces e.g. with Modality-toolkit - see:

////

//// 1. The NTMI user dir, POOL and prefs files
//// NTMI creates a user directory, usually at "~/NTMI",
// which contains configurable files and directories:
// an ntmi_prefs file,
// a POOL directory which contains the soundprocesses to load,
// and other general loadable resources,
// and files for additional code to run at different boot stages.
NTMI.dir.user;
NTMI.dir.user.openOS;


// NTMI keeps it preferences information in this dictionary:
NTMI.prefs;

// where the user preferences file is stored under this path:
NTMI.prefs.userPrefPath;
// and which can be opened for detailed reading and editing:
NTMI.prefs.open;

// *** Read this file carefully, and try changing things there,
// to find out how tweaking these settings works best for you! ***


// A copy of the default prefs file lives in the NTMI quark,
// at the path here - may be useful for comparisons/repairs
NTMI.prefs.defaultPath;
// And these are its settings:
NTMI.prefs.default;



// 1a. adding additional code at different stages in the load process

// to be continued ...
