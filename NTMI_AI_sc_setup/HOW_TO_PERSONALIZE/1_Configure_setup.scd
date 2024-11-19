/***** Make_your_own_setup - OVERVIEW ******/

// OVERVIEW of ways to customize NTMI to your preferences:

// 1.  configuring which elements of NTMI setup will load
// 1a. how to add additional code within the load process
// ---> both explained in this file.

// 2. add, rename, and edit presets for sound processes - see here:
Document.open("2_adding_presets.scd".resolveRelative);

// 3. choose which sound processes to use,
// and add your own sound processes - to be written...

// 4. choose which supported physical interfaces to connect
// and add your own interfaces e.g. with Modality-toolkit - see:

// usesMidi, usesHID, connect found or not ...

Document.open("4a_Connecting_new_interfaces.scd".resolveRelative);

Butz(\Personalize).run(\Interface_doc);

// 1.  configure which elements NTMI setup loads

//// 1. The NTMI user dir, POOL and prefs files
//// NTMI creates a user directory in the user home folder:
"~/NTMI".standardizePath.postcs;

// which contains configurable files and directories:
// a POOL directory which contains:
// the soundprocesses to load,
// a directory for soundfiles,
// a directory with examples startup files,
// and optionally other general loadable resources, such as
// files for additional code to run within startup,
// for example code for attaching preferred interfaces.

NTMI.dir.user;
NTMI.dir.user.openOS;




/**** SETTINGS and DEFAULTS ****/

// NTMI has many settings which users can define before running NTMI;
// if these are not given, NTMI will use sensible default values.
// these default values are stored here:
NTMI.defaults.sortedKeysValuesDo { |key, val|
	"\nNTMI.% = %;\n".postf(key, val.cs);
}; "";

// 1a. adding additional code at different stages in the loading process

// - check and set the directories NTMI uses - this is required.
// - check early which MIDI or HID interfaces are present -
// ... this can be configured to skip MIDI and HID to speed up booting.

// - load various global functions ...

// Now, the question arises how to handle the sound server:
// is is booted already?
// if yes, should we leave it as is, or reboot? can be set in prefs:
// if boot or reboot, we can configure the server by a script file:

// and just before booting, NTMI runs an optional preBoot function:
NTMI.preBoot;
// and then (if off or to be rebooted), the server boots ...

// ... and when booted, NTMI first runs this:
NTMI.postBoot;

// - load some soundfile buffers,
// - load all synthesis processes, and make NdefPresets for them
// ... when presets are done, this runs:
NTMI.postPresets;

// - load all built-in interfaces, slots, randomOrbits etc
// - Then, try to load all present MIDI or HID interfaces,
// as well as the ones set in the prefs at:
NTMI.interfacesToLoad.postcs;

// - before loading the mainFX, this runs:
NTMI.preMainFX;

// - then load mainFX, unless flag says to skip:
NTMI.usesMainFX;

// - before loading all GUIs, run this:
NTMI.preGui;

// - then load all guis, unless flag says to skip:
NTMI.hasGui;

// after the GUIs are loaded, NTMI is ready, and runs this:
NTMI.finalSetup;


///// example for adding code at various setup stages:
(
NTMI.reboot = false;

NTMI.preBoot = { "my preboot thingies".postln };
NTMI.postBoot = { "booted, now e.g. load my soundfiles?".postln };

NTMI.postPresets = {
	"tweak my presets somehow".postln;
	"read a codefile at given location:".postln;
	LoadMe("~/NTMI/myPostPresetsCodeFile.scd");
	"or prepare for my interfaces?".postln;
};

NTMI.preMainFX = { "my interfaces are in - anything to do about them?".postln };

NTMI.preGui = { "after mainFX, before GUIs run ...".postln };

NTMI.finalSetup = { "setup done - run my autoplay mode now?".postln };

NTMI.run;
);
