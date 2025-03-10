/*** Personalizing Presets to NTMI Sound Processes ***

There are several ways to change the available presets
of the sound processes used in the NTMI setup.

- Presets can be added by code, from a Preset GUI,
and (while playing) by using the NTMI snapshot function.
- Preset lists are stored as text files, which can be edited
as text, or by GUI.
- For NTMI, they are stored in the userPOOL folder,
which is in the current user's home directory:

"~/NTMI/POOL/2_process/presets/".openOS;

This way, they are independent of the NTMI quark folder,
which should not be changed, since that makes updating difficult.
*/

//// add presets by code:
// 1. tune an ndef, e.g. Ndef(\allArm) to a setting you like
// then add this setting as a named preset for testing
NdefPreset(\allArm).addSet(\test123, toDisk: true);

NdefPreset(\allArm).addSet();

// print them all: \test123 shows up after \curr..
NdefPreset(\allArm).settings.printcsAll; "";

//// add presets from GUI
/// open the presets window
Butz(\NTMI).run(\presets);
// 1. tune an ndef, e.g. Ndef(\allArm) to a setting you like
// 2. click on the sto button:
// -> a little dialog opens for naming the new preset
// enter a name and hit enter -> preset is saved.

//// add snapshot presets while playing
// 1. play at least one sound with NTMI setup, e.g. on main GUI
// 2. when you like the sound settings, click on SNAP! button,
// or on the snapshot button on the connected physical interface.
// -> presets with date stamp as name are added to the running ndef.
// to check, look on the presets window.

// if you want to snap-store by dialog,
// e.g. to prepare for a show, set this flag:
NTMI.snapDialog = true;

//// renaming presets is easiest in the settings text file.
//// open the text file with code,
//// or by clicking the edit button on the Preset GUI:
NdefPreset(\allArm).storePath.openOS;

//// the file looks something like this:

// --- start of file allArm.pxpreset.scd --- //
/*
///// These are the settings for NdefPreset('allArm'):
///// you can edit the textfile, e.g. choosing better preset names,
///// tuning parameter values, or deleting unwanted presets.
///// When done, save the textfile where it is, and
///// then load the edited settings again with:
NdefPreset('allArm').loadSettings(clear: true);
*/

List[
	('curr' -> [ [ 'divefreq', 1.01 ], [ 'topfreq', 37.0 ], [ 'filtfreq', 910.0 ] ]),
	('test123' -> [ [ 'divefreq', 0.2 ], [ 'topfreq', 10000 ], [ 'filtfreq', 20 ] ]),
	('231125_131608' -> [ [ 'divefreq', 0.2 ], [ 'topfreq', 10000 ], [ 'filtfreq', 20 ] ]),
	('mildew' -> [ [ 'divefreq', 1.01 ], [ 'topfreq', 37.0 ], [ 'filtfreq', 910.0 ] ]),
	('krakl' -> [ [ 'divefreq', 18.72 ], [ 'topfreq', 57135.0 ], [ 'filtfreq', 112.0 ] ]),
	('set1' -> [ [ 'divefreq', 20.0 ], [ 'topfreq', 67270.0 ], [ 'filtfreq', 136.0 ] ]),
	('set2' -> [ [ 'divefreq', 12.97 ], [ 'topfreq', 912.0 ], [ 'filtfreq', 25599.0 ] ]),
	('doak' -> [ [ 'divefreq', 0.06 ], [ 'topfreq', 49176.0 ], [ 'filtfreq', 2986.0 ] ]),
	('set2333' -> [ [ 'divefreq', 0.09 ], [ 'topfreq', 68.0 ], [ 'filtfreq', 65.0 ] ]),
	('nervz' -> [ [ 'divefreq', 0.52 ], [ 'topfreq', 561.0 ], [ 'filtfreq', 54939.0 ] ])
]

// --- end of file allArm.pxpreset.scd --- //

// each setting is on a separate line, and can be edited easily.
// since this is code, best make a backup file copy before you edit!
// 1. to rename a setting, replace e.g. 'test123' with a fitting and memorable name, e.g. 'rumpsty'.
// 2. to delete a setting, e.g. if you did not like  snapshot 231125_131608, remove its line.
// 3. to test that the settings will still work, select all and evaluate with Cmd-Enter;
// -> when still valid code, the result will be a valid List.
// 4. if valid, save the file
// 5. to reload the edited settings immediately, run the line given in the comments:
NdefPreset('allArm').loadSettings(clear: true);


//// deleting presets by name can also be done from the deleteDialog:
//// 1. on a Preset GUI, click on the del button:
//// -> a dialog window opens that allows deleting entries by name.
//// these edits will also be saved to disk.
